/*
    Fonksiyon: TAC_fnc_optActive
    Çalışma yeri: İstemci

    Oyuncu şu an kapalı lensli bir optikten mi bakıyor? Koşullar: sistem açık, hayatta, yaya,
    nişan görünümü (cameraView "GUNNER"), eldeki silah birincil silah ve takılı optik kapalı lensli.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: BOOL
*/

params [["_unit", objNull, [objNull]]];

TAC_opt_enabled
&& {alive _unit}
&& {isNull objectParent _unit}
&& {cameraView isEqualTo "GUNNER"}
&& {(currentWeapon _unit) isEqualTo (primaryWeapon _unit)}
&& {!((primaryWeapon _unit) isEqualTo "")}
&& {[((primaryWeaponItems _unit) select 2)] call TAC_fnc_optIsSealed}
