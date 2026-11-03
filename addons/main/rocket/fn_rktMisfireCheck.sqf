/*
    Fonksiyon: TAC_fnc_rktMisfireCheck
    Çalışma yeri: İstemci (ACE "DefaultAction" koşulu: ACE'nin arıza sistemiyle aynı mekanizma)

    Tetik çekilirken fırlatıcı ateşlenmeli mi? true dönerse varsayılan ateş eylemi iptal edilir ve
    TAC_fnc_rktMisfireDo çalışır: mermi HİÇ çıkmaz (geri tepme alanı da oluşmaz).
    Zar, her yüklü mühimmat için BİR kez atılır (durumda saklanır): reload veya başarılı atışta sıfırlanır.

        p = taban x ölçek x (1 + 1.5 x soğuk + ıslaklık + aşınma)
        soğuk = clamp((5 - sıcaklık °C) / 30, 0, 1)      ıslaklık = yağmur (0..1), sığ suda 1
        aşınma = clamp(atış / 300, 0, 1)  (yalnızca yeniden doldurulabilir ve güdümlü)
        test ayarı varsa p en az o kadar.  Üst sınır 0.5.
    Önce hazırlık kontrolü: "Atışa hazırla" yapılmamışsa (ayar açıksa) atış engellenir, zar atılmaz.
    Hızlı çıkışlar: sistem kapalı, silah elde fırlatıcı değil, mermi yok, silah kullanılamıyor (CBA), ACE güvenlik açık.

    Parametreler (ACE koşulu): [hedef, birim]
    Dönüş: BOOL - true = ateşlenmeme (atış engellenir)
*/

params ["", "_unit"];

if (!TAC_rkt_enabled) exitWith {false};

private _weapon = currentWeapon _unit;

if (_weapon isEqualTo "" || {!(_weapon isEqualTo (secondaryWeapon _unit))} || {(_unit ammo _weapon) < 1}) exitWith {false};
if !(_unit call CBA_fnc_canUseWeapon) exitWith {false};

if (
    !isNil "ace_safemode_fnc_getWeaponSafety"
    && {["ace_safemode"] call ace_common_fnc_isModLoaded}
    && {[_unit, _weapon, currentMuzzle _unit] call ace_safemode_fnc_getWeaponSafety}
) exitWith {false};

private _state = [_unit, _weapon] call TAC_fnc_rktGetState;

// Hazirlanmamis firlatici atesleyemez (tetik sadece tik sesi verir, zar atilmaz, bekleme baslamaz).
missionNamespace setVariable ["TAC_rkt_blockPrep", false];

if (TAC_rkt_prepare && {!(_state select 5)}) exitWith {
    missionNamespace setVariable ["TAC_rkt_blockPrep", true];
    true
};

if !(_state select 1) then {
    private _profile = [_weapon] call TAC_fnc_rktProfile;
    private _reusable = !((_profile select 0) isEqualTo "disposable");
    private _coldF = (((5 - ((ambientTemperature) select 0)) / 30) max 0) min 1;
    private _pos = getPosATL _unit;
    private _wetF = if (surfaceIsWater _pos && {(_pos select 2) < 0.4}) then {1} else {rain min 1};
    private _wearF = if (_reusable) then {((_state select 0) / 300) min 1} else {0};

    private _p = ((_profile select 1) * TAC_rkt_scale * (1 + (1.5 * _coldF) + _wetF + _wearF)) min 0.5;
    if (TAC_rkt_testChance > 0) then {_p = _p max (TAC_rkt_testChance / 100)};

    _state set [1, true];
    _state set [2, random 1 < _p];

    if (TAC_rkt_debug) then {
        systemChat format [
            "[TAC roket] %1 (%2) | ihtimal %3%% | soguk %4 | islaklik %5 | asinma %6 | SONUC: %7",
            _weapon,
            _profile select 2,
            (round (_p * 1000)) / 10,
            (round (_coldF * 100)) / 100,
            (round (_wetF * 100)) / 100,
            (round (_wearF * 100)) / 100,
            ["atesleyecek", "ATESLENMEYECEK"] select (_state select 2)
        ];
    };
};

_state select 2
