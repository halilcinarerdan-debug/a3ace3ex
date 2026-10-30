/*
    XEH_postInit.sqf
    Mission başlarken, objeler oluşturulduktan sonra çalışır (JIP dahil).
    Bu dosya initPlayerLocal.sqf'in addon karşılığıdır; mission dosyasına
    hiçbir şey eklemek gerekmez.
*/

// Her şey oyuncu arayüzüyle ilgili: sunucuda / headless client'ta yapacak iş yok.
if (!hasInterface) exitWith {};

// 1. Taktiksel Not Defteri
call TAC_fnc_notebookPostInit;

// 2. Gelişmiş NVG Pili
call TAC_fnc_nvgPostInit;
