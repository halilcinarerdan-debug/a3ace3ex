/*
    Fonksiyon: TAC_fnc_rktPanelRefresh
    Çalışma yeri: İstemci

    Paneli durumla eşitler: yapılan adımların parçaları "açık" çizilir, eğitim modunda sıradaki parçanın
    etiketi sarı olur, durum satırına mesaj yazılır.

    Parametreler:
        0: STRING - durum satırı metni (isteğe bağlı)
        1: NUMBER - geçiş süresi sn (isteğe bağlı, varsayılan 0.2)

    Dönüş: yok
*/

params [["_message", "", [""]], ["_commit", 0.2, [0]]];

private _unit = ACE_player;
private _weapon = secondaryWeapon _unit;
private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
private _prepared = _state select 5;
private _progress = _state param [10, 0];

(uiNamespace getVariable ["TAC_panel_data", [[], controlNull]]) params ["_data", "_status"];

{
    _x params ["_step", "_shapes", "_labels"];

    private _done = _prepared || {_step < _progress};
    private _hint = TAC_rkt_panelHint && {!_prepared} && {_step == _progress};

    {
        _x params ["_c", "_closed", "_open", "_cc", "_oc"];
        _c ctrlSetPosition ([_closed, _open] select _done);
        _c ctrlSetBackgroundColor ([_cc, _oc] select _done);
        _c ctrlCommit _commit;
    } forEach _shapes;

    {
        _x params ["_lc", "_text"];
        _lc ctrlSetStructuredText parseText format ["<t align='center' size='0.9' color='%1'>%2</t>", ["#dddddd", "#ffd633"] select _hint, _text];
    } forEach _labels;
} forEach _data;

if (!isNull _status) then {
    _status ctrlSetStructuredText parseText format ["<t align='center' size='0.9' color='#dddddd'>%1</t>", _message];
};
