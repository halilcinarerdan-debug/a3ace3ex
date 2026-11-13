# TAC – Realism Pack (CBA_A3 + ACE3)

Tek bir mod (`@TAC`): ana PBO `tac_main.pbo` + dört **opsiyonel** uyumluluk PBO'su (`tac_compat_rhs.pbo`, `tac_compat_rhs_afrf.pbo`, `tac_compat_tmt.pbo`, `tac_compat_cup.pbo`). Yalnızca **CBA_A3** ve **ACE3**
(ACE overheating dahil, ACE ile gelir) gerektirir; RHS, CUP, Project OPFOR, ACM, LAMBS, ACRE2 ile birlikte kullanılır. Uyumluluk PBO'ları dışında hiçbir mod zorunlu bağımlılık değildir.
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
| 7 | MG: gerçekçi yedek namlu ağırlığı + sıcak namlu değiştirme yanığı (ısı eldiveni) | ✅ hazır (test bekliyor) |
| 7a | MG: RHS ve CUP Minimi için hafif namlu (opsiyonel compat PBO'lar) | ✅ hazır (test bekliyor) |
| 7b | MG: besleme kapağı / kayış adımı | ✅ hazır (test bekliyor) |
| 8 | Optik: buğulanma ve kirlenme (kapalı lensli optikler) | ✅ hazır (test bekliyor) |
| 9 | Roketatar / füze: ateşlenmeme, bekleme, mühimmat çıkarma (tüm türler) | ✅ hazır (test bekliyor) |

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
        fn_wpnJamChance.sqf              arıza ihtimali formülü (1/MRBS x durum x ortam)
        fn_wpnProfile.sqf                silah başına gerçek güvenilirlik profili (MRBS, kir / yağ duyarlılığı)
        fn_wpnCategory.sqf / fn_wpnGetState.sqf / fn_wpnEnvFactor.sqf   kategori, durum, ortam
        fn_wpnClean / wpnLube / wpnClearJam / wpnReplaceParts / wpnInspect   bakım eylemleri ve kart
    mg/                                  7. özellik
        CfgMagazines.hpp                 gerçekçi yedek namlu ağırlıkları (ACE_SpareBarrel yaması + hafif/ağır sınıf)
        CfgWeapons.hpp                   vanilla MG'lere namlu ataması, ACE_SpareBarrel_Item ağırlığı, Isı Eldiveni
        fn_mgInitSettings.sqf            CBA ayarları (yanık)
        fn_mgInit.sqf                    ACE namlu değiştirme olayına sunucu dinleyicisi + istemci olayı
        fn_mgBurn.sqf                    sıcak namlu yanığı
    optic/                               8. özellik
        CfgFunctions.hpp / CfgWeapons.hpp  Lens Bezi eşyası
        fn_optInitSettings.sqf           CBA ayarları
        fn_optPostInit.sqf               "cameraView" / "weapon" / "unit" olayları + ACE "Optiği sil"
        fn_optRefresh / optStart / optStop / optTick   optikten bakarken çalışan döngü (0.5 sn PFH)
        fn_optApply.sqf / optClearEffects.sqf          DynamicBlur + ColorCorrections (kalıcı PP)
        fn_optIsSealed / optGetState / optActive / optInspectLines / optWipe
    rocket/                              9. özellik
        CfgFunctions.hpp
        fn_rktInitSettings.sqf           CBA ayarları
        fn_rktPostInit.sqf               "unit" olayı + ACE "Roketatar" menüsü
        fn_rktAttach.sqf                 Fired / Reloaded + ACE DefaultAction dinleyicisi (tetik anında zar)
        fn_rktProfile / rktGetState / rktParseTable   tür profili, durum, elle tablo
        fn_rktMisfireCheck / rktMisfireDo / rktOnFired / rktOnReloaded
        fn_rktRemoveRound / rktInspect / rktDebug
addons/compat_rhs/                       -> tac_compat_rhs.pbo (OPSİYONEL; RHS Minimi ailesine hafif namlu + FIM-92 kilit sesleri)
addons/compat_rhs_afrf/                  -> tac_compat_rhs_afrf.pbo (OPSİYONEL; RHS AFRF Igla kilit sesleri)
addons/compat_tmt/                       -> tac_compat_tmt.pbo (OPSİYONEL; TMT_FIM92_launcher kilit sesleri)
addons/compat_cup/                       -> tac_compat_cup.pbo (OPSİYONEL; CUP Minimi / M249 ailesine hafif namlu)
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
5. pboProject `requiredAddons` (cba_main, ace_main, ace_common, ace_interact_menu, ace_overheating) bulunamadı diye uyarı verirse,
   CBA ve ACE PBO'larını DePbo ile P: sürücüsüne açman veya bu denetimi pboProject ayarlarından gevşetmen gerekir.
6. Dedicated sunucuda imza doğrulaması açıksa: Arma 3 Tools'taki `DSCreateKey` ile anahtar üret,
   PBO'yu `.biprivatekey` ile imzala (pboProject imzalama seçeneği veya `DSSignFile`) ve `.bikey` dosyasını sunucunun `keys/` klasörüne koy.
   **`.biprivatekey` dosyasını asla depoya koyma** (`.gitignore` zaten engeller).

### Opsiyonel uyumluluk PBO'ları (RHS, CUP)

`addons/compat_rhs` ve `addons/compat_cup` küçük, **opsiyonel** PBO'lardır; `tac_main` ile aynı yöntemle derlenir
(kaynak: `P:\z\tac\addons\compat_rhs`, prefix `$PBOPREFIX$` dosyasından okunur: `z\tac\addons\compat_rhs`; aynısı `compat_rhs_afrf`, `compat_tmt` ve `compat_cup` için).
Her biri `skipWhenMissingDependencies = 1` taşır: ilgili mod (RHS USAF / CUP Weapons) yüklü değilse config'leri **sessizce atlanır**, hata vermez.
Bu PBO'ları `@TAC\addons` içine koymazsan o modun MG'leri yalnızca varsayılan orta namluyu kullanır. İçerik: 7. özellik bölümü.
pboProject `requiredAddons` uyarısı verirse (örn. `rhsusf_main_loadorder`, `CUP_Weapons_LoadOrder`), yukarıdaki 5. adımdaki gibi ilgili modu P: sürücüsüne aç ya da denetimi gevşet.

Sonuç: `@TAC\addons\tac_main.pbo` (+ varsa `tac_compat_rhs.pbo`, `tac_compat_rhs_afrf.pbo`, `tac_compat_tmt.pbo`, `tac_compat_cup.pbo`, `.bisign` dosyaları) ve `@TAC\mod.cpp`.

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
| `TAC_nvg_notify` | kapalı | kişisel (istemci) |

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
| **Kir** 0-100 | atış başına `kirlenme hızı/1000 x kategori x ortam x susturucu`. Tüfek 1, MG x1.3, tabanca x0.5 | arıza çarpanına `kir duyarlılığı x 40 x (kir/100)^2.5` eklenir: temizken ihmal edilebilir, kirlendikçe hızla artar |
| **Yağ** 0-100 | atış başına azalır, yağlayınca +65 | %30 altı sürtünme arızaları; %90 üstü aşırı yağlı: tozda daha çok kirlenir |
| **Aşınma** (atış) | her atış +1 | çarpana `6 x (aşınma/ömür)^3` eklenir; yalnızca silahçı parça değiştirerek sıfırlar |

Arıza türü nedene göre ağırlıklanır: kir -> besleme / kovan atma, düşük yağ ve aşınma -> kovan çıkarma, küçük sabit pay -> kusurlu mühimmat.
Ortam çarpanı (3 sn önbellekli, atış başına hesaplanmaz): yağmur +0.4 x şiddet, sığ suda +0.8, tozlu/çamurlu zeminde yatarken +0.6 (çömelirken +0.2).

**Kategori** config'ten otomatik: birincil silah, şarjör/kayış kapasitesi (`magazines` + `magazineWell`) `MG eşiği`ni (60) aşıyorsa **MG** (daha çok kirlenir, temizlik 45 sn), değilse tüfek (25 sn); tabanca 15 sn. Yanlış sınıflananı `MG olarak zorla` tablosuna yaz. Fırlatıcı ve bomba takip edilmez.

### Güvenilirlik verisi: gerçekçi arıza oranları (silah ve kalibre başına)

Arıza ihtimali artık sabit bir sayı değil, **silahın gerçek güvenilirlik verisine (MRBS)** dayanır:

```
atış başına arıza ihtimali = (1 / MRBS) x durum çarpanı x ortam x genel ölçek
durum çarpanı = 1 + kir duyarlılığı x 40 x (kir/100)^2.5 + yağ duyarlılığı x 10 x ((30 - yağ)/30)^2 + 6 x (aşınma/ömür)^3
```

**MRBS** (Mean Rounds Between Stoppages), temiz, yağlı, yeni silahta iki tıkanma arası ortalama atıştır. Temiz silahta ihtimal tam 1/MRBS'tir (M4'te atış başına ~%0.028).
**Kir duyarlılığı**, tam kirli silahta MRBS'in ne kadar çöktüğünü belirler (çarpan = 1 + duyarlılık x 40); 40 değeri ABD Ordusu 2007 aşırı toz testinden türetildi (aşağıda).
`Arıza ihtimali ölçeği` 1 = gerçek; oyunu zorlaştırmak için artır (gerçek MRBS binlerce atış olduğu için normal bir görevde pek arıza görmezsin; kirlendikçe/yağsız kalınca belirginleşir).
Bilinmeyen silahlar için **kalibre** (ilk şarjörün mühimmat adından) ve **kategori** (tüfek / MG / tabanca) genel değerleri kullanılır; yerleşik tablonun gerçek RHS/CUP sınıf adlarına karşı doğruluğu ACE'nin uyumluluk yamalarındaki sınıf listesiyle sınandı.

| Silah ailesi (örnek sınıflar) | Temiz MRBS | Kir duyarlılığı | Veri kalitesi |
|-------------------------------|-----------:|----------------:|---------------|
| M16A2/A4 (`rhs_weap_m16a4`, `CUP_arifle_M16*`), M4/M4A1/Mk18 | 3600 | 1.0 | **kaynak**: M4A1 + M855 taban değeri 3.592 MRBS; aşırı tozda M4 ~68-195 |
| M16A1 / XM16E1 | 1500 | 1.2 | tahmin (erken hizmet sorunları) |
| HK416 / M27 | 4500 | 0.41 | **kaynak**: aşırı tozda ~257 MRBS |
| FN SCAR (Mk16/17/H/L) | 4000 | 0.35 | **kaynak**: aşırı tozda ~265 MRBS |
| XM8 | 5000 | 0.24 | **kaynak**: aşırı tozda ~472 MRBS |
| G36, L85A2, G3/HK417, FAL, M14, SR-25 | 4000, 2500, 4000, 3500, 3000, 3200 | 0.4-0.9 | tahmin |
| AK ailesi (AKM, AK-74, AK-12, Vz.58, Galil...) | 5000 | 0.25 | tahmin (resmi sayı yok; itibar + tek tüfek günlükleri) |
| M240 / Mk48 | 2900 | 0.55 | **kaynak**: 2002 testinde 2.962 MRBS |
| M60 | 850 | 0.6 | **kaynak**: 2002 testinde 846 MRBS |
| M249 / Minimi | 1000 | 0.6 | tahmin (kullanıcılar M60'tan az güvenilir buluyor ama sayı yok) |
| PKM / PKP / Zafir | 3000 | 0.35 | tahmin |
| MG3 / MG42 | 2500 | 0.5 | tahmin |
| Beretta M9 | 5000 | 0.5 | tahmin: Beretta 17.500 iddia ediyor, ABD MHS şartı 2.000; ortası alındı |
| Glock 17/19 | 6000 | 0.4 | tahmin |
| M1911 / .45 ACP | 2500 | 0.7 | tahmin |
| Makarov / TT | 4000 | 0.3 | tahmin |
| Sürgülü tüfekler | 15000 | 0.2 | tahmin |
| Kalibre genel değerleri (kayıt yoksa) | tüfek 5.56: 3200, 7.62x39: 4500, 7.62/6.5: 3500; MG 5.56: 1000, 7.62: 2500; ağır: 2000; tabanca: 4000 | 0.3-0.6 | tahmin |

**Dürüst not:** gerçekten yayımlanmış sayı bulabildiklerim yalnızca M16/M4 (taban değer ve aşırı toz testi), HK416, SCAR-L, XM8 (aşırı toz testi), M240 ve M60 (2002 testi). Diğerleri yayımlanmış veri bulunamadığı için bilinen itibar ve aile benzerliğine göre
**tahmin**dir ve tabloda öyle işaretlidir. Aşırı toz testinin kendisi tartışmalıdır: Ordu'nun kendi sunumunda iki koşuda M4 için 296 ve 863 tıkanma çıkmış, yani protokol tekrarlanabilir değil. Rakamlar oyun dengesi için makul bir başlangıçtır, kesin bilgi değildir.
> _0.26.2_: adında `arifle_` geçen tüm tüfekler (`ef_arifle_*`, `CUP_arifle_*`...) MG / kayışlı sayılmaz (ilk mermide besleme arızası düzeltmesi).

### Hazırlık görseli (0.30.0)

Adımlar yine ACE self-menü > Roketatar > **Atışa hazırla** altından yapılır (etkileşim yalnızca menüdedir). Her adımdan sonra ekranda kısa süre (`TAC_rkt_hintTime`, 3 sn) siyah zeminli sade bir görsel belirir: fırlatıcının yalnızca prosedürde dokunulan parçaları. Yapılan adımın parçası "açık" konuma geçer (pim çıkar, dayanak açılır, nişangah / horoz kolu kalkar, iç tüp uzar, takılan birim tüpe oturur, durum ışığı kırmızıdan yeşile döner). Hatalı sırada ya da yeniden yüklemede (R) hazırlık sıfırlanınca parçalar katlanmış görünür. Sıradaki adım hiç gösterilmez. Kapatmak için `TAC_rkt_hint`. Görsel ekranın köşesinde küçük durur (siyah zemin yalnızca çizimi kaplar, hızlı solar); **istemci ayarları** (her oyuncu kendisi seçer, sunucu zorlamaz): `TAC_rkt_hintCorner` (sağ üst / sol üst / sağ alt / sol alt), `TAC_rkt_hintSize` (%, 30), `TAC_rkt_hintTime` (sn, 3). Arka bölge (backblast) kontrolü adım değildir; oyuncu kendisi ayarlar.

Görsel, `rktPrepSteps` ile aynı ailelerde çalışır; başlığa özel ek adım gelirse "Başlık fünyesi" parçası otomatik eklenir. Çizim tablosu: `rocket/fn_rktHintLayout.sqf` (parça türleri dosya başlığında).

**Kayışlı makineli tüfekler (0.32.0):** aynı görsel besleme prosedürü için de çıkar (`TAC_mg_feedStep` açıkken). Parçalar silaha özel adım metinlerinden anahtar sözcükle seçilir: besleme kapağı, yatak (tepsiyi kaldır / yatağı kontrol et), kutu, kayış, kapak kilidi, kurma kolu. Yeni kayış takılınca (R) parçalar katlanmış görünür. Ayarlar roketle ortak (`TAC_rkt_hint`, boyut, köşe, süre). Adım sırası M240 ve M249 için TM 9-1005-313-10 / 201-10'dan, diğerleri tahmin.

| Aile | Adım sırası | Kaynak |
|------|-------------|--------|
| M136 AT4, M72, M141 BDM | pim, omuz dayanağı / tüp, nişangah, horoz / ateşleme kapağı | **FM 3-23.25 (2006)** |
| RPG-7, RPG-18/22/26, Panzerfaust, NLAW, SMAW, Carl Gustaf, SPG-9, Javelin, Stinger, Igla, TOW, Metis / Kornet, Titan | genel çalışma sırası | **kaynaksız, tahmin**; resmi kılavuz gelince düzeltilmeli |

### Kilit / uyarı sesleri (hazırlık, 0.31.0)

`addons/main/sound/` içinde beş mono 44,1 kHz `.ogg` var (Python ile üretildi; harmonikler azaltılmış, sıkıştırıcı + limiter ile dinamik aralık daraltılmış, tepe -4,4 dBFS): `tac_seeker_search` (600 Hz titreşimli), `tac_seeker_locking` (1,2 kHz, 4 bip/sn), `tac_seeker_locked` (2 kHz sabit), `tac_rwr_lock` (1 kHz, 2,5 bip/sn), `tac_rwr_launch` (2,2 kHz, 8 bip/sn). **Bağlananlar:** `rhs_weap_fim92` (`tac_compat_rhs.pbo`) `rhs_weap_igla` (`tac_compat_rhs_afrf.pbo`) ve `TMT_FIM92_launcher` (`tac_compat_tmt.pbo`; üst sınıf `Launcher_Base_F`, addon `TMT_Weapon`, oyundan doğrulandı): arama sesi `tac_seeker_locking`, kilit sesi `tac_seeker_locked` (hacim 0,35; ilgili config dosyasında ayarlanır). Motor yalnızca "arama" ve "kilit" olmak üzere iki ses kullanır; `tac_seeker_search` ve RWR sesleri henüz bağlı değil. Üst sınıf adları (`launch_O_Titan_F`, `rhs_weap_strela`) ve `requiredAddons` değerleri ACE'nin RHS uyumluluk yamalarından alındı. Diğer fırlatıcılar için önce `["titan"] call TAC_fnc_lockScan` (fırlatıcılar) ve uçakta `[vehicle player] call TAC_fnc_lockScan` ile hangi sınıfların kilit sesi tanımladığı taranır, çıktıya göre config yaması yazılır. Kilit sesini susturmak değil, değiştirmek mümkün.

### Envanter ikonları (0.33.0)

Tüm TAC eşyalarının kendi ikonu var (`addons/main/data/icons/*_ca.png`, 256x256, şeffaf zemin; mat, soluk renkli, gerçekçi ışık ve doku; sade çizgi film stili değil): AA ve lityum NVG pili (%100 / 75 / 50 / 25 / 10 kademeleri ayrı, altta sade tek renkli 5 çizgilik şarj göstergesi; bitik pil sızıntılı ve kararmış), lens bezi, silah bakım kiti, silah yağı, yedek parça seti, ısı eldiveni, füze pili (BCU), hafif ve ağır yedek namlu. İkonlar 2D yükseklik haritası + ışık yöntemiyle çizilir (telsiz referansındaki gibi: bevel, çukur, kabartma, kenar aşınması, çizik, gren, girinti kiri, yumuşak gölge; mat, eskitilmiş, milsim stil). `tools/gen_icons.py` ile üretilir (`python3 tools/gen_icons.py`; Pillow + numpy gerekir, ~5 sn); beğenmediğini script'te değiştirip yeniden çalıştır. Yeni eşya eklemek için parçaları (`part`, `cyl`, `recess`, `text`) tanımlaman yeter.

**Önemli:** config `.paa` yoluna bakar (`..._ca.paa`), repoda ise `.png` kaynaklar durur. Paketlerken PNG'lerin `.paa`'ya çevrilmesi gerekir: **Mikero pboProject** bunu otomatik yapar (`_ca` son eki = renk + alfa). Addon Builder kullanıyorsan "Binarize all textures" seçeneğini aç ya da PNG'leri TexView 2 ile `.paa` olarak kaydet (aynı klasöre, aynı adla). Çevrilmezse eşya çalışır ama envanterde ikon boş görünür.

### Soğuk Savaş modu (0.36.0)

CBA ayarı **Soğuk Savaş modu** (`TAC_coldWar`, varsayılan kapalı, sunucu zorlayabilir): S.O.G. Prairie Fire, Global Mobilization (GM) ve CSLA gibi içeriklerle kullanmak için sistemi döneme uydurur. Açıkken:

- **Erken M16 ailesi:** `M16` (A2 / A4 değil) M16A1 güvenilirliğine düşer (MRBS 1500, kir duyarlılığı 1.2; Vietnam dönemi tozlanma ve temizlik sorunları), `XM177` / `CAR-15` ayrı profil alır (2200). M16A2 / A4 modern değerinde kalır.
- **Lityum AA pil dönem dışı:** NVG pil ömrü hesabında lityum pil alkalin gibi davranır.
- Modern M4 / HK416 / SCAR gibi aileler tabloda durur ama dönem içeriklerinde zaten bulunmaz.
- Ek olarak mod bağımsız tanıma eklendi: `gm_mg3` (MG3), `pzf44` (Panzerfaust 44, hazırlık adımları ve görsel dahil). Değerler kaynaksız tahmindir.

Dönem içeriğinin silahları (S.O.G. `vn_*`, GM `gm_*`, CSLA `CSLA_*`) kalibre ve alt dize eşleşmeleriyle büyük ölçüde tanınır; tabloda adı bulunamayanlar "GENEL" profile düşer. Hangilerinin düştüğünü görmek için mod yüklüyken tarama aracı çalıştırılır (`["vn_"] call TAC_fnc_wpnScan`, `["gm_"] ...`, `["csla"] ...`); çıktıya göre eşleşmeler eklenir.

**S.O.G. Prairie Fire taraması (`vn_`, 0.36.1):** taramada 129 silah "GENEL" profile düşmüştü; düzeltmeler:
- Mühimmatsız "silahlar" (bıçak, kazma, el aleti: `vn_m_*`) artık takip edilmez (arıza / bakım menüsü çıkmaz).
- `vn_xm177*`, `vn_type56*`, `vn_ak_01`, `vn_kbkg*`, `vn_ppsh41`, `vn_k50m`, `vn_gau5a*`, `vn_type64*` MG değil tüfek sayılır (büyük tambur şarjörler yüzünden MG çıkıyordu); `vn_mg42` MG sayılır.
- `vn_m16*` M16A1 (MRBS 1500) profilindedir (mod açık / kapalı fark etmez), `xm177` ayrı profil; `xm148` eki yüzünden M14 sanılan `vn_xm177_xm148*` ve `vn_l34a1_xm148` düzeltildi.
- Yeni dönem profilleri (hepsi **tahmin**): Stoner 63, BAR M1918, Bren L4, RPD, DP-28, PK, M79, pompalı / av tüfeği, dönem SMG'leri (PPSh, PPS, MAT-49, Sterling, Thompson, vz.61...), M1 / M2 Carbine, Garand, SKS M4956, M21 / L2A1, dönem sürgülü tüfekleri (Springfield, Kar98k, MAS-36, Mosin, vz.54).
- Fırlatıcılar: `vn_rpg2` ve `vn_m20a1b1` (bazuka) güdümlü sanılıyordu, güdümsüz yeniden doldurulabilir oldu.
- `vn_sa7`, `vn_rpg7`, `vn_m72` zaten doğru tanınıyordu. Statik silahlar (M2, M1919, M60, DShK, PK, RPD, SGM, MG42, ZPU-4, ZGU-1, Maxim) doğru türde.
GM (`gm_`) ve CSLA taramaları bekleniyor.

Beğenmediğin bir değeri CBA'daki `MRBS tablosu` ayarına `classname=MRBS` yazarak (ör. `rhs_weap_m4a1=2500, CUP_arifle_AK74=4000`) ezebilirsin; Silahı incele kartında silahçı, silahın profilini (etiket, MRBS, kalite) görür.

**Kaynaklar:**
[M4 aşırı toz testi (The Firearm Blog)](https://www.thefirearmblog.com/blog/2007/12/19/m4-beaten-by-piston-carbines/) ·
[M4 toz testi tartışması (ShadowSpear)](https://shadowspear.com/threads/m4-carbine-fares-poorly-in-dust-test.1667/) ·
[Ordu: M4A1 3.592 MRBS şartı (Military.com, 2013)](https://365.military.com/daily-news/2013/06/14/army-gun-makers-didnt-meet-reliability-standard.html) ·
[Improved Carbine yarışması (Breaking Defense, 2013)](https://breakingdefense.com/2013/06/army-killed-new-carbine-because-it-wasnt-twice-as-good-as-current-m4/2/) ·
[M60 / M240 2002 testi (StrategyPage)](https://www.strategypage.com/htmw/htweap/articles/20021218.aspx) ·
[M240 / M60 güvenilirlik (SA Defense Journal)](https://sadefensejournal.com/?p=164) ·
[M17/M9 güvenilirlik şartları (Military.com, 2019)](https://365.military.com/kitup/2019/02/21/pentagon-says-design-fixes-improve-reliability-new-army-service-pistol.html) ·
[AK işkence testleri (Thin Line wiki)](https://thinlineweapons.com/wiki/index.php/Torture_Testing)

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
| `TAC_wpn_jamScale` (arıza ihtimali ölçeği; 1 = gerçek MRBS) | 1 |
| `TAC_wpn_jamCooldown` (iki arıza arası asgari atış) | 60 |
| `TAC_wpn_mrbsTable` (elle MRBS: `classname=MRBS, ...`) | boş |
| `TAC_wpn_wearLife` (parça ömrü, atış) | 15000 |
| `TAC_wpn_suppressorMult` | 1.6 |
| `TAC_wpn_env` (ortam etkisi) | açık |
| `TAC_wpn_mgThreshold` (MG eşiği) | 60 |
| `TAC_wpn_mgTable` (MG olarak zorla, virgülle) | boş |
| `TAC_wpn_needKit` (bakım malzemesi gerekli) | açık |
| `TAC_wpn_fx` (bakım hareketi ve sesi) | açık |
| `TAC_wpn_cleanTimeMult` (bakım süresi çarpanı) | 1 |
| `TAC_wpn_testMode` / `TAC_wpn_testMult` (test çarpanı) | kapalı / 20 |
| `TAC_wpn_debug` (arıza nedeni göstergesi) | kapalı, kişisel |

### Başka modların silahlarıyla uyum (TMT, RHS, CUP...)

Sistem classname'e **ve görünen ada**, bilinmeyen silahta mühimmat **kalibresine** ve **kategoriye** (tüfek / MG / tabanca / fırlatıcı / güdümlü) bakar; yani TMT gibi tabloda adı olmayan modların silahları da bir profil alır (kalibre yedeği, "tahmin"). Doğrulamak ve yanlış sınıflananı bulmak için tarama aracı:

```sqf
["tmt"] call TAC_fnc_wpnScan     // classname'inde "tmt" geçen tüm silahlar ve statikler (mod yüklüyken, yerel çalıştır)
```

Çıktı (ekrana özet, RPT'ye `[TAC][SCAN]` satırları, panoya tam liste) her silah için kategori, güvenilirlik profili (etiket, MRBS, kalite), kayışlı MG mi, fırlatıcıysa tür ve taban ateşlenmeme; tabloda adı bulunamayıp **GENEL** profile düşenleri işaretler; statik silahlar için atanan türü yazar.
Yanlış çıkanı elle düzeltmek: CBA `MRBS tablosu` (`classname=MRBS`), `MG olarak zorla`, `Ateşlenmeme tablosu`. Kalıcı düzeltme için çıktıyı bana gönder, tablolara alt dize eklenir. ACE yedek namlu / namlu değiştirme için MG'nin ACE'de işaretli (`ace_overheating_allowSwapBarrel`) olması gerekir; TMT MG'leri işaretli değilse besleme prosedürü ve namlu değiştirme onlarda çıkmaz (gerekirse ayrı bir TMT uyumluluk PBO'su yazılır: sınıf adları gerekir).

**TMT (taranıp doğrulandı, 99 silah + 5 statik):** tüm TMT M4 / M16 / HK416 / SVD / AK / PKM / Minimi / M60E4 / M72 / Stinger / TOW eşleşti. GENEL'e düşenler için eşleşmeler eklendi: Tar-21, Sig516, HK G3A4 / HK33, MPT-76, M200 / L115 / JNG90 (sürgülü), M82, M92 (Beretta), düz TMT_M4, MG3, Milkor MGL, ERYX (güdümlü). TMT MG'leri ACE'de namlu değiştirilebilir işaretli olmadığı için kayışlı MG sayılmıyordu; artık güvenilirlik profili kayışlı aileden (M60, M240, M249 / Minimi, PKM, MG3) olan MG'ler ACE işareti olmasa da kayışlı sayılır ve besleme prosedürü çıkar.

**TMT, 2. tarama (146 silah):** eşleşmeler eklendi: MPT-76 / KNT-76 (G3 ailesi profili), MPT55 / KCR556 / SAR-223 / HK33 (5.56 modern), SAR-308 (AR-10 tipi), SAR-56 (AK ailesi), Bora-12 / Accuracy (sürgülü), Canik TP9 / Zigana PX9 (modern 9 mm tabanca). MPT76_AK40 gibi adlardaki "AK40" bir optik adı olduğu için artık AK ailesine karışmaz (MPT / KNT satırları AK satırından önce eşleşir). Kayışlı olmayan tüfeklerin (SAR-308 gibi) magazineWell'lerindeki tambur / kutu şarjörler yüzünden MG sayılması engellendi.

### Silahı yere atmak / başkasının alması (kalıcılık)

Silah yere / kutuya / araca / cesede konunca **her şey** silahla birlikte saklanır ve alan kişiye (aynı oyuncu ya da başkası) geçer:

| Ne | Saklanan / devralınan |
|----|----------------------|
| Bakım durumu | kir, yağ, aşınma, son arıza, arıza sayısı |
| MG besleme | hazır mı, prosedür ilerlemesi |
| Optik | lens buğusu ve kiri |
| ACE namlu sıcaklığı | bırakıldığı andaki sıcaklık; geçen süre için ACE'nin soğuma hesabıyla (ortam sıcaklığına kadar) soğutulup yeni sahibine yazılır |
| Roketatar | tüp aşınması, zar / ateşlenmeme / bekleme, hazırlık ve prosedür ilerlemesi, güdümlüde güç / soğuma / pil (açık kalma süresi önce pilden düşülür) |

**İki katmanlı kayıt:** durum hem bırakılan **kapta** (`TAC_stash`, herkese yayınlanır) hem **yedek genel listede** (`TAC_stashGlobal`, en çok 60 kayıt: sınıf, konum, zaman) tutulur. Motor envanterden atılan eşya için bazen farklı / yeni bir yer-kabı yarattığından kap değişkeni kaybolabilir; o zaman aynı sınıftan **8 m içindeki en yeni** kayıt devralınır. Bulunan kayıt iki yerden de silinir.
Sabit silahlarda (taret) durum zaten araçta, herkese yayınlanan değişkende tutulur (taşınmaz, silah araçla kalır).
"At, yenisini al" hilesi yok: aynı sınıftan yeni (arsenal) silah sıfırdan başlar. Mühimmat nemi (roket) birime bağlıdır, taşınmaz. Test göstergesi (`TAC_wpn_debug`, `TAC_rkt_debug`) bırakma ve alma satırlarını yazar (hangi kayıtlar saklandı / devralındı, sıcaklık değişimi).
**Sınırlar:** kap yok olursa ve 8 m yedeği de tutmazsa (uzağa atılmış / başka biri aldıysa) durum kaybolur; ölü oyuncunun silahı alana sıfırdan başlar; aynı sınıftan iki silah taşıyorsan durumu paylaşırlar. ACE yedek namlu sıcaklıkları (ayrı magazine'ler) buradan bağımsızdır.

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

## Özellik 7 – Makineli tüfek: yedek namlu ağırlığı + sıcak namlu yanığı

ACE overheating zaten ısıyı, yedek namlu değiştirmeyi (yardımcı veya kendin), namlu sıcaklığı takibini ve cook-off'u yapıyor; bu modül onun **üstüne** gerçekçilik ekler, ACE'nin akışını değiştirmez.

### Yedek namlu ağırlığı (envanterde)

ACE'nin yedek namlusu tüm MG'ler için tek tip ve 25 birimdi (~1.1 kg). Arma kütle birimi: **22 birim = 1 kg** (ACE de aynı oranı kullanır). Gerçekçi değerler:

| Sınıf | Silahlar | Kütle | Yaklaşık |
|-------|----------|-------|----------|
| `TAC_SpareBarrel_Light` | MX SW, Mk200, LIM-85 (5.56 / 6.5 mm SAW tipi) | 42 | ~1.9 kg |
| `ACE_SpareBarrel` (orta) | Zafir ve **ACE varsayılanını kullanan her MG**: RHS (PKM/PKP, M240, MG42...), CUP (M240, M60, MG3, Mk48, PKM, UK59), TMT | 59 (eskiden 25) | ~2.7 kg |
| `TAC_SpareBarrel_Heavy` | Navid (9.3), SPMG (.338) | 84 | ~3.8 kg |

**RHS ve CUP uyumluluk yamaları** (opsiyonel PBO'lar, yukarıdaki derleme bölümü): yalnızca **5.56 mm Minimi ailesine hafif namlu** atar; diğer her şey orta kalır.

| PBO | Gerekli mod | Hafif namlu verilen sınıf | Kapsam |
|-----|-------------|---------------------------|--------|
| `tac_compat_rhs` | RHS USAF (`rhsusf_main_loadorder`) | `rhs_weap_saw_base` | tüm RHS Minimi / M249 / Mk46 türevleri |
| `tac_compat_cup` | CUP Weapons (`CUP_Weapons_LoadOrder`) | `CUP_saw_base` | CUP Minimi / M249 (minimi, para, railed, pip1-4, E2) |

Sınıf ve üst sınıf adlarını ACE'nin kendi `compat_rhs_usf3` ve `compat_cup_weapons` yamalarından birebir aldım (kendi derlemelerinde çalışan ad ve hiyerarşi). RHS/CUP güncellenip adları değişirse yamanın derlemesi yine geçer ama atama sessizce uygulanmaz: o silah orta namluya döner.

- ACE'nin envanter-eşyası sarmalayıcısı `ACE_SpareBarrel_Item` de 59 olur (editör/arsenal tutarlılığı).
- Atama ACE'nin kendi config özelliğiyle yapılır: `ace_overheating_barrelClassname`. Sınıf ve üst sınıf adları ACE'nin overheating yamasıyla aynıdır (derleme hatası olmaz).
- **ACE'nin ısınma hesabı değişmez** (namlu ısı kütlesi): yalnızca envanter ağırlığı. İstersek ısı kütlesini de bu değerlere çekeriz; MG'ler daha hızlı ısınır.
- Değerler yaklaşık: gerçekte silah modeline göre değişir. İstediğin silaha farklı namlu atamak için `mg/CfgWeapons.hpp`'ye `ace_overheating_barrelClassname = "..."` eklemen yeterli.
- Incele kartı (MG): `Yedek namlu: 2 (her biri ~2.7 kg)`.

### Sıcak namlu yanığı

ACE ile namlu değiştirilirken (kendin ya da yardımcı) çıkarılan **namlunun sıcaklığı** eşiğin üstündeyse ve namluyu tutan oyuncuda **Isı Eldiveni** (`TAC_HeatGlove`) envanterde **yoksa** sağ kolda yanık oluşur.

- Hasar: `maksimum x (0.3 + 0.7 x clamp((sıcaklık - eşik) / 350, 0, 1))`. ACE tıbbı varsa `ace_medical_fnc_addDamageToUnit` ("RightArm", "burn"), yoksa vanilla `HitHands`.
- **Oyuncuya bildirim yok**: acı ve yara ACE tıbbından görünür.
- Eldiven tükenmez; envanterde bulunması yeterli.
- MP: ACE'nin sunucu olayına (`ace_overheating_loadCoolestSpareBarrel`) sunucuda dinleyici bağlanır, sıcaklık eşiğin üstündeyse namluyu tutan oyuncuya olay gönderilir; hasar yalnızca onun makinesinde (yerel birim) uygulanır.

### CBA ayarları (`... > TAC - Gerçekçilik Paketi > Makineli tüfek (namlu)`)

| Ayar | Varsayılan |
|------|-----------|
| `TAC_mg_burn` | açık |
| `TAC_mg_burnTemp` (°C eşiği) | 150 |
| `TAC_mg_burnDamage` (azami hasar) | 0.35 |
| `TAC_mg_feedStep` (besleme kapağı adımı, 7b) | açık |
| `TAC_mg_debug` (test göstergesi) | kapalı, kişisel |

### Test adımları

1. Debug konsolunda (yerel çalıştır): MG + yedek namlu:
   ```sqf
   player addWeapon "arifle_MX_SW_F"; player addMagazines ["100Rnd_65x39_caseless_mag", 8];
   player addMagazine "TAC_SpareBarrel_Light"; player addMagazine "TAC_SpareBarrel_Light";
   ```
   Envanterde yedek namlunun ağırlığına bak (~1.9 kg). Navid/SPMG ile `TAC_SpareBarrel_Heavy`, Zafir/RHS MG'siyle `ACE_SpareBarrel` dene.
2. Test göstergesini aç. Sıcak ateşle namluyu ısıt (ACE'nin sıcaklık eylemiyle kontrol edebilirsin: ACE self-menü > Namlu sıcaklığı).
3. Namlu değiştir (ACE self-menü > Namlu değiştir, ya da yardımcıyla). Eldivensiz sıcak değiştirince sağ kolda yanık oluşmalı; ekranda `sicaklik / esik / eldiven / hasar` yazmalı.
4. `player addItem "TAC_HeatGlove"` ile eldiven ekle, tekrar dene: yanık olmamalı.
5. Soğuk namluyu (eşiğin altında) değiştir: yanık olmamalı.
6. Zafir / RHS PKM / CUP M240 (atanmamış): orta namlu (`ACE_SpareBarrel`, ~2.7 kg) kullanılmalı.
6b. **RHS / CUP Minimi** (compat PBO'ları yüklüyse): `weapon player` ile sınıfı doğrula, `player addMagazine "TAC_SpareBarrel_Light"` ekle, ACE ile değiştir: hafif namlu (~1.9 kg) kullanılmalı. `getText (configFile >> "CfgWeapons" >> currentWeapon player >> "ace_overheating_barrelClassname")` değeri `TAC_SpareBarrel_Light` dönmeli. Compat PBO'sunu çıkarıp aynı testi yap: orta namluya dönmeli.
7. `call TAC_fnc_wpnDebug` ile MG kategorisini, Silahı incele ile yedek namlu satırını doğrula.

> Sonraki adım (7b): besleme kapağı / kayış adımı.

## Özellik 8 – Optik: buğulanma ve kirlenme

Yalnızca **2D resimli büyütmeli dürbünler** etkilenir (ACOG, RCO, tarama dürbünleri...). Config ölçütü: `ItemInfo >> OpticsModes` altında en az bir mod `useModelOptics = 1` **ve** büyütme >= 1.5
(`opticsZoomMin <= 0.16`; Arma'da 0.25 = 1x). Kırmızı nokta, holografik ve diğer 1x nişangahlar (bazıları `useModelOptics = 1` kullansa da), 3D (PiP) dürbünler ve demir nişan **etkilenmez**. Etki **yalnızca optikten bakarken** görünür: görüntü bulanır ve kontrast düşer.
**Çok modlu optik:** Ctrl + sağ tıkla kırmızı nokta / demir nişan moduna geçince efekt **kapanır** (`getTurretOpticsMode` ile mevcut mod, optiğin `OpticsModes` sınıfıyla eşleştirilir; mod alınamazsa eski davranış). Büyütmeli moda dönünce efekt geri gelir, lens durumu korunur.
Yine **oyuncuya bildirim yok**; durum "Silahı incele" kartında gözlem diliyle okunur.

### Model (silah başına: buğu 0-100 ve kir 0-100)

| Değer | Nasıl artar | Nasıl azalır |
|-------|-------------|--------------|
| **Buğu** | optikten bakarken, soğukta ve ıslakta: `hız x fogF`, `fogF = min(1, 0.7 x soğuk + 0.6 x ıslaklık)`; soğuk = `(10 - sıcaklık)/15` (10 °C ve üstü 0, -5 °C altı 1), ıslaklık = yağmur ya da sığ su | koşul yoksa bakarken saniyede 0.8; **bakmıyorken** saniyede 1.5 (bakışın başında hesaplanır); optiği silince 0 |
| **Kir** | atış başına `0.05 x ortam çarpanı` (silah bakımındaki aynı ortam çarpanı: yağmur, tozda yatma); yağmurda optikten bakarken saniyede 0.15 x yağmur | optiği silince %70 azalır; **Silahı temizle** (tam temizlik) kiri %5'e, buğuyu 0'a indirir |

Etki seviyesi `min(1, (buğu + 0.6 x kir)/100)`: bulanıklık `En fazla bulanıklık x seviye^1.3` (DynamicBlur), kontrast düşüşü `0.3 x pus ayarı x seviye` (ColorCorrections).
Sıcaklık vanilla `ambientTemperature` ile okunur (ACE hava durumu gerekmez).

### ACE self-menü > Silah Bakımı

- **Optiği sil:** 4 sn (bakım süresi çarpanı kadar), `Lens Bezi` (`TAC_LensCloth`, tükenmez) ister. Buğu 0, kir %70 azalır.
- **Silahı incele** kartına satır eklenir: `Optik lensi: temiz | buğu: yok` (silahçı yüzdeleri de görür).

### CBA ayarları (`... > TAC - Gerçekçilik Paketi > Optik (buğu / kir)`)

| Ayar | Varsayılan |
|------|-----------|
| `TAC_opt_enabled` | **kapalı** (varsayılan; açınca sistem devreye girer) |
| `TAC_opt_fogRate` (saniyede % buğulanma) | 1.5 |
| `TAC_opt_shotDirt` (atış başına % kir) | 0.05 |
| `TAC_opt_rainDirt` (yağmurda saniyede % damlacık) | 0.15 |
| `TAC_opt_blurMax` (en fazla bulanıklık) | 2, kişisel |
| `TAC_opt_haze` (kontrast kaybı) | 0.3, kişisel |

Test hızlandırması silah bakım sisteminin `Test modu` / `Test çarpanı` ayarını kullanır (x20).

### MP mantığı (optik)

Tamamen yerel oyuncuda: durum birimin üzerinde, görsel etki yalnızca oyuncunun ekranında. Ağa hiçbir şey yayınlanmaz, sunucuya yük sıfır, yapay zekâ için kod çalışmaz.
Döngü yalnızca kapalı lensli optikten bakarken vardır (CBA `cameraView` olayı başlatıp durdurur); bakmıyorken sıfır maliyet. PP efektleri bir kez yaratılıp kalıcı tutulur.
Durum "birim + silah sınıfı" başınadır; silah yere atılınca optik durumu silah bakımı gibi **taşınmaz** (buğu zaten geçici, kir ise silmeyle kolay temizlenir).

### Test adımları

1. Kapalı lensli optikli bir silah al (ör. vanilla `arifle_MX_F` + `optic_Hamr` ya da RHS ACOG) ve `player addItem "TAC_LensCloth"`. Silah Bakımı Test modunu aç (x20).
2. **Soğuk / yağmur:** Debug konsolunda `0 setRain 1; setDate [2026,1,1,6,0]` ya da yeterince soğuk bir harita/saat dene. Nişan alıp optikten bak: birkaç saniyede görüntü bulanmalı. Nişanı bırakıp biraz bekle: tekrar bakınca buğu azalmış olmalı.
3. **Atışla kir:** Test modunda ~100 atış sonra optikten bak: hafif bulanıklık. Silah Bakımı > **Silahı incele**: `Optik lensi: lekeli`.
4. **Optiği sil:** menüden sil, buğu gitmeli, kir azalmalı. **Silahı temizle** ile kir ~%5'e inmeli.
5. **Kırmızı nokta / demir nişan:** hiçbir bulanıklık olmamalı, incele kartında optik satırı çıkmamalı.
6. Ayarlardan `En fazla bulanıklık`'ı 0 yap: bulanıklık kalkar, kontrast hâlâ düşer. `Kontrast kaybı`nı 0 yap: görüntü bozulmaz.
7. **Dikkat edilecekler (görsel):** `ColorCorrections` optiğin siyah çerçevesini hafif grileştirebilir; rahatsız ederse `Kontrast kaybı`'nı düşür. Bulanıklık tüm ekranı etkiler (reticle dahil).

## Özellik 7b – MG besleme kapağı adımı

**Yalnızca kayışlı MG'ler** (MG kategorisi + ACE'nin namlu değiştirilebilir MG işareti: M249, M240, PKM, MG3, Mk200, MMG...; tamburlu MX SW tipi hariç) ve eylem yalnızca bu silah **elde seçiliyken** görünür. MG'ye şarjör veya kayış takılınca (`Reloaded`) silah **hazır sayılmaz**. ACE self-menü > Silah Bakımı > **Kayışı yerleştir, kapağı kapat** (4 sn, silah hareketi ve ses) yapılmalı.
Yapılmadan ilk atışta **besleme arızası** (ACE `feed`, bir kez) çıkar; ACE'nin arıza gider eylemleriyle düzelir. İncele kartında `Besleme: hazır / kayış yerleştirilmedi`. CBA: `TAC_mg_feedStep` (açık). Başlangıçta ve tüfek / tabancada adım yoktur.

## Silaha ve başlığa özel hazırlık prosedürleri (MG besleme, roketatar atışa hazırlama)

MG besleme ve roketatar atış hazırlığı artık tek bir "hazırla" düğmesi değil, **silaha (ve roket başlığına) özel, oyuncunun kendisinin sırayla uygulaması gereken prosedürlerdir**:

- ACE self-menü > Silah Bakımı > **Besleme prosedürü** (kayışlı MG elde seçiliyken) ve Roketatar > **Atış hazırlığı prosedürü** altında silaha özel **adımlar ayrı ayrı** listelenir (ör. "Emniyet kapağını çıkar", "Başlığı itici barutla birleştir", "Horozu kur").
- Adımlar menüde **alfabetik** sırayla durur, doğru sırayı **oyuncu bilmelidir** (sıra ipucu verilmez). Yapılan adım kendi ilerleme çubuğu, hareketi ve sesiyle yürür; tamamlanan adımlar menüden kalkar.
- **Yanlış sırada** bir adım yapılırsa (adım yine de zaman alır) prosedür **sıfırlanır** ("Hatalı sıra: prosedür baştan başlamalı"), baştan başlanır. Tüm adımlar doğru sırayla bitince silah hazır olur.
- İncele kartında "Prosedür: N adım tamamlandı" yazar; doğru sıra kartta veya menüde gösterilmez.
- Süreler `Bakım süresi çarpanı` ile çarpılır (saniye, yaklaşık). Aşağıdaki tablolar **doğru sırayı** gösterir (oyuncuya gösterilmez).

**Sürgü / şarj kolu adımları varsayılan olarak yoktur** (reload animasyonu sürgüyü zaten çeker): aşağıdaki tablolardaki "sürgüyü çek", "kolu çek", "sürgü kolunu çek" adımları CBA `Sürgü / şarj kolu adımı` (`TAC_mg_chargingStep`, varsayılan kapalı) açılırsa devreye girer. Bu, sabit silahlar için de geçerli. Roketatarın "horozu kur" gibi elle yapılan adımları korunur.

**MG besleme (elde seçili kayışlı MG):**

| Silah | Adımlar |
|-------|---------|
| M249 / Minimi / Mk46 | kapağı aç (1.5) > tepsiyi kaldır, yatağı kontrol et (2) > kutuyu tak (2) > kayışı yerleştir (2.5) > kapat, kilidi kontrol et (1.5) > sürgüyü çek (1.5). **Kaynak: TM 9-1005-201-10 (Loading)** |
| M240 / Mk48 / M60 | kapağı aç (1.5) > tepsiyi kaldır, yatağı kontrol et (2) > kayışı yerleştir, açık yan aşağı (2.5) > kapat, kilidi kontrol et (1.5) > sürgüyü çek (1.5). **Kaynak (M240): TM 9-1005-313-10 (Loading)**; Mk48 / M60 aynı sıra = tahmin |
| PKM / PKP / Zafir | kapağı aç (1.5) > kayışı tepsiye yerleştir (2.5) > kapat (1) > sürgüyü çek (1.5) |
| MG3 / MG42 / UK59 | kapağı kaldır (1.5) > kayışı yerleştir (2.5) > indir (1) > kolu çek (2) |
| Navid / SPMG (ağır MMG) | aynı adımlar, daha uzun (2 / 3 / 1.5 / 2) |
| diğer kayışlı MG | kapağı aç (1.5) > kayışı yerleştir (2) > kapat (1) |

**Roketatar atışa hazırlama (fırlatıcıya göre):**

| Fırlatıcı | Adımlar |
|-----------|---------|
| RPG-7 / RPG-32 | emniyet kapağını çıkar (2) > başlığı itici barutla birleştir (3) > horozu kur (2) |
| M72, RPG-18/22/26/75 | emniyet pimini çek (1.5) > tüpü uzat (2-2.5) |
| M136 / AT4 | kapakları çıkar (2) > emniyeti aç, nişangahı kaldır (2) |
| NLAW / APILAS | emniyet kapaklarını aç (2) > nişangahı kaldır, sistemi çalıştır (2.5) |
| SMAW / Mk153 | tüp kilidini kontrol et (2) > fünye ayarı ve emniyeti aç (2) > horoz (1.5) |
| MAAWS / Carl Gustaf / MRAWS | kama kilidini kontrol et (2) > emniyeti ve ateşleme modunu ayarla (2.5) > horoz (1) |
| Panzerfaust | emniyet çevirmesini aç (2) > tüpü ve nişangahı kaldır (2) |
| Javelin | BCU'yu bağla (2) > CLU'ya güç ver (2) > arayıcı soğutmasını başlat (2) |
| Stinger / FIM-92 | BCU / soğutucu kartuşunu tak (2.5) > güç ver (1.5) > IFF ve arayıcıyı başlat (2) |
| Igla / Strela | pil-soğutma ünitesini tak (2.5) > güç ver (1.5) > arayıcıyı başlat (2) |
| Titan / Vorona / Metis / TOW | güç ve sistem kontrolü (2.5) > arayıcıyı başlat (2) |
| tanınmayan | türe göre tek adım (tek kullanımlık 3, omuz atarı 5, güdümlü 6 sn) |

**Başlığa özel ek adım (güdümsüz roketlerde, son adımdan önce):** mühimmatın `warheadName` / sınıf adına göre: **tandem** -> çift fünye kontrolü (2.5), **termobarik** -> emniyet halkası kontrolü (2), **HE / parçalı** (OG-7 vb.) -> fünye ayarı ani / gecikmeli (2). HEAT'te ek adım yok.
Sıralar ve süreler gerçek prosedürlere yaklaşık, oyun temposuna göre ayarlandı (tahmin). Değiştirmek için `weapon/fn_wpnFeedSteps.sqf` ve `rocket/fn_rktPrepSteps.sqf` içindeki tablolar.

**Kaynak (FM 3-23.25, ABD Ordusu, 2006):** M136 AT4, M72 ve M141 BDM hazırlık adımları ve misfire bekleme süreleri bu kılavuzdan alındı (AT4: pim, omuz dayanağı, nişangah+menzil, horoz; M72: pim, tüpü uzat, kilidi dene; M141: iç tüp kilidi, ARMED kapağı). Kılavuzun yalnızca güdümsüz omuz silahlarını kapsadığını unutma; Javelin/Stinger/TOW/Igla adımları hâlâ tahmin.

## Özellik 10 – Koop yardımı (arkadaş silah hazırlığına yardım eder) ve MP uyumluluğu

**Kullanım:** yardım edeceğin arkadaşa bak, **ACE etkileşim tuşuna** (varsayılan sol Windows) bas > **Silah yardımı**. Arkadaşın durumuna göre altta:

- **MG besleme prosedürü:** arkadaşın elinde seçili kayışlı MG var ve besleme hazır değil.
- **Atış hazırlığı prosedürü:** arkadaşın fırlatıcısı yüklü ve hazır değil (güdümlü füzede pil / soğutma açılışı dahil).

Adımlar silaha ve başlığa özeldir, alfabetik listelenir (doğru sırayı **yardımcı** bilmelidir). Yardımcının çubuğu yürür; her adım `Yardımlı adım süre çarpanı` (0.7, ikili çalışma daha hızlı) ile kısalır. Adım arkadaşın makinesine gider ve **orada** sıra doğrulanır: yanlış sıra prosedürü sıfırlar, doğru adımlar birikir, son adımda silah hazır olur. Arkadaş kendi adımlarıyla da yardımcıyla da ilerleyebilir (aynı ilerleme).
Koşullar: aynı taraf, oyuncu, 4 m içinde, ikisi de yaşıyor ve bilinci açık. CBA: `TAC_assist_enabled`, `TAC_assist_speed`.

### MP / coop denetimi

| Konu | Durum |
|------|-------|
| Silah / optik / roket durumu, nem, zarlar | birimde **yerel**, ağa yayılmaz; ayarlar sunucudan senkron / `force` edilebilir |
| Hazırlık ilerlemesi (yardım için) | yalnızca küçük, değişince yayınlanan `TAC_pub_feed` / `TAC_pub_rkt` |
| Yardım adımı | yardımcıdan, durumun sahibinin makinesine **CBA hedefli olayı** (`TAC_assistStep`); doğrulama ve sonuç sahipte |
| Hasar (namlu yanığı, roket erken müdahale yok) | yalnızca yerel birime, sahibin makinesinde |
| UXO (patlamamış mühimmat) | sunucuda yaratılır (`enableSimulationGlobal` yalnızca sunucuda çalışır), herkese görünür |
| Fırlatıcı / silah bırakma-alma durumu | kapta herkese yayınlanan `TAC_rkt_stash` / `TAC_wpn_stash` |
| Dedicated sunucu / HC | sunucuda yalnızca olay dinleyicileri (UXO, namlu yanığı yönlendirmesi, yardım olayı); arayüz kodu `hasInterface` ile atlanır |
| Ses | `playSound3D` global: yakındaki herkes bakım seslerini duyar |

### Tek başına test

CBA'da silah bakımı **Test modu**nu aç: ACE self-menüsünde **Silah yardımı (test: kendi silahım)** çıkar. Yardımcı da hedef de sen olursun, adım yine olay yoluyla (gerçek koop yolu) uygulanır. Adımları yardımlı yoldan (kısaltılmış süreyle) uygula; kendi prosedür menünle karşılaştır. Gerçek iki kişilik testte (arkadaşın makinesi) aynı akış çalışır; tek kişilikte ağ gecikmesi / yerellik farkları test edilemez.

## Arıza sıklığı ve MG menüsü (0.26)

- **Optik buğu / kir modülü varsayılan olarak KAPALI.** CBA > Optik (buğu / kir) > "Optik buğu / kir sistemi aktif" ile açılır; kapalıyken lens kirlenmez, görüntü bozulmaz, "Optiği sil" menüsü çıkmaz.
- **Arızalar arası asgari atış** (`TAC_wpn_jamCooldown`, varsayılan 60): bu sistemden çıkan iki arıza arasında en az bu kadar atış geçer, kirli silahta peş peşe tutukluk zinciri olmaz. ACE'nin kendi ısı arızası bundan bağımsızdır (kaynağı test göstergesi yazar: "KAYNAK: ACE" ya da bizim sistem).
- **Test modu açık kalmışsa** (silah bakım `Test modu`, x20) kirlenme, yağ kaybı ve aşınma 20 kat hızlanır ve ~100 atışta silah tam kirli olup sık tutukluk yapar: normal oyunda KAPALI olmalı.
- **Vanilla `arifle_*` silahlar (MX, MX SW, Katiba, Mk20, SPAR...) artık hiçbir zaman MG / kayışlı sayılmaz** (0.26.1): ortak şarjör kümelerindeki (magazineWell) 100-200 mermilik tambur ve kutu şarjörler yüzünden tüfekler MG sanılıyor, her reload sonrası ilk mermide "besleme prosedürü" istenip ilk atışta besleme arızası çıkıyordu. Vanilla kayışlı MG'ler `LMG_*` / `MMG_*` adlıdır.
- **Kayışlı MG ölçütü sıkılaştı:** MG kategorisi + en büyük şarjör / kayış kapasitesi >= 75 + (ACE namlu değiştirme işareti veya profil M60 / M240 / M249 / PKM / MG3 ailesi) + adı tamburlu / MX SW değil. Tüfekler (60-70 mermilik tambur taşıyanlar dahil) besleme prosedürü menüsü görmez.

## Etkileşim kuralı: silah ELDE olmalı

Silah bakımı, MG besleme, roketatar ve optik menüleri **yalnızca ilgili silah elde seçiliyken** açılır; hem kendin için hem arkadaşına yardım ederken:

| Menü | Koşul |
|------|-------|
| Silah Bakımı (incele, temizle, yağla, arıza gider, parça değiştir) | elde seçili, takip edilen silah (tüfek / MG / tabanca); sırtta ya da seçili değilse menü yok |
| MG besleme prosedürü | elde seçili **kayışlı MG** |
| Optiği sil | elde seçili birincil silahta büyütmeli optik |
| Roketatar (incele, hazırlık, kurula, pil, mühimmat çıkar) | fırlatıcı elde seçili **ve** yüklü mühimmat (roket başlığı / füze) var |
| Arkadaşa yardım (Silah yardımı) | **arkadaşın** MG'si / fırlatıcısı elinde seçili (MG: yüklü kayışlı; fırlatıcı: yüklü mühimmat) |

Hazırlık adımları da (kendi ya da yardımlı) adım bitiminde silahın hâlâ elde olduğunu doğrular: silah değiştirilirse adım uygulanmaz. Sabit silahlarda kural zaten gunner koltuğu / silahın yanı.

## Özellik 9 – Roketatar / füze: ateşlenmeme ve doktrin

Yalnızca RPG-7 değil, **ikincil silah olan her fırlatıcı** (vanilla, RHS, CUP) kapsanır; tür config'ten / sınıf adından belirlenir:

| Kategori | Örnekler (sınıf alt dizesi) | Taban ateşlenmeme | Ateşlenmezse |
|----------|------------------------------|------------------:|--------------|
| Tek kullanımlık, eski / Doğu | M72, RPG-18/22/26/75, RShG | %2 | fırlatıcı güvenle çıkarılıp atılır |
| Tek kullanımlık, modern | M136/AT4, NLAW, APILAS | %1 | aynı |
| Panzerfaust (eski) | panzerfaust, pf60 | %5 | aynı |
| RPG-7 tipi (yeniden doldurulabilir) | RPG-7, RPG-32 | %2 | mühimmat atılır, tüp boşalır |
| Modern omuz atarı | SMAW, MAAWS/Carl Gustaf, Mk153, MRAWS | %0.8 | aynı |
| Güdümlü füze | Javelin, Titan, Stinger/FIM-92, Igla, Strela, Metis, TOW | %2.5 | aynı |
| Tanınmayan | mühimmatın yönlendirme alanlarına (manualControl, lock, maxControlRange) bakılır: güdümlü %2.5, değilse omuz atarı %2 | | |

**Bu taban oranlar tahmindir:** yayımlanmış tek bir sayı bulamadım. Eski / Doğu bloku mühimmatı ve eski silahlarda yüksek, modern sistemlerde düşük aldım. Beğenmediğini CBA `Ateşlenmeme tablosu` ayarıyla ez (`launch_RPG7_F=3, rhs_weap_rpg7=3`).

### Model

```
p = taban x ölçek x (1 + soğuk + 0.5 x ıslaklık + aşınma + 0.8 x nem/100 + sıcak)        üst sınır %50
soğuk = clamp((5 - sıcaklık °C) / 30, 0, 1)       ıslaklık = yağmur (0..1), sığ suda 1
aşınma = clamp(atış / 300, 0, 1)  (yeniden doldurulabilir ve güdümlü; tek kullanımlıkta yok)
nem = taşınan mühimmatın zamanla biriken nemi 0..100 (aşağıya bak; tek kullanımlıkta sızdırmaz tüp: etkisi yarım)
sıcak = clamp((sıcaklık - 35) / 15, 0, 1) x 0.3
```

- **Zar tetik çekilirken, bir yüklü mühimmat için bir kez atılır** (reload veya başarılı atışta sıfırlanır). Ateşlenmeme çıkarsa ACE'nin arıza sistemindeki mekanizmayla (`DefaultAction` dinleyicisi) **atış tamamen engellenir**: mermi hiç çıkmaz, ACE geri tepme alanı da oluşmaz, kuru tık sesi duyulur.
- **Doktrin:** tık sesinden sonra **bekle** (varsayılan 30 sn; gecikmeli ateşleme riski). Bekleme sırasında tetiğe tekrar basılırsa süre yeniden başlar. Süre dolunca ACE self-menü > **Roketatar > Ateşlenmeyen mühimmatı çıkar** görünür (8 sn); tek kullanımlıkta fırlatıcı çıkarılır, diğerlerinde mühimmat atılır.
- **Atış öncesi hazırlık** (`TAC_rkt_prepare`, açık): her yüklü mühimmat için ACE self-menü > Roketatar > **Atışa hazırla** yapılmadan fırlatıcı ateşlenmez; tetik yalnızca tık sesi verir (zar atılmaz, bekleme başlamaz). Süre türe göre: tek kullanımlık 3 sn (kapakları aç, tüpü uzat, pimleri çek), omuz atarı 5 sn (emniyet kapağı, itici / başlık kontrolü, horoz), güdümlü 6 sn (güç ver, sensörü başlat); silah bakımındaki süre çarpanıyla çarpılır. Reload, atış veya ateşlenmeyen mühimmatın çıkarılması hazırlığı sıfırlar. Yükleme sırası: yükle -> hazırla -> ateşle.
- **Hareket ve ses:** hazırlık ve mühimmat çıkarma sırasında fırlatıcının kendi yükleme hareketi tekrarlanır (silah bakımıyla aynı mekanizma), başlangıçta kapak / emniyet tıkı, bitişte sürgü sesi çalar (yakındakiler de duyar; `TAC_wpn_fx` ile kapatılır). Hareket yalnızca fırlatıcı elde seçiliyken oynar.
- **Oyuncuya bildirim yok:** tık sesi ve menü görünürlüğü dışında bilgi verilmez; durum "Fırlatıcıyı / mühimmatı incele" kartında okunur.

### Hedefte patlamama (dud) ve kalıcı patlamamış mühimmat

Güdümsüz roket (omuz atarı, tek kullanımlık) hedefe çarpıp **patlamayabilir** (`TAC_rkt_dudChance`, taban %1.5; nem, soğuk, sıcak aynı koşul çarpanıyla artırır). Roket havadayken izlenir; bir yüzeye çarpmadan hemen önce patlamadan silinir ve çarptığı noktada **kalıcı, donmuş bir patlamamış mühimmat (UXO)** yaratılır
(sunucuda, `enableSimulationGlobal false`; görev bitene veya Zeus silene kadar kalır). Güdümlü füzeler kapsam dışı. Roket çarpmadan uçarsa bir şey olmaz.
ACE'de bunun hazır bir karşılığı bulamadım: ACE'nin "Dud" kavramı yalnızca silahın hazneye aldığı kusurlu mermi arızasıdır (silah arıza türü), roketin hedefte patlamaması değil. Ayrıca ACE Explosives yalnızca elle kurulan patlayıcıları kapsar. (Tüm ACE'yi taramadım.)
UXO ile etkileşim (imha vb.) şimdilik yok; silmek için Zeus veya `deleteVehicle`.

### Güdümlü füze: pil ve soğutma (Javelin, Titan, Stinger, Igla...)

Yalnızca **güdümlü** kategori (tek kullanımlık NLAW hariç). Gerçek sistemlerin (Javelin CLU, Stinger BCU) mantığı, döngüsüz (tembel hesap):

1. **Atışa hazırla** (6 sn) sistemi açar: pil sayılmaya başlar, arayıcı **soğumaya** girer (`TAC_rkt_cooldown`, varsayılan 12 sn; > 25 °C sıcakta en fazla %50 uzar).
2. Soğuyana kadar tetik yalnızca tık sesi verir. Soğuduktan sonra **soğutucu** `TAC_rkt_coolantTime` (180 sn) dayanır; ateşlenmezse arayıcı **ısınır**: sistem kapanır, hazırlık sıfırlanır, yeniden "Atışa hazırla" (yeni soğuma) gerekir.
3. **Pil:** sistem açık kaldıkça boşalır (`TAC_rkt_batteryMinutes`, varsayılan 30 dk açık kalma = %100). Pil boşsa füze ateşlenmez; sistem de açılmaz. Sistem **açık kalır**: atış, reload ve mühimmat çıkarma güç / hazırlığı sıfırlamaz (yeni füze için yeniden güç ve hazırlık istenmez). Yalnızca soğutucu süresi bitince (arayıcı ısınır), pil boşalınca ya da fırlatıcı bırakılınca kapanır; geçen süre kadar pil düşülür.
4. **Pili değiştir:** ACE self-menü > Roketatar, yedek `TAC_MissileBattery` (Güdümlü Füze Pili) ister (5 sn). Pil %100 olur.
5. Oyuncuya bildirim yok: İncele kartında "Sistem: kapalı / açık, arayıcı soğuyor (~N sn) / hazır (soğutucu ~N sn) / arayıcı ısındı" ve pil "dolu / yarı / zayıf / boş" yazar; silahçı yüzdeyi görür.
CBA: `TAC_rkt_guided`, `TAC_rkt_cooldown`, `TAC_rkt_coolantTime`, `TAC_rkt_batteryMinutes`. Süreler gerçekten daha uzun / kısa olabilir; oyun temposuna göre ayarlandı (tahmin).
Test: `player addWeapon "launch_I_Titan_F"` (ya da CUP Javelin) + `player addItem "TAC_MissileBattery"`; hazırla, soğuma bitmeden ateş etmeyi dene (tık), bekle, ateşle; 180 sn bekleyip ısındığını gör.

### Hava koşulları ve mühimmat nemi (ılımlı)

Hava yalnızca atış anında değil, **zamanla** da mühimmatı etkiler. Tek bir 10 sn'lik PFH (fırlatıcı yoksa anında çıkar) taşınan roket / füze mühimmatının **nemini** (0-100) günceller:

| Durum | Nem değişimi |
|-------|--------------|
| Açıkta yağmur | + 0.2 x yağmur şiddeti / sn (şiddetli yağmurda ~8 dk'da tam nemli) |
| Sığ suda / yüzerken | + 1 / sn |
| Kuru hava, bina içi veya araçta | - 0.1 / sn (~17 dk'da tamamen kurur) |

Atış ihtimaline etkisi bilerek **ılımlı**: tam nemli mühimmat ihtimali yaklaşık **1.8 katına** çıkarır (tek kullanımlıkta 1.4); soğuk (< 5 °C) en fazla 2 kat, sıcak (> 35 °C) en fazla 1.3 kat; yağmurda atış anındaki ıslaklık 1.5 kat. Hepsi bir arada en kötü senaryoda ihtimal birkaç katına çıkar ama %2'lik bir RPG-7 %10'a dayanmaz.
**Araç, mühimmat sandığı ve depodaki eşyalar hava koşullarından etkilenmez** (nem yalnızca oyuncunun taşıdığı fırlatıcı mühimmatında birikir; oradan alınan fırlatıcının nemi en fazla %10 olur, yerden alınanın sıfırlanmaz). Silahın kir / yağ / aşınması ve optik durumu da zaten yalnızca atış / bakışta değişir.
Çare: ACE self-menü > Roketatar > **Mühimmatı kurula** (10 sn, Silah Bakım Kiti; nem %10'a iner). İncele kartında mühimmat "kuru / hafif nemli / nemli / ıslak" olarak okunur. Test modunda nem birikimi hızlanır.

### İncele kartı (config'ten, RHS / CUP / vanilla)

Tür, yüklü mühimmat adı, **başlık türü** (`warheadName`: HEAT, tandem, HE...), **silahlanma mesafesi** (`fuseDistance`), **patlama etki alanı** (`indirectHitRange`), **geri tepme alanı** (ACE `ace_overpressure_range` varsa), güdümlü ise uyarı, tüp durumu (yeni gibi / kullanılmış / yıpranmış) ve ateşlenmeme bekleme durumu.
Silahçı ayrıca taban ihtimali, atış sayısını ve ateşlenmeme sayısını görür.

### CBA ayarları (`... > TAC - Gerçekçilik Paketi > Roketatar / füze`)

| Ayar | Varsayılan |
|------|-----------|
| `TAC_rkt_enabled` | açık |
| `TAC_rkt_prepare` (atış öncesi hazırlık gerekli) | açık |
| `TAC_rkt_scale` (ateşlenmeme ölçeği) | 1 |
| `TAC_rkt_dudChance` (hedefte patlamama, %) | 1.5 |
| `TAC_rkt_waitTime` (bekleme, sn) | 30 (AT4 için 120, M72 için 70, M141 için 60 sn: FM 3-23.25 değerleri; ayar bunlara ölçek olur: 30 = kılavuz, 15 = yarısı) |
| `TAC_rkt_table` (`classname=yüzde, ...`) | boş |
| `TAC_rkt_testChance` (test: asgari ihtimal %) | 0 |
| `TAC_rkt_debug` (test göstergesi) | kapalı, kişisel |

### Fırlatıcıyı yere atmak / başkasının alması

Fırlatıcı yere / kutuya / araca / cesede konunca durumu (atış sayısı = tüp aşınması, yüklü mühimmatın zarı, ateşlenmeme ve bekleme, hazır işareti) kapta saklanır (`TAC_rkt_stash`, herkese yayınlanır) ve silahı alanla gider: ateşlenmeyen bir fırlatıcı başkasının eline geçince de ateşlenmez, "at, yenisini al" ile bedava yeni zar atılamaz. Aynı sınıftan yeni (arsenal, kayıtsız) fırlatıcı sıfırdan başlar.
Mühimmat nemi birime bağlıdır, taşınmaz. Sınırlar silah bakımındakiyle aynı: kap yok olursa durum kaybolur, ölü oyuncunun fırlatıcısı alana sıfırdan başlar.

### MP mantığı (roketatar)

Tamamen yerel oyuncuda: zar ve durum birimde, ağa bir şey yayınlanmaz, sunucuya yük sıfır, yapay zekâ için kod çalışmaz. Dinleyici yalnızca oyuncu birimine bağlıdır. Durum "birim + fırlatıcı sınıfı" başınadır; respawn'da sıfırlanır.

### Test adımları

1. CBA'da **Test: asgari ateşlenmeme ihtimali**'ni 100 yap, **Test göstergesi**ni aç. Debug konsolunda (yerel çalıştır) bir fırlatıcı ver:
   ```sqf
   player addWeapon "launch_RPG7_F"; player addSecondaryWeaponItem "RPG7_F";
   ```
   (ya da RHS `rhs_weap_rpg7`, `rhs_weap_m72a7`; CUP `CUP_launch_M72A6_Loaded`, `CUP_launch_Javelin`...).
2. Fırlatıcıyı elinde seç, önce ateş etmeyi dene: yalnızca tık (hazırlık yok). Sonra ACE menü > Roketatar > **Atışa hazırla** (çubuk, hareket), tekrar ateş et: kuru tık gelmeli, mermi çıkmamalı, ekranda `ATESLENMEYECEK` yazmalı. Tetiğe tekrar bas: bekleme yeniden başlar.
3. **Fırlatıcıyı / mühimmatı incele**: mühimmat bilgisi ve "Ateşlenmedi: bekle (~N sn)".
4. Süre dolunca **Ateşlenmeyen mühimmatı çıkar**: tek kullanımlıkta fırlatıcı gitmeli, RPG-7 tipinde tüp boşalmalı. Yeni mühimmat yükle (`player addMagazine "RPG7_F"`) ve zar yeniden atılmalı.
5. Test ihtimalini 0 yap: normal oranda (RPG-7 ~%2) ateş et. Soğuk (`setDate` ile kış gecesi) ve yağmurda ihtimal artmalı; `Test göstergesi` soğuk / ıslaklık / aşınma değerlerini yazar.
6. `call TAC_fnc_rktDebug` profil, durum ve dinleyici kimliğini döker (`TAC_rkt_actionId` -1 ise dinleyici bağlanmamış demektir: bana bildir).

> Kapsam dışı (şimdilik): gecikmeli ateşleme patlaması, araç / statik silah fırlatıcıları (ayrı silah sınıfları).

## Özellik 11 – Sabit silah / taret (DShK, M2, KORD, TOW, Metis...)

Aynı sistemler **sabit silahlara** (`StaticWeapon`) uygulanır; gunner ya da yanından geçen herkes **sabit silaha bakıp ACE etkileşim tuşuna** basarak kullanır (ACE etkileşim menüsü > **Sabit silah bakımı / hazırlığı**). Durum **araçta, herkese yayınlanan** bir değişkende tutulur (gunner ve yardımcı aynı durumu görür).

| Tür (otomatik) | Ölçüt | Neler uygulanır |
|----------------|-------|------------------|
| **Kayışlı MG** (DShK, M2, KORD, NSV, statik M240...) | ilk şarjör >= 50 mermi ve mühimmat simülasyonu kurşun | silaha özel **besleme prosedürü** (ağır statik MG'ler için daha uzun adımlar), kir / yağ / aşınma ve **arıza** (kişisel silahlarla aynı oranlar, MG x1.3, gerçek MRBS profili), **Silahı temizle / yağla**, **Arızayı gider (ayrıntılı)**; tutukluk varken tetik yalnızca tık verir |
| **Güdümlü** (TOW, Metis, Titan, Igla statik...) | roketatar profili "güdümlü" | silaha ve başlığa özel **atış hazırlığı prosedürü**, **pil ve soğutma** (arayıcı soğuma, soğutucu süresi, açık kaldıkça pil), **ateşlenmeme** zarı + bekleme, **Pili değiştir**, **Ateşlenmeyen mühimmatı çıkar** |

- Tetik, gunner'da ACE `DefaultAction` dinleyicisiyle kontrol edilir (kişisel silah sistemiyle aynı mekanizma); atış `FiredMan` olayıyla işlenir.
- Adımlar alfabetik listelenir, doğru sırayı oyuncu bilmelidir; yanlış sıra prosedürü sıfırlar. Adımı yapan kişi gunner de olabilir, yanındaki arkadaş da (durum araçta olduğu için ayrı bir yardım olayı gerekmez).
- **Silaha / kalibreye özel prosedürler (0.22):** besleme: M2 / .50 BMG (kayış, sürgü kolu 2 kez, boşluk ve zamanlama kontrolü), DShK / NSV / Kord / KPV (tırnağa oturt, gaz ayarı), bombaatarlar Mk19 / GMG / AGS (kutu, kolu 2 kez çek, emniyet); 7.62 statikler kişisel MG tablosundan. Atış hazırlığı: **TOW** (tüp kilidi, kablo ve optik bağlantı, gece nişangahı soğutma, güç), **Metis / Kornet / Konkurs / Fagot / Spike** (tüpü raya yerleştir, yönlendirme birimi, termal soğutma), **Igla / Stinger podları**, **SPG-9** gibi güdümsüz statik fırlatıcılar (namlu kilidi, mermi ve kama, emniyet + horoz; hazırlık ve ateşlenmeme uygulanır, pil / soğutma yok). Tür **mühimmattan** da çıkarılır: şarjör >= 50 mermi (bombaatar >= 20) ve simülasyon kurşun / bomba / topçu mermisi = kayışlı MG; roket / füze simülasyonu = fırlatıcı; şarjör bilgisi silah config'inde yoksa araçtaki taret şarjörü kullanılır.
- **Tanıma:** tüm tablolar artık silahın **classname'i + görünen adı** üzerinde alt dize arar (`TAC_fnc_wpnSearchKey`): RHS / CUP gibi modlarda anlaşılmaz classname'ler görünen adla da eşleşir.
- **Teşhis:** bir sabit silaha bakarak `call TAC_fnc_trtDebug`: araç sınıfı, silah, şarjör, mühimmat simülasyonu, atanan **tür**, besleme / hazırlık adımları ve durum. Kişisel silah için: `[currentWeapon player] call TAC_fnc_wpnFeedSteps` (MG) ya da `[secondaryWeapon player, secondaryWeaponMagazine player select 0] call TAC_fnc_rktPrepSteps` (fırlatıcı). Bir silah genel (aynı) adımları açıyorsa bu çıktıları ve silahın sınıf adını gönder, tabloya eklenir.
- Ayarlar: `TAC_trt_enabled`; diğerleri (`TAC_wpn_*`, `TAC_rkt_*`, `TAC_mg_feedStep`) ilgili modüllerle ortaktır.
- **Kapsam dışı (şimdilik):** araç taretleri (zırhlı araç, helikopter), sabit silahta optik buğusu, sabit silah namlu değiştirme / yanık (ACE sabit silahta namlu değiştirmeyi kendi destekliyorsa o çalışır), UXO (patlamamış mühimmat), mühimmat nemi.
- **Test:** `_s = createVehicle ["O_HMG_01_F", player modelToWorld [0,3,0], [], 0, "CAN_COLLIDE"]; player moveInGunner _s;` (DShK benzeri vanilla statik) ya da TOW için `"B_static_AT_F"` / RHS / CUP statik TOW. Önce ateş etmeyi dene (tık, hazırlık yok), ACE menüsünden (araçtan inmeden değil, aracın başında) prosedürü uygula, ateşle.
- **Bilinmeyenler:** ACE menüsünde `StaticWeapon` sınıfı, `FiredMan` olayının sabit silah gunner'ı için çalışması ve `DefaultAction` dinleyicisinin silah gunner koltuğunda tetiği yakalaması **oyunda doğrulanmadı**; çalışmazsa bana RPT'deki hatayı gönder.

## Yeni özellik ekleme

1. `addons/main/<özellik>/` klasörü aç; `fn_*.sqf` dosyalarını ve bir `CfgFunctions.hpp` ekle (`notebook/`, `nvg/` örnek). Envanter eşyası gerekiyorsa `CfgWeapons.hpp` de ekle.
2. `config.cpp` içindeki `CfgFunctions > TAC` bloğuna `#include "<özellik>\CfgFunctions.hpp"` satırını ekle (eşya varsa `CfgWeapons` bloğuna da).
3. Ayarlar için `XEH_preInit.sqf`'e, istemci kurulumu için `XEH_postInit.sqf`'e modülün giriş fonksiyonunu ekle.
4. Her modülün kendi `TAC_<özellik>_enabled` CBA ayarı olsun.
