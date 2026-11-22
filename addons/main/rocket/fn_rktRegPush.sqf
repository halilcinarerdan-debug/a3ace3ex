/*
    Fonksiyon: TAC_fnc_rktRegPush
    Çalışma yeri: İstemci

    Roketatar durumunu (hazırlık ilerlemesi / hazır, atış sayısı, zar ve ateşlenmeme, güdümlü güç / soğuma / pil) UZUN
    OTURUMA dayanıklı bir deftere de yazar: TAC_rkt_regList = [[anahtar ("r:" + sınıf), durum, konum ASL, zaman], ...],
    herkese yayınlanır, en çok 300 kayıt. Roketatar bırakılınca (TAC_fnc_rktOnPut) normal kaba kayıt (TAC_stash) ve genel
    yedek liste (TAC_stashGlobal) yanında bunu da yazar; kap silinse / listeler dolsa da hazırlık durumu kaybolmasın.

    Parametreler:
        0: STRING - anahtar ("r:" + sınıf, küçük harf)
        1: ARRAY  - roketatar durumu (kopyalanır)
        2: ARRAY  - konum (ASL)

    Dönüş: yok
*/

params ["_key", "_state", "_pos"];

private _reg = missionNamespace getVariable ["TAC_rkt_regList", []];

_reg pushBack [_key, +_state, _pos, time];

if (count _reg > 300) then {_reg deleteAt 0};

missionNamespace setVariable ["TAC_rkt_regList", _reg, true];
