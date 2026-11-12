import SwiftUI

struct OzetTabView: View {
    @ObservedObject var session: SessionStore
    @Binding var aktifSekme: Int
    @Binding var yeniRandevuGoster: Bool
    @Binding var yeniHastaGoster: Bool

    private var yaklasanRandevular: [Randevu] {
        let simdi = Date()
        let cal = Calendar.current
        let currentHour = cal.component(.hour, from: simdi)
        let currentMinute = cal.component(.minute, from: simdi)
        let currentTotalMinutes = currentHour * 60 + currentMinute

        let bugununTarihiStr: String = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f.string(from: simdi)
        }()

        return session.randevular.filter { r in
            // Tarih kontrolü (bugüne ait olmalı)
            if !r.tarih.isEmpty && r.tarih != bugununTarihiStr {
                return false
            }

            // Tamamlanmış veya iptal edilmiş randevuları yaklaşan listesinde gösterme
            let d = r.durum.lowercased()
            if d.contains("geldi") || d.contains("iptal") || d.contains("gelmedi") {
                return false
            }

            // Saat kontrolü (saati geçen randevular gizlenir)
            let parcalar = r.saat.split(separator: ":")
            if parcalar.count == 2,
               let h = Int(parcalar[0]),
               let m = Int(parcalar[1]) {
                let randevuMinutes = h * 60 + m
                return randevuMinutes >= currentTotalMinutes
            }
            return true
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Klinik Durum Özeti")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.textPrimary)

                        Text("Bugünkü randevular ve genel hasta hareketleri")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textSecondary)
                    }
                    Spacer()

                    Button(action: {
                        Task { await session.tumVerileriYukle() }
                    }) {
                        Label("Yenile", systemImage: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.darkSurfaceElevated)
                            .foregroundColor(Theme.emeraldLight)
                            .cornerRadius(10)
                    }
                }

                // 4 Metrik Kartı
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    metrikKarti(
                        baslik: "Toplam Kayıtlı Hasta",
                        deger: "\(session.ozet?.toplam_hasta ?? session.hastalar.count)",
                        ikon: "person.2.fill",
                        renk: Theme.emeraldPrimary
                    )

                    metrikKarti(
                        baslik: "Bugünkü Randevular",
                        deger: "\(session.ozet?.bugun_randevu ?? session.randevular.count)",
                        ikon: "calendar",
                        renk: Theme.cyanAccent
                    )

                    metrikKarti(
                        baslik: "Bugün Yapılan Seans",
                        deger: "\(session.ozet?.bugun_seans ?? 0)",
                        ikon: "figure.walk",
                        renk: Theme.statusSuccess
                    )

                    metrikKarti(
                        baslik: "Bekleyen Web Talebi",
                        deger: "\(session.ozet?.bekleyen_web ?? session.webRandevulari.count)",
                        ikon: "globe",
                        renk: Theme.statusWarning
                    )
                }

                // Hızlı İşlemler
                Text("Hızlı İşlemler")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 10)

                HStack(spacing: 14) {
                    hizliIslemButonu(
                        baslik: "Yeni Randevu",
                        aciklama: "Randevu takvimine ekle",
                        ikon: "calendar.badge.plus",
                        renk: Theme.emeraldPrimary
                    ) {
                        yeniRandevuGoster = true
                    }

                    hizliIslemButonu(
                        baslik: "Yeni Hasta Kaydı",
                        aciklama: "Klinik dosyası aç",
                        ikon: "person.badge.plus",
                        renk: Theme.cyanAccent
                    ) {
                        yeniHastaGoster = true
                    }

                    hizliIslemButonu(
                        baslik: "Hızlı Seans & Ödeme",
                        aciklama: "Seans işlemini tamamla",
                        ikon: "creditcard.fill",
                        renk: Theme.statusSuccess
                    ) {
                        aktifSekme = 3 // Hızlı Seans Tab
                    }
                }

                // Günün Yaklaşan Randevuları
                HStack {
                    Text("Günün Yaklaşan Randevuları")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Spacer()

                    if !yaklasanRandevular.isEmpty {
                        Text("\(yaklasanRandevular.count) Kalan")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Theme.cyanAccent.opacity(0.15))
                            .foregroundColor(Theme.cyanAccent)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 10)

                if yaklasanRandevular.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Theme.statusSuccess)
                            Text("Günün sonraki saatleri için bekleyen randevu kalmadı.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(32)
                        Spacer()
                    }
                    .background(Theme.darkSurface)
                    .cornerRadius(14)
                } else {
                    VStack(spacing: 10) {
                        ForEach(yaklasanRandevular.prefix(6)) { randevu in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(randevu.hasta_ad_soyad)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Theme.textPrimary)
                                    Text(randevu.telefon ?? "Telefon kaydı yok")
                                        .font(.system(size: 13))
                                        .foregroundColor(Theme.textSecondary)
                                }
                                Spacer()
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 12))
                                    Text(randevu.saat)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(Theme.cyanAccent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Theme.cyanAccent.opacity(0.12))
                                .cornerRadius(8)
                            }
                            .padding(14)
                            .background(Theme.darkSurface)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    private func metrikKarti(baslik: String, deger: String, ikon: String, renk: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(baslik)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                Text(deger)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
            }
            Spacer()
            Circle()
                .fill(renk.opacity(0.15))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: ikon)
                        .font(.system(size: 22))
                        .foregroundColor(renk)
                )
        }
        .padding(18)
        .background(Theme.darkSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.darkBorder.opacity(0.5), lineWidth: 1)
        )
    }

    private func hizliIslemButonu(baslik: String, aciklama: String, ikon: String, renk: Color, aksiyon: @escaping () -> Void) -> some View {
        Button(action: aksiyon) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: ikon)
                    .font(.system(size: 24))
                    .foregroundColor(renk)
                VStack(alignment: .leading, spacing: 2) {
                    Text(baslik)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text(aciklama)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Theme.darkSurface)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(renk.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
