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
    [2, 40, 12, 0],
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
    "TAC_hit_blinkStrength",
    "SLIDER",
    ["Ekran kararması: şiddet (%)", "Tam şiddette ekranın ne kadarı kararır (%100 = tam siyah). Gerçek kararma isabet eden hasara göre ölçeklenir. İstemci ayarı."],
    _category,
    [5, 100, 100, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkScaleDamage",
    "CHECKBOX",
    ["Ekran kararması: hasara göre ölçeklensin", "Kapalıysa (varsayılan) her mermi isabetinde ekran ayarlanan şiddette (%100 = tam siyah) ve sürede kararır. Açıksa küçük hasarlar daha hafif ve kısa, büyük hasarlar tam kararma verir. İstemci ayarı."],
    _category,
    false,
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkTime",
    "SLIDER",
    ["Ekran kararması: süre (sn)", "Kararma tepe noktasından açılana kadar geçen süre (tam hasarda). Aşağıdaki çarpanla çarpılır. İstemci ayarı."],
    _category,
    [0.2, 10, 2, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkScale",
    "SLIDER",
    ["Ekran kararması: süre çarpanı", "Kararma süresini (açılma + tepede tutma) bu kadar katına çıkarır; 1 = olduğu gibi, 2.5 = 2.5 kat uzun. İstemci ayarı."],
    _category,
    [0.5, 2.5, 1.5, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkHold",
    "SLIDER",
    ["Ekran kararması: tepe süresi (sn)", "Ekran en karanlık noktada ne kadar tutulur (göz kapalı kalma süresi), sonra açılmaya başlar. İstemci ayarı."],
    _category,
    [0, 3, 0.3, 2],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkMute",
    "CHECKBOX",
    ["Ekran kararması: sesler kesilsin", "Açıksa kararma boyunca sesler kesilir ve kararma açılırken yumuşakça (fade-in) geri gelir. ACE'nin kulak çınlaması / koruma sistemiyle uyumludur (en düşük ses ayarı geçerli). İstemci ayarı."],
    _category,
    true,
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkMuteLevel",
    "SLIDER",
    ["Ekran kararması: ses kesilme oranı (%)", "100 = sesler tamamen kesilir. Düşük değer sesleri yalnızca kısar. İstemci ayarı."],
    _category,
    [0, 100, 100, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_blinkMinHit",
    "SLIDER",
    ["Ekran kararması: asgari hasar", "Bundan az hasar veren isabetler ekranı karartmaz. 0 (varsayılan) = vücudun NERESİNE olursa olsun her mermi isabeti karartır. ACE tıbbında hasar birimi yaralanma ağırlığıdır; 0.05-0.15 arası sıyrıkları eler. İstemci ayarı."],
    _category,
    [0, 1, 0, 2],
    false
] call CBA_settings_fnc_init;
