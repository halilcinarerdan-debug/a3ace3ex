/*
    Fonksiyon: TAC_fnc_wpnOnTake
    Çalışma yeri: İstemci (oyuncunun "Take" olayı)

    Oyuncu bir silahı yerden / kutudan / araçtan / cesetten alınca, kayıtlı durum varsa (kaptan ya da yedek genel
    listeden, TAC_fnc_stashPop) devralınır:
      - bakım durumu (kir / yağ / aşınma / arıza geçmişi / MG besleme hazırlığı ve ilerlemesi)
      - optik durumu (lens buğusu / kiri)
      - ACE namlu sıcaklığı: bırakıldığı andaki sıcaklık, geçen süre için ACE'nin soğuma hesabıyla (ambient
        sıcaklığa kadar) soğutulup silahı alan birime yazılır
    Kayıt yoksa (arsenal, yeni silah) ve oyuncu o sınıftan başka silah taşımıyorsa kalıntı bakım / optik kaydı
    silinir (sıfırdan başlar).

    Parametreler: Take olayı: [unit, container, item]
    Dönüş: yok
*/

params ["_unit", "_container", "_item"];

if (!TAC_wpn_enabled || {([_item] call TAC_fnc_wpnCategory) isEqualTo []}) exitWith {};

private _key = toLower _item;
private _payload = [_container, _unit, "w:" + _key] call TAC_fnc_stashPop;

private _all = _unit getVariable "TAC_wpn_state";
private _optAll = _unit getVariable "TAC_opt_state";

if (_payload isEqualTo []) exitWith {
    if (TAC_wpn_debug) then {systemChat format ["[TAC silah] ALINDI %1 | kayit YOK -> sifirdan basliyor", _item]};

    if (({(toLower _x) isEqualTo _key} count (weapons _unit)) <= 1) then {
        if (!isNil "_all") then {_all deleteAt _key};
        if (!isNil "_optAll") then {_optAll deleteAt _key};
    };
};

_payload params ["_state", "_optState", "_heat"];

if (!(_state isEqualTo [])) then {
    if (isNil "_all") then {
        _all = createHashMap;
        _unit setVariable ["TAC_wpn_state", _all];
    };

    _all set [_key, _state];
};

if (!(_optState isEqualTo [])) then {
    if (isNil "_optAll") then {
        _optAll = createHashMap;
        _unit setVariable ["TAC_opt_state", _optAll];
    };

    _optAll set [_key, _optState];
};

_heat params ["_temp", "_putTime"];

if (_temp > -999 && {!isNil "ace_overheating_fnc_calculateCooling"} && {!isNil "ace_overheating_fnc_getWeaponData"}) then {
    private _data = [_item] call ace_overheating_fnc_getWeaponData;
    private _elapsed = ((if (isNil "CBA_missionTime") then {0} else {CBA_missionTime}) - _putTime) max 0;
    private _cooled = [_temp, _data select 7, _elapsed, _data select 6] call ace_overheating_fnc_calculateCooling;
    private _tracked = _unit getVariable ["ace_overheating_trackedWeapons", []];
    private _tempVar = format ["ace_overheating_%1_temp", _item];

    _unit setVariable [_tempVar, _cooled, true];
    _unit setVariable [format ["ace_overheating_%1_time", _item], CBA_missionTime];
    _tracked pushBackUnique _tempVar;
    _unit setVariable ["ace_overheating_trackedWeapons", _tracked];

    if (TAC_wpn_debug) then {
        systemChat format ["[TAC silah] ALINDI %1 | devralindi: bakim %2 | optik %3 | namlu %4 C -> %5 C (%6 sn sonra)", _item, !(_state isEqualTo []), !(_optState isEqualTo []), round _temp, round _cooled, round _elapsed];
    };
} else {
    if (TAC_wpn_debug) then {
        systemChat format ["[TAC silah] ALINDI %1 | devralindi: bakim %2 | optik %3", _item, !(_state isEqualTo []), !(_optState isEqualTo [])];
    };
};
