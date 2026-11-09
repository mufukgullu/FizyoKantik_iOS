import SwiftUI

struct HastalarTabView: View {
    @ObservedObject var session: SessionStore
    @Binding var yeniHastaGoster: Bool
    @Binding var secilenHasta: Hasta?
    @State private var aramaMetni: String = ""

    private var filtrelenmisHastalar: [Hasta] {
        if aramaMetni.isEmpty {
            return session.hastalar
        }
        let q = aramaMetni.lowercased()
        return session.hastalar.filter { h in
            h.ad_soyad.lowercased().contains(q) ||
            (h.telefon.contains(q)) ||
            (h.tc_kimlik_no?.contains(q) ?? false) ||
            (h.tani?.lowercased().contains(q) ?? false)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hasta Dosyaları")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Kayıtlı \(session.hastalar.count) hasta profili")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()

                Button(action: { yeniHastaGoster = true }) {
                    Label("Yeni Hasta", systemImage: "person.badge.plus")
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

            // Arama Çubuğu
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.textMuted)
                TextField("", text: $aramaMetni, prompt: Text("Hasta adı, telefon, TC veya tanı ara...").foregroundColor(Theme.textMuted))
                    .foregroundColor(Theme.textPrimary)
                if !aramaMetni.isEmpty {
                    Button(action: { aramaMetni = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.textMuted)
                    }
                }
            }
            .padding(12)
            .background(Theme.darkSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.darkBorder.opacity(0.6), lineWidth: 1)
            )
            .padding(.horizontal, 20)

            // Liste
            if filtrelenmisHastalar.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.textMuted)
                    Text("Kayıtlı hasta bulunamadı.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(filtrelenmisHastalar) { hasta in
                        Button(action: { secilenHasta = hasta }) {
                            HStack(spacing: 16) {
                                // Avatar
                                Circle()
                                    .fill(Theme.emeraldContainer)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Text(hasta.ad.prefix(1) + hasta.soyad.prefix(1))
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Theme.emeraldLight)
                                    )

                                // Bilgiler
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(hasta.ad_soyad)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Theme.textPrimary)

                                    HStack(spacing: 10) {
                                        if !hasta.telefon.isEmpty {
                                            HStack(spacing: 4) {
                                                Image(systemName: "phone.fill")
                                                    .font(.system(size: 11))
                                                Text(hasta.telefon)
                                            }
                                        }
                                        if let tc = hasta.tc_kimlik_no, !tc.isEmpty {
                                            Text("TC: \(tc)")
                                        }
                                    }
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textSecondary)

                                    if let tani = hasta.tani, !tani.isEmpty {
                                        Text("Tanı: \(tani)")
                                            .font(.system(size: 12))
                                            .foregroundColor(Theme.cyanAccent)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                // Seans ve Bakiye
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(hasta.toplam_seans ?? 0) Seans")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Theme.textSecondary)

                                    if hasta.bakiye > 0 {
                                        Text("₺\(String(format: "%.0f", hasta.bakiye)) Borç")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(Theme.statusError)
                                    } else {
                                        Text("Borçsuz")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Theme.statusSuccess)
                                    }
                                }

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textMuted)
                            }
                            .padding(.vertical, 6)
                        }
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
}
