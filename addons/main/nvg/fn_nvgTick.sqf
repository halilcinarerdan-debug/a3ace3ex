/*
    Fonksiyon: TAC_fnc_nvgTick
    Çalışma yeri: İstemci (CBA PFH, 0.25 sn'de bir, yalnızca NVG açıkken)

    1. NVG hâlâ açık mı? Değilse döngüyü durdurur.
    2. Geçen süreye göre şarjı düşürür:
           pil_ömrü_sn = pil_saati * dakika_per_saat * 60 / (test_hızı)
           oran (%/sn) = 100 / pil_ömrü_sn * tüketim_çarpanı   (cihaz x soğuk, TAC_fnc_nvgDrainFactor)
           şarj < %15 ise oran 1x -> 2x hızlanır (voltaj düşümü, "Voltaj düşümü" ayarı)
       pil_saati, takılı pilin classname'ine göre tablodan gelir (TAC_nvg_installedClass).
    3. Şarj düşük eşiğin altındaysa efekt şiddetini hesaplar:
           şiddet = 1 - şarj / eşik        (eşikte 0, şarj 0'da 1)
    4. Şarj 0 ise NVG'yi kapatır.
    5. Test modunda ekrana şarj / pil sınıfı / ömür / kalan süreyi yazar.

    Şarj ve takılı pil birimin üzerinde (yerel) tutulur -> respawn'da yeni beden %100 başlar.

    Parametreler (CBA PFH): [_args, _handle]
    Dönüş: yok
*/

params ["_args", "_handle"];

private _unit = ACE_player;

if !(TAC_nvg_enabled && {alive _unit} && {currentVisionMode _unit == 1} && {!((hmd _unit) isEqualTo "")}) exitWith {
    call TAC_fnc_nvgStop;
};

// Geçen süre (duraklama / büyük zıplamalara karşı 0..1 sn ile sınırlı)
private _now = time;
private _dt = ((_now - (missionNamespace getVariable ["TAC_nvg_lastTick", _now])) max 0) min 1;
missionNamespace setVariable ["TAC_nvg_lastTick", _now];

private _installed = _unit getVariable ["TAC_nvg_installedClass", ""];
private _speed = if (TAC_nvg_testMode) then {TAC_nvg_testSpeed max 1} else {1};
private _lifeSeconds = (((([_installed] call TAC_fnc_nvgGetHours) * TAC_nvg_minutesPerHour) * 60) max 1) / _speed;
private _rate = (100 / _lifeSeconds) * ([_unit] call TAC_fnc_nvgDrainFactor);

// Voltaj dusumu: sarjin son %15'inde tuketim hizlanir (1x -> 2x). Gostergedeki "kalan" bu hizla hesaplanir.
private _charge = (_unit getVariable ["TAC_nvg_charge", 100]);
if (TAC_nvg_sag && {_charge < 15}) then {_rate = _rate * (2 - (_charge / 15))};

_charge = (_charge - (_rate * _dt)) max 0;
_unit setVariable ["TAC_nvg_charge", _charge];

// Pil bitti
if (_charge <= 0) exitWith {
    call TAC_fnc_nvgStop;
    _unit action ["NVGogglesOff", _unit];
    ["NVG pili bitti."] call TAC_fnc_nvgNotify;
};

// Test modu: durum göstergesi (hintSilent yerinde güncellenir, mesaj yığılmaz)
if (TAC_nvg_testMode) then {
    missionNamespace setVariable ["TAC_nvg_testHint", true];

    hintSilent parseText format [
        "<t color='#ffcc00'>[TEST] NVG pili</t><br/>Şarj: %1<br/>Pil: %2<br/>Ömür: %3 sn (x%4)<br/>Kalan: %5 sn",
        (str ((round (_charge * 10)) / 10)) + "%",
        if (_installed isEqualTo "") then {"başlangıç pili"} else {_installed},
        round _lifeSeconds,
        _speed,
        round (_charge / _rate)
    ];
};

// Düşük pil: parazit + kararma/flicker
if (_charge < TAC_nvg_lowThreshold) then {
    if !(_unit getVariable ["TAC_nvg_lowWarned", false]) then {
        _unit setVariable ["TAC_nvg_lowWarned", true];
        ["NVG pili zayıf: " + ((str (round _charge)) + "%")] call TAC_fnc_nvgNotify;
    };

    [1 - (_charge / TAC_nvg_lowThreshold)] call TAC_fnc_nvgApplyEffects;
};
