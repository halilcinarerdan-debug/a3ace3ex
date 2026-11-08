// ----------------------------------------------------------------------------
//  7. ozellik (MG)
//  - ACE'nin envanter-esyasi sarmalayicisi ACE_SpareBarrel_Item de ayni (orta) agirliga cekilir.
//  - Vanilla MG'lere kalibreye uygun yedek namlu atanir (ACE'nin ace_overheating_barrelClassname
//    config ozelligi). Sinif ve ust sinif adlari ACE'nin kendi overheating yamasiyla birebir ayni.
//    Atanmayan MG'ler (Zafir, RHS, CUP, TMT...) ACE_SpareBarrel (orta, ~2.7 kg) kullanir.
//  - Isi eldiveni esyasi: sicak namlu degistirirken yanigi onler.
// ----------------------------------------------------------------------------
class ACE_ItemCore;

class ACE_SpareBarrel_Item: ACE_ItemCore
{
    class ItemInfo: CBA_MiscItem_ItemInfo
    {
        mass = 59;
    };
};

class Rifle_Base_F;
class Rifle_Long_Base_F: Rifle_Base_F {};

class arifle_MX_Base_F: Rifle_Base_F {};
class arifle_MX_SW_F: arifle_MX_Base_F
{
    ace_overheating_barrelClassname = "TAC_SpareBarrel_Light";
};

class LMG_Mk200_F: Rifle_Long_Base_F
{
    ace_overheating_barrelClassname = "TAC_SpareBarrel_Light";
};

class LMG_03_Base_F: Rifle_Long_Base_F
{
    ace_overheating_barrelClassname = "TAC_SpareBarrel_Light";
};

class MMG_01_base_F: Rifle_Long_Base_F
{
    ace_overheating_barrelClassname = "TAC_SpareBarrel_Heavy";
};

class MMG_02_base_F: Rifle_Long_Base_F
{
    ace_overheating_barrelClassname = "TAC_SpareBarrel_Heavy";
};

class TAC_HeatGlove: CBA_MiscItem
{
    author = "TAC";
    scope = 2;
    displayName = "Isi Eldiveni";
    descriptionShort = "Sicak makineli tufek namlusunu degistirirken eli yanmaktan korur.<br/>Envanterde bulunmasi yeterlidir.";
    picture = "\z\tac\addons\main\data\icons\heat_glove_ca.paa";

    class ItemInfo: CBA_MiscItem_ItemInfo
    {
        mass = 3;
    };
};
