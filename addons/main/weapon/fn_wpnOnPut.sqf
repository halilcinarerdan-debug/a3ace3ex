/*
    Fonksiyon: TAC_fnc_wpnOnPut
    Çalışma yeri: İstemci (oyuncunun "Put" olayı)

    Oyuncu bir silahı yere / kutuya / araca / cesede koyduğunda silahın bakım durumu kapta saklanır
    ("stash": [[silah sınıfı, durum], ...], herkese yayınlanır) ve silahı başkası alınca onunla birlikte
    gider. Oyuncu o sınıftan başka silah taşımıyorsa kendi durumu silinir: aynı sınıftan yeni bir silah
    alırsa sıfırdan başlar ("at, yenisini al" ile temizlik hilesi olmaz).
    Hiç takip edilmemiş (hiç ateş edilmemiş / incelenmemiş) silahta saklanacak bir şey yoktur.
    Kap yok olursa (boşalıp temizlenirse) durum da kaybolur.

    Parametreler: Put olayı: [unit, container, item]
    Dönüş: yok
*/

params ["_unit", "_container", "_item"];

if (!TAC_wpn_enabled || {([_item] call TAC_fnc_wpnCategory) isEqualTo []}) exitWith {};

private _key = toLower _item;
private _all = _unit getVariable "TAC_wpn_state";

if (isNil "_all") exitWith {};

private _state = _all get _key;

if (isNil "_state") exitWith {};

private _stash = _container getVariable ["TAC_wpn_stash", []];

_stash pushBack [_key, +_state];
_container setVariable ["TAC_wpn_stash", _stash, true];

// Ayni siniftan baska silah tasimiyorsa kendi durumunu sil.
if (({(toLower _x) isEqualTo _key} count (weapons _unit)) == 0) then {
    _all deleteAt _key;
};
