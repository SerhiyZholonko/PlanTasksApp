import SwiftUI

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel = .init()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.appTheme.accent)

                Text(viewModel.authType == .signIn ? "Sign In" : "Create Account")
                    .font(.largeTitle.bold())

                VStack(spacing: 16) {
                    if viewModel.authType == .signUp {
                        TextField("Display name", text: $viewModel.displayName)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                    }

                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(viewModel.authType == .signUp ? .newPassword : .password)
                }
                .padding(.horizontal)

                Button(action: viewModel.submit) {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(viewModel.authType == .signIn ? "Sign In" : "Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appTheme.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .disabled(viewModel.isLoading || !viewModel.isFormValid)

                Button(action: viewModel.toggleAuthType) {
                    Text(viewModel.authType == .signIn
                         ? "Don't have an account? Sign Up"
                         : "Already have an account? Sign In")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTheme.accent)
                }

                Spacer()
            }
            .showError(item: $viewModel.error)
        }
    }
}

#Preview {
    AuthView()
}
