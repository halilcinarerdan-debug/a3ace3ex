// ============================================================================
//  TAC - Realism Pack (tek PBO: tac_main)
//  Yeni ozellik eklemek icin:
//    1) addons\main\<ozellik>\ klasoru ac (fn_*.sqf + CfgFunctions.hpp)
//    2) asagidaki CfgFunctions icine #include satiri ekle
//    3) XEH_preInit.sqf / XEH_postInit.sqf icine modulun giris fonksiyonunu ekle
//  NOT: config.cpp'yi ASCII tut (Mikero rapify icin en guvenlisi).
// ============================================================================

class CfgPatches
{
    class tac_main
    {
        name = "TAC - Realism Pack";
        author = "TAC";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"cba_main", "ace_main", "ace_common", "ace_interact_menu"};
        version = 0.1;
        versionStr = "0.1.0";
        versionAr[] = {0,1,0};
    };
};

class CfgFunctions
{
    class TAC
    {
        tag = "TAC";

        // 1. Taktiksel Not Defteri
        #include "notebook\CfgFunctions.hpp"
    };
};

// CBA XEH: tum makinelerde (sunucu, istemci, HC) mod yuklenince calisir.
class Extended_PreInit_EventHandlers
{
    class tac_main
    {
        init = "call compile preprocessFileLineNumbers '\z\tac\addons\main\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class tac_main
    {
        init = "call compile preprocessFileLineNumbers '\z\tac\addons\main\XEH_postInit.sqf'";
    };
};
