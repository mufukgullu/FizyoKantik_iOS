import SwiftUI

struct DashboardView: View {
    @ObservedObject var session: SessionStore
    @State private var aktifSekme: Int = 0

    // Sheet durumları
    @State private var yeniHastaGoster: Bool = false
    @State private var yeniRandevuGoster: Bool = false
    @State private var secilenHasta: Hasta? = nil
    @State private var onaylanacakWebTalep: WebRandevuTalep? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Üst Bar (Header)
                HStack(spacing: 14) {
                    Image("logo", bundle: nil)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("FizyoKantik Klinik")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.textPrimary)

                        if let user = session.aktifKullanici {
                            Text("\(user.ad_soyad ?? user.kullanici_adi ?? "") • \(user.rol ?? "Fizyoterapist")")
                                .font(.system(size: 11))
                                .foregroundColor(Theme.emeraldLight)
                        }
                    }

                    Spacer()

                    if session.yukleniyor {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.emeraldLight))
                            .padding(.trailing, 6)
                    }

                    // Çıkış Butonu
                    Button(action: {
                        session.cikisYap()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.statusError)
                            .padding(8)
                            .background(Theme.statusError.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.darkSurface)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Theme.darkBorder.opacity(0.5)),
                    alignment: .bottom
                )

                // Sekme İçerikleri
                TabView(selection: $aktifSekme) {
                    OzetTabView(
                        session: session,
                        aktifSekme: $aktifSekme,
                        yeniRandevuGoster: $yeniRandevuGoster,
                        yeniHastaGoster: $yeniHastaGoster
                    )
                    .tag(0)
                    .tabItem {
                        Label("Özet", systemImage: "chart.bar.fill")
                    }

                    RandevularTabView(
                        session: session,
                        yeniRandevuGoster: $yeniRandevuGoster
                    )
                    .tag(1)
                    .tabItem {
                        Label("Randevular", systemImage: "calendar")
                    }

                    HastalarTabView(
                        session: session,
                        yeniHastaGoster: $yeniHastaGoster,
                        secilenHasta: $secilenHasta
                    )
                    .tag(2)
                    .tabItem {
                        Label("Hastalar", systemImage: "person.2.fill")
                    }

                    HizliSeansTabView(
                        session: session
                    )
                    .tag(3)
                    .tabItem {
                        Label("Hızlı Seans", systemImage: "bolt.fill")
                    }

                    WebRandevulariTabView(
                        session: session,
                        onaylanacakTalep: $onaylanacakWebTalep
                    )
                    .tag(4)
                    .tabItem {
                        Label("Web Randevuları", systemImage: "globe")
                    }
                    .badge(session.webRandevulari.filter { $0.durum.caseInsensitiveCompare("Beklemede") == .orderedSame }.count)
                }
                .accentColor(Theme.emeraldLight)
            }
            .background(Theme.darkBg)
            .sheet(isPresented: $yeniHastaGoster) {
                YeniHastaSheet(session: session)
            }
            .sheet(isPresented: $yeniRandevuGoster) {
                YeniRandevuSheet(session: session)
            }
            .sheet(item: $secilenHasta) { hasta in
                HastaDetaySheet(hasta: hasta, session: session)
            }
            .sheet(item: $onaylanacakWebTalep) { talep in
                WebRandevuOnaylaSheet(talep: talep, session: session)
            }
            .task {
                await session.tumVerileriYukle()
            }
        }
    }
}

