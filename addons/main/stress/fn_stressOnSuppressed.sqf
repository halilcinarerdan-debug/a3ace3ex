/*
    Fonksiyon: TAC_fnc_stressOnSuppressed
    Çalışma yeri: İstemci (CBA yerel olayı "TAC_suppressed")

    Yakından geçen mermi için stres seviyesini yükseltir. Mesafe eşikten büyükse veya (ayar
    kapalıyken) atıcı dostsa sayılmaz. Artış mesafeye göre azalır:
        artış = mermi_başına_artış * (1 - 0.6 * mesafe / eşik)
    Stres sıfırdan yükseliyorsa temel sway değeri kaydedilir ve düşüş döngüsü (PFH) başlar.

    Parametreler: [unit, mesafe, atıcı, mühimmat]
    Dönüş: yok
*/

params ["_unit", "_distance", "_shooter"];

if (!TAC_stress_enabled || {_distance > TAC_stress_range}) exitWith {};

if (!TAC_stress_friendly && {!isNull _shooter} && {((side group _shooter) getFriend (side group _unit)) >= 0.6}) exitWith {};

private _add = TAC_stress_gain * (1 - (0.6 * (_distance / (TAC_stress_range max 0.1))));
private _level = missionNamespace getVariable ["TAC_stress_level", 0];

// Stres sıfırdan başlıyorsa: hedef değişkeni bul ve temel değeri kaydet.
if (_level <= 0) then {
    private _var = call TAC_fnc_stressResolveVar;

    missionNamespace setVariable ["TAC_stress_var", _var];
    missionNamespace setVariable ["TAC_stress_base", if (_var isEqualTo "") then {getCustomAimCoef _unit} else {missionNamespace getVariable _var}];
    missionNamespace setVariable ["TAC_stress_last", time];
};

missionNamespace setVariable ["TAC_stress_level", (_level + _add) min 1];

if ((missionNamespace getVariable ["TAC_stress_pfh", -1]) < 0) then {
    missionNamespace setVariable ["TAC_stress_pfh", [TAC_fnc_stressTick, 0.1] call CBA_fnc_addPerFrameHandler];
};
