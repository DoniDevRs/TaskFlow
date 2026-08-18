import Core
import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var passcodeInput = ""
    private let onSyncNow: () -> Void

    public init(
        viewModel: @autoclosure @escaping () -> SettingsViewModel,
        onSyncNow: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onSyncNow = onSyncNow
    }

    public var body: some View {
        Form {
            Section {
                Button("Sync now", action: onSyncNow)
            } header: {
                SectionLabel(title: "Sync")
            }

            Section {
                Toggle("Face ID lock", isOn: Binding(
                    get: { viewModel.isBiometricLockEnabled },
                    set: { newValue in
                        if newValue {
                            Task { await viewModel.enableBiometricLock() }
                        } else {
                            viewModel.disableBiometricLock()
                        }
                    }
                ))

                SecureField("Passcode fallback (4-6 digits)", text: $passcodeInput)
                    .keyboardType(.numberPad)

                Button("Save passcode") {
                    viewModel.setPasscode(passcodeInput)
                    passcodeInput = ""
                }
                .disabled(passcodeInput.isEmpty)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(TFTypography.label())
                        .foregroundStyle(TFColor.terracotta)
                }
            } header: {
                SectionLabel(title: "App lock")
            }

            Section {
                Text(viewModel.languageDisplayName)
                    .foregroundStyle(TFColor.ink.opacity(0.7))
            } header: {
                SectionLabel(title: "Language")
            }
        }
        .scrollContentBackground(.hidden)
        .background(TFColor.background.ignoresSafeArea())
    }
}
