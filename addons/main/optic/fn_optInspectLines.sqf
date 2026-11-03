/*
    Fonksiyon: TAC_fnc_optInspectLines
    Çalışma yeri: İstemci

    "Silahı incele" kartına eklenen optik satırları (birincil silahta kapalı lensli optik varsa).
    Gözlem dili: kir temiz / hafif lekeli / lekeli / çok kirli; buğu yok / hafif / buğulu / yoğun.
    Buğu, bakılmadığı süre boyunca toparlanmış haliyle gösterilir. Silahçıya yüzdeler de yazılır.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - silah classname
        2: BOOL   - silahçı mı (sayıları göster)

    Dönüş: ARRAY - satırlar (yoksa [])
*/

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]], ["_armorer", false, [false]]];

if (
    !TAC_opt_enabled
    || {!(_weapon isEqualTo (primaryWeapon _unit))}
    || {!([((primaryWeaponItems _unit) select 2)] call TAC_fnc_optIsSealed)}
) exitWith {[]};

private _state = [_unit, _weapon] call TAC_fnc_optGetState;
private _fog = _state select 0;
private _dirt = _state select 1;

if ((_state select 2) >= 0 && {!([_unit] call TAC_fnc_optActive)}) then {
    _fog = (_fog - (1.5 * ((time - (_state select 2)) max 0))) max 0;
};

private _dirtText = if (_dirt < 15) then {"temiz"} else {if (_dirt < 40) then {"hafif lekeli"} else {if (_dirt < 70) then {"lekeli"} else {"çok kirli"}}};
private _fogText = if (_fog < 8) then {"yok"} else {if (_fog < 30) then {"hafif"} else {if (_fog < 60) then {"buğulu"} else {"yoğun buğulu"}}};

private _lines = [format ["Optik lensi: %1 | buğu: %2", _dirtText, _fogText]];

if (_armorer) then {
    _lines pushBack format ["Optik: kir %1%% | buğu %2%%", round _dirt, round _fog];
};

_lines
