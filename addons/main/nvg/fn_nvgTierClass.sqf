/*
    Fonksiyon: TAC_fnc_nvgTierClass
    Çalışma yeri: İstemci

    Sökülen pilin şarjına göre envantere dönecek eşyayı seçer. Kademeler 100/75/50/25/10'dur ve
    HER ZAMAN aşağı yuvarlanır (0.03 payla): kullanılmış pil "bedava yenilenemez".
        şarj >= 0.97 -> ana sınıf (dolu)       0.72 -> _p75      0.47 -> _p50      0.22 -> _p25      0.07 -> _p10
        şarj < 0.07  -> "TAC_NVGBattery_Dead" (yalnızca TAC pillerinde)
    Kademesi olmayan pil (başka modun piliyse): 0.97 üstü ana sınıf, aşağısı "" (pil tükenmiş sayılır).

    Parametreler:
        0: STRING - ana pil sınıfı ("" = başlangıç pili, TAC_NVGBattery sayılır)
        1: NUMBER - şarj 0..1

    Dönüş: STRING - envantere eklenecek classname, yoksa ""
*/

params [["_base", "", [""]], ["_charge", 0, [0]]];

if (_base isEqualTo "") then {_base = "TAC_NVGBattery"};

if (_charge >= 0.97) exitWith {_base};

private _tacBase = ((getText (configFile >> "CfgWeapons" >> _base >> "TAC_base")) != "");
if (!_tacBase) exitWith {""};

private _result = "TAC_NVGBattery_Dead";

{
    _x params ["_limit", "_suffix"];

    if (_charge + 0.03 >= _limit) exitWith {
        private _class = format ["%1_%2", _base, _suffix];
        if (isClass (configFile >> "CfgWeapons" >> _class)) then {_result = _class};
    };
} forEach [[0.75, "p75"], [0.5, "p50"], [0.25, "p25"], [0.1, "p10"]];

_result
