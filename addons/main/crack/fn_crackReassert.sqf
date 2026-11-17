/*
    Fonksiyon: TAC_fnc_crackReassert
    Çalışma yeri: İstemci (CBA oyuncu olayları: görüş / optik / silah değişimi)

    Optiğe geçince / çıkınca oyun ya da başka bir mod (LPVO dürbün modları vb.) post-process efektlerini
    silebilir veya sıfırlayabilir: bulanıklık kaybolur ve geri gelmez. Bu işlev:
      - efekt SÜRÜYORSA: bulanıklık efektini SİLİP yeniden yaratır (geçersiz kalmış handle'a karşı), son
        değerine ayarlar; geçişten 0.15 ve 0.5 sn sonra bir kez daha aynısını yapar
      - efekt sürmüyorsa: efekti "kirli" işaretler; bir sonraki tetiklemede (TAC_fnc_crackStart) efekt yeniden
        yaratılır (böylece optik kullanıldıktan sonraki şok dalgasında da bulanıklık çalışır)
    Döngü yoktur.

    Parametreler: yok
    Dönüş: yok
*/

if !(missionNamespace getVariable ["TAC_crack_active", false]) exitWith {
    missionNamespace setVariable ["TAC_crack_ppDirty", true];
};

private _apply = {
    if !(missionNamespace getVariable ["TAC_crack_active", false]) exitWith {};

    private _value = missionNamespace getVariable ["TAC_crack_blurAdj", 0];
    if (_value <= 0) exitWith {};

    // Eski efekti sil, yenisini yarat (geçersiz handle'a karşı)
    private _old = missionNamespace getVariable ["TAC_crack_ppBlur", -1];
    if (_old >= 0) then {ppEffectDestroy _old};

    private _blur = -1;

    for "_i" from 0 to 100 do {
        _blur = ppEffectCreate ["DynamicBlur", 450 + _i];
        if (_blur >= 0) exitWith {};
    };

    missionNamespace setVariable ["TAC_crack_ppBlur", _blur];
    missionNamespace setVariable ["TAC_crack_ppDirty", false];

    if (_blur >= 0) then {
        _blur ppEffectEnable true;
        _blur ppEffectForceInNVG true;
        _blur ppEffectAdjust [_value];
        _blur ppEffectCommit 0.05;

        if (TAC_crack_debug) then {
            systemChat format ["[TAC crack] optik / gorus degisti: blur yeniden yaratildi (handle %1, deger %2)", _blur, (round (_value * 100)) / 100];
        };
    };
};

call _apply;
[_apply, [], 0.15] call CBA_fnc_waitAndExecute;
[_apply, [], 0.5] call CBA_fnc_waitAndExecute;
