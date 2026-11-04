/*
    Fonksiyon: TAC_fnc_trtFeedSteps
    Çalışma yeri: İstemci

    Sabit silahın besleme prosedürü: silaha ve kalibreye özel tablo (TAC_fnc_trtFeedStepsRaw) süzülür:
    "sürgü / kolu çek" adımları varsayılan olarak yoktur (reload animasyonunda var); "Sürgü / şarj kolu adımı"
    ayarı (TAC_mg_chargingStep) açıksa korunur.

    Parametreler:
        0: STRING - silah classname
        1: OBJECT - (isteğe bağlı) araç

    Dönüş: ARRAY - [[metin, süre], ...]
*/

([_this select 0, _this param [1, objNull]] call TAC_fnc_trtFeedStepsRaw) call TAC_fnc_wpnFilterSteps
