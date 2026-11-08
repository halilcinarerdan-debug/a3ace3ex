/*
    Fonksiyon: TAC_fnc_rktPanel
    Çalışma yeri: İstemci

    Atışa hazırlık panelini açar (ACE self-menü > Roketatar > Atışa hazırla). Sade bir şematik çizim:
    fırlatıcının yalnızca prosedürde dokunulan parçaları. Oyuncu parçalara DOĞRU SIRAYLA tıklar;
    sıradaki parça gösterilmez (eğitim modu açıksa adı sarı yanar). Yapılan parçalar "açık" durumda çizilir
    (pim çıkar, omuz dayanağı açılır, nişangah kalkar, horoz kolu kalkar, arka bölge yeşile döner).
    Yanlış sırada tıklanırsa prosedür baştan başlar (aynı durum: TAC_fnc_rktStepApply). ESC ile kapanır; ilerleme saklanır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: BOOL - panel açıldı mı
*/

params [["_unit", objNull, [objNull]]];

private _layout = [_unit] call TAC_fnc_rktPanelLayout;
if (_layout isEqualTo []) exitWith {false};

_layout params ["_title", "_statics", "_parts"];

if (!createDialog "TAC_ProcDialog") exitWith {false};

private _display = findDisplay 91701;
if (isNull _display) exitWith {false};

private _s = safeZoneH min (safeZoneW / 1.6);
private _ox = safeZoneX + ((safeZoneW - (1.6 * _s)) / 2);
private _oy = safeZoneY + ((safeZoneH - (0.9 * _s)) / 2);

private _fnRect = {
    params ["_r"];
    [_ox + ((_r select 0) * _s), _oy + ((_r select 1) * _s), (_r select 2) * _s, (_r select 3) * _s]
};

private _fnBlock = {
    params ["_rect", "_color"];
    private _c = _display ctrlCreate ["RscText", -1];
    _c ctrlSetPosition ([_rect] call _fnRect);
    _c ctrlSetBackgroundColor _color;
    _c ctrlCommit 0;
    _c
};

private _fnText = {
    params ["_rect", "_text"];
    private _c = _display ctrlCreate ["RscStructuredText", -1];
    _c ctrlSetPosition ([_rect] call _fnRect);
    _c ctrlSetStructuredText parseText format ["<t align='center' size='0.9' color='#dddddd'>%1</t>", _text];
    _c ctrlCommit 0;
    _c
};

// Arka plan ve panel
private _dim = _display ctrlCreate ["RscText", -1];
_dim ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
_dim ctrlSetBackgroundColor [0, 0, 0, 0.55];
_dim ctrlCommit 0;

[[0, 0, 1.6, 0.9], [0.08, 0.09, 0.08, 0.96]] call _fnBlock;

private _titleCtrl = [[0.05, 0.03, 1.5, 0.07], _title] call _fnText;
_titleCtrl ctrlSetStructuredText parseText format ["<t align='center' size='1.3' color='#ffffff'>%1</t>", _title];

// Sabit parcalar (tup govdesi)
{
    _x params ["_rect", "_color"];
    [_rect, _color] call _fnBlock;
} forEach _statics;

[[1.30, 0.52, 0.25, 0.04], "ÖN"] call _fnText;

// Parcalar: sekiller + etiketler (veri uiNamespace'te; yenileme ve tiklama bunu kullanir)
private _data = [];
private _hitList = [];

{
    _x params ["_label", "_step", "_shapes", "_hits"];

    private _shapeData = _shapes apply {
        _x params ["_closed", "_open", "_cc", "_oc"];
        private _c = [_closed, _cc] call _fnBlock;
        [_c, [_closed] call _fnRect, [_open] call _fnRect, _cc, _oc]
    };

    private _labels = [];

    {
        _x params ["_hitRect", "_labelRect"];
        _labels pushBack [[_labelRect, _label] call _fnText, _label];
        _hitList pushBack [_hitRect, _step];
    } forEach _hits;

    _data pushBack [_step, _shapeData, _labels];
} forEach _parts;

// Tiklama dugmeleri en uste (seffaf)
{
    _x params ["_hitRect", "_step"];

    private _btn = _display ctrlCreate ["TAC_RscHit", -1];
    _btn ctrlSetPosition ([_hitRect] call _fnRect);
    _btn setVariable ["TAC_step", _step];
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        [_ctrl getVariable ["TAC_step", 0]] call TAC_fnc_rktPanelClick;
    }];
    _btn ctrlCommit 0;
} forEach _hitList;

// Durum satiri
private _status = [[0.05, 0.80, 1.5, 0.06], ""] call _fnText;

uiNamespace setVariable ["TAC_panel_data", [_data, _status]];
uiNamespace setVariable ["TAC_panel_lock", 0];

["", 0] call TAC_fnc_rktPanelRefresh;

true
