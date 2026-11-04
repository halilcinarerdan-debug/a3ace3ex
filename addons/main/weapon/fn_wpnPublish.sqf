/*
    Fonksiyon: TAC_fnc_wpnPublish
    Çalışma yeri: İstemci (durumun sahibi)

    MG besleme prosedürü durumunu yardımcı arkadaşın görebilmesi için herkese yayınlar (yalnızca değişince):
    birimde "TAC_pub_feed" = [silah, besleme hazır mı, prosedür ilerlemesi]. Asıl durum yerelde kalır.

    Parametreler:
        0: OBJECT - birim
        1: STRING - silah classname

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]]];

private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;

_unit setVariable ["TAC_pub_feed", [_weapon, _state param [7, true], _state param [8, 0]], true];
