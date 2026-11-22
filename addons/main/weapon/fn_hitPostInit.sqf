/*
    Fonksiyon: TAC_fnc_hitPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    İsabet dinleyicileri:
      - ACE tıbbı varsa CBA yerel olayı "ace_medical_woundReceived" ([unit, hasarlar, atıcı, mühimmat]).
      - ACE tıbbı yoksa oyuncu birimine vanilla "HandleDamage" dinleyicisi (değeri DEĞİŞTİRMEZ; son satır nil).
    Her ikisi TAC_fnc_hitOnWound'a gider. Sürekli döngü yok.

    Parametreler: yok
    Dönüş: yok
*/

// ACE tibbi: kendi yerel olayi
["ace_medical_woundReceived", {
    _this call TAC_fnc_hitOnWound;
}] call CBA_fnc_addEventHandler;

// Silah nesnesine isabet testi: mermi yolu silah dogrusuna cok yakin gecerse
["TAC_suppressed", {
    _this call TAC_fnc_hitOnSuppressed;
}] call CBA_fnc_addEventHandler;

// Silah vuruldu (baska makinede izlenen mermiden): yerel birimde silahi hasarla ve dusur
["TAC_hit_weapon", {
    params ["_unit"];

    if (!local _unit || {!alive _unit}) exitWith {};
    if (time < (_unit getVariable ["TAC_hit_next", 0])) exitWith {};

    private _weapon = currentWeapon _unit;

    if (_weapon isEqualTo "" || {!(_weapon in [primaryWeapon _unit, handgunWeapon _unit])}) exitWith {};
    if (([_weapon] call TAC_fnc_wpnCategory) isEqualTo []) exitWith {};

    _unit setVariable ["TAC_hit_next", time + 3];
    [_unit, _weapon] call TAC_fnc_hitDisable;
}] call CBA_fnc_addEventHandler;

// Mermi izleme: ProjectileCreated (silah nesnesine isabet; Suppressed mermi nesnesini vermese de calisir)
addMissionEventHandler ["ProjectileCreated", {
    _this call TAC_fnc_hitProjectile;
}];

// ACE tibbi yoksa vanilla dinleyici (oyuncu birimi degisince yeniden baglanir)
["unit", {
    params ["_newUnit", "_oldUnit"];

    if (!isNull _oldUnit) then {
        private _id = _oldUnit getVariable ["TAC_hit_ehDamage", -1];
        if (_id >= 0) then {_oldUnit removeEventHandler ["HandleDamage", _id]};
        _oldUnit setVariable ["TAC_hit_ehDamage", -1];
    };

    if (isNull _newUnit || {!isNil "ace_medical_fnc_addDamageToUnit"} || {(_newUnit getVariable ["TAC_hit_ehDamage", -1]) >= 0}) exitWith {};

    _newUnit setVariable ["TAC_hit_ehDamage", _newUnit addEventHandler ["HandleDamage", {
        params ["_unit", "_selection", "_damage", "_source", "_projectile"];

        // Yalnizca genel ("") hasar cagrisi, mermi ise: kol secimi ve toplam hasar tek olaya cevrilir
        private _part = switch (true) do {
            case (_selection isEqualTo "hand_l"): {"hand_l"};
            case (_selection isEqualTo "hand_r"): {"hand_r"};
            case (_selection isEqualTo "hands"): {"hands"};
            case (_selection isEqualTo "arm_l"): {"leftarm"};
            case (_selection isEqualTo "arm_r"): {"rightarm"};
            case (_selection isEqualTo ""): {"body"};
            default {""};
        };

        if (!(_part isEqualTo "") && {_projectile isEqualType ""} && {!(_projectile isEqualTo "")}) then {
            private _delta = _damage - (damage _unit);
            if (_delta > 0.001) then {[_unit, [[_delta, _part]], _source, _projectile] call TAC_fnc_hitOnWound};
        };

        nil
    }]];
}, true] call CBA_fnc_addPlayerEventHandler;
