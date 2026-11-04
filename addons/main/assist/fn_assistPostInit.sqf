/*
    Fonksiyon: TAC_fnc_assistPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır; diğer menülerden sonra)

    ACE etkileşim menüsü (başka bir oyuncuya bakıp ACE etkileşim tuşuna (varsayılan sol Windows) basınca; 0. tip): "Silah yardımı". Altında, arkadaşın durumuna göre:
      - "MG besleme prosedürü": arkadaşın elinde seçili kayışlı MG var ve besleme hazır değilse
      - "Atış hazırlığı prosedürü": arkadaşın fırlatıcısı yüklü ve hazır değilse
    Adımlar silaha / başlığa özeldir ve alfabetik listelenir (doğru sırayı yardımcı bilmelidir). Arkadaşın
    durumu yerelde tutulduğu için hazırlık ilerlemesi birimde yayınlanan küçük değişkenlerden okunur
    (TAC_pub_feed, TAC_pub_rkt; TAC_fnc_wpnPublish / TAC_fnc_rktPublish).

    Parametreler: yok
    Dönüş: yok
*/

private _root = [
    "TAC_assist",
    "Silah yardımı",
    "",
    {},
    {
        params ["_target", "_player"];

        TAC_assist_enabled
        && {alive _target}
        && {!(_target isEqualTo _player)}
        && {isPlayer _target}
        && {(side group _target) isEqualTo (side group _player)}
        && {!(_player getVariable ["ACE_isUnconscious", false])}
        && {time >= (_player getVariable ["TAC_wpn_busyUntil", 0])}
    },
    {
        _this call TAC_fnc_assistChildren
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _root, true] call ace_interact_menu_fnc_addActionToClass;

// Tek basina test: test modunda kendi silahin icin ayni yardim menusu (self-menu). Yardimci = sen, hedef = sen:
// adim olay yoluyla (arkadasin makinesine giden yolla) uygulanir, yani gercek koop akisini birebir dener.
private _selfTest = [
    "TAC_assist_selfTest",
    "Silah yardımı (test: kendi silahım)",
    "",
    {},
    {
        params ["_target", "_player"];

        TAC_assist_enabled
        && {TAC_wpn_testMode}
        && {alive _player}
        && {time >= (_player getVariable ["TAC_wpn_busyUntil", 0])}
    },
    {
        params ["_target", "_player"];
        [_player, _player] call TAC_fnc_assistChildren
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _selfTest, true] call ace_interact_menu_fnc_addActionToClass;

diag_log "[TAC][ASSIST] hazir";
