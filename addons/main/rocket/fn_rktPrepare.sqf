/*
    Fonksiyon: TAC_fnc_rktPrepare
    Çalışma yeri: İstemci

    "Atışa hazırla": fırlatıcıya ve yüklü başlığa özel çok adımlı prosedür (TAC_fnc_rktPrepSteps): ör. RPG-7'de
    emniyet kapağı, başlık-itici birleştirme, horoz; Javelin'de BCU, CLU gücü, soğutma; tandem / termobarik / HE
    başlıkta ek bir kontrol adımı. Her adım kendi çubuğu, hareketi ve sesiyle çalışır (TAC_fnc_wpnSteps); bir
    adım iptal edilirse prosedür baştan başlar. Son adım bitince hazır işareti açılır.
    Güdümlü fırlatıcıda (pil ve soğutma açıksa) ayrıca sistem açılır: pil sayılmaya başlar, arayıcı soğumaya girer.
    Reload, atış veya ateşlenmeyen mühimmatın çıkarılması hazırlığı sıfırlar. Mühimmat yoksa yapılmaz.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "" || {(_unit ammo _weapon) < 1}) exitWith {};

private _mags = secondaryWeaponMagazine _unit;
private _magazine = if (_mags isEqualTo []) then {currentMagazine _unit} else {_mags select 0};

[_unit, [_weapon, _magazine] call TAC_fnc_rktPrepSteps, "rocket", _weapon, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    if !(_weapon isEqualTo (secondaryWeapon _unit)) exitWith {};

    private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
    private _category = ([_weapon] call TAC_fnc_rktProfile) select 0;

    if (TAC_rkt_guided && {_category isEqualTo "guided"}) then {
        // Sistemi ac: pil bos degilse guc verilir, arayici sogumaya baslar (sicak havada daha yavas).
        if ((_state param [9, 100]) <= 0) exitWith {
            ["Pil boş: sistem açılmadı. Yedek pille 'Pili değiştir'."] call ace_common_fnc_displayTextStructured;
        };

        private _hot = ((((ambientTemperature select 0) - 25) / 20) max 0) min 1;

        _state set [7, time];
        _state set [8, time + (TAC_rkt_cooldown * (1 + (0.5 * _hot)))];
    };

    _state set [5, true];
}, [_weapon]] call TAC_fnc_wpnSteps;
