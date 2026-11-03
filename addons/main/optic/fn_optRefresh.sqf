/*
    Fonksiyon: TAC_fnc_optRefresh
    Çalışma yeri: İstemci (CBA "cameraView", "weapon" ve "unit" oyuncu olayları çağırır)

    Optikten bakış başladı mı / bitti mi? Başladıysa izleme döngüsünü başlatır, bittiyse durdurur.
    Döngü yalnızca optikten bakarken vardır; bakmıyorken sıfır maliyet.

    Parametreler: yok
    Dönüş: yok
*/

if ([ACE_player] call TAC_fnc_optActive) then {
    call TAC_fnc_optStart;
} else {
    call TAC_fnc_optStop;
};
