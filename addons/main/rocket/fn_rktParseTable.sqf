/*
    Fonksiyon: TAC_fnc_rktParseTable
    Çalışma yeri: İstemci + sunucu (ayar kaydında ve her değişimde CBA çağırır)

    "Ateşlenmeme tablosu" ayarını ("classname=yüzde, ...") çözer ve TAC_rkt_map (HashMap:
    küçük_harf_classname -> ihtimal 0..1) üretir; profil önbelleği sıfırlanır. Ayraç ","
    (";" CBA ayar dosyasında komut ayracıdır). Geçersiz girişler (sayı değil, < 0) atlanır.

    Parametreler:
        0: STRING - tablo metni

    Dönüş: yok
*/

params [["_table", "", [""]]];

private _map = createHashMap;

{
    private _parts = _x splitString "= ";

    if (count _parts >= 2) then {
        private _percent = parseNumber (_parts select 1);

        if (_percent >= 0) then {_map set [toLower (_parts select 0), _percent / 100]};
    };
} forEach (_table splitString ",;");

missionNamespace setVariable ["TAC_rkt_map", _map];
missionNamespace setVariable ["TAC_rkt_profileCache", createHashMap];
