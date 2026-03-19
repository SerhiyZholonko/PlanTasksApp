import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel = .init()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.appTheme.accent)

                Text("Увійти")
                    .font(.largeTitle.bold())

                Spacer().frame(height: 8)

                Button(action: viewModel.signInWithGoogle) {
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                            .font(.system(size: 18, weight: .medium))
                        Text("Продовжити з Google")
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
                        Text("Продовжити з телефоном")
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
