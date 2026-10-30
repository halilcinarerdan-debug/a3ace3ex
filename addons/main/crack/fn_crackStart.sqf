/*
    Fonksiyon: TAC_fnc_crackStart
    Çalışma yeri: İstemci

    Şok dalgası efektini başlatır (debug konsolundan elle de çağrılabilir: [] call TAC_fnc_crackStart):
      - tam ekran bulanıklık (DynamicBlur PP efekti)
      - kenar kararması (vignette): ekran kenarlarında içe doğru şeffaflaşan 12 kademeli koyu bantlar
        (display 46 üzerinde geçici kontroller; efekt bitince silinir). Orta bölge temiz kalır.
      - tüm HUD'u gizler (showHUD false); orijinal HUD durumu (shownHUD) saklanır ve bitince geri yüklenir
    Süre: ilk ~%40 tam şiddet, kalan sönümlenir. Zamanlayıcılar bir "jeton" taşır: efekt arada
    yeniden tetiklenirse eski zamanlayıcılar geçersiz sayılır.

    Parametreler (hepsi isteğe bağlı; sayı olmayan / yanlış gelen argüman yok sayılır):
        0: NUMBER - süre sn; verilmezse ayardaki süre
        1: NUMBER - şiddet çarpanı 0..1 (blur ve vignette ile çarpılır); verilmezse 1

    Dönüş: yok
*/

private _duration = -1;
private _power = 1;

if (_this isEqualType 0) then {_duration = _this};

if (_this isEqualType []) then {
    if (count _this > 0 && {(_this select 0) isEqualType 0}) then {_duration = _this select 0};
    if (count _this > 1 && {(_this select 1) isEqualType 0}) then {_power = (_this select 1) max 0 min 1};
};

if (_duration < 0) then {_duration = TAC_crack_duration};

private _token = (missionNamespace getVariable ["TAC_crack_token", 0]) + 1;
missionNamespace setVariable ["TAC_crack_token", _token];
missionNamespace setVariable ["TAC_crack_last", time];

// --- HUD ---------------------------------------------------------------------
// Zaten gizliyse (önceki efekt sürüyor) tekrar kaydetme: orijinal durum bozulmasın.
if (TAC_crack_hideHud && {!(missionNamespace getVariable ["TAC_crack_hudHidden", false])}) then {
    missionNamespace setVariable ["TAC_crack_hudSaved", shownHUD];
    missionNamespace setVariable ["TAC_crack_hudHidden", true];
    showHUD false;
};

// --- Bulaniklik --------------------------------------------------------------
// Oncelik 450'den baslar (ACE'nin kullandigi aralik); doluysa ppEffectCreate -1 doner, bir sonrakini dene.
private _blur = missionNamespace getVariable ["TAC_crack_ppBlur", -1];

if (_blur < 0) then {
    for "_i" from 0 to 100 do {
        _blur = ppEffectCreate ["DynamicBlur", 450 + _i];
        if (_blur >= 0) exitWith {};
    };
    missionNamespace setVariable ["TAC_crack_ppBlur", _blur];
};

private _blurValue = TAC_crack_blur * _power;

if (_blur >= 0 && {_blurValue > 0}) then {
    _blur ppEffectEnable true;
    _blur ppEffectForceInNVG true;
    _blur ppEffectAdjust [_blurValue];
    _blur ppEffectCommit 0.05;
};

// --- Vignette ----------------------------------------------------------------
// Onceki efektten kalan kontrolleri temizle, sonra yeniden kur.
{ctrlDelete _x} forEach (missionNamespace getVariable ["TAC_crack_ctrls", []]);
missionNamespace setVariable ["TAC_crack_ctrls", []];

private _display = findDisplay 46;
private _vignette = TAC_crack_vignette * _power;

if (!isNull _display && {_vignette > 0}) then {
    private _controls = [];
    private _rings = 12;
    // Kenardan icerye derinlik: genislikte %16, yukseklikte %26 (her yan). Orta bolge temiz.
    private _stepX = (safeZoneW * 0.16) / _rings;
    private _stepY = (safeZoneH * 0.26) / _rings;

    for "_i" from 0 to (_rings - 1) do {
        private _alpha = _vignette * ((1 - (_i / _rings)) ^ 2.2);
        private _px = safeZoneX + (_i * _stepX);
        private _py = safeZoneY + (_i * _stepY);
        private _pw = safeZoneW - (2 * _i * _stepX);
        private _ph = safeZoneH - (2 * _i * _stepY);

        // Halka = 4 serit (ust, alt, sol, sag); bantlar birbiriyle ust uste binmez.
        {
            private _control = _display ctrlCreate ["RscText", -1];
            _control ctrlSetPosition _x;
            _control ctrlSetBackgroundColor [0, 0, 0, _alpha];
            _control ctrlSetFade 1;
            _control ctrlCommit 0;
            _control ctrlSetFade 0;
            _control ctrlCommit 0.08;
            _controls pushBack _control;
        } forEach [
            [_px, _py, _pw, _stepY],
            [_px, _py + _ph - _stepY, _pw, _stepY],
            [_px, _py + _stepY, _stepX, _ph - (2 * _stepY)],
            [_px + _pw - _stepX, _py + _stepY, _stepX, _ph - (2 * _stepY)]
        ];
    };

    missionNamespace setVariable ["TAC_crack_ctrls", _controls];
};

if (TAC_crack_debug) then {
    systemChat format [
        "[TAC crack] efekt basladi | sure %1 sn | siddet %2 | blur handle %3 (deger %4) | vignette kontrol %5 | display46 %6",
        (round (_duration * 10)) / 10,
        (round (_power * 100)) / 100,
        _blur,
        (round (_blurValue * 100)) / 100,
        count (missionNamespace getVariable ["TAC_crack_ctrls", []]),
        !isNull _display
    ];
};

// --- Zamanlayicilar ----------------------------------------------------------
// ~%40'tan sonra sonumlenmeye basla, sure sonunda temizle.
[{
    params ["_token", "_fadeTime"];
    if (_token != (missionNamespace getVariable ["TAC_crack_token", 0])) exitWith {};

    private _blur = missionNamespace getVariable ["TAC_crack_ppBlur", -1];
    if (_blur >= 0) then {
        _blur ppEffectAdjust [0];
        _blur ppEffectCommit _fadeTime;
    };

    {
        _x ctrlSetFade 1;
        _x ctrlCommit _fadeTime;
    } forEach (missionNamespace getVariable ["TAC_crack_ctrls", []]);
}, [_token, _duration * 0.6], _duration * 0.4] call CBA_fnc_waitAndExecute;

[{
    params ["_token"];
    [_token] call TAC_fnc_crackEnd;
}, [_token], _duration] call CBA_fnc_waitAndExecute;
