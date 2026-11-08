/*
    Fonksiyon: TAC_fnc_lockScan
    Çalışma yeri: İstemci (debug konsolundan elle)

    Kilit seslerini değiştirmek için config tarama aracı. Sonuç panoya kopyalanır (editöre yapıştırıp gönder).

    Kullanım:
        ["titan"] call TAC_fnc_lockScan      -> adında "titan" geçen fırlatıcılar (boş string = hepsi)
        [vehicle player] call TAC_fnc_lockScan -> aynı komut, elindeki uçak / araç için kilit-uyarı özellikleri

    Fırlatıcı satırı: sınıf | ata | sesi KENDİ tanımlıyor mu (d) ya da ataladan mı (i) | arama sesi | kilit sesi
    Araç satırı: ses / kilit / füze adı geçen özellikler (RWR, füze uyarısı)

    Parametreler:
        0: STRING - fırlatıcı adı filtresi  VEYA  OBJECT - araç

    Dönüş: STRING - satır sayısı ve panoya kopyalandı bilgisi
*/

params [["_arg", "", ["", objNull]]];

private _out = [];

if (_arg isEqualType objNull) then {
    private _cfg = configOf _arg;
    _out pushBack format ["ARAC: %1 (ata %2)", configName _cfg, configName inheritsFrom _cfg];

    {
        private _n = toLower configName _x;

        if (((_n find "sound") >= 0) && {((_n find "lock") >= 0) || {(_n find "missile") >= 0} || {(_n find "warn") >= 0} || {(_n find "incoming") >= 0}}) then {
            private _v = if (isArray _x) then {str getArray _x} else {getText _x};
            _out pushBack format ["%1 = %2", configName _x, _v];
        };
    } forEach (configProperties [_cfg, "isText _x || isArray _x", true]);

    // Turret silahlari: kilit sesleri
    {
        private _w = configFile >> "CfgWeapons" >> _x;

        if (count getArray (_w >> "lockingTargetSound") > 0) then {
            _out pushBack format ["SILAH %1 | arama %2 | kilit %3", _x, str getArray (_w >> "lockingTargetSound"), str getArray (_w >> "lockedTargetSound")];
        };
    } forEach (weapons _arg);
} else {
    private _filter = toLower _arg;

    {
        private _name = configName _x;

        if (_filter isEqualTo "" || {(toLower _name) find _filter >= 0}) then {
            private _direct = count (configProperties [_x, "configName _x == 'lockingTargetSound'", false]) > 0;

            _out pushBack format [
                "%1 | %2 | %3 | arama %4 | kilit %5",
                _name,
                configName inheritsFrom _x,
                ["i", "d"] select _direct,
                str getArray (_x >> "lockingTargetSound"),
                str getArray (_x >> "lockedTargetSound")
            ];
        };
    } forEach ("isClass _x && {getNumber (_x >> 'type') == 4} && {count getArray (_x >> 'lockingTargetSound') > 0}" configClasses (configFile >> "CfgWeapons"));
};

copyToClipboard (_out joinString "\n");

format ["%1 satir, panoya kopyalandi", count _out]
