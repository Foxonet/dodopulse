# SystemPulse

🇬🇧 [English](README.md)

macOS menü çubuğunda gerçek zamanlı sistem metriklerini güzel mini grafiklerle gösteren hafif, yerli bir macOS uygulaması.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Lisans](https://img.shields.io/badge/Lisans-MIT-green)

## Özellikler

- **CPU izleme** - Kullanım yüzdesi, sıcaklık, çekirdek başına takip ve geçmiş grafiği
- **Bellek izleme** - Kullanılan/boş bellek, aktif/wired/sıkıştırılmış dağılımı
- **GPU izleme** - Kullanım yüzdesi, sıcaklık, geçmiş grafiği
- **Ağ izleme** - İndirme/yükleme hızları, yerel ve genel IP, oturum toplamları
- **Disk izleme** - Kullanım yüzdesi, boş alan, birim adı
- **Pil izleme** - Şarj seviyesi, şarj durumu, kalan süre
- **Fan izleme** - Her fan için RPM (varsa)
- **Sistem bilgisi** - Yük ortalaması, işlem sayısı, swap kullanımı, kernel sürümü, çalışma süresi

### Etkileşimli özellikler

- Tıklanabilir bir ok görmek için herhangi bir kartın üzerine **gelin**
- İlgili sistem uygulamasını açmak için **tıklayın** (Etkinlik İzleyici, Disk İzlencesi, Sistem Ayarları vb.)
- Hızlı menü için menü çubuğu simgesine **sağ tıklayın**

## Ekran Görüntüleri

Uygulama, canlı güncellenen mini grafiklerle şık bir koyu panel görüntüler:

```
┌─────────────────────────────────┐
│ SystemPulse PRO        ↑ 2g 5s │
├─────────────────────────────────┤
│ 12.5%  CPU                 ▁▃▅▂ │
│ M2 Pro • 12 çekirdek   42°C    │
├─────────────────────────────────┤
│ 67.2%  Bellek              ▅▆▇▆ │
│ 10.8 / 16 GB                   │
├─────────────────────────────────┤
│ 8%     GPU                 ▁▁▂▁ │
│ M2 Pro                         │
├─────────────────────────────────┤
│ ↓ 1.2 MB/s  Ağ          ▂▄▁▃ │
│ ↑ 256 KB/s                     │
├─────────────────────────────────┤
│ 85%    Disk                    │
│ 500 GB'den 120 GB boş          │
├─────────────────────────────────┤
│ 72%    Pil                     │
│ 2s 30dk kaldı                  │
└─────────────────────────────────┘
```

## Gereksinimler

- macOS 14.0 (Sonoma) veya üzeri
- Apple Silicon veya Intel Mac

## Kurulum

### Seçenek 1: Kaynaktan derleme

1. Depoyu klonlayın:
   ```bash
   git clone https://github.com/bluewave-labs/systempulse.git
   cd systempulse
   ```

2. Uygulamayı derleyin:
   ```bash
   swiftc -O -o SystemPulse SystemPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. Çalıştırın:
   ```bash
   ./SystemPulse
   ```

### Seçenek 2: Uygulama paketi oluşturma (isteğe bağlı)

SystemPulse'ın düzgün bir macOS uygulaması olarak görünmesini istiyorsanız:

1. Uygulama yapısını oluşturun:
   ```bash
   mkdir -p SystemPulse.app/Contents/MacOS
   cp SystemPulse SystemPulse.app/Contents/MacOS/
   ```

2. `SystemPulse.app/Contents/Info.plist` dosyasını oluşturun:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>CFBundleExecutable</key>
       <string>SystemPulse</string>
       <key>CFBundleIdentifier</key>
       <string>com.bluewave.systempulse</string>
       <key>CFBundleName</key>
       <string>SystemPulse</string>
       <key>CFBundleVersion</key>
       <string>1.0</string>
       <key>LSMinimumSystemVersion</key>
       <string>14.0</string>
       <key>LSUIElement</key>
       <true/>
   </dict>
   </plist>
   ```

3. Uygulamalar klasörüne taşıyın (isteğe bağlı):
   ```bash
   mv SystemPulse.app /Applications/
   ```

### Seçenek 3: Automator ile çalıştırma (önerilen)

Bu yöntem, SystemPulse'ın Terminal'den bağımsız çalışmasını sağlar, böylece Terminal'i kapattıktan sonra bile çalışmaya devam eder.

1. Önce SystemPulse'ı derleyin (yukarıdaki Seçenek 1'e bakın)

2. **Automator**'ı açın (Spotlight'ta arayın)

3. **Yeni Belge**'ye tıklayın ve **Uygulama**'yı seçin

4. Arama çubuğuna "Kabuk Betiği Çalıştır" yazın ve iş akışı alanına sürükleyin

5. Varsayılan metni SystemPulse binary'nizin tam yolu ile değiştirin:
   ```bash
   /yol/systempulse/SystemPulse
   ```
   Örneğin, ana klasörünüze klonladıysanız:
   ```bash
   ~/systempulse/SystemPulse
   ```

6. **Dosya** > **Kaydet**'e gidin ve Uygulamalar klasörünüze "SystemPulse" olarak kaydedin

7. SystemPulse'ı çalıştırmak için kaydedilen Automator uygulamasına çift tıklayın

**İpucu**: Artık bu Automator uygulamasını Giriş Öğelerinize ekleyerek SystemPulse'ı açılışta otomatik başlatabilirsiniz:
1. **Sistem Ayarları** > **Genel** > **Giriş Öğeleri**'ni açın
2. **+**'ya tıklayın ve SystemPulse Automator uygulamanızı seçin

### Girişte başlat (alternatif)

Bir uygulama paketi oluşturduysanız (Seçenek 2), doğrudan Giriş Öğelerine ekleyebilirsiniz:

1. **Sistem Ayarları** > **Genel** > **Giriş Öğeleri**'ni açın
2. **+**'ya tıklayın ve SystemPulse.app'i ekleyin

## Kullanım

Çalıştırıldığında, SystemPulse menü çubuğunuzda CPU ve bellek kullanımını gösteren bir simge olarak görünür.

- Ayrıntılı paneli açmak için menü çubuğu öğesine **sol tıklayın**
- Çıkış seçeneği olan hızlı menü için **sağ tıklayın**
- Ok göstergesini görmek için herhangi bir metrik kartının üzerine **gelin**
- İlgili sistem uygulamasını açmak için bir karta **tıklayın**

### Kart tıklama eylemleri

| Kart | Açılan Uygulama |
|------|-----------------|
| CPU | Etkinlik İzleyici |
| Bellek | Etkinlik İzleyici |
| GPU | Sistem Bilgisi |
| Ağ | Ağ Ayarları |
| Disk | Disk İzlencesi |
| Pil | Pil Ayarları |
| Fanlar | Sistem Bilgisi |
| Sistem | Etkinlik İzleyici |

## Teknik detaylar

SystemPulse, doğru metrikler için yerli macOS API'lerini kullanır:

- **CPU**: `host_processor_info()` Mach API
- **Bellek**: `host_statistics64()` Mach API
- **GPU**: IOKit `IOAccelerator` servisi
- **Ağ**: Arayüz istatistikleri için `getifaddrs()`
- **Pil**: IOKit'ten `IOPSCopyPowerSourcesInfo()`
- **Sıcaklık/Fanlar**: IOKit aracılığıyla SMC (Sistem Yönetim Denetleyicisi)

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen bir pull request göndermekten çekinmeyin.

## Lisans

MIT Lisansı - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## Teşekkürler

Yerli macOS performansı için Swift ve AppKit ile geliştirilmiştir.
