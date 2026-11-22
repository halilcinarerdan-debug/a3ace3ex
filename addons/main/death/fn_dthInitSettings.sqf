/*
    Fonksiyon: TAC_fnc_dthInitSettings
    Çalışma yeri: Tüm makineler (XEH_preInit)

    CBA ayarları - ölüm / yaralı ekranı (hepsi istemci ayarıdır: her oyuncu kendisi seçer):
      Vanilla revive'de yere düştüğünde (bilinçsiz) ve öldüğünde: sesler kısılır, ekran bulanıklaşır, griye döner ve kararır.
      Efekt yeniden doğunca (respawn) KESİLMEZ: yumuşakça (fade) söner. Sürekli döngü yoktur (olay tabanlı).
*/

private _category = ["TAC - Gerçekçilik Paketi", "Ölüm ve yaralı ekranı"];

[
    "TAC_dth_enabled",
    "CHECKBOX",
    ["Ölüm / yaralı ekranı", "Açıksa vanilla revive'de yere düşünce (bilinçsiz) ve ölünce sesler kısılır, ekran bulanıklaşır, griye döner ve kararır. Yeniden doğunca efekt kesilmez, yumuşakça söner. İstemci ayarı."],
    _category,
    true,
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_incap",
    "CHECKBOX",
    ["Yere düşünce (revive) devreye girsin", "Vanilla revive'de (ya da başka bir bilinçsizlik sisteminde) yaralı yere düşünce efekt başlar; kalkınca yumuşakça söner. İstemci ayarı."],
    _category,
    true,
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_death",
    "CHECKBOX",
    ["Ölünce devreye girsin", "Öldüğünde efekt başlar ve yeniden doğana kadar sürer; yeniden doğunca yumuşakça söner. İstemci ayarı."],
    _category,
    true,
    false
] call CBA_settings_fnc_init;

// --- Ani kararma (vurulur vurulmaz: ekran + ses) ---
[
    "TAC_dth_instant",
    "CHECKBOX",
    ["Ani kararma: vurulduğu anda ekran ve ses kararsın", "Açıksa ölümcül mermi isabet ettiği an (öldün ya da revive'de yere düştün) ekran tam siyah olur ve sesler kesilir; ardından aşağıdaki bekleme süresi dolunca normal ölüm / yaralı ekranına (kararma %, bulanıklık, renk solması) yumuşakça geçer. Kapalıysa efekt yalnızca 'Efektin gelme süresi' kadar yavaşça gelir. Sıradan (ölümcül olmayan) isabetlerde ekran kararmaz. İstemci ayarı."],
    _category,
    true,
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_instantTime",
    "SLIDER",
    ["Ani kararma: kararma hızı (sn)", "Ekranın ve sesin tam kararıp kesilmesi için geçen süre (0.05 = neredeyse anında). İstemci ayarı."],
    _category,
    [0.01, 1, 0.05, 2],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_deathHold",
    "SLIDER",
    ["Ölünce: tam karanlıkta kalma (sn)", "Öldüğünde ekranın tam siyah ve seslerin kesik kaldığı süre; sonra ölüm ekranına geçer. Yeniden doğunca efekt yine yumuşakça söner. 0 = hiç beklemeden ölüm ekranı. İstemci ayarı."],
    _category,
    [0, 60, 4, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_incapHold",
    "SLIDER",
    ["Yere düşünce (revive): tam karanlıkta kalma (sn)", "Revive'de yere düştüğünde ekranın tam siyah ve seslerin kesik kaldığı süre; sonra yaralı ekranına geçer. Kaldırılırsan beklemeden söner. İstemci ayarı."],
    _category,
    [0, 60, 1.5, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_instantMute",
    "SLIDER",
    ["Ani kararma: ses kesilme oranı (%)", "100 = ani kararmada sesler tamamen kesilir. Bekleme bitince 'Sesleri kısma oranı' değerine yumuşakça geçer. İstemci ayarı."],
    _category,
    [0, 100, 100, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_muffle",
    "SLIDER",
    ["Sesleri kısma oranı (%)", "Ani kararma bittikten sonra (ya da ani kararma kapalıysa) sesler bu oranda kısık kalır; 100 = sesler tamamen kesilir. ACE'nin kulak sistemiyle uyumludur (en düşük ses ayarı geçerli). İstemci ayarı."],
    _category,
    [0, 100, 90, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_blur",
    "SLIDER",
    ["Bulanıklık", "Efektteki ekran bulanıklığı. İstemci ayarı."],
    _category,
    [0, 6, 1.6, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_gray",
    "SLIDER",
    ["Renk solması (%)", "100 = ekran tamamen siyah-beyaz. İstemci ayarı."],
    _category,
    [0, 100, 75, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_dark",
    "SLIDER",
    ["Ölünce: kararma (%)", "Ani kararmanın ve bekleme süresinin ardından ÖLÜM ekranında ekranın ne kadar karardığı (100 = simsiyah kalır). Yere düşünce (revive) için ayrı ayar vardır. İstemci ayarı."],
    _category,
    [0, 100, 55, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_incapDark",
    "SLIDER",
    ["Yere düşünce (revive): kararma (%)", "Revive'de yerdeyken ekranın ne kadar karardığı (100 = simsiyah; kaldırılana ya da öldürülene kadar böyle kalır, kalkınca yumuşakça söner). Ani kararma açıksa önce tam siyah olur, bekleme süresinden sonra bu seviyeye geçer. İstemci ayarı."],
    _category,
    [0, 100, 100, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_fadeIn",
    "SLIDER",
    ["Efektin gelme süresi (sn)", "Ani kararma kapalıysa efektin tam şiddete ulaşma süresi; açıksa tam karanlıktan ölüm / yaralı ekranına geçiş süresi. İstemci ayarı."],
    _category,
    [0.1, 8, 1.8, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_respawnFade",
    "SLIDER",
    ["Yeniden doğunca sönme süresi (sn)", "Yeniden doğduktan sonra ölüm efektinin ve seslerin yumuşakça normale dönme süresi (efekt yeniden doğunca kesilmez). İstemci ayarı."],
    _category,
    [0.5, 20, 6, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_reviveFade",
    "SLIDER",
    ["Kaldırılınca sönme süresi (sn)", "Revive ile kalkınca efektin yumuşakça sönme süresi. İstemci ayarı."],
    _category,
    [0.5, 20, 3.5, 1],
    false
] call CBA_settings_fnc_init;
