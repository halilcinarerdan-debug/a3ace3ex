// ============================================================================
//  TAC - RHS AFRF uyumluluk yamasi (tac_compat_rhs_afrf) - OPSIYONEL PBO
//  RHS AFRF yuklu degilse config'i atlanir (skipWhenMissingDependencies).
//  Yapilan: Igla (rhs_weap_igla) kilit sesleri. Ust sinif ACE'nin compat_rhs_afrf3 yamasiyla ayni.
//  NOT: config'i ASCII tut.
// ============================================================================

class CfgPatches
{
    class tac_compat_rhs_afrf
    {
        name = "TAC - RHS AFRF compat";
        author = "TAC";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"tac_main", "rhs_main_loadorder"};
        skipWhenMissingDependencies = 1;
        version = 0.1;
        versionStr = "0.1.0";
        versionAr[] = {0,1,0};
    };
};

class CfgWeapons
{
    class rhs_weap_strela;
    class rhs_weap_igla: rhs_weap_strela
    {
        lockingTargetSound[] = {"z\tac\addons\main\sound\tac_seeker_locking.ogg", 0.35, 1};
        lockedTargetSound[] = {"z\tac\addons\main\sound\tac_seeker_locked.ogg", 0.35, 1};
    };
};
