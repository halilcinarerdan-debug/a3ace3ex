/*
    onPlayerRespawn.sqf
    Oyuncu yeniden doğduğunda KENDİ makinesinde çalışır (SP'de çalışmaz).
    respawnOnStart -1 değilse mission başında da bir kez tetiklenir (_oldUnit = objNull).
*/

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

// ----------------------------------------------------------------------------
// 1. Taktiksel Not Defteri
// ----------------------------------------------------------------------------
// Yeni bedenin ACE eylemleri sıfırdır -> yeniden ekle (+ "ölümde sil" ayarı).
[_newUnit, _oldUnit] call TAC_fnc_notebookOnRespawn;
