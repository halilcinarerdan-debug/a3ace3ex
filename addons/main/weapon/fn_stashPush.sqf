/*
    Fonksiyon: TAC_fnc_stashPush
    Çalışma yeri: İstemci

    Bırakılan bir eşyanın durumunu (silah bakımı, optik, ACE namlu sıcaklığı, roketatar durumu...) İKİ yere kaydeder:
      1) bırakılan kapta ("TAC_stash" değişkeni, herkese yayınlanır) - asıl yol
      2) herkese yayınlanan genel kayıt listesinde (TAC_stashGlobal: [anahtar, yük, kimlik, konum, zaman]) -
         yedek yol: motor, envanterden atılan eşya için bazen farklı / yeni bir yer-kabı yaratır, kap değişkeni
         kaybolabilir; aynı sınıftan en yakın (8 m) en yeni kayıt o zaman bulunur.
    Liste en çok 60 kayıt tutar (en eskisi düşer). Kayıt kimliği ikisinde de aynıdır: biri alınınca diğeri silinir.

    Parametreler:
        0: OBJECT - kap (yer-kabı, sandık, araç, ceset)
        1: STRING - anahtar ("w:" + silah sınıfı, "r:" + fırlatıcı sınıfı; küçük harf)
        2: ARRAY  - yük (herhangi bir dizi; kopyalanarak saklanır)
        3: ARRAY  - konum (ATL), bırakan kişinin yakını

    Dönüş: yok
*/

params [["_container", objNull, [objNull]], ["_key", "", [""]], ["_payload", [], [[]]], ["_pos", [0, 0, 0], [[]]]];

private _id = floor (random 1e9);

if (!isNull _container) then {
    private _stash = _container getVariable ["TAC_stash", []];

    _stash pushBack [_key, +_payload, _id];
    _container setVariable ["TAC_stash", _stash, true];
};

private _global = missionNamespace getVariable ["TAC_stashGlobal", []];

_global pushBack [_key, +_payload, _id, _pos, time];

if (count _global > 60) then {_global deleteAt 0};

missionNamespace setVariable ["TAC_stashGlobal", _global, true];
