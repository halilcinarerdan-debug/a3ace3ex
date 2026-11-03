/*
    Fonksiyon: TAC_fnc_optApply
    Çalışma yeri: İstemci

    Lens durumunu ekrana yansıtır: seviye = min(1, (buğu + 0.6 x kir) / 100).
      - bulanıklık = "En fazla bulanıklık" x seviye^1.3        (DynamicBlur)
      - kontrast düşüşü = 0.3 x pus ayarı x seviye, hafif aydınlanma (ColorCorrections)
    PP efektleri ilk kullanımda bir kez yaratılır ve kalıcı tutulur (yaratıp yok etmek takılma yapar);
    seviye çok düşükse kapatılır. Efekt öncelikleri 480 ve 620'den başlar, doluysa bir sonrakine geçilir.

    Parametreler:
        0: NUMBER - buğu 0..100
        1: NUMBER - kir 0..100

    Dönüş: yok
*/

params [["_fog", 0, [0]], ["_dirt", 0, [0]]];

private _level = ((_fog + (0.6 * _dirt)) / 100) min 1;

private _blur = missionNamespace getVariable ["TAC_opt_ppBlur", -1];
private _color = missionNamespace getVariable ["TAC_opt_ppColor", -1];

if (_blur < 0) then {
    for "_i" from 0 to 100 do {
        _blur = ppEffectCreate ["DynamicBlur", 480 + _i];
        if (_blur >= 0) exitWith {};
    };
    missionNamespace setVariable ["TAC_opt_ppBlur", _blur];
};

if (_color < 0) then {
    for "_i" from 0 to 100 do {
        _color = ppEffectCreate ["ColorCorrections", 620 + _i];
        if (_color >= 0) exitWith {};
    };
    missionNamespace setVariable ["TAC_opt_ppColor", _color];
};

if (_level < 0.02) exitWith {
    call TAC_fnc_optClearEffects;
};

private _blurValue = TAC_opt_blurMax * (_level ^ 1.3);

if (_blur >= 0) then {
    _blur ppEffectEnable (_blurValue > 0);
    _blur ppEffectAdjust [_blurValue];
    _blur ppEffectCommit 0.5;
};

if (_color >= 0) then {
    _color ppEffectEnable (TAC_opt_haze > 0);
    _color ppEffectAdjust [1, 1 - (0.3 * TAC_opt_haze * _level), 0.04 * TAC_opt_haze * _level, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
    _color ppEffectCommit 0.5;
};
