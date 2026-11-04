/*
    Fonksiyon: TAC_fnc_rktPrepSteps
    Çalışma yeri: İstemci

    Fırlatıcıya ve yüklü BAŞLIĞA özel atış hazırlığı prosedürü adımları.
    1) Fırlatıcı ailesine göre (classname alt dizesi): RPG-7 (emniyet kapağı, başlık-itici birleştirme, horoz),
       M72 / RPG-18/22/26/75 (pim, tüpü uzat), M136/AT4, NLAW/APILAS, SMAW/Mk153, MAAWS/Carl Gustaf/MRAWS,
       Panzerfaust, Javelin (BCU, CLU gücü, soğutma), Stinger (soğutucu kartuş, güç, IFF), Igla/Strela
       (pil-soğutma ünitesi), Titan/Vorona/Metis/TOW. Tanınmayan fırlatıcı: türe göre genel süre (3 / 5 / 6 sn).
    2) Başlık türüne göre (güdümsüz): mühimmat config'inden warheadName / sınıf adı: tandem -> çift fünye
       kontrolü; termobarik -> emniyet halkası kontrolü; HE / parçalı (OG-7 vb.) -> fünye ayarı (ani / gecikmeli).
       HEAT'te ek adım yok. Başlık adımı son adımdan hemen önce araya girer.

    Parametreler:
        0: STRING - fırlatıcı classname
        1: STRING - yüklü mühimmat (magazine) classname ("" olabilir)

    Dönüş: ARRAY - [[metin, süre], ...]
*/

params [["_weapon", "", [""]], ["_magazine", "", [""]]];

private _key = [_weapon] call TAC_fnc_wpnSearchKey;
private _category = ([_weapon] call TAC_fnc_rktProfile) select 0;

private _table = [
    [["rpg7", "rpg32"], [["Emniyet kapağını çıkar", 2], ["Başlığı itici barutla birleştir", 3], ["Horozu kur", 2]]],
    [["panzerfaust", "pf60"], [["Emniyet çevirmesini aç", 2], ["Tüpü ve nişangahı kaldır", 2]]],
    [["m72"], [["Emniyet pimini çek", 1.5], ["Tüpü uzat, nişangahı aç", 2]]],
    [["m136", "at4"], [["Ön ve arka kapakları çıkar", 2], ["Emniyeti aç, nişangahı kaldır", 2]]],
    [["rpg18", "rpg22", "rpg26", "rpg75"], [["Emniyet pimini çek", 1.5], ["Tüpü uzat, emniyeti aç", 2.5]]],
    [["nlaw", "apilas"], [["Emniyet kapaklarını aç", 2], ["Nişangahı kaldır, sistemi çalıştır", 2.5]]],
    [["smaw", "mk153"], [["Fırlatma tüpü kilidini kontrol et", 2], ["Fünye ayarı ve emniyeti aç", 2], ["Horozu kur", 1.5]]],
    [["maaws", "carl", "mraws"], [["Kama kilidini kontrol et", 2], ["Emniyeti ve ateşleme modunu ayarla", 2.5], ["Horozu kur", 1]]],
    [["javelin"], [["BCU'yu bağla", 2], ["CLU'ya güç ver", 2], ["Arayıcı soğutmasını başlat", 2]]],
    [["stinger", "fim92"], [["BCU / soğutucu kartuşunu tak", 2.5], ["Güç ver", 1.5], ["IFF ve arayıcıyı başlat", 2]]],
    [["igla", "strela", "9k"], [["Pil-soğutma ünitesini tak", 2.5], ["Güç ver", 1.5], ["Arayıcıyı başlat", 2]]],
    [["tow"], [["Fırlatma tüpünü yerleştir ve kilitle", 3], ["Kablo ve optik bağlantıyı yap", 2.5], ["Gece nişangahı soğutmasını başlat", 2.5], ["Güç ver", 1.5]]],
    [["metis", "kornet", "konkurs", "fagot", "spike", "stugna", "mapats", "9k"], [["Füze tüpünü raya yerleştir ve kilitle", 3], ["Yönlendirme birimini bağla", 2.5], ["Güç ver, termal soğutmayı başlat", 2.5]]],
    [["spg9", "spg-9", "recoilless"], [["Namlu kilidini kontrol et", 2], ["Mermiyi yerleştir, kamayı kilitle", 3], ["Emniyeti aç, tetik halatını kur", 2]]],
    [["titan", "vorona"], [["Güç ve sistem kontrolü", 2.5], ["Arayıcıyı başlat", 2]]]
];

private _index = _table findIf {(_x select 0) findIf {(_key find _x) >= 0} >= 0};

private _steps = if (_index >= 0) then {
    +((_table select _index) select 1)
} else {
    switch (_category) do {
        case "disposable": {[["Emniyetleri aç, tüpü hazırla", 3]]};
        case "guided": {[["Sistemi aç ve arayıcıyı başlat", 6]]};
        default {[["Emniyeti aç, horozu kur", 5]]};
    }
};

// Baslik turune ozel ek adim (gudumsuzde)
if (!(_category isEqualTo "guided") && {!(_magazine isEqualTo "")}) then {
    private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
    private _warhead = toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "warheadName"));
    private _ammoKey = toLower _ammo;
    private _extra = [];

    if ((_warhead find "tandem") >= 0 || {(_ammoKey find "tandem") >= 0}) then {
        _extra = ["Tandem başlık: çift fünye kontrolü", 2.5];
    } else {
        if ((_warhead find "thermo") >= 0 || {(_ammoKey find "tbg") >= 0} || {(_ammoKey find "thermo") >= 0}) then {
            _extra = ["Termobarik başlık: emniyet halkası kontrolü", 2];
        } else {
            if (_warhead isEqualTo "he" || {(_warhead find "frag") >= 0} || {(_ammoKey find "og7") >= 0} || {(_ammoKey find "_he") >= 0}) then {
                _extra = ["Fünye ayarı: ani / gecikmeli", 2];
            };
        };
    };

    if !(_extra isEqualTo []) then {
        _steps = (_steps select [0, (count _steps) - 1]) + [_extra] + (_steps select [(count _steps) - 1, 1]);
    };
};

_steps
