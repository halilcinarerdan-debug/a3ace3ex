# TAC – Realism Pack (CBA_A3 + ACE3)

Tek bir mod (`@TAC`), tek bir PBO (`tac_main.pbo`). Yalnızca **CBA_A3** ve **ACE3** gerektirir;
RHS, Project OPFOR, ACM, LAMBS, ACRE2 ile birlikte kullanılır ama hiçbirine bağımlılık yoktur.
Mission dosyasına (`initPlayerLocal.sqf`, `description.ext` vb.) **hiçbir şey eklemek gerekmez**.

## Yol haritası

| # | Özellik | Durum |
|---|---------|-------|
| 1 | Taktiksel Not Defteri (ACE etkileşimli) | ✅ hazır |
| 2 | Gelişmiş NVG pili ve efektleri | ✅ hazır (test bekliyor) |
| 3 | Kalibreye göre dinamik recoil | ✅ hazır (test bekliyor) |
| 4 | Baskı altında artan sway | ✅ hazır (test bekliyor) |
| 5 | Mermi yakın geçiş (crack) + patlama + ekran efekti + HUD kapatma | ✅ hazır (test bekliyor) |
| 6 | Silah bakım ve arıza (tüfek + MG): kir, yağ, aşınma, ACE arızası | ✅ hazır (test bekliyor) |
| 7 | MG: namlu ısısı ve sıcak namlu değiştirme, kayış/kapak | ⏳ |
| 8 | Optik: buğulanma, kirlenme | ⏳ |
| 9 | Roket atar / RPG: hazırlık, ateşlenmeme, misfire prosedürü | ⏳ |

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
        fn_nvgDebug.sqf                  teşhis (call TAC_fnc_nvgDebug)
    recoil/                              3. özellik
        CfgFunctions.hpp
        fn_recoilInitSettings.sqf        CBA ayarları (kategoriler, çarpanlar, tavan)
        fn_recoilPostInit.sqf            CBA oyuncu olayları (unit/weapon/muzzle/vehicle)
        fn_recoilAttach.sqf              oyuncuya Fired/Reloaded dinleyicisi bağlar
        fn_recoilUpdate.sqf              mühimmattan çarpanı hesaplar, setUnitRecoilCoefficient
        fn_recoilGetCategory.sqf         enerji -> kategori (istisna tablosu dahil)
        fn_recoilGetEnergy.sqf           mühimmat -> kinetik enerji (önbellekli)
        fn_recoilParseOverrides.sqf      istisna tablosunu çözer
        fn_recoilRefresh.sqf             ayar değişince yeniden hesapla
        fn_recoilDebug.sqf               teşhis (call TAC_fnc_recoilDebug)
    stress/                              4. özellik
        CfgFunctions.hpp
        fn_stressInitSettings.sqf        CBA ayarları
        fn_stressPostInit.sqf            "TAC_suppressed" dinleyicisi + CBA "unit" olayı
        fn_stressAttach.sqf              oyuncuya "Suppressed" EH bağlar -> TAC_suppressed olayı
        fn_stressOnSuppressed.sqf        mermi geçişi -> stres seviyesi artışı
        fn_stressResolveVar.sqf          sway değişkenini bulur (ace_common_swayFactor vb.)
        fn_stressTick.sqf                seviyeyi düşürür, çarpanı uygular (yalnızca stres varken)
        fn_stressReset.sqf               temel değeri geri yazar, döngüyü kaldırır
        fn_stressDebug.sqf               teşhis (call TAC_fnc_stressDebug)
    crack/                               5. özellik
        CfgFunctions.hpp
        fn_crackInitSettings.sqf         CBA ayarları
        fn_crackPostInit.sqf             "TAC_suppressed" dinleyicisi + CBA "unit" olayı + ACE firlatma olayi
        fn_crackAttach.sqf               oyuncuya Explosion / Fired / FiredNear baglar
        fn_crackTrack.sqf                patlayici mermiyi izler, patlama noktasini bulur
        fn_crackBlast.sqf                mesafe + engel -> siddet, efekti baslatir
        fn_crackOnSuppressed.sqf         koşullar: mesafe, hız (>343 m/s), dost, bekleme
        fn_crackStart.sqf                blur + vignette + HUD gizleme, zamanlayıcılar
        fn_crackEnd.sqf                  temizlik + HUD'u geri yükleme
        fn_crackDebug.sqf                teşhis (call TAC_fnc_crackDebug)
    weapon/                              6. özellik
        CfgFunctions.hpp / CfgWeapons.hpp  bakım malzemesi eşyaları (kit, yağ, yedek parça)
        fn_wpnInitSettings.sqf           CBA ayarları
        fn_wpnPostInit.sqf               "unit" olayı, ace_weaponJammed dinleyicisi, ACE "Silah Bakımı" menüsü
        fn_wpnOnFired.sqf                her atışta kir/yağ/aşınma + arıza zarı (oyuncuya bağlı Fired)
        fn_wpnJamChance.sqf              arıza ihtimali formülü
        fn_wpnCategory.sqf / fn_wpnGetState.sqf / fn_wpnEnvFactor.sqf   kategori, durum, ortam
        fn_wpnClean / wpnLube / wpnClearJam / wpnReplaceParts / wpnInspect   bakım eylemleri ve kart
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
- **ACE self-menü > NVG Pili** (NVG takılıyken görünür):
  - **Pil durumu:** takılı pilin şarjı, tahmini kalan kullanım (pil saati ve oyunda dakika), tüketim çarpanı ve envanterdeki yedek piller. Yazı kartı, ayrı pencere yok.
  - **Pil tak / değiştir:** envanterdeki her pil türü (ve kısmen kullanılmış kademe) ayrı satır. Seçilen takılır, **eski pil kalan şarjıyla envantere geri döner** (yer yoksa yere düşer).
  - **Pili çıkar:** pil söküldüğünde NVG pilsiz kalır, yeni pil takılana kadar açılmaz.

### Kısmen kullanılmış piller (v0.8)

Eşyalar şarj tutamadığı için sökülen pil, kalan şarjına göre **kademeli sınıfa** döner. Kademeler her zaman **aşağı** yuvarlanır (pil bedava yenilenemez):

| Kalan şarj | Envantere dönen |
|-----------|-----------------|
| %97+ | dolu pil (ana sınıf) |
| %72-97 | `..._p75` (~%75) |
| %47-72 | `..._p50` (~%50) |
| %22-47 | `..._p25` (~%25) |
| %7-22 | `..._p10` (~%10) |
| %7 altı | `TAC_NVGBattery_Dead` (bitik pil, kullanılamaz) |

Kademe sınıfları (`TAC_NVGBattery_p50`, `TAC_NVGBattery_Lithium_p25` ...) arsenal'de gizlidir. Başka modların pilleri pil tablosuna yazılabilir ama kademesi yoktur:
%97 üstü iade edilir, altı tükenmiş sayılıp atılır. Config alanları: `TAC_base` (ana sınıf), `TAC_charge` (taşıdığı şarj), `TAC_coldK` (soğuk hassasiyeti).

### Gerçekçilik ayarları (v0.8)

- **Cihaz tüketim çarpanı** (`TAC_nvg_deviceTable`, `classname=çarpan, ...`): takılı NVG'nin pil tüketimini ölçekler. Varsayılan: ENVG tipi gözlükler (`NVGogglesB_*_F`) 1.5. Tabloda olmayan cihaz 1.
- **Soğukta kapasite** (`TAC_nvg_cold`): ACE hava durumu açıksa `kapasite = 1 - TAC_coldK x (20 - sıcaklık)` (alt sınır 0.25), tüketim `1/kapasite` katına çıkar. Alkalin 0.012 (0 °C'de ~%76), lityum 0.003. ACE hava durumu yoksa 20 °C sayılır, etkisizdir.
- **Voltaj düşümü** (`TAC_nvg_sag`): şarjın son %15'inde tüketim 1x'ten 2x'e hızlanır.

### Pil eşyaları ve sınıf bazlı ömür

| Eşya | Varsayılan ömür |
|------|-----------------|
| `TAC_NVGBattery` – NVG Bataryası (AA) | 40 saat |
| `TAC_NVGBattery_Lithium` – NVG Bataryası (AA Lityum) | 60 saat |

Ömürler eşyanın içinde değil, CBA ayarındaki **Pil tablosu**ndadır (`TAC_nvg_batteryTable`), böylece sunucudan zorlanabilir:

```
TAC_NVGBattery=40, TAC_NVGBattery_Lithium=60, baskaMod_Pil=25
```

- Biçim: `classname=gerçek saat`, girişler `,` ile ayrılır (`;` kullanma: CBA ayar dosyasında komut ayracıdır, import bozulur). Başka modların eşyaları da yazılabilir.
- **Sıra öncelik sırasıdır:** pil değiştirirken envanterde bulunan *ilk* pil kullanılır.
- Takılı pilin sınıfı birimde saklanır; tüketim hızı o sınıfın ömrüne göre belirlenir. Tabloda olmayan veya başlangıçtaki pil için **Varsayılan pil ömrü** geçerlidir.
- Geçersiz girişler (sayı değil, saat ≤ 0) atlanır. Tablo boşsa `TAC_NVGBattery` varsayılan kullanılır.

Pili almak için: Arsenal/loadout veya `player addItem "TAC_NVGBattery"`. Mission'a pil koymak için Eden'de sandık envanterine eşya ekleyebilir veya loadout'a yazabilirsin.

### CBA ayarları (`Options > Addon Options > TAC - Gerçekçilik Paketi > NVG Pili`)

| Ayar | Varsayılan | Kapsam |
|------|-----------|--------|
| `TAC_nvg_enabled` | açık | global |
| `TAC_nvg_batteryHours` | 40 sa (1–100): başlangıç/tabloda olmayan pil | global |
| `TAC_nvg_batteryTable` | `TAC_NVGBattery=40, TAC_NVGBattery_Lithium=60` | global |
| `TAC_nvg_deviceTable` | `NVGogglesB_blk_F=1.5, NVGogglesB_grn_F=1.5, NVGogglesB_gry_F=1.5` | global |
| `TAC_nvg_cold` | açık | global |
| `TAC_nvg_sag` | açık | global |
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
force force TAC_nvg_batteryTable = "TAC_NVGBattery=40, TAC_NVGBattery_Lithium=60";
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
4. `Ctrl + Sol Windows` → **NVG Pili** → **Pil tak / değiştir** → listeden bir pil → ilerleme çubuğu → şarj pilin taşıdığı değere ayarlanmalı, seçilen pil envanterden düşmeli, **eski pil kalan şarjına uygun kademede envantere dönmeli** (ör. %50 kalmışsa "~%50"). Hangi pilin takıldığını test göstergesindeki `Pil:` satırından gör.
4b. **Pili çıkar:** NVG pilsiz kalır, `N` ile açılmaz; pil envantere kalan şarjıyla döner. **Pil durumu** kartı şarjı ve yedekleri göstermeli.
4c. **Kısmi pil:** `player addItem "TAC_NVGBattery_p50"` ile ~%50'lik pil ekle, tak: şarj %50 olmalı. Şarjı `ACE_player setVariable ["TAC_nvg_charge", 3]` ile %3 yapıp pili çıkar: "bitik pil" gelmeli.
4d. **Soğuk:** `ace_weather_currentTemperature = -10` ile (`call TAC_fnc_nvgDebug` çarpanı gösterir) alkalin pilde tüketim ~1.5x, lityumda ~1.04x olmalı.
5. **Sınıf bazlı ömür:** envanterden `TAC_NVGBattery`'yi at (`player removeItem "TAC_NVGBattery"`), lityumu tak ve ömrün 60 sn göründüğünü doğrula. Tablodaki sayıyı değiştirip (`TAC_NVGBattery=20, ...`) ömrün değiştiğini gör. Tablodaki sıranın önceliği: iki pil varken ilk yazılan takılır.
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

## Özellik 3 – Kalibreye göre dinamik recoil

Mühimmatın **kinetik enerjisine** göre 5 kategori; her kategori için **tek bir çarpan**. Çarpan silahın
**mevcut recoil'inin üstüne** biner (config + ACE + A3RO değerleri korunur; `setUnitRecoilCoefficient`).

| Kat. | Sınıf | Enerji (varsayılan) | Tipik mühimmat | Çarpan |
|------|-------|---------------------|----------------|--------|
| 1 | Tabanca / PDW | < 1000 J | 9mm, .45, 5.7 | x1.2 |
| 2 | Hafif | 1000–1950 J | 5.56, 5.45, 5.8 | x1.5 |
| 3 | Orta | 1950–3000 J | 7.62x39, 6.5 | x1.9 |
| 4 | Ağır | 3000–5500 J | 7.62x51, 7.62x54R | x2.4 |
| 5 | Aşırı | >= 5500 J | .338, .50 | x2.9 |

- **Enerji:** `E = 0.5 · kütle · hız²`; kütle `CfgAmmo >> ACE_bulletMass` (grain), hız `typicalSpeed`.
  ACE kütlesi yoksa `hit² · 20` ile tahmin edilir. Roket, bomba atar, havan gibi **mermi olmayan** mühimmatta
  ve araç silahlarında recoil'e dokunulmaz.
- **Ekrana girmesin:** son çarpan **Maksimum çarpan** (varsayılan 3.0) ile sınırlanır. Silah kameraya giriyorsa
  tavanı düşür; his yetersizse kategori çarpanlarını yükselt.
- **Güncelleme:** silah / namlu / araç değişince (CBA oyuncu olayları), şarjör değişince (`Reloaded`) ve
  her atışta o anki mühimmatla (`Fired`, **yalnızca oyuncuda**; yapay zekâ atışları kod çalıştırmaz).
  Mühimmat değişmediyse atış başına tek karşılaştırma yapılır.
- **Yanlış sınıflanan mühimmat:** `Kategori istisnaları` ayarına `mühimmat=kategori` yaz
  (`B_762x51_Ball=4, rhs_ammo_556x45_M855A1_Ball=2`). `0` = o mühimmatta recoil değişmesin.

### CBA ayarları (`Options > Addon Options > TAC - Gerçekçilik Paketi > Recoil`)

| Ayar | Varsayılan |
|------|-----------|
| `TAC_recoil_enabled` | açık |
| `TAC_recoil_scale` (genel ölçek) | 1.0 |
| `TAC_recoil_maxCoef` (tavan) | 3.0 |
| `TAC_recoil_t1..t4` (kategori sınırları, J) | 1000 / 1950 / 3000 / 5500 |
| `TAC_recoil_m1..m5` (kategori çarpanları) | 1.2 / 1.5 / 1.9 / 2.4 / 2.9 |
| `TAC_recoil_overrides` | boş |
| `TAC_recoil_debug` (test göstergesi) | kapalı, kişisel |

Sunucudan zorlamak için `cba_settings.sqf`:

```sqf
force force TAC_recoil_enabled = true;
force force TAC_recoil_maxCoef = 3;
force force TAC_recoil_m2 = 1.5;
force force TAC_recoil_m4 = 2.4;
```

### MP mantığı (recoil)

Ayarlar tüm makinelerde kaydedilir (global, `force` edilebilir). Çarpan **yalnızca yerel oyuncuda** uygulanır;
ağa hiçbir şey yayınlanmaz, sunucuya yük sıfırdır. Döngü yok, her şey olay tabanlı.

### Test adımları

1. `Test göstergesi`ni aç. Farklı silahlara geç (5.56, 7.62x39, 7.62x51, .338 vb.): ekranda mühimmat, enerji, kategori ve çarpan görünmeli.
2. Debug konsolunda (**Yerel çalıştır**): `call TAC_fnc_recoilDebug`. `Motorun uyguladigi katsayi` kategori çarpanıyla uyuşmalı.
3. Aynı silahla `Genel ölçek`i 0.1 ve 3 yapıp recoil farkını hisset; `Maksimum çarpan`ı 1 yapınca recoil'in vanilla'ya döndüğünü doğrula.
4. Şarjör türü değiştir (ör. normal -> AP): çarpan bir sonraki atışta yeni mühimmata göre güncellenmeli.
5. Roketatar / araç silahı: çarpan 1 olmalı. Respawn: yeni bedende çarpan hemen yeniden uygulanmalı.

## Özellik 4 – Baskı altında artan sway

Oyuncunun yakınından mermi geçince **stres seviyesi** (0..1) yükselir, ateş kesilince **doğrusal** olarak
sıfıra iner (varsayılan 15 sn). Sway çarpanı seviyeye göre artar ve **nabız gibi** hafifçe dalgalanır:

`çarpan = 1 + (maksimum - 1) · seviye · (1 + nabız · sin(2π · 1.4 · t))`

- **Algılama:** vanilla `Suppressed` olayı (mermi oyuncunun yanından geçince, mermiye en yakın mesafeyle tetiklenir).
  Yalnızca oyuncuya bağlıdır. Olay genel bir CBA yerel olayına çevrilir (`TAC_suppressed`); 5. özellik de bunu dinleyecek.
- **Stres eşiği:** mermi `Stres eşiği: mermi mesafesi` (varsayılan 12 m) içinden geçmeli. Artış mesafeyle azalır:
  `artış = mermi_başına_artış · (1 - 0.6 · mesafe / eşik)`. Dost atışları varsayılan olarak sayılmaz.
- **Uygulama:** sway değişkeni otomatik bulunur: `ace_common_swayFactor`, yoksa `ace_advanced_fatigue_swayFactor`,
  o da yoksa vanilla `setCustomAimCoef`. Stres başlarken temel değer kaydedilir, bitince geri yazılır.
  Döngü (0.1 sn PFH) **yalnızca stres varken** çalışır.

### CBA ayarları (`... > TAC - Gerçekçilik Paketi > Baskı altında sway`)

| Ayar | Varsayılan |
|------|-----------|
| `TAC_stress_enabled` | açık |
| `TAC_stress_maxMult` (maks. sway çarpanı) | 3.0 |
| `TAC_stress_range` (eşik mesafe, m) | 12 |
| `TAC_stress_gain` (mermi başına artış) | 0.30 |
| `TAC_stress_decay` (sönüm süresi, sn) | 15 |
| `TAC_stress_pulse` (nabız dalgalanması) | 0.15 |
| `TAC_stress_friendly` (dost atışı da say) | kapalı |
| `TAC_stress_swayVar` (sway değişkeni) | `auto` |
| `TAC_stress_debug` (test göstergesi) | kapalı, kişisel |

Hepsi global ve `cba_settings.sqf` ile `force` edilebilir (`TAC_stress_debug` hariç).

### MP mantığı (stres)

Her şey yerel oyuncuda; ağa hiçbir şey yayınlanmaz, sunucuya yük sıfır. Yapay zekâ için kod çalışmaz.

### Test adımları

1. `Test göstergesi`ni aç. Debug konsolunda (**Yerel çalıştır**) `call TAC_fnc_stressDebug`: `Bulunan sway degiskeni` dolu olmalı.
2. Yapay stres: `["TAC_suppressed", [ACE_player, 2, objNull, ""]] call CBA_fnc_localEvent` (birkaç kez çalıştır): seviye yükselip ~15 sn'de sıfırlanmalı, silah belirgin sallanmalı.
3. Gerçek test: Zeus ile bir AI'ya oyuncunun yakınından ateş ettir; mermi geçince sway artmalı. Uzak (12 m üstü) geçişler etki etmemeli.
4. Bitince `Bulunan sway degiskeni`nin değeri eski haline dönmeli. Respawn'da stres sıfırlanmalı.
5. Sway etkisi görünmüyorsa `TAC_stress_swayVar`a ACE'nin gerçek değişken adını yaz ve `stressDebug` çıktısını gönder.

> Not: ACE gelişmiş yorgunluk sway çarpanını belirli aralıklarla okur; etki ilk anda saniyenin kesri kadar gecikebilir.

## Özellik 5 – Mermi yakın geçiş (crack) + tam ekran efekti + HUD kapatma

Ses hızından (343 m/s) hızlı bir mermi oyuncunun kafasından **2-3 m** yakından geçerse 1-2 sn'lik şok dalgası efekti:

- **Tam ekran bulanıklık:** `DynamicBlur` PP efekti.
- **Kenar kararması (vignette):** ekran kenarlarından (genişlikte %20, yükseklikte %32) içe doğru `smoothstep` eğrisiyle şeffaflaşan, **üst üste binen katmanlar (ayar: varsayılan 48)** (kenara doğru opaklık birikir: bant dikişi yok, köşeler doğal olarak daha koyu); orta bölge temiz kalır (display 46 üzerinde kalıcı kontroller: ilk tetiklemede bir kez kurulur, sonra yalnızca gizlenip gösterilir; blur PP efekti de kalıcıdır ve bitince kapatılır, silinmez; yaratıp silmek takılma yapıyordu).
- **HUD kapanır:** `showHUD false`. Efektten önceki HUD durumu (`shownHUD`) saklanır ve efekt bitince **aynen** geri yüklenir (HUD'u zaten gizleyen bir mission varsa bozulmaz).
- **Zaman çizelgesi:** ilk ~%40 tam şiddet, kalanı sönümlenir. Efekt arada yeniden tetiklenirse eski zamanlayıcılar geçersiz sayılır (jeton), HUD iki kez kaydedilmez.

**Tetikleme koşulları (hepsi):** modül açık ve oyuncu hayatta · mermi `Tetik mesafesi` (3 m) içinden geçti · hız `Minimum hız`
(343 m/s) üstünde (hız olaydaki **gerçek mermi nesnesinden**, alınamazsa config `typicalSpeed`) · atıcı dost değil · bekleme süresi (3 sn) doldu.
Olay 4. özellikteki `Suppressed` dinleyicisinden gelir (`TAC_suppressed`); ek maliyet yoktur, döngü yoktur.

### CBA ayarları (`... > TAC - Gerçekçilik Paketi > Mermi yakın geçiş (crack)`)

| Ayar | Varsayılan |
|------|-----------|
| `TAC_crack_enabled` | açık |
| `TAC_crack_dist` (tetik mesafesi, m) | 3 |
| `TAC_crack_minSpeed` (m/s) | 343 |
| `TAC_crack_duration` (sn) | 1.6 |
| `TAC_crack_blur` (bulanıklık) | 2.5 |
| `TAC_crack_vignette` (kenar kararması) | 0.7 |
| `TAC_crack_layers` (vignette katman sayısı, 16-96) | 48, kişisel |
| `TAC_crack_blast` (patlama efekti) | açık |
| `TAC_crack_blastDist` (patlama etki mesafesi, m) | 25 |
| `TAC_crack_blastDuration` (patlama efekt süresi, sn) | 3.5 |
| `TAC_crack_hideHud` | açık |
| `TAC_crack_cooldown` (sn) | 3 |
| `TAC_crack_friendly` (dost atışı) | kapalı |
| `TAC_crack_debug` (test göstergesi) | kapalı, kişisel |

Hepsi global ve `cba_settings.sqf` ile `force` edilebilir (`TAC_crack_debug` hariç).

### Patlama senaryosu (el bombası, 40mm, roket, havan/top)

Aynı efekt (blur + vignette + HUD gizleme) yakın patlamalarda da çalışır. Şiddet mesafeyle **doğrusal** azalır
(0 m = tam, etki mesafesi = 0), arada engel (duvar, araç, zemin) varsa **yarıya** iner; süre = `patlama süresi * (0.5 + 0.5 * şiddet)`.
İki yol vardır:

- **Hasar yolu:** oyuncuya bağlı vanilla `Explosion` olayı (patlamadan hasar aldı) -> şiddet 1.
- **Mesafe yolu:** patlayıcı mermi (config `indirectHit >= 5` ve `indirectHitRange >= 2`, ya da `explosive >= 0.5`) izlenir; yok olduğu son konum patlama noktasıdır.
  Mermi kaynakları: oyuncunun kendi `Fired` olayı, çevredekilerin `FiredNear` olayı (~69 m) ve **ACE Gelişmiş Fırlatma**'nın
  `ace_throwableThrown` olayı (ACE gerçek bombayı kendi yarattığı için). Ek maliyet: her yakın atışta tek hashmap araması (kurşun
  hemen elenir); kare-başı işleyici yalnızca havada patlayıcı varken çalışır ve kendini kaldırır.
- Etki mesafesi mermi büyüklüğüne göre ölçeklenir: `ayar * clamp(indirectHitRange / 8, 0.5, 3)`.
- ACE'nin sildiği vanilla bomba (0.4 sn'den kısa ömürlü `GrenadeCore`) patlama sayılmaz. ACE olayının adından bağımsız olarak, atılan el bombasından 0.15 sn sonra atanın çevresinde aynı sınıftan nesne aranır ve o izlenir.
- `Test göstergesi` açıkken zincir ekrana yazılır: `mermi sınıfı ... patlayıcı: true/false` -> `patlayıcı izleniyor` -> `... patladı | mesafe | etki mesafesi` -> `PATLAMA | şiddet`. Hangi adımda kesildiği görülür.
- Aynı patlama iki yoldan gelirse 0.5 sn içinde tek efekt (güçlü olan kazanır).
- Çok uzak topçu isabetleri (FiredNear 69 m dışı) yalnızca hasar yoluyla yakalanır.

### MP mantığı (crack)

Tamamen yerel oyuncuda; ağa hiçbir şey yayınlanmaz, sunucuya yük sıfır. Yapay zekâ için kod çalışmaz.

### Test adımları

1. Debug konsolunda (**Yerel çalıştır**): `[] call TAC_fnc_crackStart`. Blur + vignette + HUD kapanması ~1.6 sn sürüp HUD geri gelmeli.
2. Gerçek geçişi taklit: `["TAC_suppressed", [ACE_player, 1.5, objNull, "B_762x51_Ball", 800]] call CBA_fnc_localEvent`. Hız 300 yap: tetiklenmemeli. Mesafeyi 5 yap: tetiklenmemeli.
3. `Test göstergesi`ni aç: her mermi geçişi için `hız / mesafe / TETİKLENDİ veya atlandı: neden` yazar.
4. Gerçek test: Zeus ile bir AI'ya oyuncunun çok yakınından ateş ettir. Bekleme süresi (3 sn) içinde ikinci efekt çıkmamalı.
5. **Patlama:** `[5] call TAC_fnc_crackBlast` (5 m uzakta patlama taklidi), `[0] call TAC_fnc_crackBlast` (doğrudan). Sonra gerçek test: yakına el bombası at (vanilla ve ACE Gelişmiş Fırlatma ile ayrı ayrı), 40mm/roket ile yakın bir duvara ateş et. `Test göstergesi` açıkken `PATLAMA | mesafe | etki mesafesi | şiddet` yazılır; duvar arkasında "(engelli)" görünmeli.
6. `call TAC_fnc_crackDebug` ile durum raporu al (efekt takılı kalırsa `[-1] call TAC_fnc_crackEnd` ile zorla temizle).

> Not: ACE gibi arayüz modlarının kendi öğeleri `showHUD`'a bağlı değilse ekranda kalabilir. HUD'u geri yükleyen kod `shownHUD` değerini birebir kullanır.

## Özellik 6 – Silah bakım ve arıza (tüfek + MG)

Her silahın **kir**, **yağ** ve **aşınma** durumu vardır. Atış kirletir ve yağı azaltır; ortam (yağmur, sığ su, tozlu zeminde yatma) ve susturucu hızlandırır.
Arıza ihtimali bunlardan hesaplanır ve **ACE'nin kendi arıza sistemine** verilir (`ace_overheating_fnc_jamWeapon`): arıza türleri Eject / Extract / Feed / Fire / Dud, ACE'nin
"arıza gider" eylemi aynen çalışır. ACE'nin ısıya bağlı arızası ayrıca devam eder; bizim sistem onu değiştirmez.

**İlke: oyuncuya kendiliğinden bilgi verilmez** (uyarı, ipucu, bildirim yok). Silahın durumu yalnızca ACE menüsünden **"Silahı incele"** ile, gözlem diliyle okunur.

### Model

| Değer | Artış / azalış | Etkisi |
|-------|----------------|--------|
| **Kir** 0-100 | atış başına `kirlenme hızı/1000 x kategori x ortam x susturucu`. Tüfek 1, MG x1.3, tabanca x0.5 | arıza ihtimali `Pmax x (kir/100)^2.5`: temizken ihmal edilebilir, kirlendikçe hızla artar |
| **Yağ** 0-100 | atış başına azalır, yağlayınca +65 | %30 altı sürtünme arızaları; %90 üstü aşırı yağlı: tozda daha çok kirlenir |
| **Aşınma** (atış) | her atış +1 | `Pmax x 0.5 x (aşınma/ömür)^3` eklenir; yalnızca silahçı parça değiştirerek sıfırlar |

Arıza türü nedene göre ağırlıklanır: kir -> besleme / kovan atma, düşük yağ ve aşınma -> kovan çıkarma, küçük sabit pay -> kusurlu mühimmat.
Ortam çarpanı (3 sn önbellekli, atış başına hesaplanmaz): yağmur +0.4 x şiddet, sığ suda +0.8, tozlu/çamurlu zeminde yatarken +0.6 (çömelirken +0.2).

**Kategori** config'ten otomatik: birincil silah, şarjör/kayış kapasitesi (`magazines` + `magazineWell`) `MG eşiği`ni (60) aşıyorsa **MG** (daha çok kirlenir, temizlik 45 sn), değilse tüfek (25 sn); tabanca 15 sn. Yanlış sınıflananı `MG olarak zorla` tablosuna yaz. Fırlatıcı ve bomba takip edilmez.

### ACE self-menü > Silah Bakımı

| Eylem | Ne yapar |
|-------|----------|
| **Silahı incele** | Kir / yağ / parçalar / namlu ısısı, son temizlikten atış, son arıza, şu an arızalı mı. Sayı yok, sözlü bantlar |
| **Silahı temizle** | Bakım Kiti ister (tükenmez). Kir %5'e iner, **yağ da gider** (en çok %12 kalır), yani sonra yağlamak gerekir |
| **Silahı yağla** | Silah Yağı ister (her seferinde 1 tükenir). Yağ +65 |
| **Arızayı gider (ayrıntılı)** | Silah arızalıyken görünür. ACE'nin hızlı müdahalesi (tap-rack, şansa bağlı) başarısız olursa **ikinci kademe**: başarı garantili, temizlik süresinin %40'ı |
| **Parça değiştir** | Yalnızca **silahçı**. Yedek Parça Seti ister (tükenir). Aşınma sıfırlanır |

Silahçı: test modu açık, birimde `TAC_isArmorer = true` (Eden: birim init'ine `this setVariable ["TAC_isArmorer", true, true]`) ya da ACE mühendis özelliği.
Silahçı, incele kartında ayrıca **sayısal değerleri ve tahmini arıza ihtimalini** görür.

**Hareket ve ses:** her bakım eyleminde silahın kendi yükleme hareketi (ACE'nin arıza gidermede kullandığıyla aynı üst gövde jesti, duruş değişmez) süre bitene kadar 2.8 sn'de bir tekrarlanır; çubuk iptal edilirse durur.
Sesler yalnızca kaynağı doğrulanmış olanlardır: temizlik başlangıcı vanilla `Acts_carFixingWheel`, arıza giderme ACE `ace_overheating_fixing_rifle/pistol`, parça değiştirme ACE `ACE_BarrelSwap`, bitişlerde vanilla sürgü (`reload_Katiba`) ve kuru tık (`dry9`) dosyaları.
Eksik sınıf sessizce atlanır. `playSound3D` globaldir: yakındaki oyuncular da duyar. Kapatmak: `TAC_wpn_fx`.

Eşyalar: `TAC_WeaponCleaningKit`, `TAC_WeaponOil`, `TAC_WeaponSpareParts`. Hedef silah: elindeki takipli silah, yoksa birincil silah.

### CBA ayarları (`... > TAC - Gerçekçilik Paketi > Silah bakım ve arıza`)

| Ayar | Varsayılan |
|------|-----------|
| `TAC_wpn_enabled` | açık |
| `TAC_wpn_dirtRate` (1000 atışta kir %) | 60 |
| `TAC_wpn_lubeLoss` (1000 atışta yağ kaybı %) | 50 |
| `TAC_wpn_jamMax` (tam kirli silahta atış başına arıza %) | 3 |
| `TAC_wpn_wearLife` (parça ömrü, atış) | 15000 |
| `TAC_wpn_suppressorMult` | 1.6 |
| `TAC_wpn_env` (ortam etkisi) | açık |
| `TAC_wpn_mgThreshold` (MG eşiği) | 60 |
| `TAC_wpn_mgTable` (MG olarak zorla, virgülle) | boş |
| `TAC_wpn_needKit` (bakım malzemesi gerekli) | açık |
| `TAC_wpn_fx` (bakım hareketi ve sesi) | açık |
| `TAC_wpn_cleanTimeMult` (bakım süresi çarpanı) | 1 |
| `TAC_wpn_testMode` / `TAC_wpn_testMult` | kapalı / 20 |
| `TAC_wpn_debug` (arıza nedeni göstergesi) | kapalı, kişisel |

### Silahı yere atmak / başkasının alması

- **Yere / kutuya / araca / cesede koyunca:** silahın kir/yağ/aşınması kapta saklanır (`TAC_wpn_stash`, herkese yayınlanır). Aynı oyuncu ya da **başkası** silahı alınca durum onunla gelir; kayıt kaptan silinir. Oyuncu o sınıftan başka silah taşımıyorsa kendi durumu da silinir.
- **"At, yenisini al" hilesi yok:** aynı sınıftan yeni (arsenal, AI cesedi, kayıtsız) silah alınca sıfırdan başlar; eski kirli durum onunla gelmez.
- **Sınırlar:** kap yok olursa (boşalıp temizlenirse, oyun çöp toplarsa) durum kaybolur. **Ölü oyuncunun** silahı: durum cesette yerel kaldığından silahı alan için sıfırdan başlar. Aynı sınıftan iki silah taşıyorsan ikisi durumu paylaşır.

### MP mantığı (silah bakım)

Tamamen yerel oyuncuda: durum birimin üzerinde tutulur, ağa hiçbir şey yayınlanmaz, sunucuya yük sıfır, yapay zekâ için kod çalışmaz. Atış başına maliyet: bir hashmap araması, birkaç toplama, bir `random`. Döngü yok.
Durum "birim + silah sınıfı" başınadır (Arma'da silahların ayrı kimliği yok): aynı sınıftan iki silah ortak durum paylaşır. Respawn'da yeni beden varsayılanla başlar.

### Test adımları (tek kişi, MG dahil)

1. Eden'de oyna. Ayarlarda **Test modu**nu aç (x20; seni silahçı yapar, sayıları görürsün). Debug konsolunda (yerel çalıştır):
   ```sqf
   player addWeapon "arifle_MX_SW_F"; player addMagazines ["100Rnd_65x39_caseless_mag", 6];
   player addItem "TAC_WeaponCleaningKit"; player addItem "TAC_WeaponOil"; player addItem "TAC_WeaponSpareParts";
   ```
   (MG yerine kendi RHS/CUP makineli tüfeğini kullanabilirsin.)
2. ACE menü > **Silah Bakımı > Silahı incele**: "temiz, yeterli yağ" görmelisin. `call TAC_fnc_wpnDebug` ile kategori **mg** çıkmalı.
3. Ateş et. Test çarpanıyla ~100 atışta kir yükselir; incele kartı "kirli"ye döner, silahçı satırı kir yüzdesini gösterir. Kir yükseldikçe arızalar çıkmalı. Test göstergesini açıp neden/ihtimalin ekrana yazılmasını izle.
4. Arıza çıkınca ACE'nin eylemiyle gider; **başarısız olursa** Silah Bakımı > **Arızayı gider (ayrıntılı)** ile kesin gider.
5. **Silahı temizle**: kir ~%5, yağ düşük. Hemen ateş et: yağ azlığı arızaları çıkabilir. **Silahı yağla**: yağ yükselir. Yağdan malzeme düşmeli.
6. Hızlı durum ayarı: `([ACE_player, currentWeapon ACE_player] call TAC_fnc_wpnGetState) set [0, 80];` (kir %80).
7. Ortam: yağmuru aç, toz/çamurda yat, sığ suda ateş et: `call TAC_fnc_wpnDebug` ortam çarpanını gösterir.
8. Susturucu tak, ateş et: kir daha hızlı artmalı. Bakım malzemesini envanterden at: temizle/yağla eylemleri görünmemeli (`Bakım malzemesi gerekli` açıkken).
9. Test modunu kapat, normal hızı gör.
10. **Hareket ve ses:** temizle / yağla / arıza gider / parça değiştir: silah hareketi tekrar etmeli, başlangıç ve bitiş sesi çalmalı; çubuğu iptal edince hareket durmalı. Yan oyuncu varsa onun da duyduğunu kontrol et.
11. **Bırakıp alma:** silahı kirletip yere at (envanterden), tekrar al: kir/yağ aynı kalmalı. Başka bir oyuncu (ya da Zeus ile kontrol ettiğin birim) alınca da aynı durumu görmeli. Aynı sınıftan yeni silahı arsenal'den al: sıfırdan başlamalı.
12. Yeni özellik dışında bir RHS/CUP tüfeğiyle de dene: kategori ve eylemler çalışmalı. Yanlış MG/tüfek çıkarsa `MG olarak zorla`'ya ekle.

> Not: `ace_overheating_fnc_jamWeapon` kaynağı `ace_overheating_enabled` ayarını kontrol etmiyor, ama ACE'nin "arıza gider" eyleminin ayar kapalıyken görünüp görünmediği **doğrulanmadı**. Garanti için ACE overheating açık kalsın; kapalıysa "Arızayı gider (ayrıntılı)" eylemi her durumda çalışır.

## Yeni özellik ekleme

1. `addons/main/<özellik>/` klasörü aç; `fn_*.sqf` dosyalarını ve bir `CfgFunctions.hpp` ekle (`notebook/`, `nvg/` örnek). Envanter eşyası gerekiyorsa `CfgWeapons.hpp` de ekle.
2. `config.cpp` içindeki `CfgFunctions > TAC` bloğuna `#include "<özellik>\CfgFunctions.hpp"` satırını ekle (eşya varsa `CfgWeapons` bloğuna da).
3. Ayarlar için `XEH_preInit.sqf`'e, istemci kurulumu için `XEH_postInit.sqf`'e modülün giriş fonksiyonunu ekle.
4. Her modülün kendi `TAC_<özellik>_enabled` CBA ayarı olsun.
