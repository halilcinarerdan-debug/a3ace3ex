/*
    Fonksiyon: TAC_fnc_wpnFeedSteps
    Çalışma yeri: İstemci

    Kayışlı MG'ye özel besleme prosedürü adımları (silah ailesine göre; classname alt dizesiyle):
      M249 / Minimi  : kapağı aç, tepsiyi kaldır + yatağı kontrol et, kutuyu tak, kayışı yerleştir, kapat, sürgüyü çek
      M240 / Mk48 / M60 : kapağı aç, tepsiyi kaldır + yatağı kontrol et, kayışı yerleştir (açık yan aşağı), kapat, sürgüyü çek
      (M240 ve M249: TM 9-1005-313-10 ve TM 9-1005-201-10 "Loading" bölümü; Mk48 / M60 aynı sırayı kullanır = tahmin)
      PKM / PKP / Zafir : kapağı aç, kayışı tepsiye yerleştir, kapat, sürgüyü çek
      MG3 / MG42 / UK59 : kapağı kaldır, kayışı yerleştir, indir, kolu çek (kol çekme daha uzun)
      Ağır MMG (Navid, SPMG) : aynı adımlar, daha uzun
      diğer kayışlı MG : kapağı aç, kayışı yerleştir, kapat
    Eşleşme classname + görünen ad üzerinde alt dize aramasıyla yapılır (TAC_fnc_wpnSearchKey).
    Süreler saniye (bakım süresi çarpanından önce); gerçek prosedürlerin sırası ve süresine yaklaşık.

    Parametreler:
        0: STRING - silah classname

    Dönüş: ARRAY - [[metin, süre], ...]
*/

params [["_weapon", "", [""]]];

private _key = [_weapon] call TAC_fnc_wpnSearchKey;

private _table = [
    [["m249", "minimi", "saw_base", "mk46"], [["Besleme kapağını aç", 1.5], ["Besleme tepsisini kaldır, yatağı kontrol et", 2], ["Kutuyu tak, mandalı kontrol et", 2], ["Kayışı tepsiye yerleştir (ilk mermi durdurucuya dayalı)", 2.5], ["Kapağı kapat, kilitlendiğini kontrol et", 1.5], ["Sürgüyü çek", 1.5]]],
    [["m240", "mk48", "m60"], [["Besleme kapağını aç", 1.5], ["Besleme tepsisini kaldır, yatağı kontrol et", 2], ["Kayışı yerleştir (açık yan aşağı, ilk mermi durdurucuya dayalı)", 2.5], ["Kapağı kapat, kilitlendiğini kontrol et", 1.5], ["Sürgüyü çek", 1.5]]],
    [["pkm", "pkp", "pecheneg", "zafir"], [["Besleme kapağını aç", 1.5], ["Kayışı tepsiye yerleştir", 2.5], ["Kapağı kapat", 1], ["Sürgüyü çek", 1.5]]],
    [["lmg_mg3", "mg42", "uk59"], [["Besleme kapağını kaldır", 1.5], ["Kayışı yerleştir", 2.5], ["Kapağı indir", 1], ["Kolu çek", 2]]],
    [["dshk", "kord", "nsv", "m2hb", "m2_", "browning", "hmg", "gmg", "mk19"], [["Besleme kapağını aç", 2], ["Kayışı yerleştir", 3], ["Kapağı kapat", 1.5], ["Sürgüyü çek", 2.5]]],
    [["mmg_01", "mmg_02"], [["Besleme kapağını aç", 2], ["Kayışı yerleştir", 3], ["Kapağı kapat", 1.5], ["Sürgüyü çek", 2]]]
];

private _index = _table findIf {(_x select 0) findIf {(_key find _x) >= 0} >= 0};

private _result = if (_index >= 0) then {
    (_table select _index) select 1
} else {
    [["Besleme kapağını aç", 1.5], ["Kayışı yerleştir", 2], ["Kapağı kapat", 1]]
};

// Sürgü / şarj kolu adımları reload animasyonunda var: varsayılan olarak ayıklanır (ayar açıksa kalır).
_result call TAC_fnc_wpnFilterSteps
