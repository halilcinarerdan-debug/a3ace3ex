/*
    Fonksiyon: TAC_fnc_wpnBrokenDo
    Çalışma yeri: İstemci (ACE "DefaultAction" ifadesi; yalnızca TAC_fnc_wpnBrokenCheck true iken)

    Hasarlı silahta tetik: yalnızca kuru tık sesi (mermi çıkmaz). Oyuncuya ayrıca bildirim verilmez.

    Parametreler (ACE ifadesi): [hedef, birim, ...]
    Dönüş: yok
*/

params ["", "_unit"];

playSound3D ["a3\sounds_f\weapons\Other\dry9.wss", objNull, insideBuilding _unit >= 0.5, eyePos _unit, 1, 1, 15];
