/*
	scripts\intro\SYG_startOnAntigua.sqf: process arrival on Antigua while you not visited the base
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
_find_civilian = {
	hint localize "+++ _find_civilian: Call start";
//	if (!(player call SYG_pointOnAntigua)) exitWith {false};

	private ["_civ","_newgroup"];
	_isle = SYG_SahraniIsletCircles select 3; // Antigua enveloped circle descr
	_pos = _isle select 1;
	_arr = nearestObjects [ _pos, ["Civilian"], _isle select 2];
	hint localize format["+++ _find_civilian: found %1 civ[s]", count _arr];
	_civ = objNull;
	{
		if (alive _x) then {
			 (isPlayer _x) exitWith {};
			 _var = _x getVariable ABORIGEN;
			 if (isNil "_var") exitWith {};
			_x setDamage 0;
			_civ = _x;
			hint localize format["+++ _find_civilian: found civ %1 at %2", typeOf _civ, getPos _civ];
		} else {
			player action ["hideBody", _x];
			sleep 0.1;
		};
		if ( alive _civ ) exitWith {};
	} forEach _arr;

	if ( isNull _civ ) then { // create civilian
	    _newgroup = ["CIV"] call x_creategroup;
//		hint localize format["+++ _find_civilian: group created %1", _newgroup];
		_unit_array = ["civilian", "CIV"] call x_getunitliste; // returned [_unit_list, _vec_type, _crewtype]
		_type = (_unit_array select 0) select 0;
//		hint localize format["+++ _find_civilian: civ not found, create unit with type %1", _type];
		_pos = (SPAWN_INFO select 3) call XfGetRanPointSquareOld; // No flat position requested
//		hint localize format["+++ _find_civilian: civ not found, create unit with type %1 at pos %2", _type, _pos];
		_civ = _type createVehicle _pos;
		hint localize format["+++ _find_civilian: created unit %1, pos %2", typeOf _civ, _pos];
		[_civ] join _newgroup;
		_civ setVariable [ABORIGEN, true];
		// TODO: debug lower code line: move code to the server sonehow... not use it on client!
		_civ addEventHandler ["killed", {(_this select 0) call XAddDead0;
				if (isPlayer (_this select 1)) then {
					if ((_this select 1) == player) then {-20 call SYG_addBonusScore} else {
						["remote_execute", format["if (name player == ""%1"") then { -20 call SYG_addBonusScore };", name (_this select 1)]] call XSendNetStartScriptClientAll
					};
				};
			} ]
	} else {
		hint localize format["+++ _find_civilian: civ found, unit %1", typeOf _civ];
		_newgrpoup = group _civ
	};

	hint localize format["+++ _find_civilian: created unit %1 (%2) at %3", typeOf _civ, _civ, _pos];
	// TODO: add follow sub-menus to the civilian:
	// 1. "Ask about boats". 2. "Ask about cars". 3. "Ask about weapons". 4. "Ask about soviet soldiers". 5. "Ask about rumors"
	{
		_civ addAction[ localize format["STR_ABORIGEN_%1", _x], "scripts\intro\SYG_aborigenAction.sqf", _x]; // "STR_ABORIGEN_BOAT", "STR_ABORIGEN_CAR" etc
	} forEach ["BOAT", "CAR", "WEAPON", "MEN", "RUMORS","GO"];

	while { !(player call SYG_pointOnAntigua) } do { sleep 5; }; // while out of Antigua

	while {((getPos player) select 2) > 5} do { sleep 1}; // while in air

	if (alive _civ) then { // show info
		player groupChat format [localize "STR_ABORIGEN_INFO", round (player distance _civ), ([player,_civ] call XfDirToObj) call SYG_getDirName]; // "Aborigen is on dist. %1 to %2"
	} else {
		player groupChat (localize "STR_ABORIGEN_INFO_NONE"); // "Locals are not observed"
	};

	// Giggle while not closer than 10 meters
	while {(player distance _civ) > 10} do {
		sleep (random 5 + 2);
		_civ setMimic (["Default","Normal","Smile","Hurt","Ironic","Sad","Cynic","Surprised","Agresive","Angry"] call XfRandomArrayVal);
		_civ say format["laughter_%1", (floor (random 12)) + 1]; // 1..12
		_civ setDir (getDir _civ) + ((random 20) - 10);
	};

	_civ setMimic "Normal";
	// Do watch while alive or near
	_civ commandWatch player;
	while { (alive _civ) && (alive player) && ((player distance _civ) < 40)} do { sleep 5};
	_civ commandWatch objNull;
	_civ spawn {
		private ["_list","_civ"];
		_civ = _this;
		_list = [
			"AmovPercMstpSnonWnonDnon_exerciseKata",	//		Martial arts moves
			"AmovPercMstpSnonWnonDnon_exercisePushup",	//	Pushups
			"AmovPercMstpSnonWnonDnon_Ease",	//	"At ease"
			"AmovPercMstpSnonWnonDnon_AmovPsitMstpSnonWnonDnon_ground",	//	Sits on the ground
			"AmovPercMstpSnonWnonDnon",	//	Stand without weapon
			"AmovPercMstpSlowWrflDnon_seeWatch",	//	Checks watch with weapon in other hand
			"AmovPercMstpSlowWrflDnon_AmovPsitMstpSlowWrflDnon"	//	Sits on ground
		];
		while {canStand _civ } do {
			_move = _list call XfRandomArrayVal;
			_civ playMove _move;
			sleep ((random 5) + 10);
		};
	};
	// set marker on civ
	_marker = createMarkerLocal["aborigen_marker", getPos _civ];
	_marker setMarkerTypeLocal  "Vehicle";
	_marker setMarkerColorLocal "ColorGreen";
	_marker setMarkerTextLocal "?";

	// exit this humorescue
};

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

	hint localize "+++ scripts/intro/SYG_startOnAntigua.sqf: simple ammo box created";
};

[] spawn _createAmmoBox;
[] spawn _find_civilian;
[[car1,car2,car3,car4,car5,car6,car7,car8,car9],600, 90, "antigua_vehs"] execVM "scripts\motorespawn.sqf"; // as moto!!!
// 1. DC3 flight to the Antigua or simple drop from a plane