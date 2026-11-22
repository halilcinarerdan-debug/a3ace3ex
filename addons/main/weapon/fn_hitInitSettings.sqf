/*
    Fonksiyon: TAC_fnc_hitInitSettings
    Çalışma yeri: Tüm makineler (XEH_preInit)

    CBA ayarları - isabet etkileri:
      1) Silah isabeti: kola (el / kol) mermi isabet edince silah hasar görür (kullanılamaz) ve elden düşer.
      2) Vurulma ekranı: mermi yenince tünel görüşü (istemci ayarı). Ölüm / yere düşme kararması: death modülü (TAC_dth_*).
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
    "TAC_hit_detect",
    "LIST",
    ["Silah isabeti: algılama yöntemi", "Kol / el isabeti: kola isabet eden mermi silahı vurmuş sayılır. Silah nesnesi: mermi yolu elindeki silahın hacmine (namlu - dipçik doğrusu) çok yakın geçerse silah vurulmuş sayılır (silah mermiyi durdursa bile tetiklenir). İkisi birden."],
    _category,
    [[0, 1, 2], ["Kol / el isabeti", "Silah nesnesine isabet (geometri)", "İkisi birden"], 1],
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
    ["Silah isabeti: hangi bölge", "Kol / el isabeti yöntemi için: silahın vurulmasına hangi vücut bölgelerine isabet yol açar: kol + el; kol + el + gövde; tüm vücut; yalnızca el (kol hariç: vanilla hasar modelinde eller bölgesi; ACE tıbbında el ayrı bölge olmadığı için kol sayılır). Silah nesnesi (geometri) yöntemini etkilemez."],
    _category,
    [[0, 1, 2, 3], ["Kol + el", "Kol + el + gövde", "Tüm vücut", "Yalnızca el (kol hariç)"], 0],
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
    "TAC_hit_weaponChance",
    "SLIDER",
    ["Silah isabeti: ihtimal (%)", "Silaha (ya da seçili yönteme göre kola) isabet eden her mermide silahın hasar görme ihtimali. 100 = silaha değen her mermi silahı bozar ve düşürür."],
    _category,
    [0, 100, 100, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_hit_tunnel",
    "CHECKBOX",
    ["Vurulunca vignette ve bulanıklık (yaralanma ekranı)", "Açıksa mermi yiyince ekranın kenarları kararır (vignette / tünel görüşü) ve bulanıklık artar; sonra yavaşça söner. Şok dalgası (crack) efektinin altyapısını kullanır; HUD gizlenmez. İstemci ayarı."],
    _category,
    true,
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_tunnelTime",
    "SLIDER",
    ["Tünel görüşü: süre (sn)", "Tünel görüşünün tam şiddette kaldığı ve sönmeye başladığı süre (toplam süre bunun yaklaşık 1.7 katıdır). İstemci ayarı."],
    _category,
    [1, 20, 5, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_tunnelBlur",
    "SLIDER",
    ["Tünel görüşü: bulanıklık çarpanı", "Şok dalgası (crack) bulanıklık ayarının kaç katı bulanıklık verileceği. İstemci ayarı."],
    _category,
    [0, 5, 2, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_hit_vignette",
    "SLIDER",
    ["Vurulunca vignette: kenar kararması (%)", "Mermi isabet edince ekran kenarlarının ne kadar karardığı (100 = kenarlar tam siyah, orta bölge temiz kalır). Şok dalgası (crack) ayarlarından bağımsızdır. Ekranın tamamen kararması yalnızca ölümde / revive'de yere düşmede olur (Ölüm ve yaralı ekranı). İstemci ayarı."],
    _category,
    [0, 100, 90, 0],
    false
] call CBA_settings_fnc_init;

