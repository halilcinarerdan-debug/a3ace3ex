# TAC – Realism Pack (CBA_A3 + ACE3)

Tek bir mod (`@TAC`), tek bir PBO (`tac_main.pbo`). Yalnızca **CBA_A3** ve **ACE3** gerektirir;
RHS, Project OPFOR, ACM, LAMBS, ACRE2 ile birlikte kullanılır ama hiçbirine bağımlılık yoktur.
Mission dosyasına (`initPlayerLocal.sqf`, `description.ext` vb.) **hiçbir şey eklemek gerekmez**.

## Yol haritası

| # | Özellik | Durum |
|---|---------|-------|
| 1 | Taktiksel Not Defteri (ACE etkileşimli) | ✅ hazır |
| 2 | Gelişmiş NVG pili ve efektleri | ✅ hazır (test bekliyor) |
| 3 | Kalibreye göre dinamik recoil | ⏳ |
| 4 | Baskı altında artan sway | ⏳ |
| 5 | Mermi yakın geçiş (crack) + ekran efekti + HUD kapatma | ⏳ |
| 6 | Aiming deadzone / silah inertiası | ⏳ |

Her özelliğin kendi CBA "aktif" ayarı vardır; parça parça test ederken diğerlerini kapatabilirsin.

## Depo yapısı

Depo kökü, P: sürücüsünde `P:\z\tac` olacak şekilde konumlandırılır (aşağıya bak).

```
mod.cpp                                  @TAC kök klasörüne kopyalanır
addons/main/                             -> tac_main.pbo   (prefix: z\tac\addons\main)
    $PBOPREFIX$                          Mikero bu dosyadan prefix'i okur
    config.cpp                           CfgPatches, CfgFunctions, CBA XEH tanımı
    XEH_preInit.sqf                      tüm makineler: CBA ayarları
    XEH_postInit.sqf                     yalnızca istemci: modül kurulumları
    notebook/                            1. özellik
        CfgFunctions.hpp
        fn_notebookInitSettings.sqf      CBA ayarları (CBA_settings_fnc_init)
        fn_notebookInitActions.sqf       ACE self-action ağacı (sınıfa eklenir, moda göre)
        fn_notebookPostInit.sqf          CBA olay dinleyicileri
        fn_notebookCanUse.sqf            menü görünme koşulu (eşya, hayatta, bilinç)
        -- Basit mod --
        fn_notebookAddNote.sqf           "Not Al": anı yakala + ilerleme çubuğu
        fn_notebookStoreNote.sqf         yerel listeye yaz + CBA olayı
        fn_notebookShow.sqf              "Notları Oku": kaydırılabilir pencere
        fn_notebookFormatEntry.sqf       kayıt -> metin
        -- Gelişmiş mod --
        fn_notebookOpenPad.sqf           Notepad benzeri düz metin editörü
        fn_notebookPadSave.sqf           metni yerel depoya yazar + karakter sayacı
    nvg/                                 2. özellik
        CfgFunctions.hpp
        CfgWeapons.hpp                   TAC_NVGBattery, TAC_NVGBattery_Lithium (envanter eşyaları)
        fn_nvgInitSettings.sqf           CBA ayarları
        fn_nvgPostInit.sqf               "NVG Pil Değiştir" eylemi + CBA oyuncu olayları
        fn_nvgOnVisionMode.sqf           NVG açıldı/kapandı -> tüketimi başlat/durdur
        fn_nvgStart.sqf / fn_nvgStop.sqf PFH'yi başlatır/durdurur (yalnızca NVG açıkken)
        fn_nvgTick.sqf                   şarjı düşürür, efekt şiddetini hesaplar, test göstergesi
        fn_nvgApplyEffects.sqf           parazit (FilmGrain) + kararma/flicker (ColorCorrections)
        fn_nvgClearEffects.sqf           efektleri yok eder
        fn_nvgParseBatteryTable.sqf      "Pil tablosu" ayarını çözer (classname -> saat)
        fn_nvgGetHours.sqf               pil sınıfının ömrünü verir
        fn_nvgFindBattery.sqf            envanterde tablodaki ilk pili bulur
        fn_nvgSwapBattery.sqf            "NVG Pil Değiştir": cihazı kapat + ilerleme çubuğu
        fn_nvgSwapFinish.sqf             pili düş, şarjı %100 yap, sınıfı kaydet
        fn_nvgNotify.sqf                 bildirim yardımcısı
```

## Mikero ile derleme

1. Mikero araçlarını (**pboProject**, MakePbo, DePbo) ve P: sürücüsünü kur.
2. Depoyu `P:\z\tac` yoluna getir. Ya doğrudan oraya klonla ya da yönetici komut isteminde:
   ```bat
   mklink /J "P:\z\tac" "C:\yol\a3ace3ex"
   ```
   (`P:\z` klasörü önceden var olmalı.) Sonuçta `P:\z\tac\addons\main\config.cpp` bulunmalı.
3. pboProject'te kaynak klasör: `P:\z\tac\addons\main`, çıktı klasörü: `...\@TAC\addons`.
   Prefix, klasördeki `$PBOPREFIX$` dosyasından okunur (`z\tac\addons\main`).
4. `mod.cpp` dosyasını `...\@TAC\` köküne kopyala.
5. pboProject `requiredAddons` (cba_main, ace_main, ace_common, ace_interact_menu) bulunamadı diye uyarı verirse,
   CBA ve ACE PBO'larını DePbo ile P: sürücüsüne açman veya bu denetimi pboProject ayarlarından gevşetmen gerekir.
6. Dedicated sunucuda imza doğrulaması açıksa: Arma 3 Tools'taki `DSCreateKey` ile anahtar üret,
   PBO'yu `.biprivatekey` ile imzala (pboProject imzalama seçeneği veya `DSSignFile`) ve `.bikey` dosyasını sunucunun `keys/` klasörüne koy.
   **`.biprivatekey` dosyasını asla depoya koyma** (`.gitignore` zaten engeller).

Sonuç: `@TAC\addons\tac_main.pbo` (+ varsa `.bisign`) ve `@TAC\mod.cpp`.

## Kurulum / başlatma

```
-mod=@CBA_A3;@ace;@TAC
```

(RHS, Project OPFOR, ACM, LAMBS, ACRE2 yanına serbestçe eklenebilir; `@TAC`'ın CBA ve ACE'den sonra gelmesi yeterli.)
**Sunucu ve tüm oyuncular aynı sürümü yüklemelidir:** ayarlar sunucuda da kaydedildiği için sunucuda `@TAC` yoksa
global ayarlar senkronlanmaz ve force çalışmaz.

## Özellik 1 – Taktiksel Not Defteri

İki mod vardır; `TAC_notebook_mode` CBA ayarıyla seçilir (varsayılan: **Gelişmiş**) ve sunucudan zorlanabilir.
Menü yalnızca oyuncunun elinde/üstünde `ItemCompass` (veya ayarlanan eşya) varsa görünür.

### Gelişmiş mod – serbest yazı (Notepad)

**ACE self-interaction** (varsayılan: `Ctrl + Sol Windows`) → `Not Defteri` tek tıkla düz bir metin editörü açar.
Oyuncu istediğini yazar; süslü arayüz yok: bir yazı kutusu, başlıkta karakter sayacı, iki düğme.

- Metin her tuş bırakılışında yerel olarak saklanır. `ESC` veya `KAYDET VE KAPAT` ile kapanır; yeniden açınca kaldığın yerden devam edersin.
- `ZAMAN / KONUM EKLE`: metnin sonuna `[30.10 14:32 | Grid 123456 | 087° | 142 m ASL] ` ekler (basit moddaki otomatik kayıt).
- Pencere modaldır: yazarken WASD vb. oyunu etkilemez.
- Maksimum uzunluk `TAC_notebook_maxChars` ile sınırlıdır (varsayılan 5000 karakter), aşan kısım kesilir.

### Basit mod – otomatik kayıt

`Taktiksel Not Defteri` alt menüsü:

- **Not Al**: o anki oyun içi tarih/saat, grid koordinatı, yön (derece) ve irtifayı kaydeder.
  Ayarlardaki süre kadar ACE ilerleme çubuğu gösterir (varsayılan 2 sn).
- **Notları Oku**: kayıtları en yeni üstte olacak şekilde pencerede gösterir. `TEMİZLE` hepsini siler, `KAPAT`/`ESC` kapatır.

Bu mod, test edilip çalıştığı doğrulanan ilk sürümün (commit `f542715`) aynısıdır.

### CBA ayarları (`Options > Addon Options > TAC - Gerçekçilik Paketi`)

| Ayar | Varsayılan | Kapsam |
|------|-----------|--------|
| `TAC_notebook_enabled` | açık | global (force edilebilir) |
| `TAC_notebook_itemClass` | `ItemCompass` | global |
| `TAC_notebook_mode` | 1 = Gelişmiş (0 = Basit) | global |
| `TAC_notebook_maxChars` | 5000 (500–20000), yalnız Gelişmiş | global |
| `TAC_notebook_maxEntries` | 40 (5–100), yalnız Basit | global |
| `TAC_notebook_writeTime` | 2 sn (0–10), yalnız Basit | global |
| `TAC_notebook_clearOnDeath` | kapalı (iki modda da geçerli) | global |
| `TAC_notebook_notify` | açık, yalnız Basit | kişisel (istemci) |

Sunucudan zorlamak için sunucunun `userconfig/cba_settings.sqf` dosyasını (veya mission köküne `cba_settings.sqf`) kullan:

```sqf
force force TAC_notebook_enabled = true;
force force TAC_notebook_mode = 1;
force force TAC_notebook_itemClass = "ItemCompass";
force force TAC_notebook_writeTime = 3;
force force TAC_notebook_clearOnDeath = true;
```

### MP mantığı (server / client)

- **Ayarlar** `XEH_preInit` ile **tüm makinelerde** kaydedilir. Sunucu da kaydetmek zorundadır; global ayarları CBA sunucudan istemcilere senkronlar ve `force` ile kilitler.
- **Eylemler ve veri**: tamamen **istemci tarafı** (`XEH_postInit` içinde `hasInterface` kontrolü). ACE menüsü yerel arayüzdür; notlar yalnızca o oyuncunun `missionNamespace`'inde durur ve ağa **yayınlanmaz**. Sunucuya yük sıfır; döngü, `waitUntil` ya da `onEachFrame` yok.
- **Respawn / JIP**: eylemler `CAManBase` sınıfına bir kez eklenir (ACE kalıtımla tüm askerlere uygular), self-menü zaten yalnızca oyuncunun kendi birimi için açılır. Bu yüzden respawn, JIP, `selectPlayer` sonrası eylemleri yeniden eklemek gerekmez.
  `Ölünce notlar silinsin` ayarı CBA `"unit"` oyuncu olayıyla işler (eski birim ölüyse, respawn sayılır).
- Gelişmiş modda yazılan metin de aynı şekilde yalnızca istemcide (`TAC_notebook_text`) durur, ağa yayınlanmaz.
- Notlar/metin bağlantı kopunca sıfırlanır (kalıcılık gerekirse sonraki adımda eklenebilir).

### Test adımları

Mission dosyası gerekmez; mod her mission'da çalışır.

1. `@TAC` ile oyunu başlat. Ana menüde `Options > Addon Options` içinde **TAC - Gerçekçilik Paketi** kategorisi görünmeli.
2. Eden'de bir oyuncu birimi koy ve `Play Scenario`. Debug konsolunda (yerel çalıştır) yükleme kontrolü:
   - `isClass (configFile >> "CfgPatches" >> "tac_main")` → `true`
   - `isNil "TAC_fnc_notebookShow"` → `false`
3. **Gelişmiş mod** (varsayılan): `Ctrl + Sol Windows` → **Not Defteri**. Editör açılır; bir şeyler yaz, `ZAMAN / KONUM EKLE`'ye bas,
   `ESC` ile kapat, tekrar aç: metin duruyor olmalı. Ham veri: `TAC_notebook_text`.
   Yazarken karakterin hareket etmediğini ve başlıktaki sayacın arttığını kontrol et.
   Sınır testi: debug konsolunda `TAC_notebook_maxChars = 500;` yapıp 500'den fazla yazmayı dene, fazlası kesilmeli.
4. **Basit mod**: `Options > Addon Options > TAC` içinde `Not defteri modu`nu Basit yap (ayar anında uygulanır).
   `Taktiksel Not Defteri` → **Not Al** → ilerleme çubuğu → onay mesajı. **Notları Oku** ile kaydı gör. Ham veri: `TAC_notebook_entries`.
5. Eşya kontrolü: `player unlinkItem "ItemCompass"` → menü kaybolmalı; `player linkItem "ItemCompass"` → geri gelmeli.
6. Respawn: Eden'de `Play Scenario in Multiplayer` ile, oyuncu birimi özelliklerinde / mission ayarlarında respawn aç, konsolda `player setDamage 1`.
   Yeniden doğunca menü yine görünmeli ve notlar/metin duruyor olmalı. `Ölünce notlar silinsin` ayarını açıp tekrar dene: defter boş gelmeli.
   Editör açıkken ölürsen pencere kapanmalı.
7. Gerçek MP (host veya dedicated + en az 2 istemci): A oyuncusu yazınca B'nin defteri boş kalmalı (notlar kişiye özel).
   `cba_settings.sqf` ile `force` ettiğin ayar (örn. `TAC_notebook_mode`) istemcide kilitli görünmeli.
8. Hata varsa `%LOCALAPPDATA%\Arma 3\*.rpt` içinde script hatalarına ve `TAC_` geçen satırlara bak (`-showScriptErrors` ile başlat).

> Not: Menü ikonları vanilla `ui_f` yollarıdır. Biri bulunamazsa yalnızca ikon boş kalır ve RPT'ye uyarı düşer; işlev etkilenmez.
> Script değişikliği sonrası PBO'yu yeniden derle; oyun açıkken PBO değiştirilemez.

## Özellik 2 – Gelişmiş NVG Pili

NVG açıkken pil azalır; %20'nin altında görüntüde **parazit** ve **kararma/flicker** başlar, %0'da cihaz kapanır.
Pil, envanterdeki **NVG Bataryası** eşyasıyla ACE self-menüsünden değiştirilir.

### Nasıl çalışır

- **Şarj** yüzde olarak (100 → 0) birimin üzerinde yerel tutulur (`TAC_nvg_charge`). Respawn'da yeni beden otomatik %100 başlar. Mission başında herkes dolu pille başlar.
- **Tüketim yalnızca NVG açıkken** (görüş modu 1 ve `hmd` dolu) işler. CBA `"visionMode"` oyuncu olayı döngüyü başlatır/durdurur; döngü (0.25 sn'lik PFH) sadece NVG açıkken vardır, kapalıyken sıfır maliyet.
- **Pil ömrü (gerçek dakika)** = `pil saati × (1 pil saati = kaç dk)`. Varsayılan: 40 sa × 1 dk = **40 dakika** NVG kullanımı.
- **Düşük pil:** şarj eşiğin (varsayılan %20) altına inince `şiddet = 1 − şarj/eşik` (eşikte 0, şarj 0'da 1).
  Şiddet arttıkça parazit (FilmGrain) güçlenir, kalıcı kararma artar ve ani sönmeler (flicker) sıklaşıp derinleşir.
- **Pil bitince** (%0) NVG kapanır ve yeni pil takılana kadar açılmaz.
- **NVG Pil Değiştir** (ACE self-menü): NVG takılıyken ve envanterde tablodaki bir pil varken görünür. Cihaz kapatılır, ilerleme çubuğu dolar, eski pil atılır, yenisi envanterden düşer, şarj %100 olur.

### Pil eşyaları ve sınıf bazlı ömür

| Eşya | Varsayılan ömür |
|------|-----------------|
| `TAC_NVGBattery` – NVG Bataryası (AA) | 40 saat |
| `TAC_NVGBattery_Lithium` – NVG Bataryası (AA Lityum) | 60 saat |

Ömürler eşyanın içinde değil, CBA ayarındaki **Pil tablosu**ndadır (`TAC_nvg_batteryTable`), böylece sunucudan zorlanabilir:

```
TAC_NVGBattery=40; TAC_NVGBattery_Lithium=60; baskaMod_Pil=25
```

- Biçim: `classname=gerçek saat`, girişler `;` ile ayrılır. Başka modların eşyaları da yazılabilir.
- **Sıra öncelik sırasıdır:** pil değiştirirken envanterde bulunan *ilk* pil kullanılır.
- Takılı pilin sınıfı birimde saklanır; tüketim hızı o sınıfın ömrüne göre belirlenir. Tabloda olmayan veya başlangıçtaki pil için **Varsayılan pil ömrü** geçerlidir.
- Geçersiz girişler (sayı değil, saat ≤ 0) atlanır. Tablo boşsa `TAC_NVGBattery` varsayılan kullanılır.

Pili almak için: Arsenal/loadout veya `player addItem "TAC_NVGBattery"`. Mission'a pil koymak için Eden'de sandık envanterine eşya ekleyebilir veya loadout'a yazabilirsin.

### CBA ayarları (`Options > Addon Options > TAC - Gerçekçilik Paketi > NVG Pili`)

| Ayar | Varsayılan | Kapsam |
|------|-----------|--------|
| `TAC_nvg_enabled` | açık | global |
| `TAC_nvg_batteryHours` | 40 sa (1–100): başlangıç/tabloda olmayan pil | global |
| `TAC_nvg_batteryTable` | `TAC_NVGBattery=40; TAC_NVGBattery_Lithium=60` | global |
| `TAC_nvg_minutesPerHour` | 1 (0.1–60): 1 pil saati = kaç gerçek dk | global |
| `TAC_nvg_lowThreshold` | %20 | global |
| `TAC_nvg_noiseMax` | 0.8 (0–2) | global |
| `TAC_nvg_flickerMax` | 0.7 (0–1) | global |
| `TAC_nvg_swapTime` | 3 sn (0–15) | global |
| `TAC_nvg_testMode` | kapalı | global |
| `TAC_nvg_testSpeed` | ×60 (1–600) | global |
| `TAC_nvg_notify` | açık | kişisel (istemci) |

Sunucudan zorlamak için `cba_settings.sqf`:

```sqf
force force TAC_nvg_enabled = true;
force force TAC_nvg_batteryTable = "TAC_NVGBattery=40; TAC_NVGBattery_Lithium=60";
force force TAC_nvg_minutesPerHour = 1;
force force TAC_nvg_lowThreshold = 20;
force force TAC_nvg_testMode = false;
```

### Test modu

`TAC_nvg_testMode` açıkken pil ömrü `TAC_nvg_testSpeed`'e bölünür; **sınıflar arası fark korunur**.
×60 ile standart pil 40 sn, lityum 60 sn sürer. NVG açıkken ekranda şu bilgi görünür ve yerinde güncellenir:

```
[TEST] NVG pili
Şarj: 63.4%
Pil: TAC_NVGBattery
Ömür: 40 sn (x60)
Kalan: 25 sn
```

Üretimde (ve sunucuda) test modunu kapalı bırak.

### Test adımları

1. Eden'de `Play Scenario`. Debug konsolunda (yerel çalıştır):
   ```sqf
   player linkItem "NVGoggles"; player addItem "TAC_NVGBattery"; player addItem "TAC_NVGBattery_Lithium";
   ```
2. Addon Options'ta **Test modu**nu aç (×60). `N` ile NVG'yi aç: "NVG pili: 100%" bildirimi ve test göstergesi gelmeli, şarj düşmeli.
3. Şarj %20'nin altına inince "NVG pili zayıf" uyarısı, parazit ve kararma/flicker başlamalı; %0'da NVG kapanmalı. `N` ile tekrar açmayı dene: açılmamalı ("NVG pili bitmiş").
4. `Ctrl + Sol Windows` → **NVG Pil Değiştir** → ilerleme çubuğu → şarj %100, envanterden bir pil düşmeli, efektler kaybolmalı. Hangi pilin takıldığını test göstergesindeki `Pil:` satırından gör.
5. **Sınıf bazlı ömür:** envanterden `TAC_NVGBattery`'yi at (`player removeItem "TAC_NVGBattery"`), lityumu tak ve ömrün 60 sn göründüğünü doğrula. Tablodaki sayıyı değiştirip (`TAC_NVGBattery=20; ...`) ömrün değiştiğini gör. Tablodaki sıranın önceliği: iki pil varken ilk yazılan takılır.
6. Hızlı manuel kontrol: `ACE_player setVariable ["TAC_nvg_charge", 22];` ile şarjı doğrudan ayarlayıp eşiği test et. Şarjı okumak için: `ACE_player getVariable ["TAC_nvg_charge", 100]`.
7. Test modunu kapatıp `TAC_nvg_minutesPerHour`'u küçültmek de (örn. 0.1) gerçek formülü hızlı doğrular.
8. Respawn: `player setDamage 1`; yeni bedende şarj %100 olmalı, efektler temizlenmeli.
9. MP: efektler ve şarj kişiye özeldir; A oyuncusunun NVG'si B'yi etkilemez. Sunucuda `cba_settings.sqf` ile `force` ettiğin değerler istemcide kilitli görünmeli.

### MP mantığı (NVG)

- Ayarlar `XEH_preInit` ile tüm makinelerde kaydedilir; pil tablosu değişince CBA her makinede çözümleyiciyi çalıştırır.
- Şarj, takılı pil, efektler ve döngü **tamamen istemcidedir**; ağa hiçbir şey yayınlanmaz. Sunucuya yük sıfır.
- `TAC_NVGBattery*` eşyaları `config.cpp`'dedir: **sunucuda da yüklü olmaları gerekir** (envanter eşyaları iki tarafta da bilinmeli).

### Sorun giderme (NVG pili)

"NVG Pil Değiştir" görünmüyor veya pil yenilenmiyorsa debug konsolunda (**Yerel çalıştır**):

```sqf
call TAC_fnc_nvgDebug
```

Rapor ekranda görünür, panoya kopyalanır (Ctrl+V) ve RPT'ye `[TAC][NVG-DEBUG]` olarak yazılır. İlk satır eylemin görünüp görünmemesi gerektiğini söyler; altındaki satırlar hangi koşulun tutmadığını gösterir:

| Satır | Anlamı |
|-------|--------|
| `Surum (yuklu PBO)` | oyunda yüklü PBO'nun sürümü. Eski PBO'da `TAC_fnc_nvgDebug` hiç yoktur ("undefined" hatası = eski PBO) |
| `Son pil degistirme` | son denemenin sonucu: `BASARILI`, `BASARISIZ` (nedeniyle), `IPTAL` veya `BASLAMADI` |
| `sistem aktif / hayatta / bilinci açık` | hepsi `true` olmalı |
| `meşgul değil` | `false` ise önceki değiştirme takılı kalmıştır (en fazla süre + 3 sn sonra kendiliğinden düzelir) |
| `NVG takılı (hmd)` | `false` ise NVG kafada değildir; eylem yalnızca NVG takılıyken görünür |
| `envanterde tablodaki pil` | `''` ise pil envanterde yok ya da sınıf adı tablodakiyle uyuşmuyor |
| `Envanterde TAC_ eşyaları` | envanterdeki `TAC_...` eşyaları; boşsa `addItem` eşyayı eklememiş (envanter dolu olabilir) |
| `Config: TAC_NVGBattery ...` | `false` ise PBO eski/yanlış derlenmiş; eşya config'te yok |

RPT'de ayrıca şu satırlar çıkar (arama: `[TAC][NVG]`):

- Açılışta: `hazir | pil 'TAC_NVGBattery': config true (scope 2) | omur 40 saat`
- Her pil değiştirmede: `pil degistirme istendi ...`, ardından `pil degistirildi ...` veya `basarisiz ...` ile nedeni.

Pil çıkarılamazsa şarj **yenilenmez** ve ekranda "NVG bataryası envanterden çıkarılamadı." görünür (bedava pil olmaz).

### Notlar

- Tüketim, **görüş modu 1** olduğu sürece işler. `hmd` boşsa (NVG takılı değilse) işlemez; silah üstü NV optiği de görüş modu 1 verebilir.
- Parazit ve kararma için ACE'nin `ace_nightvision_noiseScaling` değerini sürmek yerine kendi PP katmanlarımı (FilmGrain + ColorCorrections) kullandım. ACE'nin iç fonksiyonunu tahminle çağırmak yanlış parametrede RPT hatası/sessiz başarısızlık riski taşır. Efektler ACE'nin kendi NVG efektlerinin **üstüne** biner.
- `picture` yolu (`itemacc_ca.paa`) vanilla arsenal ikonudur. pboProject "dosya bulunamadı" derse A3 verisini P: sürücüsüne aç veya `CfgWeapons.hpp` içindeki `picture` satırını sil.

## Yeni özellik ekleme

1. `addons/main/<özellik>/` klasörü aç; `fn_*.sqf` dosyalarını ve bir `CfgFunctions.hpp` ekle (`notebook/`, `nvg/` örnek). Envanter eşyası gerekiyorsa `CfgWeapons.hpp` de ekle.
2. `config.cpp` içindeki `CfgFunctions > TAC` bloğuna `#include "<özellik>\CfgFunctions.hpp"` satırını ekle (eşya varsa `CfgWeapons` bloğuna da).
3. Ayarlar için `XEH_preInit.sqf`'e, istemci kurulumu için `XEH_postInit.sqf`'e modülün giriş fonksiyonunu ekle.
4. Her modülün kendi `TAC_<özellik>_enabled` CBA ayarı olsun.
