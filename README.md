# TAC – Realism Pack (CBA_A3 + ACE3)

Tek bir mod (`@TAC`), tek bir PBO (`tac_main.pbo`). Yalnızca **CBA_A3** ve **ACE3** gerektirir;
RHS, Project OPFOR, ACM, LAMBS, ACRE2 ile birlikte kullanılır ama hiçbirine bağımlılık yoktur.
Mission dosyasına (`initPlayerLocal.sqf`, `description.ext` vb.) **hiçbir şey eklemek gerekmez**.

## Yol haritası

| # | Özellik | Durum |
|---|---------|-------|
| 1 | Taktiksel Not Defteri (ACE etkileşimli) | ✅ hazır |
| 2 | Gelişmiş NVG pili ve efektleri | ⏳ |
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
        fn_notebookInitActions.sqf       ACE self-action ağacı (sınıfa eklenir)
        fn_notebookPostInit.sqf          CBA olay dinleyicileri
        fn_notebookAddNote.sqf           "Not Al": anı yakala + ilerleme çubuğu
        fn_notebookStoreNote.sqf         yerel listeye yaz + CBA olayı
        fn_notebookShow.sqf              "Notları Oku": kaydırılabilir pencere
        fn_notebookFormatEntry.sqf       kayıt -> metin
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

**ACE self-interaction** (varsayılan: `Ctrl + Sol Windows`) → `Taktiksel Not Defteri`:

- **Not Al**: o anki oyun içi tarih/saat, grid koordinatı, yön (derece) ve irtifayı kaydeder.
  Ayarlardaki süre kadar ACE ilerleme çubuğu gösterir (varsayılan 2 sn).
- **Notları Oku**: kayıtları en yeni üstte olacak şekilde pencerede gösterir. `TEMİZLE` hepsini siler, `KAPAT`/`ESC` kapatır.

Menü yalnızca oyuncunun elinde/üstünde `ItemCompass` (veya ayarlanan eşya) varsa görünür.

### CBA ayarları (`Options > Addon Options > TAC - Gerçekçilik Paketi`)

| Ayar | Varsayılan | Kapsam |
|------|-----------|--------|
| `TAC_notebook_enabled` | açık | global (force edilebilir) |
| `TAC_notebook_itemClass` | `ItemCompass` | global |
| `TAC_notebook_maxEntries` | 40 (5–100) | global |
| `TAC_notebook_writeTime` | 2 sn (0–10) | global |
| `TAC_notebook_clearOnDeath` | kapalı | global |
| `TAC_notebook_notify` | açık | kişisel (istemci) |

Sunucudan zorlamak için sunucunun `userconfig/cba_settings.sqf` dosyasını (veya mission köküne `cba_settings.sqf`) kullan:

```sqf
force force TAC_notebook_enabled = true;
force force TAC_notebook_itemClass = "ItemCompass";
force force TAC_notebook_writeTime = 3;
force force TAC_notebook_clearOnDeath = true;
```

### MP mantığı (server / client)

- **Ayarlar** `XEH_preInit` ile **tüm makinelerde** kaydedilir. Sunucu da kaydetmek zorundadır; global ayarları CBA sunucudan istemcilere senkronlar ve `force` ile kilitler.
- **Eylemler ve veri**: tamamen **istemci tarafı** (`XEH_postInit` içinde `hasInterface` kontrolü). ACE menüsü yerel arayüzdür; notlar yalnızca o oyuncunun `missionNamespace`'inde durur ve ağa **yayınlanmaz**. Sunucuya yük sıfır; döngü, `waitUntil` ya da `onEachFrame` yok.
- **Respawn / JIP**: eylemler `CAManBase` sınıfına bir kez eklenir (ACE kalıtımla tüm askerlere uygular), self-menü zaten yalnızca oyuncunun kendi birimi için açılır. Bu yüzden respawn, JIP, `selectPlayer` sonrası eylemleri yeniden eklemek gerekmez.
  `Ölünce notlar silinsin` ayarı CBA `"unit"` oyuncu olayıyla işler (eski birim ölüyse, respawn sayılır).
- Notlar bağlantı kopunca sıfırlanır (kalıcılık gerekirse sonraki adımda eklenebilir).

### Test adımları

Mission dosyası gerekmez; mod her mission'da çalışır.

1. `@TAC` ile oyunu başlat. Ana menüde `Options > Addon Options` içinde **TAC - Gerçekçilik Paketi** kategorisi görünmeli.
2. Eden'de bir oyuncu birimi koy ve `Play Scenario`. Debug konsolunda (yerel çalıştır) yükleme kontrolü:
   - `isClass (configFile >> "CfgPatches" >> "tac_main")` → `true`
   - `isNil "TAC_fnc_notebookShow"` → `false`
3. `Ctrl + Sol Windows` → **Taktiksel Not Defteri** → **Not Al** → ilerleme çubuğu → onay mesajı. **Notları Oku** ile kaydı gör. Ham veri: `TAC_notebook_entries`.
4. Eşya kontrolü: `player unlinkItem "ItemCompass"` → menü kaybolmalı; `player linkItem "ItemCompass"` → geri gelmeli.
5. Respawn: Eden'de `Play Scenario in Multiplayer` ile, oyuncu birimi özelliklerinde / mission ayarlarında respawn aç, konsolda `player setDamage 1`.
   Yeniden doğunca menü yine görünmeli ve notlar duruyor olmalı. `Ölünce notlar silinsin` ayarını açıp tekrar dene: defter boş gelmeli.
6. Gerçek MP (host veya dedicated + en az 2 istemci): A oyuncusu not alınca B'nin defteri boş kalmalı (notlar kişiye özel).
   `cba_settings.sqf` ile `force` ettiğin ayar istemcide kilitli görünmeli.
7. Hata varsa `%LOCALAPPDATA%\Arma 3\*.rpt` içinde script hatalarına ve `TAC_` geçen satırlara bak (`-showScriptErrors` ile başlat).

> Not: Menü ikonları vanilla `ui_f` yollarıdır. Biri bulunamazsa yalnızca ikon boş kalır ve RPT'ye uyarı düşer; işlev etkilenmez.
> Script değişikliği sonrası PBO'yu yeniden derle; oyun açıkken PBO değiştirilemez.

## Yeni özellik ekleme

1. `addons/main/<özellik>/` klasörü aç; `fn_*.sqf` dosyalarını ve bir `CfgFunctions.hpp` ekle (`notebook/` örnek).
2. `config.cpp` içindeki `CfgFunctions > TAC` bloğuna `#include "<özellik>\CfgFunctions.hpp"` satırını ekle.
3. Ayarlar için `XEH_preInit.sqf`'e, istemci kurulumu için `XEH_postInit.sqf`'e modülün giriş fonksiyonunu ekle.
4. Her modülün kendi `TAC_<özellik>_enabled` CBA ayarı olsun.
