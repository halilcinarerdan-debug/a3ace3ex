/*
    Fonksiyon: TAC_fnc_wpnParseMrbsTable
    Çalışma yeri: İstemci + sunucu (ayar kaydında ve her değişimde CBA çağırır)

    "MRBS tablosu" ayarını ("classname=MRBS, classname=MRBS, ...") çözer ve TAC_wpn_mrbsMap
    (HashMap: küçük_harf_classname -> MRBS) üretir. Profil önbelleği de sıfırlanır.
    Ayraç "," dır (";" CBA ayar dosyasında komut ayracıdır). Geçersiz girişler (sayı değil, <= 0) atlanır.

    Parametreler:
        0: STRING - tablo metni

    Dönüş: yok
*/

params [["_table", "", [""]]];

private _map = createHashMap;

{
    private _parts = _x splitString "= ";

    if (count _parts >= 2) then {
        private _mrbs = parseNumber (_parts select 1);

        if (_mrbs > 0) then {_map set [toLower (_parts select 0), _mrbs]};
    };
} forEach (_table splitString ",;");

missionNamespace setVariable ["TAC_wpn_mrbsMap", _map];
missionNamespace setVariable ["TAC_wpn_profileCache", createHashMap];
