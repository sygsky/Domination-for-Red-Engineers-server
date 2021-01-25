// Xeno
// unflipVehicle.sqf
// called only on client computer
//
#include "x_setup.sqf"

private ["_aid","_nil","_objs","_pos","_tmp","_vec","_addscore"];
_aid = _this select 2;
_objs = _this select 3;
_vec = _objs select 0;
_pos = position _vec;
_nil = "Logic" createVehicleLocal _pos;
_tmp = position _nil;
//playMusic "upsidedown";
_vec setPos _tmp;
// send message to all clients through server
[ "say_sound", _vec, "upsidedown" ] call XSendNetStartScriptClientAll; // send directly to clients except yourself (if !X_SPE), no need to send to server
//if (!X_SPE) then {_vec say "upsidedown"}; // if non-dedicated server, play sound on your owned computer
sleep 0.02;
deleteVehicle _nil;
player removeAction _aid;

//+++ Sygsky: add point for unflipping
#ifdef __RANKED__
_addscore = (d_ranked_a select 1) select 3; // add scores as for car repairing maitenance
//player addScore _addscore;
_addscore call SYG_addBonusScore;
(format [localize "STR_SYS_137", _addscore]) call XfHQChat; //"Добавлено очков за обслуживание техники: %1 ..."
#endif

//--- Sygsky

if (true) exitWith {};
