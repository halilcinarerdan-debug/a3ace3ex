class nvg
{
    file = "z\tac\addons\main\nvg";

    class nvgInitSettings {};
    class nvgPostInit {};
    class nvgNotify {};

    // Pil tablosu (classname -> saat)
    class nvgParseBatteryTable {};
    class nvgGetHours {};
    class nvgFindBattery {};
    class nvgListBatteries {};
    class nvgBatteryInfo {};
    class nvgTierClass {};
    class nvgPlaceItem {};
    class nvgDrainFactor {};
    class nvgParseDeviceTable {};

    // Olay -> pil tuketimi
    class nvgOnVisionMode {};
    class nvgStart {};
    class nvgStop {};
    class nvgTick {};

    // Gorsel efektler
    class nvgApplyEffects {};
    class nvgClearEffects {};

    // Pil degistirme
    class nvgSwapBattery {};
    class nvgSwapFinish {};
    class nvgRemoveBattery {};
    class nvgStatus {};

    // Teshis (debug konsolu: call TAC_fnc_nvgDebug)
    class nvgDebug {};
};
