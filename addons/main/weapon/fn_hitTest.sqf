/*
    Fonksiyon: TAC_fnc_hitTest
    Çalışma yeri: İstemci (debug konsolu, "Yerel çalıştır")

    İsabet etkilerini OLAYLARDAN BAĞIMSIZ elle dener (tek başına test için):
        ["blink"] call TAC_fnc_hitTest   -> ekran kararması (orta şiddet)
        ["drop"] call TAC_fnc_hitTest    -> elindeki silahı hasarlı yap ve düşür (ihtimal zarı atlanır)
        ["info"] call TAC_fnc_hitTest    -> ayar değerleri ve dinleyicilerin kurulu olup olmadığı
        ["supp", 0] call TAC_fnc_hitTest -> sentetik "Suppressed" olayı: silahı tam kesen mermi yolu (0 = isabet,
                                            0.5 = silahın 0.5 m üstünden geçer = ıska)
        ["bullet", 0] call TAC_fnc_hitTest -> GERÇEK mermi nesnesi silahın ortasından geçer (oyuncu 2.5 sn hasar almaz);
                                            ProjectileCreated / izleme yolunu test eder
    Bir işlev bile çalışmıyorsa sorun olay tarafında değil, PBO'dadır (eski sürüm derlenmiş / işlev yok).

    Parametreler:
        0: STRING - "blink" | "drop" | "info"

    Dönüş: STRING
*/

params [["_what", "info", [""]], ["_off", 0, [0]]];

private _out = "";

switch (toLower _what) do {
    case "blink": {
        [0.3] call TAC_fnc_hitBlink;
        _out = "kararma tetiklendi";
    };
    case "drop": {
        private _weapon = currentWeapon player;

        if (_weapon isEqualTo "") then {
            _out = "elinde silah yok";
        } else {
            [player, _weapon] call TAC_fnc_hitDisable;
            _out = format ["%1 hasarli yapildi ve birakildi (ayarlara gore)", _weapon];
        };
    };
    case "supp": {
        // Sentetik "Suppressed" olayi: silah doğrusunu yandan kesen mermi yolu (_off metre yukarı kaydırılabilir; 0 = tam isabet)
        private _weapon = currentWeapon player;

        if !(_weapon in [primaryWeapon player, handgunWeapon player]) then {
            _out = "elinde birincil silah / tabanca yok";
        } else {
            private _seg = [player, _weapon] call TAC_fnc_hitWeaponSeg;
            private _mid = ((_seg select 0) vectorAdd (_seg select 1)) vectorMultiply 0.5;
            private _dir = vectorNormalized (player weaponDirection _weapon);
            private _right = vectorNormalized (_dir vectorCrossProduct [0, 0, 1]);
            private _start = (_mid vectorAdd [0, 0, _off]) vectorAdd (_dir vectorMultiply 6) vectorAdd (_right vectorMultiply 4);
            private _vel = (vectorNormalized (((_mid vectorAdd [0, 0, _off])) vectorDiff _start)) vectorMultiply 800;
            private _before = player getVariable ["TAC_hit_next", 0];

            player setVariable ["TAC_hit_next", 0];
            [player, 0.3, objNull, "B_556x45_Ball", 800, _mid vectorAdd (_vel vectorMultiply -0.002), _vel] call TAC_fnc_hitOnSuppressed;
            _out = format ["sentetik Suppressed olayi gonderildi (kaydirma %1 m); sonucu '[TAC isabet]' satirlarindan oku (TAC_wpn_debug acik olmali)", _off];
        };
    };
    case "bullet": {
        // Gercek mermi nesnesi: silah ortasindan gecen mermi yaratilir; oyuncu 2.5 sn hasar almaz (allowDamage false)
        private _weapon = currentWeapon player;

        if !(_weapon in [primaryWeapon player, handgunWeapon player]) then {
            _out = "elinde birincil silah / tabanca yok";
        } else {
            private _seg = [player, _weapon] call TAC_fnc_hitWeaponSeg;
            private _mid = ((_seg select 0) vectorAdd (_seg select 1)) vectorMultiply 0.5;
            private _dir = vectorNormalized (player weaponDirection _weapon);
            private _right = vectorNormalized (_dir vectorCrossProduct [0, 0, 1]);
            private _target = _mid vectorAdd [0, 0, _off];
            private _start = _target vectorAdd (_dir vectorMultiply 10) vectorAdd (_right vectorMultiply 8);
            private _vel = (vectorNormalized (_target vectorDiff _start)) vectorMultiply 800;

            player allowDamage false;
            [{player allowDamage true}, [], 2.5] call CBA_fnc_waitAndExecute;

            private _proj = createVehicle ["B_556x45_Ball", ASLToAGL _start, [], 0, "CAN_COLLIDE"];
            _proj setPosASL _start;
            _proj setVelocity _vel;

            // ProjectileCreated betik mermisinde tetiklenmeyebilir: izlenmediyse elle ekle
            [{
                params ["_proj"];
                private _tracked = (missionNamespace getVariable ["TAC_hit_tracked", []]) findIf {(_x select 0) isEqualTo _proj} >= 0;

                if (!_tracked && {!isNull _proj}) then {
                    systemChat "[TAC isabet] TEST: ProjectileCreated bu mermiyi vermedi, izleme elle ekleniyor";
                    [_proj] call TAC_fnc_hitProjectile;
                };
            }, [_proj], 0.01] call CBA_fnc_waitAndExecute;

            _out = format ["test mermisi gonderildi (kaydirma %1 m, hasar 2.5 sn kapali)", _off];
        };
    };
    default {
        // Kucuk parcalar halinde (tek buyuk format dizisi "pre stack size violation" verebiliyordu)
        private _parts = [];
        _parts pushBack format ["islevler: hitOnWound %1 | hitOnSuppressed %2 | hitBlink %3 | hitDisable %4 | hitProjectile %5", !isNil "TAC_fnc_hitOnWound", !isNil "TAC_fnc_hitOnSuppressed", !isNil "TAC_fnc_hitBlink", !isNil "TAC_fnc_hitDisable", !isNil "TAC_fnc_hitProjectile"];
        _parts pushBack format ["ayar: etkin %1 | yontem %2 | bolge %3 | ihtimal %4 | kullanilamaz %5 | dussun %6", missionNamespace getVariable ["TAC_hit_enabled", "YOK"], missionNamespace getVariable ["TAC_hit_mode", "YOK"], missionNamespace getVariable ["TAC_hit_zone", "YOK"], missionNamespace getVariable ["TAC_hit_chance", "YOK"], missionNamespace getVariable ["TAC_hit_unusable", "YOK"], missionNamespace getVariable ["TAC_hit_drop", "YOK"]];
        _parts pushBack format ["kararma: %1 | siddet %2 | sure %3 | esik %4 cm", missionNamespace getVariable ["TAC_hit_blink", "YOK"], missionNamespace getVariable ["TAC_hit_blinkStrength", "YOK"], missionNamespace getVariable ["TAC_hit_blinkTime", "YOK"], missionNamespace getVariable ["TAC_hit_weaponRadius", "YOK"]];
        _parts pushBack format ["ACE tibbi: modu %1 | ace_medical_fnc_addDamageToUnit %2 (YOKSA vanilla HandleDamage dinleyicisi kullanilir)", ["ace_medical"] call ace_common_fnc_isModLoaded, !isNil "ace_medical_fnc_addDamageToUnit"];
        _out = _parts joinString " || ";
    };
};

systemChat ("[TAC isabet] " + _out);
diag_log ("[TAC][HIT] " + _out);
copyToClipboard _out;

_out
