/*
	scripts\intro\SYG_startOnAntigua.sqf: process arrival on Antigua while you not visited the base
	author: Sygsky
	description: none
	returns: nothing
*/

#include "x_setup.sqf"

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
_find_civilian = {
	private ["_civ","_newgroup"];
	_arr = nearestObjects [[17451,18644,0], ["Civilian"], 1500];
	_civ = objNull;
	{

		if (alive _x) then {
			 (isPlayer _x) exitWith {};
			 _var = _x getVariable ABORIGEN;
			 if (isNil "_var") exitWith {};
			_x setDamage 0;
			_civ      = _x;
		} else {
			player action ["hideBody", _x];
			sleep 0.1;
		};
		if ( !isNull _civ ) exitWith {};
	} forEach _arr;

	if (isNull _civ) then { // create civilian
	    _newgroup = ["CIV"] call x_creategroup;
		_unit_array = ["civilian", "CIV"] call x_getunitliste; // returned [_unit_list, _vec_type, _crewtype]
		_type = _unit_array select 0;
		_pos = ((SPAWN_INFO select 2) select 1) call XfGetRanPointSquare;
		_civ = _type createVehicleLocal _pos;
		_civ setVariable [ABORIGEN, true];
	} else {_newgrpoup = group _civ};

	// TODO: add follow sub-menus to the civilian:
	// 1. "Ask about boats". 2. "Ask about cars". 3. "Ask about weapons". 4. "Ask about soviet soldiers". 5. "Ask about rumors"
	{
		_civ addAction[ localize format["STR_ABORIGEN_%1", _x], "scripts\intro\SYG_aborigenAction.sqf", _x]; // "STR_ABORIGEN_BOAT", "STR_ABORIGEN_CAR" etc
	} forEach ["BOAT", "CAR", "WEAPON", "MEN", "RUMORS"];
};

_createAmmoBox = {
	hint localize "+++ call _createAmmoBox;";
	if (!alive spawn_tent) then  {
		hint localize "--- SYG_startOnAntigua: tent is dead, create ammobox as is";
	};
	_spawn_point = spawn_tent call SYG_getBuildingRndPos;

	#ifndef __TT__
    _boxname = (
    	switch (d_own_side) do {
    		case "RACS": {"AmmoBoxGuer"};
    		case "WEST": {"AmmoBoxWest"};
    		case "EAST": {if (__ACEVer) then {"ACE_WeaponBox_East"} else {"AmmoBoxEast"}};
    	}
    );
    #endif

    #ifdef __TT__
    _boxname = (
    	if (playerSide == west) then {
    		"AmmoBoxWest"
    	} else {
    		"AmmoBoxGuer"
    	}
    );
    #endif

	_box = _boxname createVehicleLocal _spawn_point;
	hint localize format["+++ _createAmmoBox: box (%1) created %2", _boxname, _box];
	_box setDir (random 360);
	_box setPos _spawn_point;
	_box call SYG_clearAmmoBox;

	{ // fill created items into the box at each client ( so Arma-1 need, only items added manually on clients during gameplay are propagated through network to all clients )
    	_box addMagazineCargo [_x, 5];
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

	hint localize "+++ scripts/intro/SYG_startOnAntigua.sqf: simple ammo box created";
};

call _createAmmoBox;
// 1. DC3 flight to the Antigua or simple drop from a plane