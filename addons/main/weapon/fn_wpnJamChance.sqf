/*
    Fonksiyon: TAC_fnc_wpnJamChance
    Çalışma yeri: İstemci

    Bir atış için arıza ihtimali (0..0.25), gerçek güvenilirlik verisine dayalı:
        p = (1 / MRBS) x durum çarpanı x ortam x genel ölçek
        durum çarpanı = 1 + kir duyarlılığı x 40 x (kir/100)^2.5          (kir)
                          + yağ duyarlılığı x 10 x ((30 - yağ)/30)^2       (yalnızca yağ %30 altındaysa)
                          + 6 x min(aşınma / parça ömrü, 1.5)^3            (parça aşınması)
    MRBS, kir ve yağ duyarlılığı silaha özgüdür (TAC_fnc_wpnProfile): M4 ~3600, AK ~5000, M240 ~2900,
    M60 ~850... Temiz, yağlı, yeni silahta p = 1/MRBS (örn. M4'te atış başına ~%0.028).
    Genel ölçek (TAC_wpn_jamScale) 1 = gerçek; oyunu zorlaştırmak için artırılabilir.

    Parametreler:
        0: ARRAY  - silah durumu (TAC_fnc_wpnGetState)
        1: NUMBER - ortam çarpanı (TAC_fnc_wpnEnvFactor)
        2: STRING - silah classname

    Dönüş: NUMBER
*/

params [["_state", [], [[]]], ["_env", 1, [0]], ["_weapon", "", [""]]];

_state params ["_dirt", "_lube", "_wear"];

([_weapon] call TAC_fnc_wpnProfile) params ["_mrbs", "_dirtSens", "_lubeSens"];

private _mult = 1
    + (_dirtSens * 40 * ((_dirt / 100) ^ 2.5))
    + (_lubeSens * 10 * ((((30 - _lube) max 0) / 30) ^ 2))
    + (6 * (((_wear / (TAC_wpn_wearLife max 1)) min 1.5) ^ 3));

((1 / (_mrbs max 1)) * _mult * _env * TAC_wpn_jamScale) min 0.25
