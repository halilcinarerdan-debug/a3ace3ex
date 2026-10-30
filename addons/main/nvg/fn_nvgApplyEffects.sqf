/*
    Fonksiyon: TAC_fnc_nvgApplyEffects
    Çalışma yeri: İstemci (düşük pilde PFH'den, 0.25 sn'de bir)

    İki ekran efekti (PP) kullanır; ilk kullanımda oluşturulur, NVG kapanınca
    TAC_fnc_nvgClearEffects ile yok edilir:
      - FilmGrain        : parazit (şiddet * "Maksimum parazit şiddeti")
      - ColorCorrections : kalıcı hafif kararma + rastgele ani sönme (flicker)
                           (şiddet * "Maksimum kararma/flicker şiddeti")
    Şiddet arttıkça hem parazit hem sönme sıklığı/derinliği artar.

    Parametreler:
        0: NUMBER - efekt şiddeti, 0..1

    Dönüş: yok
*/

params [["_severity", 0, [0]]];

_severity = (_severity max 0) min 1;

// Öncelik doluysa (başka bir PP efekti) bir sonrakini dene. Başarısızlıkta -1 döner.
private _create = {
    params ["_name", "_priority"];

    private _handle = -1;
    for "_i" from 0 to 20 do {
        _handle = ppEffectCreate [_name, _priority + _i];
        if (_handle >= 0) exitWith {};
    };

    _handle
};

private _grain = missionNamespace getVariable ["TAC_nvg_ppGrain", -1];
if (_grain < 0) then {
    _grain = ["FilmGrain", 7100] call _create;
    missionNamespace setVariable ["TAC_nvg_ppGrain", _grain];
};

private _color = missionNamespace getVariable ["TAC_nvg_ppColor", -1];
if (_color < 0) then {
    _color = ["ColorCorrections", 7130] call _create;
    missionNamespace setVariable ["TAC_nvg_ppColor", _color];
};

// Parazit: [yoğunluk, keskinlik, tane boyutu, parlaklık etkisi 0, parlaklık etkisi 1, tek renk]
if (_grain >= 0) then {
    _grain ppEffectEnable true;
    _grain ppEffectAdjust [_severity * TAC_nvg_noiseMax, 1.5, 3, 1, 1, true];
    _grain ppEffectCommit 0.1;
};

// Kararma: siyaha karışım (alfa). Kalıcı taban + olasılıkla ani sönme.
if (_color >= 0) then {
    private _alpha = _severity * TAC_nvg_flickerMax * 0.35;

    if (random 1 < (0.2 + (0.6 * _severity))) then {
        _alpha = _alpha + ((random 0.6) * _severity * TAC_nvg_flickerMax);
    };

    _alpha = _alpha min 0.95;

    _color ppEffectEnable true;
    _color ppEffectAdjust [1, 1, 0, [0, 0, 0, _alpha], [1, 1, 1, 1], [1, 1, 1, 0]];
    _color ppEffectCommit 0.05;
};
