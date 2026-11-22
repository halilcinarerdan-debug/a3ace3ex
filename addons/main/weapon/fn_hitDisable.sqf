/*
    Fonksiyon: TAC_fnc_hitDisable
    Çalışma yeri: İstemci (silahın sahibi)

    Silahı hasarlı yapar ve elden yere düşürür:
      - (CBA "kullanılamaz": TAC_hit_unusable) bakım durumunda "hasarlı" işareti (indeks 10): silah yerde / kutuda / başkasında da hasarlı kalır
        (durum silahla birlikte gider: TAC_fnc_wpnOnPut / OnTake); hasarlı silahta tetik yalnızca tık verir
        (TAC_fnc_wpnBrokenCheck). Onarım: silahçı "Parça değiştir" (Silah Yedek Parça Seti)
      - silah, nişangah ve şarjörüyle birlikte yere düşer (GroundWeaponHolder + DropWeapon eylemi)
    Düşme sonrasında (0.3 sn) durum yerdeki kaba kaydedilir; Put olayı kendiliğinden de tetiklenirse ikinci
    çağrı zararsızdır.

    Roketatar (ikincil silah) da desteklenir: hasarlı işareti roketatar durumunda (dizin 11) tutulur, düşünce
    TAC_fnc_rktOnPut ile kaba kaydedilir.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - silah classname

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_weapon", ""]];

if (isNull _unit || {_weapon isEqualTo ""}) exitWith {};

// Hasarli isareti: birincil silah / tabanca = bakim durumu dizin 10; roketatar = roketatar durumu dizin 11
private _isLauncher = _weapon isEqualTo (secondaryWeapon _unit);

if (TAC_hit_unusable) then {
    private _ref = [_unit, _weapon] call TAC_fnc_hitStateRef;
    (_ref select 0) set [_ref select 1, true];
};

if (!TAC_hit_drop) exitWith {
    if (TAC_wpn_debug) then {systemChat format ["[TAC silah] ISABET: %1 hasar gordu (elde kaldi)", _weapon]};
};

// DropWeapon eylemi bazi durumlarda sessizce hicbir sey yapmaz; silahi (nisangah, susturucu, sarjor dahil)
// dogrudan cikarip yerdeki kaba ekleriz.
private _items = (weaponsItems _unit) select {(toLower (_x select 0)) isEqualTo (toLower _weapon)};
private _item = if (_items isEqualTo []) then {[_weapon, "", "", "", [], [], ""]} else {_items select 0};

private _pos = _unit modelToWorld [0, 0.5, 0];
_pos set [2, 0];

private _holder = createVehicle ["GroundWeaponHolder", _pos, [], 0, "CAN_COLLIDE"];
_holder setPosATL _pos;

_unit removeWeapon _weapon;
_holder addWeaponWithAttachmentsCargoGlobal [_item, 1];

// Dayanikli yedek defter (hasar, kap silinse / kayit siniri dolsa da kaybolmasin): TAC_fnc_hitBrokenTake
if (TAC_hit_unusable) then {
    private _reg = missionNamespace getVariable ["TAC_hit_brokenList", []];

    _reg pushBack [toLower _weapon, getPosASL _holder, time];

    if (count _reg > 300) then {_reg deleteAt 0};

    missionNamespace setVariable ["TAC_hit_brokenList", _reg, true];
};

if (TAC_wpn_debug) then {
    systemChat format ["[TAC silah] ISABET: %1 hasar gordu ve elden dustu", _weapon];
};

[{
    params ["_unit", "_holder", "_weapon", "_isLauncher"];

    // Silah artik uzerimizde degilse durumu kaba kaydet (OnPut ayni sinif baska silah yoksa kayitlari siler)
    if (!isNull _holder && {!(_weapon in (weapons _unit))}) then {
        if (_isLauncher) then {
            [_unit, _holder, _weapon] call TAC_fnc_rktOnPut;
        } else {
            [_unit, _holder, _weapon] call TAC_fnc_wpnOnPut;
        };
    };
}, [_unit, _holder, _weapon, _isLauncher], 0.3] call CBA_fnc_waitAndExecute;
