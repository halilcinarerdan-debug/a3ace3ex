/*
    Fonksiyon: TAC_fnc_wpnFeedHint
    Çalışma yeri: İstemci

    Kayışlı MG besleme prosedürünün görselini gösterir (roket hazırlık görseliyle aynı altyapı: TAC_fnc_procHint;
    ayarlar ortak: TAC_rkt_hint, TAC_rkt_hintTime, TAC_rkt_hintSize, TAC_rkt_hintCorner). Etkileşim yoktur:
    adımlar ACE menüsünden yapılır, görsel yalnızca geri bildirimdir. Parçalar, silaha özel adım metinlerinden
    anahtar sözcükle seçilir (adet her zaman adımlarla aynıdır):
        "kutu"  -> kutu          "kayış"  -> kayış        "tepsi" / "yatağ" -> yatak (ışık)
        "kapağı kapat/indir" -> kapak kilidi (ışık)       diğer "kapağ" -> besleme kapağı        geri kalan -> kurma kolu
    Yapılan adımın parçası "açık" çizilir; hatalı sırada ya da yeniden yüklemede (R) ilerleme sıfırlanınca hepsi
    "kapalı" görünür.

    Parametreler:
        0: OBJECT - oyuncu birimi (yalnızca ACE_player için gösterilir)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (!hasInterface || {!(_unit isEqualTo ACE_player)} || {!TAC_rkt_hint}) exitWith {};

private _weapon = currentWeapon _unit;
if !([_weapon] call TAC_fnc_wpnIsBeltFed) exitWith {};

private _steps = [_weapon] call TAC_fnc_wpnFeedSteps;
if (_steps isEqualTo []) exitWith {};

private _defs = _steps apply {
    private _l = toLower (_x select 0);

    if ((_l find "kutu") >= 0) then {
        ["box", "Kutu"]
    } else {
        if ((_l find "kayış") >= 0) then {
            ["box", "Kayış"]
        } else {
            if ((_l find "tepsi") >= 0 || {(_l find "yatağ") >= 0}) then {
                ["light", "Yatak"]
            } else {
                if ((_l find "kapağı kapat") >= 0 || {(_l find "kapağı indir") >= 0}) then {
                    ["light", "Kapak kilidi"]
                } else {
                    if ((_l find "kapağ") >= 0) then {
                        ["cover", "Besleme kapağı"]
                    } else {
                        ["lever", "Kurma kolu"]
                    }
                }
            }
        }
    }
};

private _label = ([_weapon] call TAC_fnc_wpnProfile) select 3;
private _layout = [format ["%1 - Besleme", _label], _defs] call TAC_fnc_procHintBuild;

private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;

[_layout, _state param [7, true], _state param [8, 0]] call TAC_fnc_procHint;
