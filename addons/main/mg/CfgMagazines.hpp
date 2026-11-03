// ----------------------------------------------------------------------------
//  7. ozellik (MG): gercekci yedek namlu agirliklari
//  Arma kutle birimi: 22 birim = 1 kg (ACE de ayni orani kullanir).
//    Hafif  (5.56 / 6.5 mm SAW tipi)         ~1.9 kg = 42
//    Orta   (7.62 mm GPMG tipi) ACE_SpareBarrel ~2.7 kg = 59   (ACE'nin varsayilan namlusu, eskiden 25)
//    Agir   (9.3 / .338 sinifi MMG)          ~3.8 kg = 84
//  Degerler yaklasiktir; gerceklikte silah modeline gore degisir. ACE'nin isinma hesabi (namlu isi
//  kutlesi) DEGISTIRILMEZ: yalnizca envanter agirligi.
// ----------------------------------------------------------------------------
class CA_Magazine;

class ACE_SpareBarrel: CA_Magazine
{
    mass = 59;
};

class TAC_SpareBarrel_Light: ACE_SpareBarrel
{
    author = "TAC";
    displayName = "Yedek Namlu (Hafif MG)";
    descriptionShort = "5.56 / 6.5 mm hafif makineli tufek icin yedek namlu. Yaklasik 1.9 kg.";
    mass = 42;
};

class TAC_SpareBarrel_Heavy: ACE_SpareBarrel
{
    author = "TAC";
    displayName = "Yedek Namlu (Agir MG)";
    descriptionShort = "Buyuk kalibreli (9.3 / .338) makineli tufek icin yedek namlu. Yaklasik 3.8 kg.";
    mass = 84;
};
