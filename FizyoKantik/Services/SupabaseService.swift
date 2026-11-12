import Foundation

actor SupabaseService {
    static let shared = SupabaseService()

    private let supabaseUrl = "https://yvrnjxeesggoehavzmrm.supabase.co"
    private let supabaseKey = "sb_publishable_OgWx8W350AE8XHQx6QL2ow_0zuWqPuG"

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    private func postRpc<T: Decodable>(fnName: String, parameters: [String: Any] = [:]) async throws -> T {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/rpc/\(fnName)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20

        if !parameters.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } else {
            request.httpBody = "{}".data(using: .utf8)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Sunucu Hatası"
            throw NSError(domain: "SupabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }

        return try jsonDecoder.decode(T.self, from: data)
    }

    // MARK: - 1. Giriş
    func girisYap(kullaniciAdi: String, parola: String) async throws -> GirisSonuc {
        let params = [
            "p_kullanici_adi": kullaniciAdi.trimmingCharacters(in: .whitespacesAndNewlines),
            "p_parola": parola
        ]
        return try await postRpc(fnName: "tablet_giris", parameters: params)
    }

    // MARK: - 2. Dashboard Özeti
    func getDashboardOzet() async throws -> DashboardOzet {
        return try await postRpc(fnName: "tablet_ozet_getir")
    }

    // MARK: - 3. Randevular
    func getRandevular(tarih: String? = nil) async throws -> [Randevu] {
        var params: [String: Any] = [:]
        if let tarih = tarih, !tarih.isEmpty {
            params["p_tarih"] = tarih
        } else {
            params["p_tarih"] = ""
        }
        return try await postRpc(fnName: "tablet_randevulari_getir", parameters: params)
    }

    func randevuKaydet(hastaId: Int?, hastaAdSoyad: String, telefon: String?, tarih: String, saat: String, ucret: Double, notlar: String?) async throws -> GenelSonuc {
        var pRandevu: [String: Any] = [
            "hasta_ad_soyad": hastaAdSoyad,
            "telefon": telefon ?? "",
            "tarih": tarih,
            "saat": saat,
            "notlar": notlar ?? "",
            "ucret": ucret
        ]
        if let hid = hastaId, hid > 0 {
            pRandevu["hasta_id"] = hid
        }
        return try await postRpc(fnName: "tablet_randevu_kaydet", parameters: ["p_randevu": pRandevu])
    }

    func randevuDurumGuncelle(id: Int, durum: String) async throws -> GenelSonuc {
        let params: [String: Any] = [
            "p_id": id,
            "p_durum": durum
        ]
        return try await postRpc(fnName: "tablet_randevu_durum_guncelle", parameters: params)
    }

    func randevuSil(id: Int) async throws -> GenelSonuc {
        let params: [String: Any] = [
            "p_id": id
        ]
        return try await postRpc(fnName: "tablet_randevu_sil", parameters: params)
    }

    // MARK: - 4. Hastalar
    func getHastalar(arama: String? = nil) async throws -> [Hasta] {
        var params: [String: Any] = [:]
        if let arama = arama, !arama.isEmpty {
            params["p_arama"] = arama
        } else {
            params["p_arama"] = ""
        }
        return try await postRpc(fnName: "tablet_hastalari_getir", parameters: params)
    }

    func hastaKaydet(id: Int? = nil, tc: String, ad: String, soyad: String, telefon: String, tani: String?, notlar: String?, cinsiyet: String? = "Erkek", dogumTarihi: String? = "1990-01-01") async throws -> GenelSonuc {
        var pHasta: [String: Any] = [
            "tc_kimlik_no": tc,
            "ad": ad,
            "soyad": soyad,
            "telefon": telefon,
            "tani": tani ?? "",
            "notlar": notlar ?? "",
            "cinsiyet": cinsiyet ?? "Erkek",
            "dogum_tarihi": dogumTarihi ?? "1990-01-01"
        ]
        if let id = id, id > 0 {
            pHasta["id"] = id
        }
        return try await postRpc(fnName: "tablet_hasta_kaydet", parameters: ["p_hasta": pHasta])
    }

    func hastaSil(id: Int) async throws -> GenelSonuc {
        return try await postRpc(fnName: "tablet_hasta_sil", parameters: ["p_id": id])
    }

    // MARK: - 5. Seanslar
    func seansKaydet(hastaId: Int, ucret: Double, odenen: Double, islemler: String?, notlar: String?) async throws -> GenelSonuc {
        let pSeans: [String: Any] = [
            "hasta_id": hastaId,
            "seans_ucreti": ucret,
            "odenen_tutar": odenen,
            "yapilan_islemler": islemler ?? "",
            "notlar": notlar ?? ""
        ]
        return try await postRpc(fnName: "tablet_seans_kaydet", parameters: ["p_seans": pSeans])
    }

    func getSeanslar(hastaId: Int) async throws -> [Seans] {
        return try await postRpc(fnName: "tablet_seanslari_getir", parameters: ["p_hasta_id": hastaId])
    }

    // MARK: - 6. Ödemeler / Tahsilat
    func odemeKaydet(hastaId: Int, tutar: Double, aciklama: String?) async throws -> GenelSonuc {
        let pOdeme: [String: Any] = [
            "hasta_id": hastaId,
            "tutar": tutar,
            "aciklama": aciklama ?? "Tahsilat"
        ]
        return try await postRpc(fnName: "tablet_odeme_kaydet", parameters: ["p_odeme": pOdeme])
    }

    func getOdemeler(hastaId: Int) async throws -> [Odeme] {
        return try await postRpc(fnName: "tablet_odemeleri_getir", parameters: ["p_hasta_id": hastaId])
    }

    // MARK: - 7. Web Randevuları
    func getWebRandevulari() async throws -> [WebRandevuTalep] {
        return try await postRpc(fnName: "tablet_web_randevulari_getir")
    }

    func webRandevuOnayla(talepId: Int, tarih: String, saat: String, ucret: Double, tani: String) async throws -> GenelSonuc {
        let params: [String: Any] = [
            "p_talep_id": talepId,
            "p_tarih": tarih,
            "p_saat": saat,
            "p_ucret": ucret,
            "p_tani": tani
        ]
        return try await postRpc(fnName: "tablet_web_randevu_onayla", parameters: params)
    }

    func webRandevuReddet(talepId: Int) async throws -> GenelSonuc {
        let params: [String: Any] = [
            "p_talep_id": talepId
        ]
        return try await postRpc(fnName: "tablet_web_randevu_reddet", parameters: params)
    }
}
