/*
    Fonksiyon: TAC_fnc_wpnIsArmorer
    Çalışma yeri: İstemci

    Oyuncu silahçı mı? Silahçı: kartta sayısal değerleri görür ve yedek parçayla parça değiştirebilir.
    Şunlardan biri yeterli:
      - test modu açık
      - birimde TAC_isArmorer = true (Eden: birim init'ine this setVariable ["TAC_isArmorer", true, true])
      - ACE mühendis özelliği (ACE_isEngineer > 0, yoksa vanilla "engineer" özelliği)

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: BOOL
*/

params [["_unit", objNull, [objNull]]];

if (TAC_wpn_testMode || {_unit getVariable ["TAC_isArmorer", false]}) exitWith {true};

private _engineer = _unit getVariable ["ACE_isEngineer", _unit getUnitTrait "engineer"];

(_engineer isEqualTo true) || {_engineer isEqualType 0 && {_engineer > 0}}
