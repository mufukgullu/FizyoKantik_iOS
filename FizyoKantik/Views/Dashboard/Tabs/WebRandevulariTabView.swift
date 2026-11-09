import SwiftUI

struct WebRandevulariTabView: View {
    @ObservedObject var session: SessionStore
    @Binding var onaylanacakTalep: WebRandevuTalep?

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Web Randevu Talepleri")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Web sitesinden online başvuran hastalar")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()

                Button(action: {
                    Task { await session.tumVerileriYukle() }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .padding(10)
                        .background(Theme.darkSurfaceElevated)
                        .foregroundColor(Theme.emeraldLight)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            if session.webRandevulari.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 44))
                        .foregroundColor(Theme.textMuted)
                    Text("Bekleyen web randevu talebi bulunmuyor.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(session.webRandevulari) { talep in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(talep.ad_soyad)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)

                                Spacer()

                                durumRozeti(talep.durum)
                            }

                            HStack(spacing: 16) {
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.fill")
                                    Text(talep.telefon)
                                }
                                .foregroundColor(Theme.cyanAccent)
                                .font(.system(size: 13))

                                if let tarih = talep.tercih_edilen_tarih {
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar")
                                        Text(tarih)
                                    }
                                    .foregroundColor(Theme.textSecondary)
                                    .font(.system(size: 13))
                                }

                                if let zaman = talep.tercih_edilen_zaman {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                        Text(zaman)
                                    }
                                    .foregroundColor(Theme.textSecondary)
                                    .font(.system(size: 13))
                                }
                            }

                            if let sikayet = talep.sikayet, !sikayet.isEmpty {
                                Text("Şikayet: \(sikayet)")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textSecondary)
                                    .padding(8)
                                    .background(Theme.darkSurfaceElevated)
                                    .cornerRadius(8)
                            }

                            // Aksiyon Butonları
                            HStack(spacing: 10) {
                                // Arama Butonu
                                if let url = URL(string: "tel://\(talep.telefon.filter { $0.isNumber })") {
                                    Link(destination: url) {
                                        Label("Ara", systemImage: "phone")
                                            .font(.system(size: 13, weight: .semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Theme.darkSurfaceElevated)
                                            .foregroundColor(Theme.textPrimary)
                                            .cornerRadius(8)
                                    }
                                }

                                // WhatsApp Butonu
                                let temizTel = talep.telefon.filter { $0.isNumber }
                                let waTel = temizTel.hasPrefix("0") ? "9\(temizTel)" : (temizTel.hasPrefix("90") ? temizTel : "90\(temizTel)")
                                if let waUrl = URL(string: "https://wa.me/\(waTel)") {
                                    Link(destination: waUrl) {
                                        Label("WhatsApp", systemImage: "message.fill")
                                            .font(.system(size: 13, weight: .semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Color(hex: 0x25D366).opacity(0.15))
                                            .foregroundColor(Color(hex: 0x25D366))
                                            .cornerRadius(8)
                                    }
                                }

                                Spacer()

                                if talep.durum.caseInsensitiveCompare("Onaylandı") != .orderedSame {
                                    Button(action: {
                                        onaylanacakTalep = talep
                                    }) {
                                        Label("Randevuya Dönüştür", systemImage: "checkmark.circle.fill")
                                            .font(.system(size: 13, weight: .bold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Theme.emeraldPrimary)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(16)
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
            case "onaylandı": return (Theme.statusSuccess.opacity(0.15), Theme.statusSuccess)
            case "iptal": return (Theme.statusError.opacity(0.15), Theme.statusError)
            default: return (Theme.statusWarning.opacity(0.15), Theme.statusWarning)
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

