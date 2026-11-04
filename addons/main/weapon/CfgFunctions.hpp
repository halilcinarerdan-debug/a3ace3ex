class weapon
{
    file = "z\tac\addons\main\weapon";

    class wpnInitSettings {};
    class wpnPostInit {};
    class wpnAttach {};

    // Durum ve hesap
    class wpnCategory {};
    class wpnSearchKey {};
    class wpnIsBeltFed {};
    class wpnGetState {};
    class wpnEnvFactor {};
    class wpnJamChance {};
    class wpnProfile {};
    class wpnParseMrbsTable {};
    class wpnParseMgTable {};
    class wpnTargetWeapon {};
    class wpnIsArmorer {};

    // Atis
    class wpnOnFired {};
    class wpnOnReloaded {};
    class wpnFeedStep {};
    class wpnFeedApply {};
    class wpnPublish {};
    class wpnOnPut {};
    class wpnOnTake {};

    // Bakim eylemleri (ACE self-menu)
    class wpnRun {};
    class wpnFeedSteps {};
    class wpnFilterSteps {};
    class wpnFx {};
    class wpnGesture {};
    class wpnConsume {};
    class wpnHasItem {};
    class wpnClean {};
    class wpnLube {};
    class wpnClearJam {};
    class wpnReplaceParts {};
    class wpnInspect {};

    // Teshis (debug konsolu: call TAC_fnc_wpnDebug)
    class wpnDebug {};
};
