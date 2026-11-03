/*
    Fonksiyon: TAC_fnc_rktPrepare
    Çalışma yeri: İstemci

    "Atışa hazırla": ilerleme çubuğu + silah hareketi. Türe göre süre (x bakım süresi çarpanı):
      tek kullanımlık 3 sn (kapakları aç, tüpü uzat, emniyet pimlerini çek)
      yeniden doldurulabilir omuz atarı 5 sn (emniyet kapağı, itici / başlık kontrolü, horoz kur)
      güdümlü 6 sn (güç ver, sensör / arayıcıyı başlat)
    Güdümlü fırlatıcıda (pil ve soğutma açıksa) ayrıca sistem açılır: pil sayılmaya başlar, arayıcı soğumaya girer.
    Bitince hazır işareti açılır; reload, atış veya ateşlenmeyen mühimmatın çıkarılması bunu sıfırlar.
    Mühimmat yoksa yapılmaz.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "" || {(_unit ammo _weapon) < 1}) exitWith {};

private _category = ([_weapon] call TAC_fnc_rktProfile) select 0;
private _time = ([3, 5, 6] select ((["disposable", "reloadable", "guided"] find _category) max 0)) * TAC_wpn_cleanTimeMult;

[_unit, "Fırlatıcı atışa hazırlanıyor...", _time, {
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
}, [_weapon], "rocket"] call TAC_fnc_wpnRun;
