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

[
    "TAC_dth_muffle",
    "SLIDER",
    ["Sesleri kısma oranı (%)", "100 = sesler tamamen kesilir. ACE'nin kulak sistemiyle uyumludur (en düşük ses ayarı geçerli). İstemci ayarı."],
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
    ["Kararma (%)", "Efektte ekranın ne kadar karardığı (100 = tam siyah). İstemci ayarı."],
    _category,
    [0, 100, 55, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_dth_fadeIn",
    "SLIDER",
    ["Efektin gelme süresi (sn)", "Yere düşünce / ölünce efektin tam şiddete ulaşma süresi. İstemci ayarı."],
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
