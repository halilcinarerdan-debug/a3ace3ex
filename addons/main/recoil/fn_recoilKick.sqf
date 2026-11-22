/*
    Fonksiyon: TAC_fnc_recoilKick
    Çalışma yeri: İstemci (oyuncunun "Fired" olayı, TAC_fnc_recoilUpdate'ten SONRA)

    Atış sarsıntısı: her atışta kamera sarsılır (addCamShake [güç, süre, sıklık]). Güç = TAC_recoil_kickPower x kategori
    ölçeği (SMG 0.7, AR 1, AK 1.3, ağır 1.6, aşırı 2). Yalnızca güçlendirme kutusu açık kategorilerde ve (ayara göre) tabanca
    dışında çalışır. Silahın kendi recoil'i sıfır / çok düşük olsa bile çalışır. Üst sınır yoktur.
    Kategori ve tabanca bilgisi TAC_fnc_recoilUpdate'in kaydettiği değişkenlerden okunur (ek maliyet yok).

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params ["_unit"];

if (!TAC_recoil_enabled || {!TAC_recoil_kick} || {TAC_recoil_kickPower <= 0}) exitWith {};
if ((_unit getVariable ["TAC_recoil_isPistol", false]) && {TAC_recoil_skipPistols}) exitWith {};

private _cat = _unit getVariable ["TAC_recoil_cat", 0];
if (_cat < 1) exitWith {};
if !([TAC_recoil_boostC1, TAC_recoil_boostC2, TAC_recoil_boostC3, TAC_recoil_boostC4, TAC_recoil_boostC5] select (_cat - 1)) exitWith {};

addCamShake [TAC_recoil_kickPower * ([0.7, 1, 1.3, 1.6, 2] select (_cat - 1)), TAC_recoil_kickTime, TAC_recoil_kickFreq];
