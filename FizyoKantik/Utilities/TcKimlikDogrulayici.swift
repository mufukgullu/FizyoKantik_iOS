import Foundation

enum TcKimlikDogrulayici {
    static func dogrula(_ tc: String?) -> (gecerliMi: Bool, hataMesaji: String?) {
        guard let tc = tc?.trimmingCharacters(in: .whitespacesAndNewlines), !tc.isEmpty else {
            return (false, "T.C. Kimlik Numarası zorunludur.")
        }
        if tc.count != 11 {
            return (false, "T.C. Kimlik Numarası 11 haneli olmalıdır.")
        }
        if !tc.allSatisfy({ $0.isNumber }) {
            return (false, "T.C. Kimlik Numarası sadece rakamlardan oluşmalıdır.")
        }
        if tc.hasPrefix("0") {
            return (false, "T.C. Kimlik Numarası 0 ile başlayamaz.")
        }

        let digits = tc.compactMap { Int(String($0)) }
        guard digits.count == 11 else {
            return (false, "Geçersiz T.C. Kimlik Numarası.")
        }

        let tekler = digits[0] + digits[2] + digits[4] + digits[6] + digits[8]
        let ciftler = digits[1] + digits[3] + digits[5] + digits[7]
        var onuncu = ((tekler * 7) - ciftler) % 10
        if onuncu < 0 { onuncu += 10 }

        if onuncu != digits[9] {
            return (false, "Geçersiz T.C. Kimlik Numarası. Lütfen kontrol ediniz.")
        }

        let ilkOn = digits.prefix(10).reduce(0, +)
        if ilkOn % 10 != digits[10] {
            return (false, "Geçersiz T.C. Kimlik Numarası. Lütfen kontrol ediniz.")
        }

        return (true, nil)
    }

    static func gecerliMi(_ tc: String?) -> Bool {
        return dogrula(tc).gecerliMi
    }
}
