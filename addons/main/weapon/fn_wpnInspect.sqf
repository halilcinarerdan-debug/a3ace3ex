/*
    Fonksiyon: TAC_fnc_wpnInspect
    Çalışma yeri: İstemci

    "Silahı incele": hedef silahın durumunu ACE yazı kartı olarak gösterir. Oyuncu bunu isteyince
    görür; sistem kendiliğinden hiçbir uyarı vermez. Kart GÖZLEM yazar, sayı yazmaz:
        kir      : temiz / hafif kirli / kirli / çok kirli
        yağ      : kuru / az yağlı / yeterli / bol / aşırı yağlı
        parçalar : yeni gibi / kullanılmış / aşınmış / yıpranmış
        ısı      : soğuk / ılık / sıcak / çok sıcak (ACE namlu sıcaklığı)
        ayrıca   : son temizlikten beri yaklaşık atış, son arıza (tür ve ne zaman), şu an arızalı mı
    Silahçı (TAC_fnc_wpnIsArmorer) ek olarak sayısal değerleri ve tahmini arıza ihtimalini görür.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = [_unit] call TAC_fnc_wpnTargetWeapon;
if (_weapon isEqualTo "") exitWith {};

private _cat = [_weapon] call TAC_fnc_wpnCategory;
private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;
_state params ["_dirt", "_lube", "_wear", "_since", "_lastType", "_lastTime", "_jams"];

private _kind = switch (_cat select 0) do {
    case "mg": {"Makineli tüfek"};
    case "pistol": {"Tabanca"};
    default {"Tüfek"};
};

private _dirtText = if (_dirt < 15) then {"temiz"} else {if (_dirt < 40) then {"hafif kirli"} else {if (_dirt < 70) then {"kirli"} else {"çok kirli"}}};
private _lubeText = if (_lube < 15) then {"kuru"} else {if (_lube < 35) then {"az yağlı"} else {if (_lube <= 85) then {"yeterli"} else {if (_lube <= 95) then {"bol"} else {"aşırı yağlı"}}}};

private _wearRatio = _wear / (TAC_wpn_wearLife max 1);
private _wearText = if (_wearRatio < 0.25) then {"yeni gibi"} else {if (_wearRatio < 0.6) then {"kullanılmış"} else {if (_wearRatio < 0.9) then {"aşınmış"} else {"yıpranmış"}}};

private _temp = _unit getVariable [format ["ace_overheating_%1_temp", _weapon], 0];
private _heatText = if (_temp < 50) then {"soğuk"} else {if (_temp < 150) then {"ılık"} else {if (_temp < 300) then {"sıcak"} else {"çok sıcak"}}};

private _jamNames = createHashMapFromArray [
    ["eject", "kovan atılmadı (stovepipe)"],
    ["extract", "kovan çıkarılamadı"],
    ["feed", "besleme arızası"],
    ["fire", "ateşleme arızası"],
    ["dud", "kusurlu mühimmat"]
];

private _lastText = if (_jams == 0 || {_lastType isEqualTo ""}) then {
    "yok"
} else {
    private _ago = time - _lastTime;
    format [
        "%1 (%2)",
        _jamNames getOrDefault [toLower _lastType, _lastType],
        if (_ago < 90) then {"az önce"} else {format ["~%1 dk önce", round (_ago / 60)]}
    ]
};

private _jammedNow = _weapon in (_unit getVariable ["ace_overheating_jammedWeapons", []]);

private _lines = [
    format ["<t size='1.1'>%1</t>", getText (configFile >> "CfgWeapons" >> _weapon >> "displayName")],
    format ["%1 | namlu: %2", _kind, _heatText],
    format ["Kir: %1", _dirtText],
    format ["Yağ: %1", _lubeText],
    format ["Parçalar: %1", _wearText],
    format ["Son temizlikten beri: ~%1 atış", (round (_since / 10)) * 10],
    format ["Son arıza: %1", _lastText]
];

// Makineli tufek: yedek namlu sayisi ve agirligi
if (getNumber (configFile >> "CfgWeapons" >> _weapon >> "ace_overheating_allowSwapBarrel") == 1) then {
    private _barrelClass = getText (configFile >> "CfgWeapons" >> _weapon >> "ace_overheating_barrelClassname");

    if (_barrelClass isEqualTo "") then {_barrelClass = "ACE_SpareBarrel"};

    private _count = {_x isEqualTo _barrelClass} count (magazines _unit);
    private _kg = (getNumber (configFile >> "CfgMagazines" >> _barrelClass >> "mass")) / 22;

    _lines pushBack format ["Yedek namlu: %1 (her biri ~%2 kg)", _count, (round (_kg * 10)) / 10];
};

// Kapali lensli optik: lens kiri ve bugu
_lines append ([_unit, _weapon, [_unit] call TAC_fnc_wpnIsArmorer] call TAC_fnc_optInspectLines);

if (_jammedNow) then {
    _lines pushBack "<t color='#ff8844'>Şu an arızalı</t>";
};

if ([_unit] call TAC_fnc_wpnIsArmorer) then {
    private _p = [_state, 1, _weapon] call TAC_fnc_wpnJamChance;

    _lines pushBack "<t color='#88ccff'>Silahçı değerleri</t>";
    _lines pushBack format ["Kir %1%% | yağ %2%% | aşınma %3%%", round _dirt, round _lube, round (_wearRatio * 100)];
    private _profile = [_weapon] call TAC_fnc_wpnProfile;

    _lines pushBack format ["Arıza ihtimali: 100 atışta ~%1 (ortam hariç)", (round (_p * 10000)) / 100];
    _lines pushBack format ["Güvenilirlik profili: %1 | temiz MRBS ~%2 (%3)", _profile select 3, _profile select 0, _profile select 4];
};

[_lines joinString "<br/>"] call ace_common_fnc_displayTextStructured;
