import Foundation

struct CleanerResolvedApplication: Equatable {
    let bundleID: String
    let name: String
    let containerPath: String
    let version: String
}

struct CleanerCatalogRecord: Equatable {
    let application: CleanerResolvedApplication
    let containerPath: String
    let usage: LimitedCleanerUsage

    var bundleID: String { application.bundleID }
}

enum CleanerSortOrder: String, CaseIterable, Identifiable {
    case largestFirst
    case smallestFirst

    var id: String { rawValue }
}

enum CleanerCatalog {
    static func sorted<Record>(
        _ records: [Record],
        order: CleanerSortOrder,
        size: (Record) -> Int64,
        displayName: (Record) -> String,
        stableID: (Record) -> String
    ) -> [Record] {
        records.sorted { left, right in
            let leftSize = size(left)
            let rightSize = size(right)
            if leftSize != rightSize {
                switch order {
                case .largestFirst:
                    return leftSize > rightSize
                case .smallestFirst:
                    return leftSize < rightSize
                }
            }

            let nameComparison = displayName(left).localizedCaseInsensitiveCompare(displayName(right))
            if nameComparison != .orderedSame {
                return nameComparison == .orderedAscending
            }
            return stableID(left).localizedCaseInsensitiveCompare(stableID(right)) == .orderedAscending
        }
    }

    static func selectingAllVisible(
        _ visibleBundleIDs: [String],
        preserving selectedBundleIDs: Set<String>
    ) -> Set<String> {
        selectedBundleIDs.union(visibleBundleIDs)
    }

    static func scanNewApplications(
        _ applications: [CleanerResolvedApplication],
        scannedBundleIDs: inout Set<String>,
        shouldIncludeBundleID: (String) -> Bool,
        activateContainer: (CleanerResolvedApplication) -> String?,
        isValidContainerPath: (String) -> Bool,
        usageForContainer: (String) -> LimitedCleanerUsage?
    ) -> [CleanerCatalogRecord] {
        // Do not walk /var/containers/Bundle/Application here. On iOS 26 that
        // traversal can be very expensive and previously made Cleaner appear
        // frozen at "0 scanned". Resolve each name only from already-available
        // app/container metadata and LaunchServices while scanning that app.
        var records: [CleanerCatalogRecord] = []

        for application in applications {
            let bundleID = application.bundleID
            guard shouldIncludeBundleID(bundleID),
                  scannedBundleIDs.insert(bundleID).inserted,
                  let containerPath = activateContainer(application),
                  isValidContainerPath(containerPath),
                  let usage = usageForContainer(containerPath),
                  usage.totalBytes > 0 else {
                continue
            }

            let containerMetadata = ContainerStore.readContainerMetadata(containerPath: containerPath)
            let launchServicesInfo = appInfoForBundleID(bundleID) as? [String: Any] ?? [:]
            let resolvedName = AppDisplayNamePolicy.resolve(
                bundleID: bundleID,
                candidates: [
                    launchServicesInfo["name"] as? String,
                    application.name,
                    containerMetadata?.displayName
                ]
            )

            records.append(
                CleanerCatalogRecord(
                    application: CleanerResolvedApplication(
                        bundleID: bundleID,
                        name: resolvedName,
                        containerPath: application.containerPath,
                        version: application.version
                    ),
                    containerPath: containerPath,
                    usage: usage
                )
            )
        }

        return records
    }
}
