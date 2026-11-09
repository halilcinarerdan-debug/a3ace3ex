// ============================================================================
//  TAC - TMT uyumluluk yamasi (tac_compat_tmt) - OPSIYONEL PBO
//  TMT yuklu degilse config'i atlanir (skipWhenMissingDependencies).
//  Yapilan: TMT_FIM92_launcher kilit sesleri. Ust sinif (Launcher_Base_F) ve addon adi (TMT_Weapon)
//  oyundan TAC_fnc_lockScan / configSourceAddonList ile dogrulandi.
//  NOT: config'i ASCII tut.
// ============================================================================

class CfgPatches
{
    class tac_compat_tmt
    {
        name = "TAC - TMT compat";
        author = "TAC";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"tac_main", "TMT_Weapon"};
        skipWhenMissingDependencies = 1;
        version = 0.1;
        versionStr = "0.1.0";
        versionAr[] = {0,1,0};
    };
};

class CfgWeapons
{
    class Launcher_Base_F;
    class TMT_FIM92_launcher: Launcher_Base_F
    {
        lockingTargetSound[] = {"z\tac\addons\main\sound\tac_seeker_locking.ogg", 0.35, 1};
        lockedTargetSound[] = {"z\tac\addons\main\sound\tac_seeker_locked.ogg", 0.35, 1};
    };
};
