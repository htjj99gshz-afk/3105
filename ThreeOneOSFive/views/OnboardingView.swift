import SwiftUI

private enum OnboardingStep: Int, CaseIterable {
    case language = 0, welcome, versions, install

    var next: OnboardingStep? { Self(rawValue: rawValue + 1) }
    var prev: OnboardingStep? { Self(rawValue: rawValue - 1) }
}

struct OnboardingView: View {
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue
    @State private var step: OnboardingStep = .language
    @State private var dragOffset: CGFloat = 0
    var onComplete: () -> Void

    private var language: AppLanguage { AppLanguage(rawValue: languageCode) ?? .english }

    var body: some View {
        ZStack {
            AppTheme.pageBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                pageContent
                controls
            }
        }
        .tint(AppTheme.accent)
        .animation(.spring(response: 0.38, dampingFraction: 0.84), value: step)
        .animation(.spring(response: 0.38, dampingFraction: 0.84), value: languageCode)
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(OnboardingStep.allCases, id: \.rawValue) { s in
                    Capsule()
                        .fill(s.rawValue <= step.rawValue ? AppTheme.accent : Color.secondary.opacity(0.22))
                        .frame(height: 4)
                        .frame(maxWidth: s == step ? 28 : 18)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: step)
                }
            }
            .padding(.horizontal, AppTheme.pageInset)
            .padding(.top, 18)

            Text(language.text("onboarding.step", "\(step.rawValue + 1)", "\(OnboardingStep.allCases.count)"))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        ZStack {
            ForEach(OnboardingStep.allCases, id: \.rawValue) { s in
                if s == step {
                    page(for: s)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id("page-\(s.rawValue)-\(languageCode)")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func page(for s: OnboardingStep) -> some View {
        switch s {
        case .language: languagePage
        case .welcome: welcomePage
        case .versions: versionsPage
        case .install: installPage
        }
    }

    private var languagePage: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 12)
            AppLogo(size: 72)
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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                            languageCode = option.rawValue
                            step = .welcome
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.displayName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(option.rawValue == "en" ? "English" : option.rawValue == "ar" ? "العربية" : option.rawValue == "vi" ? "Tiếng Việt" : "简体中文")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if languageCode == option.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accent)
                                    .font(.title3)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(languageCode == option.rawValue ? AppTheme.accent : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            Spacer(minLength: 12)
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 10)
             ZStack {
                 RoundedRectangle(cornerRadius: 10, style: .continuous)
                     .fill(Color(uiColor: .secondarySystemBackground))
                     .overlay(
                         RoundedRectangle(cornerRadius: 10, style: .continuous)
                             .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                     )
                     .frame(width: 72, height: 72)
                 Image(systemName: "sparkles")
                     .font(.system(size: 30, weight: .medium))
                     .foregroundStyle(AppTheme.accent)
             }
            VStack(spacing: 10) {
                Text(language.text("onboarding.welcome_title"))
                    .font(.title2.weight(.bold))
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
                 .padding(.horizontal, 14)
                 .padding(.vertical, 8)
                 .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Spacer(minLength: 10)
        }
    }

    private var versionsPage: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 8)
             ZStack {
                 RoundedRectangle(cornerRadius: 18, style: .continuous)
                     .fill(Color(uiColor: .secondarySystemBackground))
                     .overlay(
                         RoundedRectangle(cornerRadius: 10, style: .continuous)
                             .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                     )
                     .frame(width: 72, height: 72)
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
                versionRow(icon: "checkmark.circle.fill", title: "iOS 17", value: ExploitSupportPolicy.verifiedIOS17Range, color: .green)
                versionRow(icon: "checkmark.circle.fill", title: "iOS 18", value: ExploitSupportPolicy.verifiedIOS18Range, color: .green)
                versionRow(icon: "checkmark.circle.fill", title: "iOS 26", value: ExploitSupportPolicy.verifiedIOS26Range, color: .green)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text("iOS 27.0").font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(language.text("onboarding.beta")).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    }
                    ForEach(ExploitSupportPolicy.verifiedIOS27Builds, id: \.build) { v in
                        HStack {
                            Text("Beta \(v.beta)" + (v.publicBeta.map { " / Public \($0)" } ?? ""))
                                .font(.caption.weight(.medium)).foregroundStyle(.secondary)
                            Spacer()
                            Text(v.build).font(.caption.monospaced()).foregroundStyle(.secondary)
                        }
                        .padding(.leading, 24)
                    }
                }
                .padding(12)
                 .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.horizontal, 20)
            Text(language.text("onboarding.versions_footer", AppInfo.osVersion, AppInfo.osBuild))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer(minLength: 8)
        }
    }

    private var installPage: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 8)
             ZStack {
                 RoundedRectangle(cornerRadius: 10, style: .continuous)
                     .fill(Color(uiColor: .secondarySystemBackground))
                     .overlay(
                         RoundedRectangle(cornerRadius: 10, style: .continuous)
                             .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                     )
                     .frame(width: 72, height: 72)
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
                installBullet(icon: "checkmark.seal.fill", text: language.text("onboarding.install_ok"), color: .green)
                installBullet(icon: "xmark.octagon.fill", text: language.text("onboarding.install_bad"), color: .red)
                installBullet(icon: "exclamationmark.triangle.fill", text: language.text("onboarding.install_jailbreak"), color: .orange)
            }
            .padding(14)
             .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 20)
            Text(language.text("onboarding.install_footer"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer(minLength: 8)
        }
    }

    private func versionRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(color)
            Text(title).font(.subheadline.weight(.semibold))
            Spacer()
            Text(value).font(.subheadline.monospaced()).foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
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

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if step != .language {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            if let prev = step.prev { step = prev }
                        }
                    } label: {
                        Label(language.text("common.back"), systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button {
                    if let next = step.next {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            step = next
                        }
                    } else {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                            onComplete()
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(language.text(step == .install ? "common.finish" : "common.next"))
                        if step != .install {
                            Image(systemName: "chevron.right").font(.caption.weight(.semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 20)

            if step == .language {
                Text(language.text("onboarding.language_hint"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 16)
        .background(.bar)
    }
}

enum OnboardingStore {
    static let completedVersionKey = "onboarding.completedVersion"
    static let completedFingerprintKey = "onboarding.completedFingerprint"

    static var currentVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(v) (\(b))"
    }

    /// Per-install token: executable mtime changes on every overwrite even if version stays the same.
    static var bundleToken: String {
        if let exe = Bundle.main.executablePath,
           let attrs = try? FileManager.default.attributesOfItem(atPath: exe),
           let date = attrs[.modificationDate] as? Date {
            return String(Int(date.timeIntervalSince1970))
        }
        if let attrs = try? FileManager.default.attributesOfItem(atPath: Bundle.main.bundlePath),
           let date = (attrs[.creationDate] as? Date) ?? (attrs[.modificationDate] as? Date) {
            return String(Int(date.timeIntervalSince1970))
        }
        return "0"
    }

    static var currentFingerprint: String { "\(currentVersion)#\(bundleToken)" }

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
        let fp = currentFingerprint
        if let stored = completedFingerprint, !stored.isEmpty {
            return stored != fp
        }
        // Migration: old installs only have completedVersion
        if let completed = completedVersion, !completed.isEmpty {
            if completed == currentVersion {
                // Same version, migrate silently — next overwrite will be detected via fingerprint
                UserDefaults.standard.set(fp, forKey: completedFingerprintKey)
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
