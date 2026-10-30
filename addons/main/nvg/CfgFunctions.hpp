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
};
