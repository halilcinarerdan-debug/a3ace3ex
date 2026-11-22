/*
    Fonksiyon: TAC_fnc_hitWeaponHit
    Çalışma yeri: İstemci / sunucu (mermi izleyen makine)

    Mermi yolu ile hedefin silah doğrusu arasındaki mesafe (m) verilince karar verir: mesafe TAC_hit_weaponRadius cm'den
    azsa ve bekleme süresi yoksa TAC_hit_weaponChance ihtimalle silah vurulmuştur. Hedef bu makinede yerelse silahı hemen
    hasarlar ve düşürür (TAC_fnc_hitDisable); başka makinedeyse CBA hedef olayı "TAC_hit_weapon" ile silahın sahibine
    gönderilir (hasar ve düşme yerel birimde çalışmak zorundadır). TAC_wpn_debug açıkken mesafe ve karar yazılır.

    Parametreler:
        0: OBJECT - hedef birim
        1: NUMBER - en yakın mesafe (m)
        2: STRING - kaynak etiketi ("olay" ya da "izleme")
        3: STRING - tutuş kaynağı (debug için)

    Dönüş: BOOL - silah vuruldu mu (zar tuttu mu)
*/

params ["_unit", "_closest", ["_label", ""], ["_gripSource", ""]];

if (TAC_wpn_debug) then {
    systemChat format ["[TAC isabet] (%1) %2: mermi yolu - silah mesafesi %3 cm (esik %4 cm) | tutus noktasi: %5", _label, name _unit, (round (_closest * 1000)) / 10, TAC_hit_weaponRadius, _gripSource];
};

if (_closest > (TAC_hit_weaponRadius / 100)) exitWith {false};
if (time < (_unit getVariable ["TAC_hit_next", 0])) exitWith {false};

if ((random 100) >= TAC_hit_weaponChance) exitWith {
    if (TAC_wpn_debug) then {systemChat format ["[TAC isabet] silahi vurdu ama zar tutmadi (ihtimal %%%1)", TAC_hit_weaponChance]};
    false
};

_unit setVariable ["TAC_hit_next", time + 3];

if (local _unit) then {
    [_unit, currentWeapon _unit] call TAC_fnc_hitDisable;
} else {
    ["TAC_hit_weapon", [_unit], _unit] call CBA_fnc_targetEvent;

    if (TAC_wpn_debug) then {systemChat format ["[TAC isabet] %1'in silahi vuruldu: olay sahibine gonderildi", name _unit]};
};

true
