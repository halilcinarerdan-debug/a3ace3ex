/*
    Fonksiyon: TAC_fnc_actionRegister
    Çalışma yeri: İstemci

    Silah (hasarlı silahta tetik engeli) ve roketatar (hazırlık / ateşlenmeme tetik engeli) için ACE "DefaultAction"
    dinleyicilerini birimde YENİDEN kurar. ACE bu dinleyiciler için birimde gizli bir addAction kullanır
    (birim değişkeni "ACE_Action_DefaultAction" = [eylem kimliği, [son kimlik, kimlikler, eylemler], birim]).
    Gizli addAction bir nedenle kaybolursa (başka bir betik removeAllActions çağırırsa, uzun oturum, görev betikleri) liste
    durur ama tetik hiçbir şeye bağlı değildir: engel çalışmaz. Bu işlev:
      1. eski (kayıp olabilecek) gizli eylemi siler,
      2. kendi kayıtlarımızı listeden çıkarır, listenin geri kalanını (ACE'nin arıza sistemi ve başkaları) KORUR,
      3. listeyi "eylem yok" (-1) olarak işaretler; ilk addActionEventHandler çağrısı ACE'ye yeni gizli eylemi kurdurur,
      4. iki dinleyicimizi yeniden ekler ve kimliklerini birime yazar (TAC_wpn_actionId, TAC_rkt_actionId).

    Parametreler:
        0: OBJECT - birim

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {isNil "ace_common_fnc_addActionEventHandler"}) exitWith {};

private _name = "ACE_Action_DefaultAction";
private _var = _unit getVariable [_name, []];

private _stale = -1;
private _arr = [-1, [], []];

if (_var isEqualType [] && {count _var >= 3} && {(_var select 1) isEqualType []} && {count (_var select 1) >= 3}) then {
    _stale = _var select 0;
    _arr = _var select 1;
};

if (_stale isEqualType 0 && {_stale >= 0}) then {_unit removeAction _stale};

// Kendi kayitlarimizi listeden cikar (kimlik listesi ve eylem listesi ayni siradadir)
private _ids = _arr select 1;
private _acts = _arr select 2;

{
    private _i = _ids find _x;

    if (_i >= 0) then {
        _ids deleteAt _i;
        _acts deleteAt _i;
    };
} forEach [_unit getVariable ["TAC_wpn_actionId", -1], _unit getVariable ["TAC_rkt_actionId", -1]];

// Eylem kimligi -1: ACE bir sonraki eklemede yeni gizli addAction kurar
_unit setVariable [_name, [-1, _arr, _unit], false];

_unit setVariable ["TAC_wpn_actionId", [
    _unit,
    "DefaultAction",
    {_this call TAC_fnc_wpnBrokenCheck},
    {_this call TAC_fnc_wpnBrokenDo}
] call ace_common_fnc_addActionEventHandler];

_unit setVariable ["TAC_rkt_actionId", [
    _unit,
    "DefaultAction",
    {_this call TAC_fnc_rktMisfireCheck},
    {_this call TAC_fnc_rktMisfireDo}
] call ace_common_fnc_addActionEventHandler];
