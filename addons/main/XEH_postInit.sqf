/*
    XEH_postInit.sqf
    Mission başlarken, objeler oluşturulduktan sonra çalışır (JIP dahil).
    Bu dosya initPlayerLocal.sqf'in addon karşılığıdır; mission dosyasına
    hiçbir şey eklemek gerekmez.
*/

// 7. Makineli tüfek: sıcak namlu yanığı olayları (sunucu + istemci bağlantısı; hasInterface kontrolünden önce)
call TAC_fnc_mgInit;

// 9. Roketatar: kalıcı patlamamış mühimmat (sunucu)
call TAC_fnc_rktInit;

// 10. Koop yardımı: yardım olayı (sahibin makinesinde uygulanır)
call TAC_fnc_assistInit;

// Her şey oyuncu arayüzüyle ilgili: sunucuda / headless client'ta yapacak iş yok.
if (!hasInterface) exitWith {};

// 1. Taktiksel Not Defteri
call TAC_fnc_notebookPostInit;

// 2. Gelişmiş NVG Pili
call TAC_fnc_nvgPostInit;

// 3. Kalibreye göre dinamik recoil
call TAC_fnc_recoilPostInit;

// 4. Baskı altında artan sway
call TAC_fnc_stressPostInit;

// 5. Mermi yakın geçiş (crack)
call TAC_fnc_crackPostInit;

// 6. Silah bakım ve arıza
call TAC_fnc_wpnPostInit;

// 8. Optik (buğu / kir): silah bakım menüsünden sonra
call TAC_fnc_optPostInit;

// 9. Roketatar / füze
call TAC_fnc_rktPostInit;

// 10. Koop yardımı: arkadaşın silah menüsü
call TAC_fnc_assistPostInit;
