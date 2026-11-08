/*
    Fonksiyon: TAC_fnc_rktMisfireDo
    Çalışma yeri: İstemci (ACE "DefaultAction" ifadesi; yalnızca TAC_fnc_rktMisfireCheck true iken)

    Ateşlenmeme: kuru tık sesi (ACE'nin arıza sesiyle aynı vanilla dosya). Bekleme süresi başlar; bekleme
    sırasında tetiğe tekrar basılırsa süre yeniden başlar. Bekleme bitince "Roketatar > Ateşlenmeyen
    mühimmatı çıkar" eylemi görünür. Oyuncuya ayrıca bildirim verilmez.

    Parametreler (ACE ifadesi): [hedef, birim, ...]
    Dönüş: yok
*/

params ["", "_unit"];

playSound3D ["a3\sounds_f\weapons\Other\dry9.wss", objNull, insideBuilding _unit >= 0.5, eyePos _unit, 1, 1, 15];

// Hazirlanmadigi icin engellendiyse yalnizca tik (zar / bekleme yok).
if (missionNamespace getVariable ["TAC_rkt_blockPrep", false]) exitWith {};

private _weapon = secondaryWeapon _unit;
private _state = [_unit, _weapon] call TAC_fnc_rktGetState;

if ((_state select 3) <= 0 || {time >= (_state select 3)}) then {
    _state set [4, (_state select 4) + 1];
};

// FM 3-23.25 (2006) misfire bekleme sureleri: AT4 2 dk, M72 ~70 sn (10 sn + 1 dk), M141 BDM 60 sn.
// Ayardaki bekleme (varsayilan 30) olcek olarak kullanilir: 30 = kilavuz degerleri, 15 = yarisi. Diger firlaticilar: ayardaki sure.
private _key = [_weapon] call TAC_fnc_wpnSearchKey;
private _fm = [[["m136", "at4"], 120], [["m72"], 70], [["m141", "bdm"], 60]];
private _fmIndex = _fm findIf {(_x select 0) findIf {(_key find _x) >= 0} >= 0};
private _wait = if (_fmIndex >= 0) then {((_fm select _fmIndex) select 1) * (TAC_rkt_waitTime / 30)} else {TAC_rkt_waitTime};

_state set [3, time + _wait];

if (TAC_rkt_debug) then {
    systemChat format ["[TAC roket] ATESLENMEDI | bekleme %1 sn (tetige tekrar basmak sureyi yeniden baslatir)", round _wait];
};
