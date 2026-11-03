/*
    Fonksiyon: TAC_fnc_rktPowerOff
    Çalışma yeri: İstemci

    Güdümlü fırlatıcının sistemini kapatır: açık kalınan süre kadar pil düşülür (tembel hesap, döngü yok):
        pil % -= geçen dakika / pil ömrü (dk) x 100
    Güç zamanını sıfırlar (-1). Zaten kapalıysa bir şey yapmaz. Atış, reload, bırakma, mühimmat çıkarma ve
    soğutucu bitişinde çağrılır.

    Parametreler:
        0: ARRAY - fırlatıcı durumu (TAC_fnc_rktGetState)

    Dönüş: yok
*/

params [["_state", [], [[]]]];

private _since = _state param [7, -1];

if (_since < 0) exitWith {};

private _charge = (_state param [9, 100]) - (((time - _since) / 60) / (TAC_rkt_batteryMinutes max 1) * 100);

_state set [9, _charge max 0];
_state set [7, -1];
