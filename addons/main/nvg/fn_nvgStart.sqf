/*
    Fonksiyon: TAC_fnc_nvgStart
    Çalışma yeri: İstemci

    Pil tüketim döngüsünü başlatır: 0.25 sn aralıklı bir CBA PerFrameHandler.
    Yalnızca NVG açıkken çalışır; zaten çalışıyorsa bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

if ((missionNamespace getVariable ["TAC_nvg_pfh", -1]) >= 0) exitWith {};

missionNamespace setVariable ["TAC_nvg_lastTick", time];

private _pfh = [TAC_fnc_nvgTick, 0.25] call CBA_fnc_addPerFrameHandler;
missionNamespace setVariable ["TAC_nvg_pfh", _pfh];
