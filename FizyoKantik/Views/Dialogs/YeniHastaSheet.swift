import SwiftUI

struct YeniHastaSheet: View {
    @ObservedObject var session: SessionStore
    @Environment(\.dismiss) var dismiss

    @State private var tcKimlik: String = ""
    @State private var ad: String = ""
    @State private var soyad: String = ""
    @State private var telefon: String = ""
    @State private var tani: String = ""
    @State private var notlar: String = ""
    @State private var cinsiyet: String = "Erkek"

    @State private var kayitEdiliyor: Bool = false
    @State private var hataMesaji: String? = nil

    private var tcHataMesaji: String? {
        if tcKimlik.isEmpty { return "T.C. Kimlik Numarası zorunludur (11 hane)" }
        let sonuc = TcKimlikDogrulayici.dogrula(tcKimlik)
        return sonuc.gecerliMi ? nil : sonuc.hataMesaji
    }

    private var formGecerliMi: Bool {
        !ad.trimmingCharacters(in: .whitespaces).isEmpty &&
        !soyad.trimmingCharacters(in: .whitespaces).isEmpty &&
        !telefon.trimmingCharacters(in: .whitespaces).isEmpty &&
        tcKimlik.count == 11 &&
        TcKimlikDogrulayici.gecerliMi(tcKimlik)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Kişisel Bilgiler").foregroundColor(Theme.emeraldLight)) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("T.C. Kimlik Numarası (11 Hane)", text: $tcKimlik)
                            .keyboardType(.numberPad)
                        if let err = tcHataMesaji {
                            Text(err)
                                .font(.system(size: 11))
                                .foregroundColor(Theme.statusError)
                        }
                    }

                    TextField("Ad", text: $ad)
                    TextField("Soyad", text: $soyad)
                    TextField("Telefon (05xx)", text: $telefon)
                        .keyboardType(.phonePad)

                    Picker("Cinsiyet", selection: $cinsiyet) {
                        Text("Erkek").tag("Erkek")
                        Text("Kadın").tag("Kadın")
                    }
                }

                Section(header: Text("Klinik Bilgileri").foregroundColor(Theme.emeraldLight)) {
                    TextField("Tanı / Şikayet (Örn: Bel Fıtığı, Menisküs)", text: $tani)
                    TextField("Klinik Notları", text: $notlar, axis: .vertical)
                        .lineLimit(3...5)
                }

                if let hata = hataMesaji {
                    Section {
                        Text(hata)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.statusError)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.darkBg)
            .navigationTitle("Yeni Hasta Kaydı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        kaydet()
                    }
                    .font(.headline)
                    .foregroundColor(Theme.emeraldPrimary)
                    .disabled(!formGecerliMi || kayitEdiliyor)
                }
            }
        }
    }

    private func kaydet() {
        kayitEdiliyor = true
        hataMesaji = nil

        Task {
            do {
                let sonuc = try await SupabaseService.shared.hastaKaydet(
                    tc: tcKimlik.trimmingCharacters(in: .whitespaces),
                    ad: ad.trimmingCharacters(in: .whitespaces),
                    soyad: soyad.trimmingCharacters(in: .whitespaces),
                    telefon: telefon.trimmingCharacters(in: .whitespaces),
                    tani: tani.isEmpty ? nil : tani,
                    notlar: notlar.isEmpty ? nil : notlar,
                    cinsiyet: cinsiyet
                )

                if sonuc.basarili {
                    await session.tumVerileriYukle()
                    dismiss()
                } else {
                    hataMesaji = sonuc.mesaj ?? "Hasta kaydı başarısız oldu."
                }
            } catch {
                hataMesaji = "Hata: \(error.localizedDescription)"
            }
            kayitEdiliyor = false
        }
    }
}
