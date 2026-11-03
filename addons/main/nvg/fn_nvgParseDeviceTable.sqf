/*
    Fonksiyon: TAC_fnc_nvgParseDeviceTable
    Çalışma yeri: İstemci + sunucu (ayar kaydında ve her değişimde CBA çağırır)

    "Cihaz tüketim çarpanı" ayarını ("classname=çarpan, classname=çarpan, ...") çözer ve
    TAC_nvg_deviceMap (HashMap: küçük_harf_classname -> çarpan) üretir. Çarpan, takılı NVG
    (hmd) sınıfının pil tüketimini ölçekler: 1 = normal, 1.5 = %50 fazla. Tabloda olmayan cihaz 1.
    Ayraç "," dır (";" CBA ayar dosyasında komut ayracıdır); geçersiz girişler (sayı değil, <= 0) atlanır.

    Parametreler:
        0: STRING - tablo metni

    Dönüş: yok
*/

params [["_table", "", [""]]];

private _map = createHashMap;

{
    private _parts = _x splitString "= ";

    if (count _parts >= 2) then {
        private _mult = parseNumber (_parts select 1);

        if (_mult > 0) then {_map set [toLower (_parts select 0), _mult]};
    };
} forEach (_table splitString ",;");

missionNamespace setVariable ["TAC_nvg_deviceMap", _map];
