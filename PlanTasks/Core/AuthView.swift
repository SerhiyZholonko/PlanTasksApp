import SwiftUI
import AuthenticationServices

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

                HStack {
                    Rectangle().frame(height: 1).foregroundStyle(Color.appTheme.divider)
                    Text("or").font(.subheadline).foregroundStyle(Color.appTheme.secondaryText)
                    Rectangle().frame(height: 1).foregroundStyle(Color.appTheme.divider)
                }
                .padding(.horizontal)

                Button(action: viewModel.signInWithGoogle) {
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                            .font(.system(size: 18, weight: .medium))
                        Text("Continue with Google")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appTheme.cellBackground)
                    .foregroundStyle(Color.appTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appTheme.divider, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                SignInWithAppleButton(.signIn,
                    onRequest: viewModel.handleAppleRequest,
                    onCompletion: viewModel.handleAppleCompletion
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                Button(action: viewModel.startPhoneAuth) {
                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Continue with Phone")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appTheme.cellBackground)
                    .foregroundStyle(Color.appTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appTheme.divider, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

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
            .sheet(isPresented: $viewModel.showPhoneSheet) {
                PhoneAuthSheet(viewModel: viewModel)
            }
        }
    }
}

private struct PhoneAuthSheet: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.appTheme.accent)

                if viewModel.isEnteringCode {
                    Text("Enter verification code")
                        .font(.title2.bold())

                    Text("We sent a 6-digit code to\n\(viewModel.phoneNumber)")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTheme.secondaryText)
                        .multilineTextAlignment(.center)

                    TextField("6-digit code", text: $viewModel.verificationCode)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .padding(.horizontal)

                    Button(action: viewModel.verifyPhoneCode) {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Verify")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appTheme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading || viewModel.verificationCode.count < 6)

                } else {
                    Text("Enter your phone number")
                        .font(.title2.bold())

                    Text("We'll send you a verification code")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTheme.secondaryText)

                    TextField("+380 XX XXX XXXX", text: $viewModel.phoneNumber)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .padding(.horizontal)

                    Button(action: viewModel.sendPhoneCode) {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Send Code")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appTheme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading || viewModel.phoneNumber.count < 10)
                }

                Spacer()
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showPhoneSheet = false
                    }
                }
            }
            .showError(item: $viewModel.error)
        }
    }
}

#Preview {
    AuthView()
}
