/*
    Fonksiyon: TAC_fnc_stashPop
    Çalışma yeri: İstemci

    Alınan bir eşyanın kayıtlı durumunu bulur ve kayıttan siler (TAC_fnc_stashPush'un karşılığı).
    Önce alınan kaptaki kayıt ("TAC_stash"); yoksa genel listede (TAC_stashGlobal) aynı anahtarlı, alan kişiye
    8 m içindeki EN YENİ kayıt. Bulunan kaydın kimliği her iki yerden de silinir.

    Parametreler:
        0: OBJECT - alınan kap
        1: OBJECT - alan oyuncu
        2: STRING - anahtar

    Dönüş: ARRAY - yük, bulunamadıysa []
*/

params [["_container", objNull, [objNull]], ["_unit", objNull, [objNull]], ["_key", "", [""]]];

private _payload = [];
private _id = -1;

// 1) kaptaki kayit
if (!isNull _container) then {
    private _stash = _container getVariable ["TAC_stash", []];
    private _index = _stash findIf {(_x select 0) isEqualTo _key};

    if (_index >= 0) then {
        private _entry = _stash select _index;

        _payload = _entry select 1;
        _id = _entry select 2;

        _stash deleteAt _index;
        _container setVariable ["TAC_stash", _stash, true];
    };
};

private _global = missionNamespace getVariable ["TAC_stashGlobal", []];

// 2) yedek: genel listede en yakin / en yeni kayit
if (_id < 0) then {
    private _best = -1;
    private _bestTime = -1;

    {
        _x params ["_k", "", "", "_pos", "_time"];

        if (_k isEqualTo _key && {(_pos distance2D (getPosATL _unit)) < 8} && {_time > _bestTime}) then {
            _best = _forEachIndex;
            _bestTime = _time;
        };
    } forEach _global;

    if (_best >= 0) then {
        _payload = (_global select _best) select 1;
        _id = (_global select _best) select 2;
    };
};

// Kimligi genel listeden de sil (kaptan alindiysa cift kayit kalmasin)
if (_id >= 0) then {
    private _index = _global findIf {(_x select 2) == _id};

    if (_index >= 0) then {
        _global deleteAt _index;
        missionNamespace setVariable ["TAC_stashGlobal", _global, true];
    };
};

_payload
