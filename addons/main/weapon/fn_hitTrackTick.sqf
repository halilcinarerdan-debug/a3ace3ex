/*
    Fonksiyon: TAC_fnc_hitTrackTick
    Çalışma yeri: İstemci / sunucu (CBA kare başı işleyicisi; yalnızca izlenen mermi varken)

    İzlenen her [mermi, önceki konum, hız, doğum, HEDEF oyuncu] için önceki ve şimdiki konum arasındaki parçayı hedefin
    silah doğrusuyla test eder (TAC_fnc_hitSegDist). Mermi silinmişse (durdu / çarptı) son hız yönünde bir kare daha
    süpürür. Süre aşımı (4 sn), uzaklık (> 400 m) ve hedefin elinde silah kalmaması izlemeyi bitirir; liste boşalınca
    işleyici kaldırılır. İsabet kararı TAC_fnc_hitWeaponHit'te (hedef başka makinedeyse olay gider).

    Parametreler: yok
    Dönüş: yok
*/

private _list = missionNamespace getVariable ["TAC_hit_tracked", []];
private _segs = createHashMap;
private _keep = [];
private _hit = false;

{
    _x params ["_proj", "_last", "_vel", "_born", "_target"];

    if (!_hit && {TAC_hit_enabled} && {TAC_hit_detect != 0} && {!isNull _target} && {alive _target}) then {
        private _weapon = currentWeapon _target;

        if (!(_weapon isEqualTo "") && {_weapon in [primaryWeapon _target, handgunWeapon _target]}) then {
            private _key = netId _target;
            private _seg = _segs getOrDefault [_key, []];

            if (_seg isEqualTo []) then {
                _seg = [_target, _weapon] call TAC_fnc_hitWeaponSeg;
                _segs set [_key, _seg];
            };

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
                systemChat format ["[TAC isabet] izlenen mermi %1 silahina %2 cm yaklasti%3", name _target, (round (_closest * 1000)) / 10, ["", " (mermi silindi)"] select !_alive];
            };

            if ([_target, _closest, "izleme", _seg select 2] call TAC_fnc_hitWeaponHit) then {
                _hit = true;
            } else {
                if (_alive && {(time - _born) < 4} && {(_new distance _target) < 400}) then {
                    _keep pushBack [_proj, _new, _vel, _born, _target];
                };
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
