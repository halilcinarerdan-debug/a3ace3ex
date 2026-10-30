/*
    Fonksiyon: TAC_fnc_recoilParseOverrides
    Çalışma yeri: İstemci + sunucu (ayar kaydında ve her değişimde CBA çağırır)

    "Kategori istisnaları" ayarını ("mühimmat=kategori; ...") çözer:
        TAC_recoil_overrideMap : HashMap  küçük_harf_mühimmat -> kategori (0..5)
    Geçersiz girişler atlanır; tekrarlarda ilk giriş geçerlidir.

    Parametreler:
        0: STRING - ayar metni

    Dönüş: yok
*/

params [["_table", "", [""]]];

private _map = createHashMap;

{
    private _parts = _x splitString "= ";

    if (count _parts >= 2) then {
        private _key = toLower (_parts select 0);
        private _category = round (parseNumber (_parts select 1));

        if (_category >= 0 && {_category <= 5} && {(_map getOrDefault [_key, -1]) < 0}) then {
            _map set [_key, _category];
        };
    };
} forEach (_table splitString ";");

missionNamespace setVariable ["TAC_recoil_overrideMap", _map];
