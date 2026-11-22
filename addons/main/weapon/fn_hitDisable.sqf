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

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - silah classname

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_weapon", ""]];

if (isNull _unit || {_weapon isEqualTo ""}) exitWith {};

if (TAC_hit_unusable) then {
    private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;
    _state set [10, true];
};

if (!TAC_hit_drop) exitWith {
    if (TAC_wpn_debug) then {systemChat format ["[TAC silah] ISABET: %1 hasar gordu (elde kaldi)", _weapon]};
};

private _holder = createVehicle ["GroundWeaponHolder", getPosATL _unit, [], 0, "CAN_COLLIDE"];
_unit action ["DropWeapon", _holder, _weapon];

if (TAC_wpn_debug) then {
    systemChat format ["[TAC silah] ISABET: %1 hasar gordu ve elden dustu", _weapon];
};

[{
    params ["_unit", "_holder", "_weapon"];

    // Silah artik uzerimizde degilse durumu kaba kaydet (OnPut ayni sinif baska silah yoksa kayitlari siler)
    if (!isNull _holder && {!(_weapon in (weapons _unit))}) then {
        [_unit, _holder, _weapon] call TAC_fnc_wpnOnPut;
    };
}, [_unit, _holder, _weapon], 0.3] call CBA_fnc_waitAndExecute;
