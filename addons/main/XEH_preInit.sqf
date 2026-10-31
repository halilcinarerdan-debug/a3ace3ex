/*
    XEH_preInit.sqf
    TÜM makinelerde (sunucu + istemci + HC), objeler oluşmadan önce çalışır.
    CBA ayarları burada kaydedilmeli: sunucu da kaydetmek zorunda, çünkü global
    ayarları CBA sunucudan istemcilere senkronlar ve sunucu "force" edebilir.
*/

// 1. Taktiksel Not Defteri
call TAC_fnc_notebookInitSettings;

// 2. Gelişmiş NVG Pili
call TAC_fnc_nvgInitSettings;

// 3. Kalibreye göre dinamik recoil
call TAC_fnc_recoilInitSettings;

// 4. Baskı altında artan sway
call TAC_fnc_stressInitSettings;

// 5. Mermi yakın geçiş (crack)
call TAC_fnc_crackInitSettings;
