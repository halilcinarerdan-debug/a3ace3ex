// Pil omru (saat) bu dosyada degil, CBA ayarindaki "Pil tablosu"nda tutulur.
// Ozel config alanlari:
//   TAC_base   : pilin ait oldugu ana sinif (pil tablosundaki ad). Kismen kullanilmis pil de ayni ana siniftandir.
//   TAC_charge : bu esyanin tasidigi sarj (0..1). Ana siniflar 1 (dolu).
//   TAC_coldK  : soguk hassasiyeti. Kapasite = 1 - TAC_coldK * (20 - sicaklik C), 0.25 alt sinir.
// Kismen kullanilmis piller sabit kademelerdir (%75 / %50 / %25 / %10); cikarilan pil sarjina gore
// asagi yuvarlanan kademeye doner, %7 altindaki pil "bitik" olur. Arsenal'de gorunmezler.
#define TAC_TIER(CLS,PARENT,BASE,FRAC,NAME,PIC) class CLS: PARENT { displayName = NAME; picture = PIC; TAC_base = BASE; TAC_charge = FRAC; scopeArsenal = 0; scopeCurator = 0; };

class TAC_NVGBattery: CBA_MiscItem
{
    author = "TAC";
    scope = 2;
    displayName = "NVG Bataryasi (AA)";
    descriptionShort = "AN/PVS-14 tipi gece gorusu icin AA pil. Soguga duyarli.<br/>Kullanmak icin: ACE self-menu > NVG Pili.";
    picture = "\z\tac\addons\main\data\icons\nvg_aa_100_ca.paa";
    TAC_base = "TAC_NVGBattery";
    TAC_charge = 1;
    TAC_coldK = 0.012;

    class ItemInfo: CBA_MiscItem_ItemInfo
    {
        mass = 1;
    };
};

TAC_TIER(TAC_NVGBattery_p75,TAC_NVGBattery,"TAC_NVGBattery",0.75,"NVG Bataryasi (AA) ~%75","\z\tac\addons\main\data\icons\nvg_aa_75_ca.paa")
TAC_TIER(TAC_NVGBattery_p50,TAC_NVGBattery,"TAC_NVGBattery",0.5,"NVG Bataryasi (AA) ~%50","\z\tac\addons\main\data\icons\nvg_aa_50_ca.paa")
TAC_TIER(TAC_NVGBattery_p25,TAC_NVGBattery,"TAC_NVGBattery",0.25,"NVG Bataryasi (AA) ~%25","\z\tac\addons\main\data\icons\nvg_aa_25_ca.paa")
TAC_TIER(TAC_NVGBattery_p10,TAC_NVGBattery,"TAC_NVGBattery",0.1,"NVG Bataryasi (AA) ~%10","\z\tac\addons\main\data\icons\nvg_aa_10_ca.paa")

class TAC_NVGBattery_Lithium: TAC_NVGBattery
{
    displayName = "NVG Bataryasi (AA Lityum)";
    descriptionShort = "Uzun omurlu lityum AA pil, soguktan az etkilenir. Omru CBA ayarlarindaki Pil tablosundan degistirilir.<br/>Kullanmak icin: ACE self-menu > NVG Pili.";
    picture = "\z\tac\addons\main\data\icons\nvg_li_100_ca.paa";
    TAC_base = "TAC_NVGBattery_Lithium";
    TAC_coldK = 0.003;
};

TAC_TIER(TAC_NVGBattery_Lithium_p75,TAC_NVGBattery_Lithium,"TAC_NVGBattery_Lithium",0.75,"NVG Bataryasi (AA Lityum) ~%75","\z\tac\addons\main\data\icons\nvg_li_75_ca.paa")
TAC_TIER(TAC_NVGBattery_Lithium_p50,TAC_NVGBattery_Lithium,"TAC_NVGBattery_Lithium",0.5,"NVG Bataryasi (AA Lityum) ~%50","\z\tac\addons\main\data\icons\nvg_li_50_ca.paa")
TAC_TIER(TAC_NVGBattery_Lithium_p25,TAC_NVGBattery_Lithium,"TAC_NVGBattery_Lithium",0.25,"NVG Bataryasi (AA Lityum) ~%25","\z\tac\addons\main\data\icons\nvg_li_25_ca.paa")
TAC_TIER(TAC_NVGBattery_Lithium_p10,TAC_NVGBattery_Lithium,"TAC_NVGBattery_Lithium",0.1,"NVG Bataryasi (AA Lityum) ~%10","\z\tac\addons\main\data\icons\nvg_li_10_ca.paa")

class TAC_NVGBattery_Dead: TAC_NVGBattery
{
    displayName = "Bitik NVG Bataryasi";
    descriptionShort = "Bosalmis pil. Artik kullanilamaz.";
    picture = "\z\tac\addons\main\data\icons\nvg_dead_ca.paa";
    TAC_base = "TAC_NVGBattery_Dead";
    TAC_charge = 0;
    scopeArsenal = 0;
    scopeCurator = 0;
};
