/*
    Fonksiyon: TAC_fnc_crackOnSuppressed
    Çalışma yeri: İstemci (CBA yerel olayı "TAC_suppressed")

    Efekti tetikleme koşulları (hepsi sağlanmalı):
      - modül açık, oyuncu hayatta
      - mermi tetik mesafesinden (varsayılan 3 m) yakın geçti
      - mermi hızı minimum hızdan (varsayılan 343 m/s) yüksek
        (hız olaydaki gerçek mermi nesnesinden; alınamadıysa config typicalSpeed)
      - atıcı dost değil (ayar izin vermiyorsa)
      - bekleme süresi doldu

    Parametreler: [unit, mesafe, atıcı, mühimmat, hız]
    Dönüş: yok
*/

params ["_unit", "_distance", "_shooter", "_ammo", ["_speed", -1]];

if (!TAC_crack_enabled || {!alive _unit} || {_distance > TAC_crack_dist}) exitWith {};

if (_speed <= 0) then {
    _speed = getNumber (configFile >> "CfgAmmo" >> _ammo >> "typicalSpeed");
};

private _reason = "";

if (_speed < TAC_crack_minSpeed) then {
    _reason = "yavas";
} else {
    if (!TAC_crack_friendly && {!isNull _shooter} && {((side group _shooter) getFriend (side group _unit)) >= 0.6}) then {
        _reason = "dost";
    } else {
        if ((time - (missionNamespace getVariable ["TAC_crack_last", -1000])) < TAC_crack_cooldown) then {
            _reason = "bekleme";
        };
    };
};

if (TAC_crack_debug) then {
    systemChat format [
        "[TAC crack] %1 | hiz %2 m/s | mesafe %3 m | %4",
        _ammo,
        round _speed,
        (round (_distance * 10)) / 10,
        if (_reason isEqualTo "") then {"TETIKLENDI"} else {"atlandi: " + _reason}
    ];
};

if (_reason isEqualTo "") then {
    [] call TAC_fnc_crackStart;
};
