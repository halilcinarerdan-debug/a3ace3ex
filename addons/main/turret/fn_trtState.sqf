/*
    Fonksiyon: TAC_fnc_trtState
    Çalışma yeri: İstemci (herhangi bir makine)

    Bir sabit silahın (araç) bir silahının durumunu verir; yoksa oluşturur. Durum ARAÇTA, herkese yayınlanan
    bir değişkende tutulur ("TAC_trt_<silah>"): gunner, yardımcı ve yanından geçen herkes aynı durumu görür.
    Diziyi değiştirdikten sonra TAC_fnc_trtState ile aldığın referansı `_veh setVariable [name, state, true]`
    ile yeniden yayınla (aşağıdaki yardımcı: [_veh, _weapon, _state] çağrısı için ad hesabı aynıdır).

    Düzen (roketatar durumuyla aynı + MG alanları):
      0 atış, 1 zar atıldı, 2 ateşlenmeme var, 3 bekleme bitişi, 4 ateşlenmeme sayısı, 5 hazır (MG besleme /
      fırlatıcı hazırlığı), 6 koşul çarpanı, 7 güç zamanı (güdümlü), 8 soğuma bitişi, 9 pil %, 10 prosedür ilerlemesi,
      11 kir, 12 yağ, 13 aşınma, 14 arızalı (MG)

    Parametreler:
        0: OBJECT - araç (sabit silah)
        1: STRING - silah classname
        2: ARRAY  - (isteğe bağlı) verilirse bu durum yayınlanır (kaydetme)

    Dönüş: ARRAY - durum
*/

params [["_veh", objNull, [objNull]], ["_weapon", "", [""]], ["_save", [], [[]]]];

private _name = "TAC_trt_" + toLower _weapon;

if !(_save isEqualTo []) exitWith {
    _veh setVariable [_name, _save, true];
    _save
};

private _state = _veh getVariable _name;

if (isNil "_state") then {
    _state = [0, false, false, 0, 0, false, 1, -1, 0, 100, 0, 5, 70, 0, false];
    _veh setVariable [_name, _state, true];
};

_state
