// Silah bakim malzemeleri. Kullanim: ACE self-menu > Silah Bakimi.
class TAC_WeaponCleaningKit: CBA_MiscItem
{
    author = "TAC";
    scope = 2;
    displayName = "Silah Bakim Kiti";
    descriptionShort = "Fitil, firca ve temizleme cubugu. Silahi temizlemek icin gerekir, tukenmez.<br/>Kullanmak icin: ACE self-menu > Silah Bakimi.";
    picture = "\a3\ui_f\data\gui\rsc\rscdisplayarsenal\itemacc_ca.paa";

    class ItemInfo: CBA_MiscItem_ItemInfo
    {
        mass = 8;
    };
};

class TAC_WeaponOil: TAC_WeaponCleaningKit
{
    displayName = "Silah Yagi";
    descriptionShort = "Kucuk sise silah yagi. Her yaglamada bir kullanilir.<br/>Kullanmak icin: ACE self-menu > Silah Bakimi.";

    class ItemInfo: CBA_MiscItem_ItemInfo
    {
        mass = 2;
    };
};

class TAC_WeaponSpareParts: TAC_WeaponCleaningKit
{
    displayName = "Silah Yedek Parca Seti";
    descriptionShort = "Yay, kovan cikaricisi, ateskleme pimi. Yalnizca silahci (ACE muhendis ozelligi) parca degistirebilir.<br/>Kullanmak icin: ACE self-menu > Silah Bakimi.";

    class ItemInfo: CBA_MiscItem_ItemInfo
    {
        mass = 10;
    };
};
