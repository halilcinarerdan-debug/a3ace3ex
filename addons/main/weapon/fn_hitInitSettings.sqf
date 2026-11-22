/*
    Fonksiyon: TAC_fnc_hitInitSettings
    Çalışma yeri: Tüm makineler (XEH_preInit)

    CBA ayarları - isabet etkileri:
      1) Silah isabeti: kola (el / kol) mermi isabet edince silah hasar görür (kullanılamaz) ve elden düşer.
      2) Göz kapanması: mermi yenince ekran kısa süre kararır (görsel ayarlar istemci ayarıdır).
    Sürekli döngü yoktur.
*/

private _category = ["TAC - Gerçekçilik Paketi", "İsabet etkileri"];

[
    "TAC_hit_enabled",
    "CHECKBOX",
    ["Silah isabeti: silah elden düşsün", "Açıksa kola (el / kol) mermi isabet edince silah hasar görür: o silah kullanılamaz (tetik yalnızca tık verir) ve elden yere düşer. Silah, silahçının 'Parça değiştir' bakımıyla onarılır (Silah Yedek Parça Seti gerekir). Yalnızca birincil silah ve tabanca; yer ve kutudaki halinde de hasarlı kalır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_hit_mode",
    "LIST",
    ["Silah isabeti: algılama yöntemi", "Kol / el isabeti: kola isabet eden mermi silahı vurmuş sayılır. Silah nesnesi: mermi yolu elindeki silahın hacmine (namlu - dipçik doğrusu) çok yakın geçerse silah vurulmuş sayılır (silah mermiyi durdursa bile tetiklenir). İkisi birden."],
    _category,
    [[0, 1, 2], ["Kol / el isabeti", "Silah nesnesine isabet (geometri)", "İkisi birden"], 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_hit_weaponRadius",
    "SLIDER",
    ["Silah isabeti: silah nesnesi kalınlığı (cm)", "Silah nesnesine isabet yönteminde mermi yolunun silahın doğrusuna en fazla bu kadar yaklaşması isabet sayılır. Büyütmek silahı vurmayı kolaylaştırır."],
    _category,
    [2, 30, 8, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_hit_zone",
    "LIST",
    ["Silah isabeti: hangi bölge", "Silahın vurulmasına hangi vücut bölgelerine isabet yol açar: yalnızca kollar / eller; kollar + gövde (silah gövdede taşınıyor gibi); tüm vücut."],
    _category,
    [[0, 1, 2], ["Yalnızca kol / el", "Kol + gövde", "Tüm vücut"], 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_hit_unusable",
    "CHECKBOX",
    ["Silah isabeti: silah kullanılamaz olsun", "Açıksa vurulan silah hasarlanır: tetik yalnızca tık verir. Silahçının 'Parça değiştir' bakımıyla (Silah Yedek Parça Seti) onarılır. Kapalıysa silah hasarlanmaz (yalnızca 'elden düşsün' seçeneği çalışır)."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_hit_drop",
    "CHECKBOX",
    ["Silah isabeti: silah elden yere düşsün", "Açıksa vurulan silah nişangah ve şarjörüyle birlikte yere düşer. Kapalıysa silah elde kalır (hasarlıysa kullanılamaz)."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_hit_chance",
    "SLIDER",
    ["Silah isabeti: ihtimal (%)", "Kola isabet eden her mermide silahın vurulma ihtimali. Silah elde tutulurken geçerlidir."],
    _category,
    [0, 100, 35, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_hit_blink",
    "CHECKBOX",
    ["Mermi yiyince ekran kararsın (göz kapanması)", "Açıksa vücuda mermi isabet edince ekran kısa süre kararır (göz kısılması / refleks) ve yavaşça açılır. İstemci ayarı: her oyuncu kendisi seçer."],
    _category,
    true,
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkPower",
    "SLIDER",
    ["Ekran kararması: şiddet (%)", "Tam şiddette ekranın ne kadarı kararır (%100 = tam siyah). Gerçek kararma isabet eden hasara göre ölçeklenir. İstemci ayarı."],
    _category,
    [5, 100, 65, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkTime",
    "SLIDER",
    ["Ekran kararması: süre (sn)", "Kararma tepe noktasından açılana kadar geçen süre (tam hasarda). İstemci ayarı."],
    _category,
    [0.2, 4, 1.2, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkHold",
    "SLIDER",
    ["Ekran kararması: tepe süresi (sn)", "Ekran en karanlık noktada ne kadar tutulur (göz kapalı kalma süresi), sonra açılmaya başlar. İstemci ayarı."],
    _category,
    [0, 1.5, 0.12, 2],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkMinDamage",
    "SLIDER",
    ["Ekran kararması: asgari hasar", "Bundan az hasar veren isabetler ekranı karartmaz (sıyrık). ACE tıbbında hasar birimi yaralanma ağırlığıdır; 0.05-0.15 arası genelde sıyrıkları eler. İstemci ayarı."],
    _category,
    [0, 1, 0.05, 2],
    false
] call CBA_settings_fnc_init;
