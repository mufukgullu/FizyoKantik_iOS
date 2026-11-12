import SwiftUI

struct WebRandevuOnaylaSheet: View {
    let talep: WebRandevuTalep
    @ObservedObject var session: SessionStore
    @Environment(\.dismiss) var dismiss

    @State private var eslesenHastaId: Int? = nil
    @State private var tarih: Date = Date()
    @State private var saat: String = "10:00"
    @State private var ucretText: String = "1000"
    @State private var notlar: String = ""

    @State private var islemSuruyor: Bool = false
    @State private var hataMesaji: String? = nil

    private let saatSecenekleri = [
        "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
        "12:00", "13:00", "13:30", "14:00", "14:30", "15:00",
        "15:30", "16:00", "16:30", "17:00", "17:30", "18:00",
        "18:30", "19:00", "19:30", "20:00", "20:30", "21:00"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Web Başvuru Bilgisi").foregroundColor(Theme.emeraldLight)) {
                    Text(talep.ad_soyad).font(.headline)
                    Text("Telefon: \(talep.telefon)").font(.subheadline)
                    if let sikayet = talep.sikayet {
                        Text("Şikayet: \(sikayet)").font(.caption).foregroundColor(Theme.textSecondary)
                    }
                }

                Section(header: Text("Randevu Planı").foregroundColor(Theme.emeraldLight)) {
                    DatePicker("Tarih", selection: $tarih, displayedComponents: [.date])
                        .environment(\.locale, Locale(identifier: "tr_TR"))

                    Picker("Saat", selection: $saat) {
                        ForEach(saatSecenekleri, id: \.self) { s in
                            Text(s).tag(s)
                        }
                    }

                    TextField("Seans Ücreti (₺)", text: $ucretText)
                        .keyboardType(.numberPad)
                }

                if let hata = hataMesaji {
                    Section {
                        Text(hata).foregroundColor(Theme.statusError)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.darkBg)
            .navigationTitle("Talebi Randevuya Dönüştür")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Onayla ve Ekle") {
                        onayla()
                    }
                    .font(.headline)
                    .foregroundColor(Theme.emeraldPrimary)
                    .disabled(islemSuruyor)
                }
            }
            .onAppear {
                if let secilenZaman = talep.tercih_edilen_zaman, saatSecenekleri.contains(secilenZaman) {
                    saat = secilenZaman
                }
            }
        }
    }

    private func onayla() {
        islemSuruyor = true
        hataMesaji = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let tarihStr = formatter.string(from: tarih)
        let ucret = Double(ucretText) ?? 0.0

        Task {
            do {
                let res = try await SupabaseService.shared.webRandevuOnayla(
                    talepId: talep.id,
                    tarih: tarihStr,
                    saat: saat,
                    ucret: ucret,
                    tani: talep.sikayet ?? ""
                )

                if res.basarili {
                    await session.tumVerileriYukle()
                    dismiss()
                } else {
                    hataMesaji = res.mesaj ?? "Web randevusu onaylanamadı."
                }
            } catch {
                hataMesaji = "Hata: \(error.localizedDescription)"
            }
            islemSuruyor = false
        }
    }
}
