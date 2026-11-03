/*
    Fonksiyon: TAC_fnc_rktOnTake
    Çalışma yeri: İstemci (oyuncunun "Take" olayı)

    Hava koşulları yalnızca OYUNCUNUN TAŞIDIĞI fırlatıcı mühimmatını etkiler (nem döngüsü fırlatıcı taşınmıyorsa
    hiçbir şey yapmaz). Araç, mühimmat sandığı, depo gibi envanterlerdeki eşyalar etkilenmez ve kuru saklanmış
    sayılır: oyuncu oradan bir fırlatıcı alırsa mühimmat nemi en fazla %10 olur. Yerdeki (GroundWeaponHolder /
    WeaponHolder) eşyalar dışarıda sayılır, nem sıfırlanmaz.

    Parametreler: Take olayı: [unit, container, item]
    Dönüş: yok
*/

params ["_unit", "_container", "_item"];

if (!TAC_rkt_enabled || {_container isKindOf "WeaponHolder"} || {(getNumber (configFile >> "CfgWeapons" >> _item >> "type")) != 4}) exitWith {};

_unit setVariable ["TAC_rkt_moist", (_unit getVariable ["TAC_rkt_moist", 0]) min 10];
