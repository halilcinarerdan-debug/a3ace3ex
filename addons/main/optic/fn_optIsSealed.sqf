/*
    Fonksiyon: TAC_fnc_optIsSealed
    Çalışma yeri: İstemci

    Optik "2D resimli büyütmeli dürbün" mü? Yalnızca bunlarda buğu / kir etkisi görünür; kırmızı nokta,
    holografik ve diğer 1x nişangahlar ile 3D (PiP) dürbünler ve demir nişan etkilenmez.
    Config: ItemInfo >> OpticsModes altında en az bir mod
        - useModelOptics = 1  (2D resimli / model optik görünümü) VE
        - büyütme >= 1.5      (opticsZoomMin <= 0.16; Arma'da 0.25 = 1x, büyütme = 0.25 / opticsZoomMin)
    olmalı. (Bazı RHS/CUP kırmızı noktaları useModelOptics = 1 kullanır; yalnızca o bayrağa bakmak
    bütün ekranı bulandırıyordu, bu yüzden büyütme de şart.) Sınıf başına bir kez okunur (önbellekli).

    Parametreler:
        0: STRING - optik classname

    Dönüş: BOOL
*/

params [["_optic", "", [""]]];

if (_optic isEqualTo "") exitWith {false};

if (isNil "TAC_opt_sealedCache") then {TAC_opt_sealedCache = createHashMap};

private _key = toLower _optic;
private _sealed = TAC_opt_sealedCache get _key;

if (isNil "_sealed") then {
    _sealed = ("true" configClasses (configFile >> "CfgWeapons" >> _optic >> "ItemInfo" >> "OpticsModes")) findIf {
        (getNumber (_x >> "useModelOptics")) == 1
        && {(getNumber (_x >> "opticsZoomMin")) > 0}
        && {(getNumber (_x >> "opticsZoomMin")) <= 0.16}
    } >= 0;
    TAC_opt_sealedCache set [_key, _sealed];
};

_sealed
