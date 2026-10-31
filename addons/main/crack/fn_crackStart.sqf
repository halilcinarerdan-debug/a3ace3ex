/*
    Fonksiyon: TAC_fnc_crackStart
    Çalışma yeri: İstemci

    Şok dalgası efektini başlatır (debug konsolundan elle de çağrılabilir: [] call TAC_fnc_crackStart):
      - tam ekran bulanıklık (DynamicBlur PP efekti)
      - kenar kararması (vignette): ekran kenarlarında içe doğru yumuşakça (smoothstep) şeffaflaşan, üst
        üste binen katmanlar (ayardaki katman sayısı x 4 şerit; display 46 üzerinde kontroller).
        Orta bölge temiz kalır, köşeler doğal olarak daha koyudur. Kontroller ve blur PP efekti ilk
        tetiklemede bir kez kurulur, sonra kalıcıdır (her seferinde yaratıp silmek takılma yapar);
        efekt bitince yalnızca gizlenir / kapatılır.
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
// PP efekti ilk tetiklemede bir kez yaratilir ve kalici tutulur (her seferinde yarat/yok et
// shader yuklemesi yuzunden takilma yapar); bitince yalnizca kapatilir.
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
    _blur ppEffectCommit 0.1;
};

// --- Vignette ----------------------------------------------------------------
// Kontroller ilk tetiklemede bir kez kurulur ve kalici tutulur (her seferinde 100+ kontrol
// yaratip silmek takilma yapar); bitince yalnizca gizlenir (fade 1). Katman sayisi, ekran
// cozunurlugu degisirse ya da kontroller silinmisse yeniden kurulur.
private _display = findDisplay 46;
private _vignette = TAC_crack_vignette * _power;
private _layers = round TAC_crack_layers;

if (!isNull _display && {_vignette > 0}) then {
    private _controls = missionNamespace getVariable ["TAC_crack_ctrls", []];
    private _key = [_layers, safeZoneW, safeZoneH];

    if (
        !((missionNamespace getVariable ["TAC_crack_ctrlsKey", []]) isEqualTo _key)
        || {count _controls != (_layers * 4)}
        || {(_controls findIf {isNull _x}) >= 0}
    ) then {
        {ctrlDelete _x} forEach _controls;
        _controls = [];

        // Kenardan icerye derinlik: genislikte %20, yukseklikte %32 (her yan). Orta bolge temiz.
        private _stepX = (safeZoneW * 0.20) / _layers;
        private _stepY = (safeZoneH * 0.32) / _layers;

        // Ust uste binen katmanlar: katman j kenardan (j+1) adim derinlige kadar uzanir (4 serit).
        // Bir piksel kendisinden daha derin tum katmanlarla kaplanir, yani opaklik kenara dogru
        // birikir; bant dikisi / halka kenari olmaz, kose dogal olarak daha koyu olur.
        for "_j" from 0 to (_layers - 1) do {
            private _dx = (_j + 1) * _stepX;
            private _dy = (_j + 1) * _stepY;

            {
                private _control = _display ctrlCreate ["RscText", -1];
                _control ctrlSetPosition _x;
                _control ctrlSetFade 1;
                _control ctrlCommit 0;
                _controls pushBack _control;
            } forEach [
                [safeZoneX, safeZoneY, safeZoneW, _dy],
                [safeZoneX, safeZoneY + safeZoneH - _dy, safeZoneW, _dy],
                [safeZoneX, safeZoneY, _dx, safeZoneH],
                [safeZoneX + safeZoneW - _dx, safeZoneY, _dx, safeZoneH]
            ];
        };

        missionNamespace setVariable ["TAC_crack_ctrls", _controls];
        missionNamespace setVariable ["TAC_crack_ctrlsKey", _key];
    };

    // Hedef toplam kararma profili A(t) = vignette * smoothstep (kenarda en yuksek, merkeze yumusak sifir).
    // Katman alfasi: (1 - a_j) = (1 - A_j) / (1 - A_(j+1))  ->  toplam tam olarak A_j olur.
    for "_j" from 0 to (_layers - 1) do {
        private _t0 = _j / _layers;
        private _t1 = (_j + 1) / _layers;
        private _a0 = _vignette * (((1 - _t0) ^ 2) * (1 + (2 * _t0)));
        private _a1 = _vignette * (((1 - _t1) ^ 2) * (1 + (2 * _t1)));
        private _alpha = 1 - ((1 - _a0) / (1 - _a1));

        for "_k" from 0 to 3 do {
            private _control = _controls select ((_j * 4) + _k);
            _control ctrlSetBackgroundColor [0, 0, 0, _alpha];
            _control ctrlSetFade 0;
            _control ctrlCommit 0.15;
        };
    };
};

missionNamespace setVariable ["TAC_crack_active", true];

if (TAC_crack_debug) then {
    systemChat format [
        "[TAC crack] efekt basladi | sure %1 sn | siddet %2 | blur handle %3 (deger %4) | vignette kontrol %5 (katman %6) | display46 %7",
        (round (_duration * 10)) / 10,
        (round (_power * 100)) / 100,
        _blur,
        (round (_blurValue * 100)) / 100,
        count (missionNamespace getVariable ["TAC_crack_ctrls", []]),
        _layers,
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
