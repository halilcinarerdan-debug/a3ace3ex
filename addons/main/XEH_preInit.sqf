/*
    XEH_preInit.sqf
    TÜM makinelerde (sunucu + istemci + HC), objeler oluşmadan önce çalışır.
    CBA ayarları burada kaydedilmeli: sunucu da kaydetmek zorunda, çünkü global
    ayarları CBA sunucudan istemcilere senkronlar ve sunucu "force" edebilir.
*/

// 1. Taktiksel Not Defteri
call TAC_fnc_notebookInitSettings;
