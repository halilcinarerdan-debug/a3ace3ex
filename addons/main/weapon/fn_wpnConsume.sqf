/*
    Fonksiyon: TAC_fnc_wpnConsume
    Çalışma yeri: İstemci

    Envanterden bir adet eşya düşer. removeItem'in dönüş değerine güvenilmez: eşyanın envanter
    sayısı önce/sonra karşılaştırılır. "Bakım malzemesi gerekli" kapalıysa hiçbir şey düşmez ve true döner.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - eşya classname

    Dönüş: BOOL - eşya düşüldü (ya da gerekmiyordu)
*/

params [["_unit", objNull, [objNull]], ["_class", "", [""]]];

if (!TAC_wpn_needKit) exitWith {true};

private _lower = toLower _class;
private _before = {(toLower _x) isEqualTo _lower} count (items _unit);

if (_before == 0) exitWith {false};

_unit removeItem _class;

({(toLower _x) isEqualTo _lower} count (items _unit)) < _before
