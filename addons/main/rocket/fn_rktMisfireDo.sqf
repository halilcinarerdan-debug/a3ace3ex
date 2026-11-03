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

_state set [3, time + TAC_rkt_waitTime];

if (TAC_rkt_debug) then {
    systemChat format ["[TAC roket] ATESLENMEDI | bekleme %1 sn (tetige tekrar basmak sureyi yeniden baslatir)", TAC_rkt_waitTime];
};
