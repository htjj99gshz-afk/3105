import Foundation
import Darwin

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
    private static let bundleNameLock = NSLock()
    private static var cachedBundleNames: [String: String] = [:]
    private static var bundleNameCacheDate = Date.distantPast
    private static let bundleNameCacheLifetime: TimeInterval = 10

    private static let installedBundleRoots: [(path: String, nested: Bool)] = [
        ("/var/containers/Bundle/Application", true),
        ("/Applications", false),
        ("/System/Applications", false)
    ]

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
        // Refresh from the installed .app bundles at scan time instead of caching
        // this once at process startup. On iOS 26 the bundle tree can become
        // readable only after the app's traversal primitive is available.
        let liveBundleNames = installedBundleDisplayNameCatalog()
        let legacyBundleMetadata = ContainerStore.applicationBundleMetadataCatalog()

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
                    liveBundleNames[bundleID],
                    legacyBundleMetadata[bundleID]?.displayName,
                    application.name,
                    containerMetadata?.displayName,
                    launchServicesInfo["name"] as? String
                ]
            )
            let resolvedApplication = CleanerResolvedApplication(
                bundleID: application.bundleID,
                name: resolvedName,
                containerPath: application.containerPath,
                version: application.version
            )

            records.append(
                CleanerCatalogRecord(
                    application: resolvedApplication,
                    containerPath: containerPath,
                    usage: usage
                )
            )
        }
        return records
    }

    private static func installedBundleDisplayNameCatalog() -> [String: String] {
        bundleNameLock.lock()
        let age = Date().timeIntervalSince(bundleNameCacheDate)
        if age < bundleNameCacheLifetime, !cachedBundleNames.isEmpty {
            let result = cachedBundleNames
            bundleNameLock.unlock()
            return result
        }
        bundleNameLock.unlock()

        var catalog: [String: String] = [:]
        for root in installedBundleRoots {
            let bundlePaths = installedBundlePaths(at: root.path, nested: root.nested)
            for bundlePath in bundlePaths {
                autoreleasepool {
                    guard let identity = installedBundleIdentity(at: bundlePath) else { return }
                    catalog[identity.bundleID] = identity.displayName
                }
            }
        }

        bundleNameLock.lock()
        cachedBundleNames = catalog
        bundleNameCacheDate = Date()
        bundleNameLock.unlock()

        log("cleaner: resolved \(catalog.count) installed bundle display names")
        return catalog
    }

    private static func installedBundlePaths(at rootPath: String, nested: Bool) -> [String] {
        let rootEntries = ContainerStore.enumerateDirectoriesWithTraversalGrant(path: rootPath)
        guard !rootEntries.isEmpty else {
            log("cleaner: bundle root unavailable \(rootPath)")
            return []
        }

        if !nested {
            return rootEntries.prefix(2_048).filter {
                $0.hasSuffix(".app")
            }
        }

        var result: [String] = []
        result.reserveCapacity(min(rootEntries.count, 512))
        for containerPath in rootEntries.prefix(2_048) {
            let identifier = (containerPath as NSString).lastPathComponent
            guard UUID(uuidString: identifier) != nil else { continue }

            let children = ContainerStore.enumerateDirectoriesWithTraversalGrant(path: containerPath)
            for childPath in children.prefix(16) where childPath.hasSuffix(".app") {
                result.append(childPath)
            }
        }
        return result
    }

    private static func installedBundleIdentity(
        at bundlePath: String
    ) -> (bundleID: String, displayName: String)? {
        let accessHandle = ContainerStore.grantContainerAccess(bundlePath)
        defer {
            if accessHandle >= 0 { bad_query_release(accessHandle) }
        }

        let infoPath = (bundlePath as NSString).appendingPathComponent("Info.plist")
        guard let infoData = readSmallFile(at: infoPath, maximumBytes: 2 * 1_024 * 1_024),
              let info = try? PropertyListSerialization.propertyList(
                from: infoData,
                options: [],
                format: nil
              ) as? [String: Any],
              let bundleID = cleanString(info["CFBundleIdentifier"]),
              !bundleID.isEmpty else {
            return nil
        }

        var candidates: [String?] = []
        if let localized = Bundle(path: bundlePath)?.localizedInfoDictionary {
            candidates.append(cleanString(localized["CFBundleDisplayName"]))
            candidates.append(cleanString(localized["CFBundleName"]))
        }
        candidates.append(cleanString(info["CFBundleDisplayName"]))
        candidates.append(cleanString(info["CFBundleName"]))
        candidates.append(cleanString(info["CFBundleExecutable"]))

        let displayName = AppDisplayNamePolicy.resolve(
            bundleID: bundleID,
            candidates: candidates
        )
        guard displayName != bundleID else { return nil }
        return (bundleID, displayName)
    }

    private static func cleanString(_ value: Any?) -> String? {
        guard let value = value as? String else { return nil }
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }
        return cleaned
    }

    private static func readSmallFile(at path: String, maximumBytes: Int) -> Data? {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           !data.isEmpty,
           data.count <= maximumBytes {
            return data
        }

        guard let file = fopen(path, "rb") else { return nil }
        defer { fclose(file) }

        var output = [UInt8]()
        output.reserveCapacity(min(maximumBytes, 128 * 1_024))
        var buffer = [UInt8](repeating: 0, count: 64 * 1_024)

        while output.count < maximumBytes {
            let remaining = maximumBytes - output.count
            let requestCount = min(buffer.count, remaining)
            let count = fread(&buffer, 1, requestCount, file)
            if count == 0 { break }
            output.append(contentsOf: buffer.prefix(count))
        }

        guard !output.isEmpty else { return nil }
        return Data(output)
    }
}
