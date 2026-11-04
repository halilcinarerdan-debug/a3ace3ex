/*
    Fonksiyon: TAC_fnc_optModeMagnified
    Çalışma yeri: İstemci

    Oyuncunun şu an kullandığı optik MODU büyütmeli 2D resimli mod mu? Çok modlu optiklerde (Ctrl + sağ tık ile
    kırmızı nokta / demir nişan moduna geçilebilen) yalnızca büyütmeli modda buğu / kir etkisi görünür.
    getTurretOpticsMode (mevcut mod dizini) ile optiğin OpticsModes sınıfı eşleştirilir; o sınıf useModelOptics = 1
    ve opticsZoomMin <= 0.16 ise true. Dizin alınamazsa (komut -1 / aralık dışı) eski davranış: optik herhangi
    bir büyütmeli moda sahipse true.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: BOOL
*/

params [["_unit", objNull, [objNull]]];

private _optic = (primaryWeaponItems _unit) select 2;

if (_optic isEqualTo "") exitWith {false};

private _mode = getTurretOpticsMode _unit;
private _modes = "true" configClasses (configFile >> "CfgWeapons" >> _optic >> "ItemInfo" >> "OpticsModes");

if (_mode < 0 || {_mode >= count _modes}) exitWith {[_optic] call TAC_fnc_optIsSealed};

private _cfg = _modes select _mode;

(getNumber (_cfg >> "useModelOptics")) == 1
&& {(getNumber (_cfg >> "opticsZoomMin")) > 0}
&& {(getNumber (_cfg >> "opticsZoomMin")) <= 0.16}
