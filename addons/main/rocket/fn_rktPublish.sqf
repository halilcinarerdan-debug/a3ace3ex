/*
    Fonksiyon: TAC_fnc_rktPublish
    Çalışma yeri: İstemci (durumun sahibi)

    Roketatar hazırlık durumunu yardımcı arkadaşın görebilmesi için herkese yayınlar (küçük, yalnızca
    değişince): birimde "TAC_pub_rkt" = [silah, hazır mı, prosedür ilerlemesi]. Asıl durum yerelde kalır.

    Parametreler:
        0: OBJECT - birim
        1: STRING - fırlatıcı classname

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]]];

private _state = [_unit, _weapon] call TAC_fnc_rktGetState;

_unit setVariable ["TAC_pub_rkt", [_weapon, _state select 5, _state param [10, 0]], true];
