/*
    Fonksiyon: TAC_fnc_wpnFilterSteps
    Çalışma yeri: İstemci

    MG besleme prosedüründen "sürgüyü / kolu çek" adımlarını ayıklar: reload animasyonu zaten sürgüyü çektiği için
    bu adımlar varsayılan olarak yoktur. "Sürgü / şarj kolu adımı" ayarı (TAC_mg_chargingStep) açıksa korunur.
    Ayıklanan: adı "sürgü" veya "kolu" içeren adımlar (Sürgüyü çek, Sürgü kolunu çek, Kolu çek, Kolu iki kez çek).

    Parametreler:
        0: ARRAY - adımlar [[metin, süre], ...]

    Dönüş: ARRAY - adımlar
*/

private _steps = _this;

if (TAC_mg_chargingStep) exitWith {_steps};

_steps select {
    private _label = toLower (_x select 0);

    (_label find "sürgü") < 0 && {(_label find "kolu") < 0}
}
