/*
    Fonksiyon: TAC_fnc_wpnOnReloaded
    Çalışma yeri: İstemci (oyuncunun "Reloaded" olayı)

    Makineli tüfeğe yeni şarjör / kayış takıldığında besleme kapağı adımı açılır: kayış yerleştirilip
    kapak kapatılana kadar ("Kayışı yerleştir ve kapağı kapat" eylemi) silah hazır sayılmaz; hazırlanmadan
    ilk atışta besleme arızası çıkar. Yalnızca MG kategorisi ve "Besleme kapağı adımı" ayarı açıkken.

    Parametreler: Reloaded olayı: [unit, weapon, ...]
    Dönüş: yok
*/

params ["_unit", "_weapon"];

if (!TAC_wpn_enabled || {!TAC_mg_feedStep}) exitWith {};

private _cat = [_weapon] call TAC_fnc_wpnCategory;

if (_cat isEqualTo [] || {!(_cat select 3)}) exitWith {};

([_unit, _weapon] call TAC_fnc_wpnGetState) set [7, false];
