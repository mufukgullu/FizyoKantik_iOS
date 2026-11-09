import SwiftUI

struct HizliSeansTabView: View {
    @ObservedObject var session: SessionStore
    @State private var secilenHastaId: Int? = nil
    @State private var hastaArama: String = ""
    @State private var ucretText: String = "1000"
    @State private var odenenText: String = "1000"
    @State private var yapilanIslemler: String = ""
    @State private var notlar: String = ""
    @State private var kayitEdiliyor: Bool = false
    @State private var basariMesaji: String? = nil
    @State private var hataMesaji: String? = nil

    private var filtrelenmisHastalar: [Hasta] {
        if hastaArama.isEmpty { return Array(session.hastalar.prefix(10)) }
        return session.hastalar.filter { $0.ad_soyad.localizedCaseInsensitiveContains(hastaArama) }
    }

    private var secilenHasta: Hasta? {
        session.hastalar.first(where: { $0.id == secilenHastaId })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hızlı Seans & Ödeme Kaydı")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Gerçekleşen seansı ve tahsilatı tek ekranda sisteme işleyin")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }

                if let basari = basariMesaji {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.statusSuccess)
                        Text(basari)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.statusSuccess)
                        Spacer()
                    }
                    .padding(14)
                    .background(Theme.statusSuccess.opacity(0.12))
                    .cornerRadius(12)
                }

                if let hata = hataMesaji {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Theme.statusError)
                        Text(hata)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.statusError)
                        Spacer()
                    }
                    .padding(14)
                    .background(Theme.statusError.opacity(0.12))
                    .cornerRadius(12)
                }

                // 1. Hasta Seçimi
                VStack(alignment: .leading, spacing: 10) {
                    Text("1. Hasta Seçiniz")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.emeraldLight)

                    if let hasta = secilenHasta {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(hasta.ad_soyad)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Telefon: \(hasta.telefon) • Kalan Bakiye: ₺\(String(format: "%.0f", hasta.bakiye))")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            Spacer()
                            Button("Değiştir") {
                                secilenHastaId = nil
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.cyanAccent)
                        }
                        .padding(14)
                        .background(Theme.darkSurfaceElevated)
                        .cornerRadius(12)
                    } else {
                        TextField("", text: $hastaArama, prompt: Text("Hasta adı yazarak arayın...").foregroundColor(Theme.textMuted))
                            .foregroundColor(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.darkSurfaceElevated)
                            .cornerRadius(10)

                        VStack(spacing: 6) {
                            ForEach(filtrelenmisHastalar) { hasta in
                                Button(action: {
                                    secilenHastaId = hasta.id
                                    hastaArama = ""
                                }) {
                                    HStack {
                                        Text(hasta.ad_soyad)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Theme.textPrimary)
                                        Spacer()
                                        Text(hasta.telefon)
                                            .font(.system(size: 12))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    .padding(10)
                                    .background(Theme.darkSurfaceElevated.opacity(0.6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(18)
                .background(Theme.darkSurface)
                .cornerRadius(16)

                // 2. Ücret & Tahsilat
                VStack(alignment: .leading, spacing: 14) {
                    Text("2. Seans Ücreti ve Ödeme")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.emeraldLight)

                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Seans Ücreti (₺)")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                            TextField("", text: $ucretText)
                                .keyboardType(.numberPad)
                                .foregroundColor(Theme.textPrimary)
                                .padding(12)
                                .background(Theme.darkSurfaceElevated)
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tahsil Edilen (₺)")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                            TextField("", text: $odenenText)
                                .keyboardType(.numberPad)
                                .foregroundColor(Theme.textPrimary)
                                .padding(12)
                                .background(Theme.darkSurfaceElevated)
                                .cornerRadius(10)
                        }
                    }

                    // Kalan Borç Hesaplayıcı
                    let ucret = Double(ucretText) ?? 0.0
                    let odenen = Double(odenenText) ?? 0.0
                    let fark = ucret - odenen

                    HStack {
                        Text("İşlem Sonrası Hasta Bakiyesi:")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        if fark > 0 {
                            Text("+₺\(String(format: "%.0f", fark)) Borç Yazılacak")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Theme.statusError)
                        } else if fark == 0 {
                            Text("Tam Tahsilat (Borçsuz)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Theme.statusSuccess)
                        } else {
                            Text("₺\(String(format: "%.0f", abs(fark))) Fazla Ödeme")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Theme.cyanAccent)
                        }
                    }
                    .padding(12)
                    .background(Theme.darkBg)
                    .cornerRadius(10)
                }
                .padding(18)
                .background(Theme.darkSurface)
                .cornerRadius(16)

                // 3. Yapılan İşlemler ve Notlar
                VStack(alignment: .leading, spacing: 14) {
                    Text("3. Klinik Notları")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.emeraldLight)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Uygulanan Tedavi / Egzersiz")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                        TextField("", text: $yapilanIslemler, prompt: Text("Örn: Manuel terapi, kuru iğneleme, germe egzersizleri").foregroundColor(Theme.textMuted))
                            .foregroundColor(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.darkSurfaceElevated)
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ek Notlar")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                        TextField("", text: $notlar, prompt: Text("Örn: Hasta ağrısının azaldığını belirtti").foregroundColor(Theme.textMuted))
                            .foregroundColor(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.darkSurfaceElevated)
                            .cornerRadius(10)
                    }
                }
                .padding(18)
                .background(Theme.darkSurface)
                .cornerRadius(16)

                // Kaydet Butonu
                Button(action: {
                    kaydet()
                }) {
                    HStack {
                        if kayitEdiliyor {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Seansı ve Ödemeyi Onayla")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Theme.emeraldPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Theme.emeraldPrimary.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(secilenHastaId == nil || kayitEdiliyor)
            }
            .padding(20)
        }
        .background(Theme.darkBg)
    }

    private func kaydet() {
        guard let hastaId = secilenHastaId else { return }
        let ucret = Double(ucretText) ?? 0.0
        let odenen = Double(odenenText) ?? 0.0

        kayitEdiliyor = true
        basariMesaji = nil
        hataMesaji = nil

        Task {
            do {
                let sonuc = try await SupabaseService.shared.seansKaydet(
                    hastaId: hastaId,
                    ucret: ucret,
                    odenen: odenen,
                    islemler: yapilanIslemler.isEmpty ? nil : yapilanIslemler,
                    notlar: notlar.isEmpty ? nil : notlar
                )
                if sonuc.basarili {
                    basariMesaji = sonuc.mesaj ?? "Seans başarıyla kaydedildi!"
                    yapilanIslemler = ""
                    notlar = ""
                    secilenHastaId = nil
                    await session.tumVerileriYukle()
                } else {
                    hataMesaji = sonuc.mesaj ?? "Kayıt sırasında hata oluştu."
                }
            } catch {
                hataMesaji = "Hata: \(error.localizedDescription)"
            }
            kayitEdiliyor = false
        }
    }
}
