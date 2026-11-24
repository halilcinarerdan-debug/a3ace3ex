/*
    Fonksiyon: TAC_fnc_actionEnsure
    Çalışma yeri: İstemci

    Tetik engelinin (hasarlı silah, roketatar hazırlığı / ateşlenmeme) bağlı olduğu ACE "DefaultAction" gizli eyleminin
    ve iki dinleyicimizin hâlâ yerinde olduğunu doğrular; kayıpsa TAC_fnc_actionRegister ile yeniden kurar. Uzun oturumlarda
    gizli addAction kaybolabiliyordu (engel çalışmıyor, yalnızca "atışı geri al" güvenlik ağı kalıyordu).
    Sürekli döngü yok: silah / yükleme / araç değişiminde (CBA oyuncu olayları) ve güvenlik ağı tetiklenince çağrılır.
    Maliyet: iki getVariable, bir actionIDs, iki "in" araması.

    Parametreler:
        0: OBJECT - (isteğe bağlı) birim; verilmezse ACE_player

    Dönüş: BOOL - true = eylem yerindeydi, false = yeniden kuruldu (ya da kurulamadı)
*/

params [["_unit", objNull, [objNull]]];

if (!hasInterface) exitWith {true};

if (isNull _unit) then {_unit = ACE_player};
if (isNull _unit || {!alive _unit} || {isNil "ace_common_fnc_addActionEventHandler"}) exitWith {true};

private _wpnId = _unit getVariable ["TAC_wpn_actionId", -1];
private _rktId = _unit getVariable ["TAC_rkt_actionId", -1];

// Birim henuz baglanmadiysa (kimlikler -1) is attach'in: yeniden kurma
if (_wpnId < 0 && {_rktId < 0}) exitWith {true};

private _var = _unit getVariable ["ACE_Action_DefaultAction", []];
private _ok = false;

if (_var isEqualType [] && {count _var >= 3}) then {
    private _engineId = _var select 0;
    private _arr = _var select 1;

    if (_engineId isEqualType 0 && {_engineId >= 0} && {_engineId in (actionIDs _unit)} && {_arr isEqualType []} && {count _arr >= 3}) then {
        private _ids = _arr select 1;
        _ok = (_wpnId < 0 || {_wpnId in _ids}) && {_rktId < 0 || {_rktId in _ids}};
    };
};

if (_ok) exitWith {true};

[_unit] call TAC_fnc_actionRegister;

if (TAC_wpn_debug || {TAC_rkt_debug}) then {
    systemChat "[TAC] tetik engeli (ACE DefaultAction) kayipti, yeniden kuruldu";
};

// RPT'ye ilk birkac kez yaz (her olayda tekrarlanirsa dosya sismesin)
private _count = (missionNamespace getVariable ["TAC_action_healCount", 0]) + 1;
missionNamespace setVariable ["TAC_action_healCount", _count];

if (_count <= 5) then {
    diag_log format ["[TAC] tetik engeli (ACE DefaultAction) kayipti, yeniden kuruldu (%1. kez)", _count];
};

false
