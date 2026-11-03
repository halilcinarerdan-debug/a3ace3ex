/*
    Fonksiyon: TAC_fnc_mgBurn
    Çalışma yeri: İstemci (namluyu tutan oyuncunun makinesi)

    Sıcak namlu yanığı: namlu sıcaklığı eşiğin üstündeyse ve oyuncuda "Isı Eldiveni" (TAC_HeatGlove)
    envanterde yoksa sağ kola yanık hasarı uygulanır.
        hasar = maksimum x (0.5 + 0.5 x clamp((sıcaklık - eşik) / 350, 0, 1))
    ACE tıbbı varsa ace_medical_fnc_addDamageToUnit ("RightArm", "burn": termal yanık yarası; ACE tıbbı
    menüsünde sağ kolda "yanık" olarak görünür), yoksa vanilla "HitHands".
    Oyuncuya ek bildirim verilmez: acı ve yara ACE tıbbından görünür.
    Elle denemek için (debug konsolu, yerel): ["TAC_mg_hotBarrel", [ACE_player, 300]] call CBA_fnc_localEvent

    Parametreler:
        0: OBJECT - namluyu tutan birim
        1: NUMBER - çıkarılan namlunun sıcaklığı (°C, ACE)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_temp", 0, [0]]];

if (isNull _unit || {!local _unit} || {!alive _unit}) exitWith {};

private _gloved = "TAC_HeatGlove" in (items _unit);
private _hot = _temp >= TAC_mg_burnTemp;
private _damage = TAC_mg_burnDamage * (0.5 + (0.5 * ((((_temp - TAC_mg_burnTemp) / 350) max 0) min 1)));
private _medical = !isNil "ace_medical_fnc_addDamageToUnit";

private _burn = TAC_mg_burn && {_hot} && {!_gloved} && {_damage > 0};

if (TAC_mg_debug) then {
    systemChat format [
        "[TAC mg] namlu degisti | sicaklik %1 | esik %2 | eldiven %3 | yanik ayari %4 | hasar %5 | ACE tibbi %6 | SONUC: %7",
        round _temp,
        TAC_mg_burnTemp,
        _gloved,
        TAC_mg_burn,
        (round (_damage * 100)) / 100,
        _medical,
        ["yanik YOK", "YANIK UYGULANDI"] select _burn
    ];
};

if (!_burn) exitWith {};

if (_medical) then {
    [_unit, _damage, "RightArm", "burn"] call ace_medical_fnc_addDamageToUnit;
} else {
    _unit setHitPointDamage ["HitHands", ((_unit getHitPointDamage "HitHands") + _damage) min 1];
};
