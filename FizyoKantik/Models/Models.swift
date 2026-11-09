import Foundation

struct Hasta: Codable, Identifiable, Hashable {
    let id: Int?
    let tc_kimlik_no: String?
    var ad: String
    var soyad: String
    var telefon: String
    var tani: String?
    var notlar: String?
    var cinsiyet: String?
    var dogum_tarihi: String?
    var toplam_seans: Int?
    var kalan_bakiye: Double?

    var ad_soyad: String {
        "\(ad) \(soyad)".trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var bakiye: Double {
        kalan_bakiye ?? 0.0
    }
}

struct Randevu: Codable, Identifiable, Hashable {
    let id: Int?
    let hasta_id: Int?
    var hasta_ad_soyad: String
    var telefon: String?
    var tarih: String
    var saat: String
    var durum: String
    var notlar: String?
    var ucret: Double?

    var randevu_tarihi: String { tarih }
    var randevu_saati: String { saat }
    var seans_sayisi: Int { 1 }
    var seans_ucreti: Double { ucret ?? 0.0 }
}

struct Seans: Codable, Identifiable, Hashable {
    let id: Int?
    let hasta_id: Int
    var seans_tarihi: String
    var seans_no: Int
    var seans_ucreti: Double
    var odenen_tutar: Double
    var yapilan_islemler: String?
    var notlar: String?

    var ucret: Double { seans_ucreti }
    var odenen: Double { odenen_tutar }
}

struct Odeme: Codable, Identifiable, Hashable {
    let id: Int?
    let hasta_id: Int
    var tutar: Double
    var odeme_tarihi: String
    var aciklama: String?
}

struct WebRandevuTalep: Codable, Identifiable, Hashable {
    let id: Int
    let tc_kimlik_no: String?
    let ad_soyad: String
    let telefon: String
    let sikayet: String?
    let tercih_edilen_tarih: String?
    let tercih_edilen_zaman: String?
    let olusturma_tarihi: String?
    var durum: String
}

struct GirisSonuc: Codable {
    let basarili: Bool
    let id: Int?
    let kullanici_adi: String?
    let ad_soyad: String?
    let rol: String?
    let mesaj: String?
}

struct GenelSonuc: Codable {
    let basarili: Bool
    let id: Int?
    let mesaj: String?
    let seans_no: Int?
}

struct DashboardOzet: Codable {
    let toplam_hasta: Int
    let bugun_randevu: Int
    let bekleyen_web: Int
    let bugun_seans: Int
}

struct HastaGecmisResponse: Codable {
    let seanslar: [Seans]?
    let odemeler: [Odeme]?
}
