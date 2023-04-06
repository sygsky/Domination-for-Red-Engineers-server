/*
	scripts\intro\SYG_startOnAntigua.sqf: process arrival on Antigua while you not visited the base.
		runs only on server
	author: Sygsky
	description: none
	returns: nothing
*/

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__
#define ABORIGEN "ABORIGEN"
/*
		class Item5
		{
			position[]={17451.333984,1.074218,18643.750000};
			name="isle4";
			text="Antigua";
			markerType="ELLIPSE";
			type="Flag";
			colorName="ColorRedAlpha";
			a=1500.000000;
			b=1500.000000;
		};
*/

_createAmmoBox = {
	hint localize "+++ _createAmmoBox: Call start";
	if (!alive spawn_tent) then  {
		hint localize "--- SYG_startOnAntigua: tent on Antigua is dead, create ammo in any case";
	};
	_spawn_point = spawn_tent call SYG_getRndBuildingPos;
	hint localize format["+++ _createAmmoBox: _spawn_point %1",_spawn_point];
	private ["_boxname"];

	#ifndef __TT__
	hint localize format["+++ #ifndef __TT__, playerSide %1, east %2, playerSide == east = %3", playerSide, east, playerSide == east];
    _boxname = switch (playerSide) do {
					case west: {"AmmoBoxWest"};
					case east: { if (__ACEVer) then {"ACE_WeaponBox_East"} else {"AmmoBoxEast"} };
					case resistance;
					default {"AmmoBoxGuer"};
				};
    #endif

    #ifdef __TT__
	hint localize format["+++ #ifndef __TT__, playerSide %1", playerSide];
    _boxname = if (playerSide == west) then {
					"AmmoBoxWest"
				} else {
					"AmmoBoxGuer"
				};
    #endif
	hint localize format["+++ _createAmmoBox: _spawn_point %1, _boxname %2",_spawn_point, _boxname];

	_box = _boxname createVehicleLocal _spawn_point;
	hint localize format["+++ _createAmmoBox: %1 createVehicleLocal %2", _boxname, _box, _spawn_point];
	_box setDir (random 360);
	_box setPos _spawn_point;
	_box call SYG_clearAmmoBox;

	{ // fill created items into the box at each client ( so Arma-1 need, only items added manually on clients during gameplay are propagated through network to all clients )
    	_box addWeaponCargo [_x, 5];
    } forEach ["ACE_AK74","ACE_AKS74U","ACE_Bizon","ACE_AKM"];

    {
    	_box addMagazineCargo [_x, 50];
    	sleep 0.1;
    } forEach ["ACE_30Rnd_545x39_BT_AK","ACE_30Rnd_545x39_SD_AK",
    		   "ACE_30Rnd_762x39_B_RPK","ACE_30Rnd_762x39_BT_AK","ACE_30Rnd_762x39_SD_AK","ACE_40Rnd_762x39_BT_AK","ACE_75Rnd_762x39_BT_AK",
    	       "ACE_64Rnd_9x18_B_Bizon",
    		   "ACE_Bandage","ACE_Morphine","ACE_Epinephrine","ACE_Flashbang",
			   "ACE_HandGrenadeRGN","ACE_HandGrenadeRGO"
			];

	hint localize "+++ SYG_startOnAntigua.sqf: simple ammo box created";
};
if (!isNil "antigua_initiated") exitWith {};

antigua_initiated = true;

hint localize "+++ SYG_startOnAntigua.sqf: started...";
[] call _createAmmoBox;
[] execVM "scripts\intro\findAborigen.sqf";
_arr = [car1,car2,car3,car4,car5,car6,car7,car8,car9];
{ _x lock true} forEach _arr;
// [_veh_arr, _big_delay, _small_delay, "service_name_in_RPT", _lock_vehs_or_not]
[_arr, 600, 90, "antigua_vehs", true] execVM "scripts\motorespawn.sqf"; // as moto!!!
// 1. DC3 flight to the Antigua or simple drop from a plane