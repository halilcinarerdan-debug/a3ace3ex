/*
    Fonksiyon: TAC_fnc_wpnHasItem
    Çalışma yeri: İstemci (ACE menü koşullarından çağrılır, ucuz tutulmuştur)

    Bakım eylemi için malzeme var mı? "Bakım malzemesi gerekli" kapalıysa her zaman true.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - eşya classname

    Dönüş: BOOL
*/

params [["_unit", objNull, [objNull]], ["_class", "", [""]]];

!TAC_wpn_needKit || {(toLower _class) in ((items _unit) apply {toLower _x})}
