/*
    Fonksiyon: TAC_fnc_wpnOnPut
    Çalışma yeri: İstemci (oyuncunun "Put" olayı)

    Oyuncu bir silahı yere / kutuya / araca / cesede koyunca silahın TÜM durumu saklanır (TAC_fnc_stashPush):
      - bakım durumu: kir / yağ / aşınma / arıza geçmişi / besleme (MG) hazırlığı ve ilerlemesi
      - optik durumu: lens buğusu / kiri
      - ACE namlu sıcaklığı (ve bırakma anı)
    Silahı alan (aynı oyuncu ya da başkası) hepsini devralır; sıcaklık geçen süreye göre ACE'nin soğuma
    hesabıyla soğutulur. Oyuncu o sınıftan başka silah taşımıyorsa kendi kayıtları silinir (at-yenisini-al hilesi yok).
    Hiç takip edilmemiş (ateş edilmemiş / incelenmemiş) silahta yalnızca sıcaklık varsa o saklanır.

    Parametreler: Put olayı: [unit, container, item]
    Dönüş: yok
*/

params ["_unit", "_container", "_item"];

if (!TAC_wpn_enabled || {([_item] call TAC_fnc_wpnCategory) isEqualTo []}) exitWith {};

private _key = toLower _item;
private _all = _unit getVariable "TAC_wpn_state";
private _state = if (isNil "_all") then {nil} else {_all get _key};
private _optAll = _unit getVariable "TAC_opt_state";
private _optState = if (isNil "_optAll") then {nil} else {_optAll get _key};
private _temp = _unit getVariable [format ["ace_overheating_%1_temp", _item], -1000];

if (isNil "_state" && {isNil "_optState"} && {_temp < -999}) exitWith {};

private _payload = [
    if (isNil "_state") then {[]} else {_state},
    if (isNil "_optState") then {[]} else {_optState},
    [_temp, if (isNil "CBA_missionTime") then {0} else {CBA_missionTime}]
];

[_container, "w:" + _key, _payload, getPosATL _unit] call TAC_fnc_stashPush;

if (TAC_wpn_debug) then {
    systemChat format ["[TAC silah] BIRAKILDI %1 | kaydedilen: bakim %2 | optik %3 | namlu sicakligi %4", _item, !isNil "_state", !isNil "_optState", round _temp];
};

// Ayni siniftan baska silah tasimiyorsa kendi kayitlarini sil.
if (({(toLower _x) isEqualTo _key} count (weapons _unit)) == 0) then {
    if (!isNil "_all") then {_all deleteAt _key};
    if (!isNil "_optAll") then {_optAll deleteAt _key};
};
