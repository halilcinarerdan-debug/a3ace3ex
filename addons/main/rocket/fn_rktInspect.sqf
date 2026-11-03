/*
    Fonksiyon: TAC_fnc_rktInspect
    Çalışma yeri: İstemci

    "Mühimmatı / fırlatıcıyı incele": ikincil silahın (fırlatıcı) kartı. Oyuncu isteyince görür.
    Config'ten okunur (RHS / CUP / vanilla fark etmez): tür, yüklü mühimmat, başlık türü (warheadName),
    emniyet / silahlanma mesafesi (fuseDistance), etki alanı (indirectHitRange), ACE geri tepme alanı
    (ace_overpressure_range varsa). Tüp durumu sözlü (yeni gibi / kullanılmış / yıpranmış). Ateşlenmeme
    bekleme durumu ("bekle ~N sn" / "mühimmat çıkarılabilir"). Silahçıya ihtimal ve atış sayısı da yazılır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "") exitWith {};

private _profile = [_weapon] call TAC_fnc_rktProfile;
private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
_state params ["_shots", "", "_misfire", "_pendingUntil", "_count"];

private _mags = secondaryWeaponMagazine _unit;
private _mag = if (_mags isEqualTo []) then {currentMagazine _unit} else {_mags select 0};
private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;

private _lines = [format ["<t size='1.1'>%1</t>", getText (configFile >> "CfgWeapons" >> _weapon >> "displayName")]];

_lines pushBack format ["Tür: %1", _profile select 2];

if (_ammo isEqualTo "" || {(_unit ammo _weapon) < 1}) then {
    _lines pushBack "Yüklü mühimmat: yok";
} else {
    _lines pushBack format ["Mühimmat: %1", getText (configFile >> "CfgMagazines" >> _mag >> "displayName")];

    private _warhead = getText (_ammoCfg >> "warheadName");
    if !(_warhead isEqualTo "") then {_lines pushBack format ["Başlık: %1", _warhead]};

    private _fuse = getNumber (_ammoCfg >> "fuseDistance");
    if (_fuse > 0) then {_lines pushBack format ["Silahlanma mesafesi: ~%1 m (daha yakın hedefte patlamayabilir)", round _fuse]};

    private _splash = getNumber (_ammoCfg >> "indirectHitRange");
    if (_splash > 0) then {_lines pushBack format ["Patlama etki alanı: ~%1 m", round _splash]};

    private _blast = getNumber (_ammoCfg >> "ace_overpressure_range");
    if (_blast > 0) then {_lines pushBack format ["Geri tepme alanı: ~%1 m arkada tehlikeli", round _blast]};

    if ((_profile select 0) isEqualTo "guided") then {_lines pushBack "Güdümlü: kilit ve yönlendirme gerekir"};
};

if !((_profile select 0) isEqualTo "disposable") then {
    private _wear = _shots / 300;
    _lines pushBack format ["Tüp: %1", if (_wear < 0.25) then {"yeni gibi"} else {if (_wear < 0.7) then {"kullanılmış"} else {"yıpranmış"}}];
};

if (TAC_rkt_prepare && {(_unit ammo _weapon) > 0}) then {
    _lines pushBack format ["Atışa hazır: %1", ["hayır (hazırlanmadı)", "evet"] select (_state select 5)];
};

if (_misfire) then {
    _lines pushBack format [
        "<t color='#ff8844'>Ateşlenmedi: %1</t>",
        if (time < _pendingUntil) then {format ["bekle (~%1 sn)", ceil (_pendingUntil - time)]} else {"bekleme tamam, mühimmat çıkarılabilir"}
    ];
};

if ([_unit] call TAC_fnc_wpnIsArmorer) then {
    _lines pushBack "<t color='#88ccff'>Silahçı değerleri</t>";
    _lines pushBack format ["Taban ateşlenmeme: %1%% (%2) | atış %3 | ateşlenmeme sayısı %4", (round ((_profile select 1) * 1000)) / 10, _profile select 3, _shots, _count];
};

[_lines joinString "<br/>"] call ace_common_fnc_displayTextStructured;
