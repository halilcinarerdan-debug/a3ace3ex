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
        weapons[] = {"TAC_NVGBattery", "TAC_NVGBattery_Lithium"};
        requiredVersion = 0.1;
        requiredAddons[] = {"cba_main", "ace_main", "ace_common", "ace_interact_menu"};
        version = 0.7;
        versionStr = "0.7.4";
        versionAr[] = {0,7,4};
    };
};

// ----------------------------------------------------------------------------
//  Not Defteri - Gelismis mod: duz metin editoru (Notepad gibi)
//  Kendi basina duran, vanilla sinifa bagimli olmayan iki sinif:
//    TAC_RscNotepadEdit : cok satirli yazi kutusu (style 16 = ST_MULTI)
//    TAC_NotepadDialog  : bos diyalog, kontroller scriptte (ctrlCreate) kurulur
// ----------------------------------------------------------------------------
class TAC_RscNotepadEdit
{
    idc = -1;
    type = 2;
    style = 16;
    x = 0;
    y = 0;
    w = 0.3;
    h = 0.1;
    font = "PuristaMedium";
    sizeEx = 0.04;
    lineSpacing = 1;
    shadow = 0;
    colorBackground[] = {0.08,0.08,0.08,1};
    colorText[] = {0.92,0.92,0.92,1};
    colorSelection[] = {0.25,0.45,0.85,1};
    colorDisabled[] = {1,1,1,0.25};
    autocomplete = "";
    text = "";
    canModify = 1;
};

class TAC_NotepadDialog
{
    idd = 91700;
    movingEnable = 0;
    enableSimulation = 1;
    class controlsBackground {};
    class controls {};
};

class CfgFunctions
{
    class TAC
    {
        tag = "TAC";

        // 1. Taktiksel Not Defteri
        #include "notebook\CfgFunctions.hpp"

        // 2. Gelismis NVG Pili
        #include "nvg\CfgFunctions.hpp"

        // 3. Kaliberye gore dinamik recoil
        #include "recoil\CfgFunctions.hpp"

        // 4. Baski altinda artan sway
        #include "stress\CfgFunctions.hpp"

        // 5. Mermi yakin gecis (crack) + ekran efekti + HUD
        #include "crack\CfgFunctions.hpp"
    };
};

// Envanter esyalari. CBA_MiscItem: CBA'nin genel esya taban sinifi (cba_main).
class CfgWeapons
{
    class CBA_MiscItem;
    class CBA_MiscItem_ItemInfo;

    // 2. Gelismis NVG Pili
    #include "nvg\CfgWeapons.hpp"
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
