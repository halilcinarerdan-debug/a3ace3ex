/*
    Fonksiyon: TAC_fnc_wpnFx
    Çalışma yeri: İstemci

    Bakım eylemlerinin sesi. Sesler oyunda zaten var olduğu doğrulanmış kaynaklardan gelir
    (ACE'nin kendi arıza/namlu sesleri ve ACE'nin kullandığı vanilla dosyalar); eksik sınıf varsa
    sessizce atlanır. playSound3D'nin etkisi globaldir: yakındaki oyuncular da duyar.

        eylem      başlangıç                                   bitiş
        clean      "Acts_carFixingWheel" (alet / sürtme)       sürgü sesi (reload_Katiba)
        lube       -                                           kuru tık (dry9)
        clearJam   ACE "fixing_rifle" / "fixing_pistol"        sürgü sesi
        parts      ACE "ACE_BarrelSwap" (metal)                kuru tık + sürgü sesi
        rocket     kuru tık (kapak / emniyet)                  sürgü sesi

    Parametreler:
        0: OBJECT - birim
        1: STRING - eylem ("clean", "lube", "clearJam", "parts")
        2: STRING - "start" veya "end"
        3: STRING - silah classname (clearJam için tabanca/tüfek sesi seçimi)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_kind", "", [""]], ["_phase", "", [""]], ["_weapon", "", [""]]];

if (!TAC_wpn_fx || {isNull _unit}) exitWith {};

private _pos = _unit modelToWorldVisualWorld (_unit selectionPosition "RightHand");

private _config = {
    params ["_class", "_distance"];

    if (isClass (configFile >> "CfgSounds" >> _class)) then {
        [_class, _pos, nil, _distance] call ace_common_fnc_playConfigSound3D;
    };
};

private _file = {
    params ["_path", "_volume", "_distance"];

    playSound3D [_path, objNull, false, _pos, _volume, 1, _distance];
};

private _click = "a3\sounds_f\weapons\Other\dry9.wss";
private _bolt = "A3\Sounds_F\arsenal\weapons\Rifles\Katiba\reload_Katiba.wss";

switch (_kind) do {
    case "clean": {
        if (_phase isEqualTo "start") then {["Acts_carFixingWheel", 20] call _config};
        if (_phase isEqualTo "end") then {[_bolt, 1, 30] call _file};
    };
    case "lube": {
        if (_phase isEqualTo "end") then {[_click, 1, 15] call _file};
    };
    case "clearJam": {
        if (_phase isEqualTo "start") then {
            private _cat = [_weapon] call TAC_fnc_wpnCategory;
            private _class = if (_cat isEqualTo [] || {!((_cat select 0) isEqualTo "pistol")}) then {"ace_overheating_fixing_rifle"} else {"ace_overheating_fixing_pistol"};

            [_class, 25] call _config;
        };
        if (_phase isEqualTo "end") then {[_bolt, 1, 30] call _file};
    };
    case "rocket": {
        // Roketatar hazirlik / muhimmat cikarma: baslangicta kapak / emniyet tiki, bitiste surgu sesi
        if (_phase isEqualTo "start") then {[_click, 1, 15] call _file};
        if (_phase isEqualTo "end") then {[_bolt, 1, 30] call _file};
    };
    case "parts": {
        if (_phase isEqualTo "start") then {["ACE_BarrelSwap", 30] call _config};
        if (_phase isEqualTo "end") then {
            [_click, 1, 15] call _file;
            [_bolt, 1, 30] call _file;
        };
    };
};
