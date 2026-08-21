import SwiftUI

private enum OnboardingStep: Int, CaseIterable {
    case language = 0, welcome, versions, install

    var next: OnboardingStep? { Self(rawValue: rawValue + 1) }
    var prev: OnboardingStep? { Self(rawValue: rawValue - 1) }
}

struct OnboardingView: View {
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue
    @State private var step: OnboardingStep = .language
    var onComplete: () -> Void

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    var body: some View {
        ZStack {
            AppTheme.pageBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                GeometryReader { proxy in
                    ScrollView {
                        page(for: step)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: max(proxy.size.height, 1),
                                alignment: .center
                            )
                            .padding(.vertical, 20)
                            .id("page-\(step.rawValue)-\(languageCode)")
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            controls
                .zIndex(100)
        }
        .tint(AppTheme.accent)
        .animation(.spring(response: 0.38, dampingFraction: 0.84), value: step)
        .animation(.spring(response: 0.38, dampingFraction: 0.84), value: languageCode)
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(OnboardingStep.allCases, id: \.rawValue) { item in
                    Capsule()
                        .fill(item.rawValue <= step.rawValue ? AppTheme.accent : Color.secondary.opacity(0.22))
                        .frame(width: item == step ? 36 : 22, height: 4)
                }
            }

            Text(language.text(
                "onboarding.step",
                "\(step.rawValue + 1)",
                "\(OnboardingStep.allCases.count)"
            ))
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func page(for step: OnboardingStep) -> some View {
        switch step {
        case .language:
            languagePage
        case .welcome:
            welcomePage
        case .versions:
            versionsPage
        case .install:
            installPage
        }
    }

    private var languagePage: some View {
        VStack(spacing: 20) {
            AppLogo(size: 76)

            VStack(spacing: 8) {
                Text(language.text("onboarding.language_title"))
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(language.text("onboarding.language_subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 10) {
                ForEach(AppLanguage.allCases) { option in
                    Button {
                        selectLanguage(option)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.displayName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)

                                Text(nativeLanguageName(option))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 12)

                            Image(systemName: languageCode == option.rawValue ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(
                                    languageCode == option.rawValue
                                    ? AppTheme.accent
                                    : Color.secondary.opacity(0.5)
                                )
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            languageCode == option.rawValue ? AppTheme.accent : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
    }

    private var welcomePage: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "sparkles")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(spacing: 10) {
                Text(language.text("onboarding.welcome_title"))
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(language.text("onboarding.welcome_message"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Label(language.text("onboarding.welcome_badge"), systemImage: "checkmark.seal.fill")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Color(uiColor: .secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }

    private var versionsPage: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 76, height: 76)

                Image(systemName: "iphone.gen2")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(spacing: 8) {
                Text(language.text("onboarding.versions_title"))
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(language.text("onboarding.versions_subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
            }

            VStack(alignment: .leading, spacing: 10) {
                versionRow(
                    icon: "checkmark.circle.fill",
                    title: "iOS 17",
                    value: ExploitSupportPolicy.verifiedIOS17Range,
                    color: .green
                )
                versionRow(
                    icon: "checkmark.circle.fill",
                    title: "iOS 18",
                    value: ExploitSupportPolicy.verifiedIOS18Range,
                    color: .green
                )
                versionRow(
                    icon: "checkmark.circle.fill",
                    title: "iOS 26",
                    value: ExploitSupportPolicy.verifiedIOS26Range,
                    color: .green
                )

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("iOS 27.0")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(language.text("onboarding.beta"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    ForEach(ExploitSupportPolicy.verifiedIOS27Builds, id: \.build) { version in
                        HStack {
                            Text("Beta \(version.beta)" + (version.publicBeta.map { " / Public \($0)" } ?? ""))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(version.build)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 24)
                    }
                }
                .padding(12)
                .background(
                    Color(uiColor: .secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
            }
            .padding(.horizontal, 20)

            Text(language.text("onboarding.versions_footer", AppInfo.osVersion, AppInfo.osBuild))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
    }

    private var installPage: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
                    .frame(width: 76, height: 76)

                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(.orange)
            }

            VStack(spacing: 8) {
                Text(language.text("onboarding.install_title"))
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(language.text("onboarding.install_message"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
            }

            VStack(alignment: .leading, spacing: 10) {
                installBullet(
                    icon: "checkmark.seal.fill",
                    text: language.text("onboarding.install_ok"),
                    color: .green
                )
                installBullet(
                    icon: "xmark.octagon.fill",
                    text: language.text("onboarding.install_bad"),
                    color: .red
                )
                installBullet(
                    icon: "exclamationmark.triangle.fill",
                    text: language.text("onboarding.install_jailbreak"),
                    color: .orange
                )
            }
            .padding(14)
            .background(
                Color(uiColor: .secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .padding(.horizontal, 20)

            Text(language.text("onboarding.install_footer"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                if step != .language {
                    Button {
                        goBack()
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline.weight(.semibold))
                            Text(language.text("common.back"))
                                .font(.body.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    advance()
                } label: {
                    HStack(spacing: 7) {
                        Text(language.text(step == .install ? "common.finish" : "common.next"))
                            .font(.body.weight(.semibold))
                        if step != .install {
                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderedProminent)
            }

            if step == .language {
                Text(language.text("onboarding.language_hint"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(.bar)
        .contentShape(Rectangle())
    }

    private func selectLanguage(_ option: AppLanguage) {
        languageCode = option.rawValue

        // Let AppStorage and the app environment publish the selected locale first,
        // then construct the next onboarding page using the new language.
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                step = .welcome
            }
        }
    }

    private func advance() {
        if let next = step.next {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                step = next
            }
        } else {
            onComplete()
        }
    }

    private func goBack() {
        guard let previous = step.prev else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            step = previous
        }
    }

    private func nativeLanguageName(_ option: AppLanguage) -> String {
        switch option {
        case .english: return "English"
        case .arabic: return "العربية"
        case .vietnamese: return "Tiếng Việt"
        case .simplifiedChinese: return "简体中文"
        }
    }

    private func versionRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text(value)
                .font(.subheadline.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            Color(uiColor: .secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
    }

    private func installBullet(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.body.weight(.semibold))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

enum OnboardingStore {
    static let completedVersionKey = "onboarding.completedVersion"
    static let completedFingerprintKey = "onboarding.completedFingerprint"

    static var currentVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(version) (\(build))"
    }

    /// Per-install token: executable mtime changes on every overwrite even if version stays the same.
    static var bundleToken: String {
        if let executable = Bundle.main.executablePath,
           let attributes = try? FileManager.default.attributesOfItem(atPath: executable),
           let date = attributes[.modificationDate] as? Date {
            return String(Int(date.timeIntervalSince1970))
        }

        if let attributes = try? FileManager.default.attributesOfItem(atPath: Bundle.main.bundlePath),
           let date = (attributes[.creationDate] as? Date) ?? (attributes[.modificationDate] as? Date) {
            return String(Int(date.timeIntervalSince1970))
        }

        return "0"
    }

    static var currentFingerprint: String {
        "\(currentVersion)#\(bundleToken)"
    }

    static var completedVersion: String? {
        UserDefaults.standard.string(forKey: completedVersionKey)
    }

    static var completedFingerprint: String? {
        UserDefaults.standard.string(forKey: completedFingerprintKey)
    }

    static func shouldShow() -> Bool {
#if targetEnvironment(simulator)
        if ProcessInfo.processInfo.arguments.contains("--skip-onboarding") { return false }
        if ProcessInfo.processInfo.arguments.contains("--reset-onboarding") { return true }
#endif

        let fingerprint = currentFingerprint

        if let stored = completedFingerprint, !stored.isEmpty {
            return stored != fingerprint
        }

        if let completed = completedVersion, !completed.isEmpty {
            if completed == currentVersion {
                UserDefaults.standard.set(fingerprint, forKey: completedFingerprintKey)
                return false
            }
            return true
        }

        return true
    }

    static func markCompleted() {
        UserDefaults.standard.set(currentVersion, forKey: completedVersionKey)
        UserDefaults.standard.set(currentFingerprint, forKey: completedFingerprintKey)
    }
}
