/*
    Fonksiyon: TAC_fnc_wpnParseMgTable
    Çalışma yeri: İstemci + sunucu (ayar kaydında ve her değişimde CBA çağırır)

    "MG olarak zorla" ayarını ("classname, classname, ...") çözer ve TAC_wpn_mgSet (HashMap:
    küçük_harf_classname -> true) üretir. Sınıf önbelleği de sıfırlanır. Ayraç "," dır
    (";" CBA ayar dosyasında komut ayracıdır).

    Parametreler:
        0: STRING - tablo metni

    Dönüş: yok
*/

params [["_table", "", [""]]];

private _set = createHashMap;

{
    private _name = _x splitString " ";
    if (count _name > 0) then {_set set [toLower (_name select 0), true]};
} forEach (_table splitString ",;");

missionNamespace setVariable ["TAC_wpn_mgSet", _set];
missionNamespace setVariable ["TAC_wpn_catCache", createHashMap];
