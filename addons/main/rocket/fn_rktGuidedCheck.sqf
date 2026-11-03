/*
    Fonksiyon: TAC_fnc_rktGuidedCheck
    Çalışma yeri: İstemci

    Güdümlü füze atış koşulu (pil ve soğutma). Boş metin = atış serbest, doluysa atışı engelleyen neden:
        "guc"     : sistem kapalı (güç yok)
        "pil"     : pil bitmiş (açık kalma süresi dahil hesaplanır)
        "sogutma" : arayıcı henüz soğumadı
        "isindi"  : soğutucu süresi bitti (arayıcı ısındı): sistem kapatılır ve hazırlık sıfırlanır,
                    yeniden 'Atışa hazırla' gerekir
    Tembel hesap: yalnızca tetik çekilirken / incelenirken çağrılır, döngü yok.

    Parametreler:
        0: ARRAY - fırlatıcı durumu

    Dönüş: STRING
*/

params [["_state", [], [[]]]];

private _since = _state param [7, -1];

if (_since < 0) exitWith {"guc"};

private _charge = (_state param [9, 100]) - (((time - _since) / 60) / (TAC_rkt_batteryMinutes max 1) * 100);

if (_charge <= 0) exitWith {
    [_state] call TAC_fnc_rktPowerOff;
    "pil"
};

private _readyAt = _state param [8, 0];

if (time < _readyAt) exitWith {"sogutma"};

if (time > (_readyAt + TAC_rkt_coolantTime)) exitWith {
    [_state] call TAC_fnc_rktPowerOff;
    _state set [5, false];
    "isindi"
};

""
