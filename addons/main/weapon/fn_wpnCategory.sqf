/*
    Fonksiyon: TAC_fnc_wpnCategory
    Çalışma yeri: İstemci

    Silahın bakım kategorisini verir (sınıf başına bir kez hesaplanır, önbellekli):
        birincil silah (config type 1) : tüfek, ya da şarjör/kayış kapasitesi >= MG eşiği veya
                                         "MG olarak zorla" tablosunda ise MG
        tabanca (type 2)               : tabanca
        diğerleri (fırlatıcı, dürbün...) : [] (takip edilmez)
    Şarjör kapasitesi hem config "magazines" alanından hem "magazineWell" (RHS, CUP, yeni vanilla)
    kümelerinden okunur.

    Parametreler:
        0: STRING - silah classname

    Dönüş: ARRAY - [kategori, kirlenme çarpanı, temizlik süresi (sn), MG mi, en büyük şarjör kapasitesi], takip edilmiyorsa []
*/

params [["_weapon", "", [""]]];

if (_weapon isEqualTo "") exitWith {[]};

if (isNil "TAC_wpn_catCache") then {TAC_wpn_catCache = createHashMap};
if (isNil "TAC_wpn_mgSet") then {[TAC_wpn_mgTable] call TAC_fnc_wpnParseMgTable};

private _key = toLower _weapon;
private _result = TAC_wpn_catCache get _key;

if (isNil "_result") then {
    private _cfg = configFile >> "CfgWeapons" >> _weapon;
    private _type = getNumber (_cfg >> "type");

    _result = [];

    if (_type == 1 || {_type == 2}) then {
        private _isMG = false;
        private _maxCount = 0;

        if (_type == 1) then {
            private _mags = getArray (_cfg >> "magazines");

            {
                {
                    _mags append (getArray _x);
                } forEach (configProperties [configFile >> "CfgMagazineWells" >> _x, "isArray _x", true]);
            } forEach (getArray (_cfg >> "magazineWell"));

            {
                _maxCount = _maxCount max (getNumber (configFile >> "CfgMagazines" >> _x >> "count"));
            } forEach _mags;

            _isMG = _maxCount >= TAC_wpn_mgThreshold || {TAC_wpn_mgSet getOrDefault [_key, false]};

            // Bilinen TUFEK aileleri: magazineWell'lerinde tambur / kutu sarjor olsa da MG sayilmaz
            // (elle "MG olarak zorla" tablosundakiler hariç).
            if (_isMG && {!(TAC_wpn_mgSet getOrDefault [_key, false])}) then {
                private _rifleLike = ["sar308", "sar223", "sar56", "kcr", "mpt5", "mpt7", "knt7", "hk416", "hk417", "g3a", "hk33", "m4a1", "m16", "sr25", "m110", "scar", "tar21", "sig516", "bora"];

                if (_rifleLike findIf {(_key find _x) >= 0} >= 0) then {_isMG = false};

                // Vanilla "arifle_*" silahlari (MX, MX SW, Katiba, Mk20, SPAR...) tufek sayilir: ortak magazineWell'lerindeki
                // 100-200 mermilik tambur / kutu sarjorler onlari MG yapmasin. Vanilla kayisli MG'ler LMG_* / MMG_* adlidir.
                if ((_key find "arifle_") >= 0) then {_isMG = false};
            };
        };

        _result = if (_type == 2) then {
            ["pistol", 0.5, 15, false, 0]
        } else {
            if (_isMG) then {["mg", 1.3, 45, true, _maxCount]} else {["rifle", 1, 25, false, _maxCount]}
        };
    };

    TAC_wpn_catCache set [_key, _result];
};

_result
