import Foundation
import SwiftUI

@MainActor
class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published var aktifKullanici: GirisSonuc? = nil
    @Published var ozet: DashboardOzet? = nil
    @Published var randevular: [Randevu] = []
    @Published var hastalar: [Hasta] = []
    @Published var webRandevulari: [WebRandevuTalep] = []
    @Published var yukleniyor: Bool = false
    @Published var hataMesaji: String? = nil

    private let userDefaultsKey = "fizyokantik_aktif_kullanici"

    init() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(GirisSonuc.self, from: savedData) {
            self.aktifKullanici = user
        }
    }

    var girisYapildi: Bool {
        aktifKullanici?.basarili == true
    }

    func girisYap(kullaniciAdi: String, parola: String) async -> Bool {
        yukleniyor = true
        hataMesaji = nil
        do {
            let sonuc = try await SupabaseService.shared.girisYap(kullaniciAdi: kullaniciAdi, parola: parola)
            if sonuc.basarili {
                self.aktifKullanici = sonuc
                if let encoded = try? JSONEncoder().encode(sonuc) {
                    UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
                }
                yukleniyor = false
                await tumVerileriYukle()
                return true
            } else {
                hataMesaji = sonuc.mesaj ?? "Kullanıcı adı veya parola hatalı."
                yukleniyor = false
                return false
            }
        } catch {
            hataMesaji = "Bağlantı hatası: \(error.localizedDescription)"
            yukleniyor = false
            return false
        }
    }

    func cikisYap() {
        aktifKullanici = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        ozet = nil
        randevular.removeAll()
        hastalar.removeAll()
        webRandevulari.removeAll()
    }

    func tumVerileriYukle() async {
        guard girisYapildi else { return }
        yukleniyor = true
        hataMesaji = nil

        async let ozetTask = SupabaseService.shared.getDashboardOzet()
        async let randevularTask = SupabaseService.shared.getRandevular(tarih: nil)
        async let hastalarTask = SupabaseService.shared.getHastalar(arama: nil)
        async let webRandevulariTask = SupabaseService.shared.getWebRandevulari()

        let yeniOzet = try? await ozetTask
        let yeniRandevular = try? await randevularTask
        let yeniHastalar = try? await hastalarTask
        let yeniWeb = try? await webRandevulariTask

        if let o = yeniOzet { self.ozet = o }
        if let r = yeniRandevular { self.randevular = r }
        if let h = yeniHastalar { self.hastalar = h }
        if let w = yeniWeb { self.webRandevulari = w }

        yukleniyor = false
    }
}

