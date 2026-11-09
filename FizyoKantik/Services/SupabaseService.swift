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

    // MARK: - API Metodları

    func girisYap(kullaniciAdi: String, parola: String) async throws -> GirisSonuc {
        let params = [
            "p_kullanici_adi": kullaniciAdi.trimmingCharacters(in: .whitespacesAndNewlines),
            "p_parola": parola
        ]
        return try await postRpc(fnName: "tablet_giris", parameters: params)
    }

    func getDashboardOzet() async throws -> DashboardOzet {
        return try await postRpc(fnName: "tablet_dashboard_ozet")
    }

    func getRandevular(tarih: String? = nil) async throws -> [Randevu] {
        var params: [String: Any] = [:]
        if let tarih = tarih {
            params["p_tarih"] = tarih
        }
        return try await postRpc(fnName: "tablet_randevulari_getir", parameters: params)
    }

    func getHastalar(arama: String? = nil) async throws -> [Hasta] {
        var params: [String: Any] = [:]
        if let arama = arama, !arama.isEmpty {
            params["p_arama"] = arama
        }
        return try await postRpc(fnName: "tablet_hastalari_getir", parameters: params)
    }

    func getWebRandevulari() async throws -> [WebRandevuTalep] {
        return try await postRpc(fnName: "tablet_web_randevulari_getir")
    }

    func hastaEkle(tc: String, ad: String, soyad: String, telefon: String, tani: String?, notlar: String?) async throws -> GenelSonuc {
        let params: [String: Any] = [
            "p_tc": tc,
            "p_ad": ad,
            "p_soyad": soyad,
            "p_telefon": telefon,
            "p_tani": tani as Any,
            "p_notlar": notlar as Any
        ]
        return try await postRpc(fnName: "tablet_hasta_ekle", parameters: params)
    }

    func randevuEkle(hastaId: Int, tarih: String, saat: String, ucret: Double, notlar: String?) async throws -> GenelSonuc {
        let params: [String: Any] = [
            "p_hasta_id": hastaId,
            "p_tarih": tarih,
            "p_saat": saat,
            "p_ucret": ucret,
            "p_notlar": notlar as Any
        ]
        return try await postRpc(fnName: "tablet_randevu_ekle", parameters: params)
    }

    func seansKaydet(hastaId: Int, ucret: Double, odenen: Double, islemler: String?, notlar: String?) async throws -> GenelSonuc {
        let params: [String: Any] = [
            "p_hasta_id": hastaId,
            "p_ucret": ucret,
            "p_odenen": odenen,
            "p_islemler": islemler as Any,
            "p_notlar": notlar as Any
        ]
        return try await postRpc(fnName: "tablet_seans_kaydet", parameters: params)
    }

    func hastaGecmisGetir(hastaId: Int) async throws -> HastaGecmisResponse {
        return try await postRpc(fnName: "tablet_hasta_seans_odeme_gecmisi", parameters: ["p_hasta_id": hastaId])
    }

    func webRandevuDurumGuncelle(id: Int, durum: String) async throws -> GenelSonuc {
        let params: [String: Any] = [
            "p_talep_id": id,
            "p_yeni_durum": durum
        ]
        return try await postRpc(fnName: "tablet_web_randevu_durum_guncelle", parameters: params)
    }
}

