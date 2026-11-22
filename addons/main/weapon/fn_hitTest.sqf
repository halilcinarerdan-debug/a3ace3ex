/*
    Fonksiyon: TAC_fnc_hitTest
    Çalışma yeri: İstemci (debug konsolu, "Yerel çalıştır")

    İsabet etkilerini OLAYLARDAN BAĞIMSIZ elle dener (tek başına test için):
        ["blink"] call TAC_fnc_hitTest   -> ekran kararması (orta şiddet)
        ["drop"] call TAC_fnc_hitTest    -> elindeki silahı hasarlı yap ve düşür (ihtimal zarı atlanır)
        ["info"] call TAC_fnc_hitTest    -> ayar değerleri ve dinleyicilerin kurulu olup olmadığı
    Bir işlev bile çalışmıyorsa sorun olay tarafında değil, PBO'dadır (eski sürüm derlenmiş / işlev yok).

    Parametreler:
        0: STRING - "blink" | "drop" | "info"

    Dönüş: STRING
*/

params [["_what", "info", [""]]];

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
    default {
        _out = format [
            "surum islevleri: hitOnWound %1 | hitOnSuppressed %2 | hitBlink %3 | hitDisable %4 || ayar: etkin %5 | yontem %6 | bolge %7 | ihtimal %8 | kullanilamaz %9 | dussun %10 | kararma %11 (siddet %12, sure %13) || ACE tibbi olayi: %14",
            !isNil "TAC_fnc_hitOnWound", !isNil "TAC_fnc_hitOnSuppressed", !isNil "TAC_fnc_hitBlink", !isNil "TAC_fnc_hitDisable",
            missionNamespace getVariable ["TAC_hit_enabled", "YOK"], missionNamespace getVariable ["TAC_hit_mode", "YOK"], missionNamespace getVariable ["TAC_hit_zone", "YOK"],
            missionNamespace getVariable ["TAC_hit_chance", "YOK"], missionNamespace getVariable ["TAC_hit_unusable", "YOK"], missionNamespace getVariable ["TAC_hit_drop", "YOK"],
            missionNamespace getVariable ["TAC_hit_blink", "YOK"], missionNamespace getVariable ["TAC_hit_blinkPower", "YOK"], missionNamespace getVariable ["TAC_hit_blinkTime", "YOK"],
            ["ace_medical"] call ace_common_fnc_isModLoaded
        ];
    };
};

systemChat ("[TAC isabet] " + _out);
diag_log ("[TAC][HIT] " + _out);
copyToClipboard _out;

_out
