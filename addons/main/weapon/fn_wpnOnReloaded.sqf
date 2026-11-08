/*
    Fonksiyon: TAC_fnc_wpnOnReloaded
    Çalışma yeri: İstemci (oyuncunun "Reloaded" olayı)

    Makineli tüfeğe yeni şarjör / kayış takıldığında besleme kapağı adımı açılır: kayış yerleştirilip
    kapak kapatılana kadar ("Kayışı yerleştir ve kapağı kapat" eylemi) silah hazır sayılmaz; hazırlanmadan
    ilk atışta besleme arızası çıkar. Yalnızca kayışlı MG (TAC_fnc_wpnIsBeltFed) ve "Besleme kapağı adımı" ayarı açıkken.

    Parametreler: Reloaded olayı: [unit, weapon, ...]
    Dönüş: yok
*/

params ["_unit", "_weapon"];

if (!TAC_wpn_enabled || {!TAC_mg_feedStep}) exitWith {};

if !([_weapon] call TAC_fnc_wpnIsBeltFed) exitWith {};

([_unit, _weapon] call TAC_fnc_wpnGetState) set [7, false];
([_unit, _weapon] call TAC_fnc_wpnGetState) set [8, 0];
[_unit, _weapon] call TAC_fnc_wpnPublish;

// Yeni kayis: parcalar katlanmis gorunur (R tusu)
[_unit] call TAC_fnc_wpnFeedHint;
