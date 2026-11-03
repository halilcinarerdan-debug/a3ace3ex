/*
    Fonksiyon: TAC_fnc_wpnOnTake
    Çalışma yeri: İstemci (oyuncunun "Take" olayı)

    Oyuncu bir silahı yerden / kutudan / araçtan / cesetten aldığında:
      - kapta o sınıftan saklı durum varsa (TAC_fnc_wpnOnPut ile bırakılmış) silahın kir/yağ/aşınması
        o durumla devam eder ve kayıt kaptan silinir;
      - yoksa (arsenal, AI cesedi, ölü oyuncu, yeni silah) silah sıfırdan başlar: oyuncu o sınıftan
        başka silah taşımıyorsa eski kalıntı durum silinir.
    Ölü bir oyuncunun silahının durumu cesette yerel kaldığından başkası için sıfırdan başlar.

    Parametreler: Take olayı: [unit, container, item]
    Dönüş: yok
*/

params ["_unit", "_container", "_item"];

if (!TAC_wpn_enabled || {([_item] call TAC_fnc_wpnCategory) isEqualTo []}) exitWith {};

private _key = toLower _item;
private _stash = _container getVariable ["TAC_wpn_stash", []];
private _index = _stash findIf {(_x select 0) isEqualTo _key};

if (_index < 0) exitWith {
    // Kayit yok: baska ayni sinif silahi yoksa kalinti durumu temizle (taze silah).
    if (({(toLower _x) isEqualTo _key} count (weapons _unit)) <= 1) then {
        private _all = _unit getVariable "TAC_wpn_state";

        if (!isNil "_all") then {_all deleteAt _key};
    };
};

private _state = (_stash select _index) select 1;

_stash deleteAt _index;
_container setVariable ["TAC_wpn_stash", _stash, true];

private _all = _unit getVariable "TAC_wpn_state";

if (isNil "_all") then {
    _all = createHashMap;
    _unit setVariable ["TAC_wpn_state", _all];
};

_all set [_key, _state];
