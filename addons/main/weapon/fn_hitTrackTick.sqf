/*
    Fonksiyon: TAC_fnc_hitTrackTick
    Çalışma yeri: İstemci (CBA kare başı işleyicisi; yalnızca izlenen mermi varken)

    İzlenen her mermi için önceki ve şimdiki konum arasındaki parçayı silah doğrusuyla test eder
    (TAC_fnc_hitSegDist). Mermi silinmişse (durdu / çarptı) son hız yönünde bir kare daha süpürür.
    Süre aşımı (4 sn), uzaklık (> 400 m) ve silah elde değilse izleme biter; liste boşalınca işleyici kaldırılır.

    Parametreler: yok
    Dönüş: yok
*/

private _list = missionNamespace getVariable ["TAC_hit_tracked", []];
private _unit = ACE_player;
private _weapon = currentWeapon _unit;
private _ok = !isNull _unit && {alive _unit} && {_weapon in [primaryWeapon _unit, handgunWeapon _unit]} && {TAC_hit_enabled} && {TAC_hit_mode != 0};

private _seg = if (_ok) then {[_unit, _weapon] call TAC_fnc_hitWeaponSeg} else {[]};
private _keep = [];
private _hit = false;

{
    _x params ["_proj", "_last", "_vel", "_born"];

    if (_ok && {!_hit}) then {
        private _new = _last;
        private _alive = !isNull _proj;

        if (_alive) then {
            _new = getPosASL _proj;
            _vel = velocity _proj;
        } else {
            // mermi silindi (carpti / durdu): son hiz yonunde bir kare daha
            _new = _last vectorAdd (_vel vectorMultiply (diag_deltaTime max 0.016));
        };

        private _closest = [_seg select 0, _seg select 1, _last, _new] call TAC_fnc_hitSegDist;

        if (TAC_wpn_debug && {_closest < 1}) then {
            systemChat format ["[TAC isabet] izlenen mermi silaha %1 cm yaklasti%2", (round (_closest * 1000)) / 10, ["", " (mermi silindi)"] select !_alive];
        };

        if ([_unit, _closest, "izleme", _seg select 2] call TAC_fnc_hitWeaponHit) then {
            _hit = true;
        } else {
            if (_alive && {(time - _born) < 4} && {(_new distance _unit) < 400}) then {
                _keep pushBack [_proj, _new, _vel, _born];
            };
        };
    };
} forEach _list;

if (_hit) then {_keep = []};

missionNamespace setVariable ["TAC_hit_tracked", _keep];

if (_keep isEqualTo []) then {
    private _id = missionNamespace getVariable ["TAC_hit_pfh", -1];

    if (_id >= 0) then {[_id] call CBA_fnc_removePerFrameHandler};
    missionNamespace setVariable ["TAC_hit_pfh", -1];
};
