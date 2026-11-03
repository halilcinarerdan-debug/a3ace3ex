// ============================================================================
//  TAC - CUP uyumluluk yamasi (tac_compat_cup) - OPSIYONEL PBO
//  CUP Weapons yuklu degilse config'i atlanir (skipWhenMissingDependencies). Silmek veya
//  @TAC\addons icine koymamak serbesttir: CUP MG'leri o zaman ACE_SpareBarrel (orta, ~2.7 kg) kullanir.
//
//  Yapilan tek sey: CUP Minimi / M249 ailesine (5.56 mm) HAFIF yedek namlu atamak
//  (TAC_SpareBarrel_Light, ~1.9 kg, tac_main tanimlar). Digerleri (M240, M60, MG3, Mk48, PKM, UK59)
//  orta namlu kalir. Sinif ve ust sinif adlari ACE'nin compat_cup_weapons yamasiyla birebir ayni.
//  NOT: config'i ASCII tut.
// ============================================================================

class CfgPatches
{
    class tac_compat_cup
    {
        name = "TAC - CUP compat";
        author = "TAC";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"tac_main", "CUP_Weapons_LoadOrder"};
        skipWhenMissingDependencies = 1;
        version = 0.1;
        versionStr = "0.1.0";
        versionAr[] = {0,1,0};
    };
};

class CfgWeapons
{
    class Rifle_Base_F;
    class Rifle_Long_Base_F;

    // Minimi / M249 ailesinin tabani (CUP_lmg_minimi, CUP_lmg_m249_pip1..4 hepsi buradan miras alir)
    class CUP_saw_base: Rifle_Long_Base_F
    {
        ace_overheating_barrelClassname = "TAC_SpareBarrel_Light";
    };
};
