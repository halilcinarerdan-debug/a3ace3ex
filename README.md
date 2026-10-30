# TAC – Arma 3 Gerçekçilik Paketi (CBA_A3 + ACE3)

Yeni mod eklemeden, yalnızca **CBA_A3** ve **ACE3** üzerine kurulu, MP uyumlu ve modüler SQF scriptleri.
Uyumlu olduğu paket: RHS, Project OPFOR, ACM, LAMBS, ACRE2 (hiçbirine bağımlılık yok).

## Yol haritası

| # | Özellik | Durum |
|---|---------|-------|
| 1 | Taktiksel Not Defteri (ACE etkileşimli) | ✅ hazır |
| 2 | Gelişmiş NVG pili ve efektleri | ⏳ |
| 3 | Kalibreye göre dinamik recoil | ⏳ |
| 4 | Baskı altında artan sway | ⏳ |
| 5 | Mermi yakın geçiş (crack) + ekran efekti + HUD kapatma | ⏳ |
| 6 | Aiming deadzone / silah inertiası | ⏳ |

## Klasör yapısı

Depo kökü = **mission klasörünün içeriği** (`mission.sqm`'in yanına kopyalanır).

```
description.ext                          CfgFunctions (preInit ile CBA ayarları)
initPlayerLocal.sqf                      oyuncu girişinde (JIP dahil) bir kez
onPlayerRespawn.sqf                      her respawn'da
functions/notebook/
    fn_notebookInitSettings.sqf          CBA ayarları (tüm makineler, preInit)
    fn_notebookInit.sqf                  ACE self-action ağacını ekler
    fn_notebookAddNote.sqf               "Not Al": anı yakala + ilerleme çubuğu
    fn_notebookStoreNote.sqf             yerel listeye yaz + CBA olayı
    fn_notebookShow.sqf                  "Notları Oku": kaydırılabilir pencere
    fn_notebookFormatEntry.sqf           kayıt -> metin
    fn_notebookOnRespawn.sqf             respawn mantığı
```

Yeni özellikler `functions/<özellik>/` altına eklenir ve `description.ext` içinde kendi `class` bloğunu alır.

## Kurulum

1. Eden'de bir mission oluştur ve kaydet (`Scenario > Save`). Bir oyuncu birimi koy.
2. `Scenario > Open Scenario Folder` ile mission klasörünü aç.
3. Bu deponun dosyalarını `mission.sqm`'in yanına kopyala. Zaten bir `description.ext` varsa yalnızca `class CfgFunctions` bloğunu birleştir.
4. Arma'yı **CBA_A3 + ACE3** (ve istersen diğer modların) ile başlat. Script hatalarını görmek için `-showScriptErrors` parametresini ekle.

## Özellik 1 – Taktiksel Not Defteri

**ACE self-interaction** (varsayılan: `Ctrl + Sol Windows`) → `Taktiksel Not Defteri`:

- **Not Al**: o anki oyun içi tarih/saat, grid koordinatı, yön (derece) ve irtifayı kaydeder.
  Ayarlardaki süre kadar ACE ilerleme çubuğu gösterir (varsayılan 2 sn).
- **Notları Oku**: kayıtları en yeni üstte olacak şekilde pencerede gösterir. `TEMİZLE` hepsini siler, `KAPAT`/`ESC` kapatır.

Menü yalnızca oyuncunun elinde/üstünde `ItemCompass` (veya ayarlanan eşya) varsa görünür.

### CBA ayarları (`ESC > Configure > Addon Options > TAC - Gerçekçilik Paketi`)

| Ayar | Varsayılan | Kapsam |
|------|-----------|--------|
| `TAC_notebook_enabled` | açık | global (force edilebilir) |
| `TAC_notebook_itemClass` | `ItemCompass` | global |
| `TAC_notebook_maxEntries` | 40 (5–100) | global |
| `TAC_notebook_writeTime` | 2 sn (0–10) | global |
| `TAC_notebook_clearOnDeath` | kapalı | global |
| `TAC_notebook_notify` | açık | kişisel (istemci) |

Sunucudan zorlamak için mission köküne `cba_settings.sqf` koyabilir veya sunucunun `userconfig/cba_settings.sqf` dosyasını kullanabilirsin:

```sqf
force force TAC_notebook_enabled = true;
force force TAC_notebook_itemClass = "ItemCompass";
force force TAC_notebook_writeTime = 3;
force force TAC_notebook_clearOnDeath = true;
```

### MP mantığı (server / client)

- **Ayarlar**: `preInit` ile **tüm makinelerde** kaydedilir. Sunucu da kaydetmek zorundadır; global ayarları CBA sunucudan istemcilere senkronlar ve `force` ile kilitler.
- **Eylemler ve veri**: tamamen **istemci tarafı**. ACE menüsü yerel arayüzdür, notlar yalnızca o oyuncunun `missionNamespace`'inde durur ve ağa **yayınlanmaz**. Sunucuya yük sıfır; döngü, `waitUntil` ya da `onEachFrame` yok.
- **Respawn**: ACE eylemleri objeye bağlıdır, yeni beden eylemsiz doğar. `onPlayerRespawn.sqf` eylemleri yeniden ekler; tekrar eklemeyi önleyen bayrak sayesinde `initPlayerLocal.sqf` ile çift çağrılması zararsızdır.
- **JIP**: `initPlayerLocal.sqf` JIP oyuncuda da çalışır.
- Notlar bağlantı kopunca sıfırlanır (kalıcılık gerekirse sonraki adımda eklenebilir).

### Test adımları

1. Eden'de `Play Scenario` (SP) ile başlat → `initPlayerLocal.sqf` çalışır. Menüyü aç, **Not Al** → ilerleme çubuğu → onay mesajı. **Notları Oku** ile kaydı gör.
2. Debug konsolunda (yerel çalıştır):
   - `TAC_notebook_entries` → ham kayıt dizisi
   - `player unlinkItem "ItemCompass"` → menü kaybolmalı; `player linkItem "ItemCompass"` → geri gelmeli
3. `onPlayerRespawn.sqf` **SP'de çalışmaz**. `description.ext` içindeki `respawn = "BASE";` satırının yorumunu kaldır, `Play Scenario in Multiplayer` ile başlat, debug konsolunda `player setDamage 1`.
   Yeniden doğunca menü yine görünmeli ve notlar duruyor olmalı. `Ölünce notlar silinsin` ayarını açıp tekrar dene: defter boş gelmeli.
4. Gerçek MP testi (host veya dedicated + en az 2 istemci): A oyuncusu not alır, B oyuncusunun defteri boş kalmalı (notlar kişiye özel). Sunucu `cba_settings.sqf` içinde `force` ile bir değer kilitleyince istemcide o ayar gri/kilitli görünmeli.
5. Hata varsa `%LOCALAPPDATA%\Arma 3\*.rpt` içinde `[TAC]` ve script hatalarını ara.

> Not: Menü ikonları vanilla `ui_f` yollarıdır. Biri bulunamazsa yalnızca ikon boş kalır ve RPT'ye uyarı düşer; işlev etkilenmez.
