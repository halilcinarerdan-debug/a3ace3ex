// ----------------------------------------------------------------------------
//  6. ozellik: iron sight / optiksiz nisan zoomunu kaldir
//  Silah taban siniflarindaki opticsZoomMin/Max/Init hepsi ayni degere esitlenir:
//  RMB ile nisan alinca ekstra zoom olmaz, zoom tusu/tekeri bir sey yapmaz.
//  Taban siniflar (Cambusta/Ironsight modundaki ayni hiyerarsi) tum silahlara miras gecer;
//  kendi degerini tanimlayan silahlar (RHS vb.) overrides.hpp ile yamalanir.
//  Optikli nisanda optigin kendi OpticsModes degerleri gecerlidir: bu yama onlara dokunmaz.
//  NOT: config calisma aninda degistirilemez; kapatmak icin config.cpp icindeki
//  #define TAC_NOZOOM_IRONSIGHTS satirini yorum yapip yeniden derle.
// ----------------------------------------------------------------------------
class Default;

class LauncherCore;
class Launcher: LauncherCore
{
    opticsZoomMin = TAC_ZOOM_FOV;
    opticsZoomMax = TAC_ZOOM_FOV;
    opticsZoomInit = TAC_ZOOM_FOV;
};

class GrenadeLauncher: Default
{
    opticsZoomMin = TAC_ZOOM_FOV;
    opticsZoomMax = TAC_ZOOM_FOV;
    opticsZoomInit = TAC_ZOOM_FOV;
};

class UGL_F: GrenadeLauncher
{
    opticsZoomMin = TAC_ZOOM_FOV;
    opticsZoomMax = TAC_ZOOM_FOV;
    opticsZoomInit = TAC_ZOOM_FOV;
};

class RifleCore;
class Rifle: RifleCore
{
    opticsZoomMin = TAC_ZOOM_FOV;
    opticsZoomMax = TAC_ZOOM_FOV;
    opticsZoomInit = TAC_ZOOM_FOV;
};

class PistolCore;
class Pistol: PistolCore
{
    opticsZoomMin = TAC_ZOOM_FOV;
    opticsZoomMax = TAC_ZOOM_FOV;
    opticsZoomInit = TAC_ZOOM_FOV;
};

class Pistol_Base_F: Pistol
{
    opticsZoomMin = TAC_ZOOM_FOV;
    opticsZoomMax = TAC_ZOOM_FOV;
    opticsZoomInit = TAC_ZOOM_FOV;
};

// TAC_fnc_zoomScan ciktisi (RHS ve diger modlarin kendi degerleri)
#include "overrides.hpp"
