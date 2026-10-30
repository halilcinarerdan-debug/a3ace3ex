/*
    Fonksiyon: TAC_fnc_notebookCanUse
    Çalışma yeri: İstemci

    Not defteri menüsünün (iki modda da) görünme koşulu: modül açık, oyuncu hayatta ve
    bilinci yerinde, gerekli eşya (varsayılan ItemCompass) atanmış eşyalarda veya envanterde.
    ACE menüsü açıkken her karede çağrılır -> sadece ucuz kontroller.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: BOOL
*/

params ["_player"];

TAC_notebook_enabled
&& {alive _player}
&& {!(_player getVariable ["ACE_isUnconscious", false])}
&& {(TAC_notebook_itemClass in assignedItems _player) || {TAC_notebook_itemClass in items _player}}
