/*
    Fonksiyon: TAC_fnc_rktOnPut
    Çalışma yeri: İstemci (oyuncunun "Put" olayı)

    Oyuncu bir fırlatıcıyı yere / kutuya / araca / cesede koyunca fırlatıcının durumu (atış sayısı = tüp
    aşınması, yüklü mühimmatın zarı ve ateşlenmeme durumu, bekleme, hazır işareti) kapta saklanır
    ("TAC_rkt_stash": [[silah sınıfı, durum], ...], herkese yayınlanır) ve silahı alan kişiyle (aynı oyuncu
    ya da başkası) birlikte gider; ateşlenmeyen bir fırlatıcı başkasının eline geçince de ateşlenmeyen kalır.
    Oyuncudaki kayıt silinir: aynı sınıftan yeni fırlatıcı sıfırdan başlar. Mühimmat nemi birime bağlıdır
    ve taşınmaz. Kap yok olursa durum da kaybolur.

    Parametreler: Put olayı: [unit, container, item]
    Dönüş: yok
*/

params ["_unit", "_container", "_item"];

if (!TAC_rkt_enabled || {(getNumber (configFile >> "CfgWeapons" >> _item >> "type")) != 4}) exitWith {};

private _key = toLower _item;
private _all = _unit getVariable "TAC_rkt_state";

if (isNil "_all") exitWith {
    if (TAC_rkt_debug) then {systemChat format ["[TAC roket] BIRAKILDI %1 | kayitli durum YOK (hic ateslenmedi / zar atilmadi)", _item]};
};

private _state = _all get _key;

if (isNil "_state") exitWith {
    if (TAC_rkt_debug) then {systemChat format ["[TAC roket] BIRAKILDI %1 | kayitli durum YOK (hic ateslenmedi / zar atilmadi)", _item]};
};

if (TAC_rkt_debug) then {
    systemChat format ["[TAC roket] BIRAKILDI %1 | kapta saklandi: atis %2 | zar atildi %3 | ATESLENMEME %4 | kap %5", _item, _state select 0, _state select 1, _state select 2, typeOf _container];
};

private _stash = _container getVariable ["TAC_rkt_stash", []];

[_state] call TAC_fnc_rktPowerOff;
_stash pushBack [_key, +_state];
_container setVariable ["TAC_rkt_stash", _stash, true];

if !((toLower (secondaryWeapon _unit)) isEqualTo _key) then {
    _all deleteAt _key;
};
