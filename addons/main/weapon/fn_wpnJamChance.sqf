/*
    Fonksiyon: TAC_fnc_wpnJamChance
    Çalışma yeri: İstemci

    Bir atış için arıza ihtimali (0..0.25):
        p = (0.0001 + kir + yağ + aşınma) x ortam
        kir    = Pmax x (kir/100)^2.5                          (üstel: temizken ihmal edilebilir)
        yağ    = Pmax x 0.6 x ((30 - yağ)/30)^2                (yalnızca yağ %30'un altındaysa)
        aşınma = Pmax x 0.5 x min(aşınma/parça ömrü, 1.5)^3
    Pmax = "Maksimum arıza ihtimali" ayarı (atış başına, %).

    Parametreler:
        0: ARRAY  - silah durumu (TAC_fnc_wpnGetState)
        1: NUMBER - ortam çarpanı (TAC_fnc_wpnEnvFactor)

    Dönüş: NUMBER
*/

params [["_state", [], [[]]], ["_env", 1, [0]]];

_state params ["_dirt", "_lube", "_wear"];

private _max = TAC_wpn_jamMax / 100;

private _p = 0.0001
    + (_max * ((_dirt / 100) ^ 2.5))
    + (_max * 0.6 * ((((30 - _lube) max 0) / 30) ^ 2))
    + (_max * 0.5 * (((_wear / (TAC_wpn_wearLife max 1)) min 1.5) ^ 3));

(_p * _env) min 0.25
