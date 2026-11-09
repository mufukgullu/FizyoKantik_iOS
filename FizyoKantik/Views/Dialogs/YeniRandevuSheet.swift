import SwiftUI

struct YeniRandevuSheet: View {
    @ObservedObject var session: SessionStore
    @Environment(\.dismiss) var dismiss

    @State private var secilenHastaId: Int? = nil
    @State private var hastaArama: String = ""
    @State private var tarih: Date = Date()
    @State private var saat: String = "10:00"
    @State private var ucretText: String = "1000"
    @State private var notlar: String = ""

    @State private var kayitEdiliyor: Bool = false
    @State private var hataMesaji: String? = nil

    private let saatSecenekleri = [
        "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
        "12:00", "13:00", "13:30", "14:00", "14:30", "15:00",
        "15:30", "16:00", "16:30", "17:00", "17:30", "18:00",
        "18:30", "19:00", "19:30", "20:00", "20:30", "21:00"
    ]

    private var filtrelenmisHastalar: [Hasta] {
        if hastaArama.isEmpty { return Array(session.hastalar.prefix(8)) }
        return session.hastalar.filter { $0.ad_soyad.localizedCaseInsensitiveContains(hastaArama) }
    }

    private var secilenHasta: Hasta? {
        session.hastalar.first(where: { $0.id == secilenHastaId })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Hasta").foregroundColor(Theme.emeraldLight)) {
                    if let hasta = secilenHasta {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(hasta.ad_soyad)
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                Text(hasta.telefon)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            Spacer()
                            Button("Değiştir") {
                                secilenHastaId = nil
                            }
                            .foregroundColor(Theme.cyanAccent)
                        }
                    } else {
                        TextField("Hasta ara...", text: $hastaArama)
                        ForEach(filtrelenmisHastalar) { hasta in
                            Button(action: {
                                secilenHastaId = hasta.id
                                hastaArama = ""
                            }) {
                                HStack {
                                    Text(hasta.ad_soyad)
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Text(hasta.telefon)
                                        .font(.caption)
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Tarih ve Saat").foregroundColor(Theme.emeraldLight)) {
                    DatePicker("Randevu Tarihi", selection: $tarih, displayedComponents: [.date])
                        .environment(\.locale, Locale(identifier: "tr_TR"))

                    Picker("Randevu Saati", selection: $saat) {
                        ForEach(saatSecenekleri, id: \.self) { s in
                            Text(s).tag(s)
                        }
                    }

                    TextField("Seans Ücreti (₺)", text: $ucretText)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Notlar").foregroundColor(Theme.emeraldLight)) {
                    TextField("Randevu notu (isteğe bağlı)", text: $notlar, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let hata = hataMesaji {
                    Section {
                        Text(hata)
                            .foregroundColor(Theme.statusError)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.darkBg)
            .navigationTitle("Yeni Randevu Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Oluştur") {
                        kaydet()
                    }
                    .font(.headline)
                    .foregroundColor(Theme.emeraldPrimary)
                    .disabled(secilenHastaId == nil || kayitEdiliyor)
                }
            }
        }
    }

    private func kaydet() {
        guard let hastaId = secilenHastaId else { return }
        kayitEdiliyor = true
        hataMesaji = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let tarihStr = formatter.string(from: tarih)
        let ucret = Double(ucretText) ?? 0.0

        Task {
            do {
                let sonuc = try await SupabaseService.shared.randevuEkle(
                    hastaId: hastaId,
                    tarih: tarihStr,
                    saat: saat,
                    ucret: ucret,
                    notlar: notlar.isEmpty ? nil : notlar
                )
                if sonuc.basarili {
                    await session.tumVerileriYukle()
                    dismiss()
                } else {
                    hataMesaji = sonuc.mesaj ?? "Randevu oluşturulamadı."
                }
            } catch {
                hataMesaji = "Hata: \(error.localizedDescription)"
            }
            kayitEdiliyor = false
        }
    }
}
