/*
    Fonksiyon: TAC_fnc_crackBlast
    Çalışma yeri: İstemci

    Patlama (el bombası, 40mm, roket, havan/top mermisi, yakındaki araç...) şok dalgası efekti.
    Şiddet mesafeyle doğrusal azalır: 0 m = 1, "Patlama etki mesafesi" = 0. Patlama ile oyuncu
    arasında engel varsa (duvar, araç, zemin) şiddet yarıya iner. Süre: patlama süresi * (0.5 + 0.5 * şiddet).
    Efekt crackStart ile gösterilir (aynı blur + vignette + HUD gizleme).

    Çok kısa aralıkta (0.5 sn) gelen ikinci bildirim, öncekinden güçlü değilse yok sayılır:
    aynı patlama hem hasar olayından hem mermi izlemeden gelirse efekt iki kez başlamaz.

    Parametreler:
        0: NUMBER  - patlamanın oyuncuya uzaklığı (m); 0 = doğrudan etki (hasar aldı)
        1: NUMBER  - (isteğe bağlı) bu patlama için etki mesafesi; verilmezse ayardaki
        2: BOOL    - (isteğe bağlı) araya engel girdi mi; varsayılan false

    Dönüş: BOOL - efekt başlatıldı mı
*/

params [["_distance", 0, [0]], ["_range", -1, [0]], ["_occluded", false, [false]]];

if (!TAC_crack_enabled || {!TAC_crack_blast} || {!alive ACE_player}) exitWith {false};

if (_range <= 0) then {_range = TAC_crack_blastDist};
if (_distance >= _range) exitWith {false};

private _power = 1 - (_distance / _range);
if (_occluded) then {_power = _power * 0.5};
_power = _power max 0.15;

// Ayni patlama iki yoldan gelirse (hasar olayi + mermi izleme) tek efekt.
private _lastTime = missionNamespace getVariable ["TAC_crack_blastTime", -100];
private _lastPower = missionNamespace getVariable ["TAC_crack_blastPower", 0];

if ((time - _lastTime) < 0.5 && {_power <= _lastPower}) exitWith {false};

missionNamespace setVariable ["TAC_crack_blastTime", time];
missionNamespace setVariable ["TAC_crack_blastPower", _power];

if (TAC_crack_debug) then {
    systemChat format [
        "[TAC crack] PATLAMA | mesafe %1 m | etki mesafesi %2 m | siddet %3%4",
        (round (_distance * 10)) / 10,
        round _range,
        (round (_power * 100)) / 100,
        ["", " (engelli)"] select _occluded
    ];
};

[TAC_crack_blastDuration * (0.5 + (0.5 * _power)), _power] call TAC_fnc_crackStart;

true
