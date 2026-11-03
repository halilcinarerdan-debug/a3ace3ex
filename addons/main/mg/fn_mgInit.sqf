/*
    Fonksiyon: TAC_fnc_mgInit
    Çalışma yeri: TÜM makineler (XEH_postInit.sqf çağırır, hasInterface kontrolünden ÖNCE)

    Sıcak namlu değiştirme yanığı için olay bağlantıları:
      - SUNUCU: ACE'nin "ace_overheating_loadCoolestSpareBarrel" sunucu olayı (namlu değiştirme
        tamamlandığında ACE tetikler; argümanlar: [yardımcı, atıcı, silah, çıkarılan namlunun sıcaklığı,
        namlu kütlesi]). Namluyu tutan oyuncuya (yardımcı; kendi değiştiriyorsa atıcı ile aynı
        kişi) "TAC_mg_hotBarrel" olayı HER değiştirmede gönderilir; eşik / eldiven / ayar kontrolü
        istemcide yapılır.
      - İSTEMCİ: "TAC_mg_hotBarrel" -> TAC_fnc_mgBurn (hasar yalnızca yerel birime verilebilir).
    ACE kendi dinleyicisini ayrıca çalıştırır; bizim ek dinleyici ACE'nin akışını değiştirmez.

    Parametreler: yok
    Dönüş: yok
*/

if (isServer) then {
    ["ace_overheating_loadCoolestSpareBarrel", {
        params ["_assistant", "_gunner", "_weapon", "_weaponTemp"];

        // Esik ve ayar kontrolu istemcide (test gostergesi her degistirmede sicakligi gorebilsin).
        ["TAC_mg_hotBarrel", [_assistant, _weaponTemp], _assistant] call CBA_fnc_targetEvent;
    }] call CBA_fnc_addEventHandler;
};

if (hasInterface) then {
    ["TAC_mg_hotBarrel", {
        _this call TAC_fnc_mgBurn;
    }] call CBA_fnc_addEventHandler;
};
