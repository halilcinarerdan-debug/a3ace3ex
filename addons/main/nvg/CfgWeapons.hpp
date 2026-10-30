// Pil omru (saat) bu dosyada degil, CBA ayarindaki "Pil tablosu"nda tutulur.
class TAC_NVGBattery: CBA_MiscItem
{
    author = "TAC";
    scope = 2;
    displayName = "NVG Bataryasi (AA)";
    descriptionShort = "AN/PVS-14 tipi gece gorusu icin AA pil.<br/>Kullanmak icin: ACE self-menu > NVG Pil Degistir.";
    picture = "\a3\ui_f\data\gui\rsc\rscdisplayarsenal\itemacc_ca.paa";

    class ItemInfo: CBA_MiscItem_ItemInfo
    {
        mass = 1;
    };
};

class TAC_NVGBattery_Lithium: TAC_NVGBattery
{
    displayName = "NVG Bataryasi (AA Lityum)";
    descriptionShort = "Uzun omurlu lityum AA pil. Omru CBA ayarlarindaki Pil tablosundan degistirilir.<br/>Kullanmak icin: ACE self-menu > NVG Pil Degistir.";
};
