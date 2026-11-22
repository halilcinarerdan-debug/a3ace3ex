/*
    Fonksiyon: TAC_fnc_hitSegDist
    Çalışma yeri: İstemci

    İki doğru parçası arasındaki en kısa mesafe (Ericson): AB ve CD.

    Parametreler:
        0: ARRAY - A (ASL)
        1: ARRAY - B (ASL)
        2: ARRAY - C (ASL)
        3: ARRAY - D (ASL)

    Dönüş: NUMBER - metre
*/

params ["_a", "_b", "_c", "_d"];

private _u = _b vectorDiff _a;
private _v = _d vectorDiff _c;
private _w = _a vectorDiff _c;
private _aa = _u vectorDotProduct _u;
private _bb = _u vectorDotProduct _v;
private _cc = _v vectorDotProduct _v;
private _dd = _u vectorDotProduct _w;
private _ee = _v vectorDotProduct _w;
private _det = (_aa * _cc) - (_bb * _bb);

private _s = if (_det < 1e-6) then {0} else {(((_bb * _ee) - (_cc * _dd)) / _det) max 0 min 1};
private _t = ((_bb * _s) + _ee) / (_cc max 1e-6);

if (_t < 0) then {_t = 0; _s = ((-_dd) / (_aa max 1e-6)) max 0 min 1};
if (_t > 1) then {_t = 1; _s = ((_bb - _dd) / (_aa max 1e-6)) max 0 min 1};

vectorMagnitude ((_a vectorAdd (_u vectorMultiply _s)) vectorDiff (_c vectorAdd (_v vectorMultiply _t)))
