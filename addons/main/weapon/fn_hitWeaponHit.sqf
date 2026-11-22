/*
    Fonksiyon: TAC_fnc_hitWeaponHit
    Çalışma yeri: İstemci

    Mermi yolu ile silah doğrusu arasındaki mesafe (m) verilince karar verir: mesafe TAC_hit_weaponRadius cm'den
    azsa ve bekleme süresi yoksa TAC_hit_chance ihtimalle silahı hasarlar ve düşürür (TAC_fnc_hitDisable).
    TAC_wpn_debug açıkken mesafe ve karar yazılır.

    Parametreler:
        0: OBJECT - birim
        1: NUMBER - en yakın mesafe (m)
        2: STRING - kaynak etiketi ("olay" ya da "izleme")
        3: STRING - tutuş kaynağı (debug için)

    Dönüş: BOOL - silah vuruldu mu (zar tuttu mu)
*/

params ["_unit", "_closest", ["_label", ""], ["_gripSource", ""]];

if (TAC_wpn_debug) then {
    systemChat format ["[TAC isabet] (%1) mermi yolu - silah mesafesi %2 cm (esik %3 cm) | tutus noktasi: %4", _label, (round (_closest * 1000)) / 10, TAC_hit_weaponRadius, _gripSource];
};

if (_closest > (TAC_hit_weaponRadius / 100)) exitWith {false};
if (time < (_unit getVariable ["TAC_hit_next", 0])) exitWith {false};

if ((random 100) >= TAC_hit_chance) exitWith {
    if (TAC_wpn_debug) then {systemChat format ["[TAC isabet] silahi vurdu ama zar tutmadi (ihtimal %%%1)", TAC_hit_chance]};
    false
};

_unit setVariable ["TAC_hit_next", time + 3];
[_unit, currentWeapon _unit] call TAC_fnc_hitDisable;

true
