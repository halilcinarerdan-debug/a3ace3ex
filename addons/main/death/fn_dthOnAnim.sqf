/*
    Fonksiyon: TAC_fnc_dthOnAnim
    Çalışma yeri: İstemci (oyuncu biriminin "AnimStateChanged" olayı)

    Vanilla revive (ve ACE tıbbı) yaralıyı "bilinçsiz" animasyonuna sokar: animasyon adında "unconscious" geçer ve
    lifeState "INCAPACITATED" olur. Bunu yakalar:
      - bilinçsiz animasyonuna girdi ve lifeState INCAPACITATED -> ölüm / yaralı ekranı başlar ("incap")
      - bilinçsiz animasyonundan çıktı ve lifeState artık INCAPACITATED değil -> efekt yumuşakça söner
    Olay tabanlıdır; ucuz erken çıkışlarla (metin kontrolü) çalışır.

    Parametreler (olay): [unit, anim]
    Dönüş: yok
*/

params ["_unit", "_anim"];

if (!TAC_dth_enabled || {!(_unit isEqualTo ACE_player)}) exitWith {};

private _unc = ((toLower _anim) find "unconscious") >= 0;

if (_unc) then {
    if (!(missionNamespace getVariable ["TAC_dth_active", false]) && {(lifeState _unit) isEqualTo "INCAPACITATED"}) then {
        ["incap"] call TAC_fnc_dthStart;
    };
} else {
    if ((missionNamespace getVariable ["TAC_dth_active", false]) && {(missionNamespace getVariable ["TAC_dth_reason", ""]) isEqualTo "incap"} && {!((lifeState _unit) isEqualTo "INCAPACITATED")}) then {
        [TAC_dth_reviveFade] call TAC_fnc_dthEnd;
    };
};
