/*
    Fonksiyon: TAC_fnc_rktDebug
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır")

    Roketatar sisteminin durumunu döker: ayarlar, ACE dinleyici kimliği, fırlatıcı profili ve durumu.
    Çıktı ekrana, RPT'ye ("[TAC][RKT-DEBUG]") ve panoya gider.

    Kullanım:
        call TAC_fnc_rktDebug
    Zarı yeniden atmak için (debug konsolu): ([ACE_player, secondaryWeapon ACE_player] call TAC_fnc_rktGetState) set [1, false]

    Parametreler: yok
    Dönüş: STRING - rapor
*/

private _unit = ACE_player;
private _weapon = secondaryWeapon _unit;

private _lines = [
    "== TAC ROKET DEBUG ==",
    format ["Surum (yuklu PBO): %1", getText (configFile >> "CfgPatches" >> "tac_main" >> "versionStr")],
    format ["Aktif: %1 | olcek x%2 | bekleme %3 sn | test ihtimali %4%%", TAC_rkt_enabled, TAC_rkt_scale, TAC_rkt_waitTime, TAC_rkt_testChance],
    format ["ACE DefaultAction dinleyici kimligi: %1 | Fired EH: %2", _unit getVariable ["TAC_rkt_actionId", -1], _unit getVariable ["TAC_rkt_ehFired", -1]]
];

if (_weapon isEqualTo "") then {
    _lines pushBack "Ikincil silah (firlatici) yok.";
} else {
    _lines pushBack format ["Firlatici: %1 | profil [kategori, ihtimal, etiket, kalite]: %2", _weapon, [_weapon] call TAC_fnc_rktProfile];
    _lines pushBack format ["Durum [atis, zar atildi, ateslenmeme, bekleme bitisi, ateslenmeme sayisi]: %1 (time %2)", [_unit, _weapon] call TAC_fnc_rktGetState, round time];
    _lines pushBack format ["Mermi: %1 | elde: %2", _unit ammo _weapon, currentWeapon _unit];
};

private _report = _lines joinString endl;

diag_log ("[TAC][RKT-DEBUG]" + endl + _report);
copyToClipboard _report;
hint _report;

_report
