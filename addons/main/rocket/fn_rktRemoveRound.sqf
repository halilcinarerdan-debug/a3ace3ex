/*
    Fonksiyon: TAC_fnc_rktRemoveRound
    Çalışma yeri: İstemci

    "Ateşlenmeyen mühimmatı çıkar": bekleme süresi dolduktan sonra yapılır. 8 sn x bakım süresi çarpanı
    (silah bakım sistemiyle ortak ayar). Bitince:
      - tek kullanımlık: fırlatıcı artık güvenle atılabilir, silahtan çıkarılır (yenisi gerekir)
      - yeniden doldurulabilir / güdümlü: ateşlenmeyen mühimmat atılır (tüp boşalır, yeni mühimmat yüklenebilir)
    Zar ve ateşlenmeme durumu sıfırlanır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "") exitWith {};

[_unit, "Ateşlenmeyen mühimmat çıkarılıyor...", 8 * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    if !(_weapon isEqualTo (secondaryWeapon _unit)) exitWith {};

    private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
    private _profile = [_weapon] call TAC_fnc_rktProfile;

    _state set [1, false];
    _state set [2, false];
    _state set [3, 0];
    _state set [5, false];

    if ((_profile select 0) isEqualTo "disposable") then {
        _unit removeWeapon _weapon;
        ["Ateşlenmeyen fırlatıcı güvenle çıkarıldı."] call ace_common_fnc_displayTextStructured;
    } else {
        _unit setAmmo [_weapon, 0];
        ["Ateşlenmeyen mühimmat çıkarıldı."] call ace_common_fnc_displayTextStructured;
    };
}, [_weapon], "rocket"] call TAC_fnc_wpnRun;
