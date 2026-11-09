import SwiftUI

struct RandevularTabView: View {
    @ObservedObject var session: SessionStore
    @Binding var yeniRandevuGoster: Bool
    @State private var secilenTarih: Date = Date()
    @State private var filtreDurum: String = "Tümü"

    private let durumlar = ["Tümü", "Bekliyor", "Geldi", "İptal", "Gelmedi"]

    private var filtrelenmisRandevular: [Randevu] {
        session.randevular.filter { r in
            if filtreDurum == "Tümü" { return true }
            return r.durum.caseInsensitiveCompare(filtreDurum) == .orderedSame
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Top Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Randevu Takvimi")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Toplam \(filtrelenmisRandevular.count) randevu listeleniyor")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()

                Button(action: { yeniRandevuGoster = true }) {
                    Label("Yeni Randevu", systemImage: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Theme.emeraldPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Durum Filtresi
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(durumlar, id: \.self) { durum in
                        Button(action: { filtreDurum = durum }) {
                            Text(durum)
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(filtreDurum == durum ? Theme.emeraldPrimary : Theme.darkSurfaceElevated)
                                .foregroundColor(filtreDurum == durum ? .white : Theme.textSecondary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Randevu Listesi
            if filtrelenmisRandevular.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.textMuted)
                    Text("Bu filtreye uygun randevu bulunamadı.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(filtrelenmisRandevular) { randevu in
                        HStack(spacing: 16) {
                            // Saat rozeti
                            VStack(spacing: 2) {
                                Text(randevu.saat)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.cyanAccent)
                                Text(randevu.tarih)
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.textMuted)
                            }
                            .frame(width: 80)
                            .padding(.vertical, 8)
                            .background(Theme.darkSurfaceElevated)
                            .cornerRadius(10)

                            // Hasta bilgileri
                            VStack(alignment: .leading, spacing: 4) {
                                Text(randevu.hasta_ad_soyad)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)

                                if let tel = randevu.telefon, !tel.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 11))
                                        Text(tel)
                                            .font(.system(size: 13))
                                    }
                                    .foregroundColor(Theme.textSecondary)
                                }

                                if let not = randevu.notlar, !not.isEmpty {
                                    Text(not)
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.textMuted)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            // Ücret ve Durum
                            VStack(alignment: .trailing, spacing: 6) {
                                durumRozeti(randevu.durum)

                                if let ucret = randevu.ucret, ucret > 0 {
                                    Text("₺\(String(format: "%.0f", ucret))")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Theme.emeraldLight)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(Theme.darkSurface)
                        .listRowSeparatorTint(Theme.darkBorder.opacity(0.4))
                    }
                }
                .listStyle(.plain)
                .background(Theme.darkBg)
            }
        }
        .background(Theme.darkBg)
    }

    private func durumRozeti(_ durum: String) -> some View {
        let (bg, fg): (Color, Color) = {
            switch durum.lowercased() {
            case "geldi": return (Theme.statusSuccess.opacity(0.15), Theme.statusSuccess)
            case "bekliyor": return (Theme.cyanAccent.opacity(0.15), Theme.cyanAccent)
            case "iptal": return (Theme.statusError.opacity(0.15), Theme.statusError)
            case "gelmedi": return (Theme.statusWarning.opacity(0.15), Theme.statusWarning)
            default: return (Theme.darkSurfaceElevated, Theme.textSecondary)
            }
        }()

        return Text(durum)
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bg)
            .foregroundColor(fg)
            .cornerRadius(8)
    }
}

