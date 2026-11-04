/*
    Fonksiyon: TAC_fnc_assistInit
    Çalışma yeri: TÜM makineler (XEH_postInit.sqf çağırır, hasInterface kontrolünden ÖNCE)

    "TAC_assistStep" CBA olayını dinler (yardımcıdan, durumun sahibinin makinesine gelir): [birim, tür, adım].
    Durum yerelde tutulduğu için adımın sonucu yalnızca sahibin makinesinde uygulanır (sıra doğrulaması orada).
      tür "feed"   -> TAC_fnc_wpnFeedApply
      tür "rocket" -> TAC_fnc_rktStepApply

    Parametreler: yok
    Dönüş: yok
*/

["TAC_assistStep", {
    params ["_unit", "_kind", "_index"];

    if (!local _unit || {!alive _unit}) exitWith {};

    switch (_kind) do {
        case "feed": {[_unit, _index] call TAC_fnc_wpnFeedApply};
        case "rocket": {[_unit, _index] call TAC_fnc_rktStepApply};
    };
}] call CBA_fnc_addEventHandler;
