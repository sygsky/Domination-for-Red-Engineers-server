// by Xeno
if (!X_Client) exitWith {};

#include "x_setup.sqf"

d_still_in_intro = true;

sleep 4;
playMusic "ATrack10";

#ifndef __TT__
titleText ["Д О М И Н А Ц И Я !\n\nОдна команда", "PLAIN DOWN", 1];
#endif
#ifdef __TT__
titleText ["Д О М И Н А Ц И Я !\n\nОдна команда", "PLAIN DOWN", 1];
#endif

sleep 14;
titleRsc ["Titel1", "PLAIN"];

d_still_in_intro = false;

if (true) exitWith {};
