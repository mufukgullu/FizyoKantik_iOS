import SwiftUI

struct HastaDetaySheet: View {
    let hasta: Hasta
    @ObservedObject var session: SessionStore
    @Environment(\.dismiss) var dismiss

    @State private var seanslar: [Seans] = []
    @State private var odemeler: [Odeme] = []
    @State private var gecmisYukleniyor: Bool = false
    @State private var secilenSegment: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hasta Kartı
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Theme.emeraldContainer)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Text(hasta.ad.prefix(1) + hasta.soyad.prefix(1))
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Theme.emeraldLight)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(hasta.ad_soyad)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)

                                if let tc = hasta.tc_kimlik_no, !tc.isEmpty {
                                    Text("TC: \(tc)")
                                        .font(.system(size: 13))
                                        .foregroundColor(Theme.textSecondary)
                                }

                                if let tani = hasta.tani, !tani.isEmpty {
                                    Text("Tanı: \(tani)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Theme.cyanAccent)
                                }
                            }
                            Spacer()
                        }

                        Divider().background(Theme.darkBorder)

                        // İletişim & Aksiyonlar
                        HStack(spacing: 12) {
                            if let telUrl = URL(string: "tel://\(hasta.telefon.filter { $0.isNumber })") {
                                Link(destination: telUrl) {
                                    Label("Ara", systemImage: "phone.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Theme.darkSurfaceElevated)
                                        .foregroundColor(Theme.textPrimary)
                                        .cornerRadius(10)
                                }
                            }

                            let waTel = hasta.telefon.filter { $0.isNumber }
                            let waFormatted = waTel.hasPrefix("0") ? "9\(waTel)" : (waTel.hasPrefix("90") ? waTel : "90\(waTel)")
                            if let waUrl = URL(string: "https://wa.me/\(waFormatted)") {
                                Link(destination: waUrl) {
                                    Label("WhatsApp", systemImage: "message.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: 0x25D366).opacity(0.15))
                                        .foregroundColor(Color(hex: 0x25D366))
                                        .cornerRadius(10)
                                }
                            }
                        }

                        // Metrikler
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Toplam Seans")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textSecondary)
                                Text("\(hasta.toplam_seans ?? seanslar.count)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Theme.darkBg)
                            .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mevcut Bakiye")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textSecondary)
                                if hasta.bakiye > 0 {
                                    Text("₺\(String(format: "%.0f", hasta.bakiye)) Borç")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Theme.statusError)
                                } else {
                                    Text("Borçsuz")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Theme.statusSuccess)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Theme.darkBg)
                            .cornerRadius(10)
                        }
                    }
                    .padding(20)
                    .background(Theme.darkSurface)
                    .cornerRadius(18)

                    // Segmented Control
                    Picker("Geçmiş", selection: $secilenSegment) {
                        Text("Seanslar (\(seanslar.count))").tag(0)
                        Text("Ödemeler (\(odemeler.count))").tag(1)
                    }
                    .pickerStyle(.segmented)

                    // Geçmiş Listesi
                    if gecmisYukleniyor {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.emeraldLight))
                            .padding(30)
                    } else if secilenSegment == 0 {
                        // Seanslar
                        if seanslar.isEmpty {
                            Text("Kayıtlı seans bulunamadı.")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.textSecondary)
                                .padding(30)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(seanslar) { seans in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(seans.seans_no). Seans")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(Theme.textPrimary)
                                            Text(seans.seans_tarihi)
                                                .font(.system(size: 12))
                                                .foregroundColor(Theme.textSecondary)
                                            if let islem = seans.yapilan_islemler, !islem.isEmpty {
                                                Text(islem)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Theme.cyanAccent)
                                            }
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("₺\(String(format: "%.0f", seans.seans_ucreti))")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Theme.textPrimary)
                                            Text("Ödenen: ₺\(String(format: "%.0f", seans.odenen_tutar))")
                                                .font(.system(size: 12))
                                                .foregroundColor(Theme.statusSuccess)
                                        }
                                    }
                                    .padding(14)
                                    .background(Theme.darkSurface)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    } else {
                        // Ödemeler
                        if odemeler.isEmpty {
                            Text("Kayıtlı tahsilat bulunamadı.")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.textSecondary)
                                .padding(30)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(odemeler) { odeme in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Tahsilat")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(Theme.statusSuccess)
                                            Text(odeme.odeme_tarihi)
                                                .font(.system(size: 12))
                                                .foregroundColor(Theme.textSecondary)
                                            if let aciklama = odeme.aciklama, !aciklama.isEmpty {
                                                Text(aciklama)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Theme.textMuted)
                                            }
                                        }
                                        Spacer()
                                        Text("+₺\(String(format: "%.0f", odeme.tutar))")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Theme.statusSuccess)
                                    }
                                    .padding(14)
                                    .background(Theme.darkSurface)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.darkBg)
            .navigationTitle("Hasta Dosyası")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(Theme.emeraldLight)
                }
            }
            .task {
                await gecmisiYukle()
            }
        }
    }

    private func gecmisiYukle() async {
        guard let id = hasta.id else { return }
        gecmisYukleniyor = true
        do {
            let res = try await SupabaseService.shared.hastaGecmisGetir(hastaId: id)
            self.seanslar = res.seanslar ?? []
            self.odemeler = res.odemeler ?? []
        } catch {
            print("Geçmiş hatası: \(error)")
        }
        gecmisYukleniyor = false
    }
}

