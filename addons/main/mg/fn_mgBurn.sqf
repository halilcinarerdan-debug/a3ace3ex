/*
    Fonksiyon: TAC_fnc_mgBurn
    Çalışma yeri: İstemci (namluyu tutan oyuncunun makinesi)

    Sıcak namlu yanığı: oyuncuda "Isı Eldiveni" (TAC_HeatGlove) envanterde yoksa sağ kola yanık hasarı
    uygulanır. Hasar = maksimum x (0.3 + 0.7 x clamp((sıcaklık - eşik) / 350, 0, 1)).
    ACE tıbbı varsa ace_medical_fnc_addDamageToUnit ("RightArm", "burn"), yoksa vanilla "HitHands".
    Oyuncuya ek bildirim verilmez: acı ve yara ACE tıbbından görünür.

    Parametreler:
        0: OBJECT - namluyu tutan birim
        1: NUMBER - çıkarılan namlunun sıcaklığı (°C, ACE)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_temp", 0, [0]]];

if (isNull _unit || {!local _unit} || {!alive _unit}) exitWith {};

private _gloved = "TAC_HeatGlove" in (items _unit);
private _damage = TAC_mg_burnDamage * (0.3 + (0.7 * ((((_temp - TAC_mg_burnTemp) / 350) max 0) min 1)));

if (TAC_mg_debug) then {
    systemChat format [
        "[TAC mg] namlu degisti | sicaklik %1 | esik %2 | eldiven %3 | hasar %4",
        round _temp,
        TAC_mg_burnTemp,
        _gloved,
        (round (_damage * 100)) / 100
    ];
};

if (_gloved || {_damage <= 0}) exitWith {};

if (!isNil "ace_medical_fnc_addDamageToUnit") then {
    [_unit, _damage, "RightArm", "burn"] call ace_medical_fnc_addDamageToUnit;
} else {
    _unit setHitPointDamage ["HitHands", ((_unit getHitPointDamage "HitHands") + _damage) min 1];
};
