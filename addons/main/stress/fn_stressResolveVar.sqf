/*
    Fonksiyon: TAC_fnc_stressResolveVar
    Çalışma yeri: İstemci

    Sway çarpanının yazılacağı değişkeni bulur. "Sway değişkeni" ayarı "auto" ise sırayla
    ace_common_swayFactor ve ace_advanced_fatigue_swayFactor aranır; sayı olarak tanımlı
    ilki seçilir. Hiçbiri yoksa "" döner (yedek: setCustomAimCoef).

    Parametreler: yok
    Dönüş: STRING - değişken adı veya ""
*/

private _setting = TAC_stress_swayVar;
private _candidates = if ((toLower _setting) in ["", "auto"]) then {
    ["ace_common_swayFactor", "ace_advanced_fatigue_swayFactor"]
} else {
    [_setting]
};

private _index = _candidates findIf {
    private _value = missionNamespace getVariable [_x, objNull];
    _value isEqualType 0
};

if (_index < 0) then {""} else {_candidates select _index}
