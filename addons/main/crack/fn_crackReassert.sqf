/*
    Fonksiyon: TAC_fnc_crackReassert
    Çalışma yeri: İstemci (CBA oyuncu olayları: görüş / optik değişimi)

    Şok dalgası efekti sürerken oyuncu optiğe geçince / çıkınca (cameraView, visionMode, silah) oyun
    post-process efektlerini sıfırlayabilir: bulanıklık kaybolur. Bu işlev efekt SÜRÜYORSA (TAC_crack_active)
    bulanıklık efektini yeniden açar ve son değerine ayarlar. Geçiş tamamlandıktan sonra da (0.15 / 0.5 sn)
    bir kez daha uygular. Efekt sürmüyorsa hiçbir şey yapmaz; döngü yoktur.

    Parametreler: yok
    Dönüş: yok
*/

if !(missionNamespace getVariable ["TAC_crack_active", false]) exitWith {};

private _apply = {
    if !(missionNamespace getVariable ["TAC_crack_active", false]) exitWith {};

    private _blur = missionNamespace getVariable ["TAC_crack_ppBlur", -1];
    private _value = missionNamespace getVariable ["TAC_crack_blurAdj", 0];

    if (_blur >= 0 && {_value > 0}) then {
        _blur ppEffectEnable true;
        _blur ppEffectForceInNVG true;
        _blur ppEffectAdjust [_value];
        _blur ppEffectCommit 0.05;

        if (TAC_crack_debug) then {
            systemChat format ["[TAC crack] optik / gorus degisti: blur yeniden uygulandi (%1)", (round (_value * 100)) / 100];
        };
    };
};

call _apply;
[_apply, [], 0.15] call CBA_fnc_waitAndExecute;
[_apply, [], 0.5] call CBA_fnc_waitAndExecute;
