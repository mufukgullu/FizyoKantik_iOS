# FizyoKantik iOS / iPadOS

FizyoKantik Klinik & Seans Yönetim Portalı resmi iOS ve iPadOS yerel (native) SwiftUI uygulaması.

## Mimarisi
- **UI:** SwiftUI (Declarative, iOS 16+)
- **Backend:** Supabase PostgREST RPC
- **Cihaz Desteği:** iPad & iPhone (Universal)
- **CI/CD:** GitHub Actions Bulut macOS Runner + App Store Connect API + TestFlight

## Ekranlar & Yetenekler
1. **Oturum Yönetimi (Login):** Supabase `tablet_giris` kimlik denetimi ve oturum kalıcılığı.
2. **Klinik Durum Özeti (Dashboard):** Günlük randevular, aktif hastalar, yapılan seanslar ve bekleyen web talepleri.
3. **Randevu Takvimi:** Duruma göre filtreleme (Bekliyor, Geldi, İptal), saat/ücret takibi ve yeni randevu oluşturma.
4. **Hasta Dosyaları:** TC / Telefon / Ad arama, borç/bakiye görüntüleme, seans ve ödeme geçmişi.
5. **Hızlı Seans & Tahsilat:** Tek dokunuşla seans tamamlama ve borç/alacak güncelleme.
6. **Web Randevu Talepleri:** Web sitesinden gelen başvuruları inceleme, arama, WhatsApp mesajı atma ve randevuya dönüştürme.
7. **T.C. Kimlik Doğrulayıcı:** Resmi 11 haneli algoritma denetimi.
