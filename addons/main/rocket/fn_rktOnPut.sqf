/*
    Fonksiyon: TAC_fnc_rktOnPut
    Çalışma yeri: İstemci (oyuncunun "Put" olayı)

    Oyuncu bir fırlatıcıyı yere / kutuya / araca / cesede koyunca fırlatıcının durumu (atış sayısı = tüp aşınması,
    yüklü mühimmatın zarı ve ateşlenmeme / bekleme, hazır işareti ve prosedür ilerlemesi, güdümlüde güç / soğuma /
    pil) saklanır (TAC_fnc_stashPush: kapta + yedek genel liste) ve silahı alan kişiyle (aynı oyuncu ya da başkası)
    birlikte gider; ateşlenmeyen bir fırlatıcı başkasının eline geçince de ateşlenmeyen kalır. Güdümlü sistemde
    geçen açık kalma süresi önce pilden düşülür (güç kapatılır). Oyuncudaki kayıt silinir: aynı sınıftan yeni
    fırlatıcı sıfırdan başlar. Mühimmat nemi birime bağlıdır ve taşınmaz.

    Parametreler: Put olayı: [unit, container, item]
    Dönüş: yok
*/

params ["_unit", "_container", "_item"];

if (!TAC_rkt_enabled || {(getNumber (configFile >> "CfgWeapons" >> _item >> "type")) != 4}) exitWith {};

private _key = toLower _item;
private _all = _unit getVariable "TAC_rkt_state";

if (isNil "_all") exitWith {
    if (TAC_rkt_debug) then {systemChat format ["[TAC roket] BIRAKILDI %1 | kayitli durum YOK", _item]};
};

private _state = _all get _key;

if (isNil "_state") exitWith {
    if (TAC_rkt_debug) then {systemChat format ["[TAC roket] BIRAKILDI %1 | kayitli durum YOK", _item]};
};

[_state] call TAC_fnc_rktPowerOff;

[_container, "r:" + _key, _state, getPosATL _unit] call TAC_fnc_stashPush;

if (TAC_rkt_debug) then {
    systemChat format ["[TAC roket] BIRAKILDI %1 | kaydedildi: atis %2 | zar atildi %3 | ATESLENMEME %4 | hazir %5 | kap %6", _item, _state select 0, _state select 1, _state select 2, _state select 5, typeOf _container];
};

if !((toLower (secondaryWeapon _unit)) isEqualTo _key) then {
    _all deleteAt _key;
};
