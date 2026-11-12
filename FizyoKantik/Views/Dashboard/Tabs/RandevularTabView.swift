import SwiftUI

struct RandevularTabView: View {
    @ObservedObject var session: SessionStore
    @Binding var yeniRandevuGoster: Bool

    @State private var secilenTarih: Date = Date()
    @State private var filtreDurum: String = "Tümü"
    @State private var takvimAcik: Bool = false
    @State private var secilenRandevu: Randevu? = nil
    @State private var durumSecimiGoster: Bool = false
    @State private var silmeOnayiGoster: Bool = false
    @State private var randevularYukleniyor: Bool = false

    private let durumlar = ["Tümü", "Planlandı", "Geldi", "Gelmedi", "İptal", "Bekliyor"]

    private var secilenTarihStr: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: secilenTarih)
    }

    private var tarihBaslikMetni: String {
        let cal = Calendar.current
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM EEEE"
        let gunStr = f.string(from: secilenTarih)

        if cal.isDateInToday(secilenTarih) {
            return "Bugün, \(gunStr)"
        } else if cal.isDateInTomorrow(secilenTarih) {
            return "Yarın, \(gunStr)"
        } else if cal.isDateInYesterday(secilenTarih) {
            return "Dün, \(gunStr)"
        } else {
            return gunStr
        }
    }

    private var filtrelenmisRandevular: [Randevu] {
        session.randevular.filter { r in
            if filtreDurum == "Tümü" { return true }
            return r.durum.localizedCaseInsensitiveContains(filtreDurum)
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            // Top Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Randevu Takvimi")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("\(filtrelenmisRandevular.count) randevu listeleniyor")
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
            .padding(.top, 14)

            // GÜN SEÇİCİ & TARİH GEZİNME BAR (Önceki / Sonraki / Tarih Seç)
            HStack(spacing: 12) {
                // Önceki Gün
                Button(action: {
                    tarihDegistir(gunFarki: -1)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 40, height: 40)
                        .background(Theme.darkSurfaceElevated)
                        .foregroundColor(Theme.emeraldLight)
                        .cornerRadius(10)
                }

                // Tarih Seçici Buton
                Button(action: {
                    takvimAcik.toggle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(Theme.cyanAccent)
                        Text(tarihBaslikMetni)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Theme.darkSurfaceElevated)
                    .cornerRadius(10)
                }
                .popover(isPresented: $takvimAcik) {
                    VStack {
                        DatePicker("Tarih Seç", selection: $secilenTarih, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                            .padding()
                            .onChange(of: secilenTarih) { _ in
                                takvimAcik = false
                                Task { await randevulariYukle() }
                            }
                    }
                    .frame(width: 320, height: 350)
                    .background(Theme.darkSurface)
                }

                // Sonraki Gün
                Button(action: {
                    tarihDegistir(gunFarki: 1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 40, height: 40)
                        .background(Theme.darkSurfaceElevated)
                        .foregroundColor(Theme.emeraldLight)
                        .cornerRadius(10)
                }

                // Bugüne Dön Hızlı Butonu (Eğer bugün seçili değilse)
                if !Calendar.current.isDateInToday(secilenTarih) {
                    Button(action: {
                        secilenTarih = Date()
                        Task { await randevulariYukle() }
                    }) {
                        Text("Bugün")
                            .font(.system(size: 13, weight: .bold))
                            .padding(.horizontal, 12)
                            .frame(height: 40)
                            .background(Theme.cyanAccent.opacity(0.15))
                            .foregroundColor(Theme.cyanAccent)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 20)

            // Durum Filtresi
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(durumlar, id: \.self) { durum in
                        Button(action: { filtreDurum = durum }) {
                            Text(durum)
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(filtreDurum == durum ? Theme.emeraldPrimary : Theme.darkSurfaceElevated)
                                .foregroundColor(filtreDurum == durum ? .white : Theme.textSecondary)
                                .cornerRadius(18)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Randevu Listesi
            if randevularYukleniyor {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.emeraldLight))
                    .scaleEffect(1.3)
                Spacer()
            } else if filtrelenmisRandevular.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 42))
                        .foregroundColor(Theme.textMuted)
                    Text("\(tarihBaslikMetni) için kayıtlı randevu bulunamadı.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textSecondary)

                    Button(action: { yeniRandevuGoster = true }) {
                        Text("Bu Güne Randevu Ekle")
                            .font(.system(size: 13, weight: .bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.darkSurfaceElevated)
                            .foregroundColor(Theme.emeraldLight)
                            .cornerRadius(8)
                    }
                }
                Spacer()
            } else {
                List {
                    ForEach(filtrelenmisRandevular) { randevu in
                        Button(action: {
                            secilenRandevu = randevu
                            durumSecimiGoster = true
                        }) {
                            HStack(spacing: 16) {
                                // Saat rozeti
                                VStack(spacing: 2) {
                                    Text(randevu.saat)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Theme.cyanAccent)
                                    Text(randevu.tarih)
                                        .font(.system(size: 10))
                                        .foregroundColor(Theme.textMuted)
                                }
                                .frame(width: 76)
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

                                // Durum Rozeti & Dokunma İpucu
                                VStack(alignment: .trailing, spacing: 6) {
                                    durumRozeti(randevu.durum)

                                    Text("Değiştir ▸")
                                        .font(.system(size: 11))
                                        .foregroundColor(Theme.textMuted)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(Theme.darkSurface)
                        .listRowSeparatorTint(Theme.darkBorder.opacity(0.4))
                    }
                }
                .listStyle(.plain)
                .background(Theme.darkBg)
                .refreshable {
                    await randevulariYukle()
                }
            }
        }
        .background(Theme.darkBg)
        .confirmationDialog(
            "\(secilenRandevu?.hasta_ad_soyad ?? "Randevu") Durumu",
            isPresented: $durumSecimiGoster,
            titleVisibility: .visible
        ) {
            Button("✅ Geldi / Seans Yapıldı") {
                durumAyarla("Geldi / Seans Yapıldı")
            }
            Button("⏳ Bekliyor / Planlandı") {
                durumAyarla("Planlandı")
            }
            Button("❌ Gelmedi") {
                durumAyarla("Gelmedi")
            }
            Button("🚫 İptal Edildi") {
                durumAyarla("İptal Edildi")
            }
            Button("🗑️ Randevuyu Sil", role: .destructive) {
                silmeOnayiGoster = true
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Randevunun klinik durumunu güncelleyin")
        }
        .alert("Randevuyu Sil", isPresented: $silmeOnayiGoster) {
            Button("Sil", role: .destructive) {
                randevuyuSil()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("\(secilenRandevu?.hasta_ad_soyad ?? "") isimli hastanın \(secilenRandevu?.saat ?? "") randevusunu silmek istediğinizden emin misiniz?")
        }
        .onAppear {
            Task { await randevulariYukle() }
        }
    }

    private func tarihDegistir(gunFarki: Int) {
        if let yeniTarih = Calendar.current.date(byAdding: .day, value: gunFarki, to: secilenTarih) {
            secilenTarih = yeniTarih
            Task { await randevulariYukle() }
        }
    }

    private func randevulariYukle() async {
        randevularYukleniyor = true
        await session.randevulariGetir(tarih: secilenTarihStr)
        randevularYukleniyor = false
    }

    private func durumAyarla(_ yeniDurum: String) {
        guard let r = secilenRandevu, let id = r.id else { return }
        Task {
            _ = await session.randevuDurumGuncelle(id: id, durum: yeniDurum, aktifTarih: secilenTarihStr)
        }
    }

    private func randevuyuSil() {
        guard let r = secilenRandevu, let id = r.id else { return }
        Task {
            _ = await session.randevuSil(id: id, aktifTarih: secilenTarihStr)
        }
    }

    private func durumRozeti(_ durum: String) -> some View {
        let (bg, fg): (Color, Color) = {
            let d = durum.lowercased()
            if d.contains("geldi") {
                return (Theme.statusSuccess.opacity(0.15), Theme.statusSuccess)
            } else if d.contains("bekliyor") || d.contains("planlandı") {
                return (Theme.cyanAccent.opacity(0.15), Theme.cyanAccent)
            } else if d.contains("iptal") {
                return (Theme.statusError.opacity(0.15), Theme.statusError)
            } else if d.contains("gelmedi") {
                return (Theme.statusWarning.opacity(0.15), Theme.statusWarning)
            } else {
                return (Theme.darkSurfaceElevated, Theme.textSecondary)
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
