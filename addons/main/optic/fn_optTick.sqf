/*
    Fonksiyon: TAC_fnc_optTick
    Çalışma yeri: İstemci (CBA PFH, 0.5 sn'de bir, yalnızca optikten bakarken)

    1. Hâlâ optikten bakılıyor mu? Değilse döngüyü durdurur. Optik modu büyütmeli değilse (Ctrl + sağ tık ile
       kırmızı nokta / demir nişan moduna geçilmişse) etkiyi kapatır, durumu değiştirmez (döngü sürer).
    2. Buğu:  fogF = min(1, 0.7 x soğuk + 0.6 x ıslaklık)
         soğuk = clamp((10 - sıcaklık) / 15, 0, 1)   (10 °C ve üstü 0, -5 °C ve altı 1)
         ıslaklık = yağmur (0..1), sığ suda 1
         buğu değişimi (%/sn) = buğulanma hızı x fogF x test çarpanı  -  0.8 x (1 - fogF)
    3. Kir: yağmurda saniyede (damlacık hızı x yağmur x test çarpanı) artar. Atışla kirlenme ayrıca
       TAC_fnc_wpnOnFired içinde işlenir.
    4. Etkiyi uygular (TAC_fnc_optApply).
    Sıcaklık: vanilla ambientTemperature (ACE hava durumu gerekmez).

    Parametreler (CBA PFH): [_args, _handle]
    Dönüş: yok
*/

params ["_args", "_handle"];

private _unit = ACE_player;

if !([_unit] call TAC_fnc_optActive) exitWith {
    call TAC_fnc_optStop;
};

private _state = [_unit, currentWeapon _unit] call TAC_fnc_optGetState;

// Ctrl + sag tikla kirmizi nokta / demir nisan moduna gecildiyse: etki yok, durum da degismez.
if !([_unit] call TAC_fnc_optModeMagnified) exitWith {
    _state set [2, time];
    call TAC_fnc_optClearEffects;
};

private _now = time;
private _dt = ((_now - (_state select 2)) max 0) min 2;
private _accel = if (TAC_wpn_testMode) then {TAC_wpn_testMult} else {1};

_state set [2, _now];

private _pos = getPosATL _unit;
private _coldF = (((10 - ((ambientTemperature) select 0)) / 15) max 0) min 1;
private _wetF = if (surfaceIsWater _pos && {(_pos select 2) < 0.4}) then {1} else {rain min 1};
private _fogF = ((0.7 * _coldF) + (0.6 * _wetF)) min 1;

private _fogChange = ((TAC_opt_fogRate * _fogF * _accel) - (0.8 * (1 - _fogF))) * _dt;

_state set [0, (((_state select 0) + _fogChange) max 0) min 100];
_state set [1, (((_state select 1) + (TAC_opt_rainDirt * (rain min 1) * _accel * _dt)) max 0) min 100];

[_state select 0, _state select 1] call TAC_fnc_optApply;
