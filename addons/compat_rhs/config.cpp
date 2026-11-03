// ============================================================================
//  TAC - RHS uyumluluk yamasi (tac_compat_rhs) - OPSIYONEL PBO
//  RHS yuklu degilse config'i atlanir (skipWhenMissingDependencies). Silmek veya
//  @TAC\addons icine koymamak serbesttir: RHS MG'leri o zaman ACE_SpareBarrel (orta, ~2.7 kg) kullanir.
//
//  Yapilan tek sey: RHS Minimi ailesine (5.56 mm) HAFIF yedek namlu atamak
//  (TAC_SpareBarrel_Light, ~1.9 kg, tac_main tanimlar). Digerleri (PKM, M240, MG42...) orta namlu kalir.
//  Sinif ve ust sinif adlari ACE'nin compat_rhs_usf3 yamasiyla birebir ayni.
//  NOT: config'i ASCII tut.
// ============================================================================

class CfgPatches
{
    class tac_compat_rhs
    {
        name = "TAC - RHS compat";
        author = "TAC";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"tac_main", "rhsusf_main_loadorder"};
        skipWhenMissingDependencies = 1;
        version = 0.1;
        versionStr = "0.1.0";
        versionAr[] = {0,1,0};
    };
};

class CfgWeapons
{
    class Rifle_Base_F;

    // Base class for all Minimi (M249, Mk46, ...)
    class rhs_weap_saw_base: Rifle_Base_F
    {
        ace_overheating_barrelClassname = "TAC_SpareBarrel_Light";
    };
};
