import SwiftUI

struct LoginView: View {
    @ObservedObject var session: SessionStore
    @State private var kullaniciAdi: String = ""
    @State private var parola: String = ""

    var body: some View {
        ZStack {
            Theme.darkBg
                .ignoresSafeArea()

            // Subtle gradient glow
            RadialGradient(
                gradient: Gradient(colors: [Theme.emeraldContainer.opacity(0.35), Theme.darkBg]),
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Logo & Emblem
                Image("emblem", bundle: nil)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .shadow(color: Theme.emeraldPrimary.opacity(0.4), radius: 16)

                VStack(spacing: 4) {
                    Text("FizyoKantik")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text("Klinik & Seans Yönetim Portalı")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }

                // Card container
                VStack(spacing: 18) {
                    if let hata = session.hataMesaji {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Theme.statusError)
                            Text(hata)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.statusError)
                            Spacer()
                        }
                        .padding(12)
                        .background(Theme.statusError.opacity(0.12))
                        .cornerRadius(10)
                    }

                    // Kullanıcı Adı
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(Theme.emeraldLight)
                            .frame(width: 24)
                        TextField("", text: $kullaniciAdi, prompt: Text("Kullanıcı Adı").foregroundColor(Theme.textMuted))
                            .foregroundColor(Theme.textPrimary)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Theme.darkSurfaceElevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.darkBorder, lineWidth: 1)
                    )

                    // Parola
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Theme.emeraldLight)
                            .frame(width: 24)
                        SecureField("", text: $parola, prompt: Text("Parola").foregroundColor(Theme.textMuted))
                            .foregroundColor(Theme.textPrimary)
                    }
                    .padding()
                    .background(Theme.darkSurfaceElevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.darkBorder, lineWidth: 1)
                    )

                    // Giriş Butonu
                    Button(action: {
                        Task {
                            _ = await session.girisYap(kullaniciAdi: kullaniciAdi, parola: parola)
                        }
                    }) {
                        HStack {
                            if session.yukleniyor {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Giriş Yap")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Theme.emeraldPrimary, Theme.emeraldDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Theme.emeraldPrimary.opacity(0.3), radius: 8, y: 4)
                    }
                    .disabled(session.yukleniyor || kullaniciAdi.isEmpty || parola.isEmpty)
                }
                .padding(28)
                .frame(maxWidth: 420)
                .background(Theme.darkSurface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.emeraldPrimary.opacity(0.4), Theme.darkBorder],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.4), radius: 20)

                Text("v1.0.0 • FizyoKantik Klinik Sistemleri")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted)
            }
            .padding(24)
        }
    }
}
