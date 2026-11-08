/*
    Fonksiyon: TAC_fnc_rktPanelLayout
    Çalışma yeri: İstemci

    Elindeki fırlatıcı için interaktif hazırlık paneli çizimini verir (şimdilik yalnızca M136 AT4).
    Çizim sade bloklardan oluşur (tasarım alanı 1.6 x 0.9). Adım sırası TAC_fnc_rktPrepSteps ile birebir aynıdır;
    adet uyuşmazsa (ör. başlığa özel ek adım geldiyse) panel kullanılmaz, ACE menü listesi devreye girer.

    Parça biçimi: [etiket, adım no, [şekiller], [[tıklama alanı, etiket alanı], ...]]
    Şekil biçimi: [kapalı alan, açık alan, kapalı renk, açık renk]  (parça "yapıldı" olunca açık duruma geçer)

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: ARRAY - [başlık, sabit şekiller [[alan, renk]], parçalar] ; panel yoksa []
*/

params [["_unit", objNull, [objNull]]];

if (!TAC_rkt_panel) exitWith {[]};

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "") exitWith {[]};

private _key = [_weapon] call TAC_fnc_wpnSearchKey;

if ((_key find "m136") < 0 && {(_key find "at4") < 0}) exitWith {[]};

private _mags = secondaryWeaponMagazine _unit;
private _magazine = if (_mags isEqualTo []) then {currentMagazine _unit} else {_mags select 0};

// Adim sirasi: 0 pim, 1 omuz dayanagi, 2 nisangah+menzil, 3 arka bolge, 4 horoz kolu
if (count ([_weapon, _magazine] call TAC_fnc_rktPrepSteps) != 5) exitWith {[]};

private _grey = [0.34, 0.37, 0.33, 1];

[
    "M136 AT4 - Atışa hazırlık",
    [
        [[0.28, 0.38, 1.10, 0.13], _grey],
        [[1.38, 0.40, 0.04, 0.09], [0.22, 0.24, 0.21, 1]]
    ],
    [
        [
            "Nakliye pimi", 0,
            [[[0.60, 0.51, 0.03, 0.10], [0.60, 0.58, 0.03, 0.10], [0.85, 0.15, 0.15, 1], [0.25, 0.25, 0.25, 0.3]]],
            [[[0.56, 0.50, 0.11, 0.20], [0.52, 0.71, 0.19, 0.04]]]
        ],
        [
            "Omuz dayanağı", 1,
            [[[0.30, 0.51, 0.13, 0.03], [0.30, 0.51, 0.03, 0.18], [0.60, 0.48, 0.2, 1], [0.78, 0.62, 0.25, 1]]],
            [[[0.27, 0.50, 0.19, 0.21], [0.24, 0.71, 0.25, 0.04]]]
        ],
        [
            "Nişangah / menzil", 2,
            [
                [[0.34, 0.355, 0.07, 0.025], [0.36, 0.29, 0.025, 0.09], [0.55, 0.55, 0.55, 1], [0.85, 0.85, 0.85, 1]],
                [[1.26, 0.355, 0.07, 0.025], [1.28, 0.29, 0.025, 0.09], [0.55, 0.55, 0.55, 1], [0.85, 0.85, 0.85, 1]]
            ],
            [
                [[0.31, 0.26, 0.13, 0.12], [0.26, 0.21, 0.23, 0.04]],
                [[1.22, 0.26, 0.15, 0.12], [1.17, 0.21, 0.25, 0.04]]
            ]
        ],
        [
            "Arka bölge", 3,
            [[[0.02, 0.30, 0.22, 0.36], [0.02, 0.30, 0.22, 0.36], [0.55, 0.12, 0.12, 0.35], [0.12, 0.55, 0.18, 0.35]]],
            [[[0.02, 0.30, 0.22, 0.36], [0.02, 0.67, 0.22, 0.04]]]
        ],
        [
            "Horoz kolu", 4,
            [[[0.78, 0.355, 0.14, 0.025], [0.78, 0.27, 0.03, 0.11], [0.55, 0.5, 0.2, 1], [0.9, 0.7, 0.2, 1]]],
            [[[0.75, 0.25, 0.19, 0.13], [0.72, 0.20, 0.25, 0.04]]]
        ]
    ]
]
