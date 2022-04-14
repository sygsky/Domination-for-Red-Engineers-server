// by Xeno: x_vrespawn2.sqf, called only on server. Initiate editor vehicles on the base: MHQs, helicopters, trucks
private ["_vec_array", "_vehicle", "_number_v", "_kind", "_truck_ammo", "_truck_fuel", "_truck_rep", "_i", "_vec_a", "_disabled", "_type", "_empty", "_hasbox","_var"];
if (!isServer) exitWith{};

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __PRINT__

_vec_array = [];
{
	_vehicle = _x select 0;
	_number_v = _x select 1;
	_kind = _x select 2;
	_vec_array set [count _vec_array,[_vehicle,_number_v,_kind,position _vehicle,direction _vehicle,typeOf _vehicle]];

	_vehicle setVariable ["D_OUT_OF_SPACE", -1];

	switch (_kind) do {
		case "MR": {
			_var = format["MRR%1",_number_v];
			call compile format ["%1=_vehicle;publicVariable ""%1"";", _var];
			_vehicle addRating -10000; // #451: enemy may prefer to kill it ASAP
	#ifdef __TT__
			_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
	#endif
		};
	#ifdef __TT__
		case "MRR": {
			call compile format ["MRRR%1=_vehicle;publicVariable ""MRRR%1"";", _number_v];
			_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
		};
	#endif
		case "TTR";
		case "TRA";
		case "TR": // truck (supply, ammo, fuel, open etc)
		{
			call compile format ["TR%1=_vehicle;publicVariable ""TR%1"";", _number_v];
			_vehicle setAmmoCargo 0;
			_vehicle call SYG_addHorn;
	#ifdef __TT__
			_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
	#endif
		};
	#ifdef __TT__
		case "TRR": {
			call compile format ["TRR%1=_vehicle;publicVariable ""TRR%1"";", _number_v];
			_vehicle setAmmoCargo 0;
			_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
		};
	#endif
    #ifdef __TT__
		case "TTRR": {
			call compile format ["TRR%1=_vehicle;publicVariable ""TRR%1"";", _number_v];
			_vehicle setAmmoCargo 0;
			_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
		};
	#endif
	#ifdef __TT__
		case "TRAR": {
			call compile format ["TRR%1=_vehicle;publicVariable ""TRR%1"";", _number_v];
			_vehicle setAmmoCargo 0;
			_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
		};
	#endif
		case "MV": {
			MEDVEC = _vehicle; publicVariable "MEDVEC";
	#ifdef __TT__
			_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
	#endif
		};
	#ifdef __TT__
		case "MVR": {
			MEDVECR = _vehicle; publicVariable "MEDVECR";
			_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
		};
	#endif
	};
} forEach _this;
_this = nil;

_truck_ammo = d_own_trucks select 0;
_truck_fuel = d_own_trucks select 1;
_truck_rep = d_own_trucks select 2;

sleep 65;

while {true} do {
	sleep (8 + (random 5));
	if (X_MP) then {
		waitUntil {sleep (10.012 + random 1);(call XPlayersNumber) > 0};
	};
	//__DEBUG_NET("x_vrespawn2.sqf",(call XPlayersNumber))
	for "_i" from 0 to (count _vec_array - 1) do {
		_vec_a = _vec_array select _i;
		_vehicle = _vec_a select 0;
		_kind = _vec_a select 2;
		_type = _vec_a select 5;

		_disabled = false;
		if (damage _vehicle > 0.9) then {
			_disabled = true;
		} else {
			if (_kind == "TR") then {
				switch (_type) do {
					case _truck_ammo: {
						_vehicle setAmmoCargo 1;
					};
					case _truck_fuel: {
						_vehicle setFuelCargo 1;
					};
					case _truck_rep: {
						_vehicle setRepairCargo 1;
					};
				};
			};
		};

		if (_vehicle call XOutOfBounds) then {
			_outb = _vehicle getVariable "D_OUT_OF_SPACE";
			if (_outb != -1) then {
				if (time > _outb) then {_disabled = true};
			} else {
				_vehicle setVariable ["D_OUT_OF_SPACE", time + 600];
			};
		} else {
			_vehicle setVariable ["D_OUT_OF_SPACE", -1];
		};

		sleep 0.01;
		_empty = ({alive _x} count (crew _vehicle)) == 0;

		if ( _empty && (_disabled  || (!(alive _vehicle))) ) then { // vehicle has to be respawned
			_hasbox = _vehicle getVariable "d_ammobox";
			if (format["%1",_hasbox] == "<null>") then {
				_hasbox = false;
			};
			if (_hasbox) then {
				ammo_boxes = ammo_boxes - 1;
				["ammo_boxes",ammo_boxes] call XSendNetVarClient;
			};
			sleep 0.1;
			deleteVehicle _vehicle;
			sleep 0.5;
			_vehicle = objNull;
			_vehicle = _type createVehicle (_vec_a select 3);
			_vehicle setPos (_vec_a select 3);
			_vehicle setDir (_vec_a select 4);

			_vec_a set [0, _vehicle];
			_vehicle setVariable ["D_OUT_OF_SPACE",-1];
			_vehicle addRating -10000; // #451: enemy may prefer to kill it ASAP

			_number_v = _vec_a select 1;

			switch (_kind) do {
				case "MR": {
					_var = format["MRR%1",_number_v];
					call compile format ["%1=_vehicle;publicVariable ""%1"";", _var];
					[ "MHQ_respawned", _var ] call XSendNetStartScriptClient;
					//call compile format ["MRR%1=_vehicle;publicVariable ""MRR%1"";", _number_v];
					//_vehicle call SYG_reammoMHQ; // this function call is useless on server computer

					if (X_SPE) then { // on client running server
						_vehicle addAction [localize "STR_SYS_79_2","x_scripts\x_vecdialog.sqf",[],-1,false]; // "MHQ menu"
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkdriver.sqf";}];
						_vehicle addEventHandler ["getout", {_this execVM "x_scripts\x_checkdriverout.sqf";}];
					};
				#ifdef __TT__
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
				#endif
				};
			#ifdef __TT__
				case "MRR": {
					call compile format ["MRRR%1=_vehicle;publicVariable ""MRRR%1"";", _number_v];
					if (X_SPE) then {
						_vehicle addAction [localize "STR_SYS_79_2","x_scripts\x_vecdialog.sqf",[],-1,false]; // "MHQ Menu"
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkdriver.sqf";}];
						_vehicle addEventHandler ["getout", {_this execVM "x_scripts\x_checkdriverout.sqf";}];
					};
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
				};
			#endif
			    case "TRA";
				case "TR": {
    				// drop all static weapons in the truck
					call compile format [
						"TR%1=_vehicle;publicVariable ""TR%1"";"
						,_number_v
					];
					_vehicle setAmmoCargo 0;
    				_vehicle call SYG_addHorn; // add horn to all own trucks
				#ifdef __TT__
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
					if (X_SPE) then {
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
					};
				#endif
				};
			#ifdef __TT__
				case "TRR": {
					call compile format ["TRR%1=_vehicle;publicVariable ""TRR%1"";", _number_v];
					_vehicle setAmmoCargo 0;
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
					if (X_SPE) then {
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
					};
				};
			#endif
				case "TTR": {
					call compile format ["TR%1=_vehicle;publicVariable ""TR%1"";", _number_v];
					_vehicle setAmmoCargo 0;
    				_vehicle call SYG_addHorn; // add horn to all own trucks
				#ifdef __TT__
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
				#endif
				#ifdef __NO_REAMMO_IN_SALVAGE__
					hint localize format["+++ Respawned salvage truck TTR%1, remove all loaded weapon", _number_v];
					switch (_vehicle) do {
						case TR7: {
							{ deleteVehicle _x }forEach truck1_cargo_array;
							truck1_cargo_array = [];
							publicVariable "truck1_cargo_array";
//							["truck1_cargo_array",truck1_cargo_array] call XSendNetVarAll;
						};
						case TR8: {
							{ deleteVehicle _x }forEach truck2_cargo_array;
							truck2_cargo_array = [];
							publicVariable "truck2_cargo_array";
//							["truck2_cargo_array",truck2_cargo_array] call XSendNetVarAll;
						};
					};
				#endif
					if (X_SPE) then {
						if (/*__AIVer ||*/ str(player) in d_is_engineer) then {
#ifdef __PRINT__				
							hint localize format["x_vrespawn2.sqf, X_SPE : TTR%1, player %2, load static actions", _vehicle, str(player)];
#endif
							_vehicle addAction[localize "STR_SYG_10","scripts\load_static.sqf",[],-1,false]; // "Загрузка орудия"
							_vehicle addAction[localize "STR_SYG_11","scripts\unload_static.sqf",[],-1,false]; // "Выгрузка орудия"
						};
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checktrucktrans.sqf";}];
					};
				};
			#ifdef __TT__
				case "TTRR": {
					call compile format ["TRR%1=_vehicle;publicVariable ""TRR%1"";", _number_v];
					_vehicle setAmmoCargo 0;
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
					if (X_SPE) then {
						if (/*__AIVer ||*/ str(player) in d_is_engineer) then {
							_vehicle addAction[localize "STR_SYG_10","scripts\load_static.sqf",[],-1,false]; // "Загрузка орудия"
							_vehicle addAction[localize "STR_SYG_11","scripts\unload_static.sqf",[],-1,false]; //"Выгрузка орудия"
						};
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checktrucktrans.sqf";}];
					};
				};
			#endif
/*
				case "TRA": {
					call compile format ["TR%1=_vehicle;publicVariable ""TR%1"";", _number_v];
					_vehicle setAmmoCargo 0;
				#ifdef __TT__
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
					if (X_SPE) then {
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
					};
				#endif
				};
*/
			#ifdef __TT__
				case "TRAR": {
					call compile format ["TRR%1=_vehicle;publicVariable ""TRR%1"";", _number_v];
					_vehicle setAmmoCargo 0;
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
					if (X_SPE) then {
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
					};
				};
			#endif
				case "MV": {
					MEDVEC = _vehicle; publicVariable "MEDVEC";
				#ifdef __TT__
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf";}];
					if (X_SPE) then {
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
					};
				#endif
				};
			#ifdef __TT__
				case "MVR": {
					MEDVECR = _vehicle; publicVariable "MEDVECR";
					_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
					if (X_SPE) then {
						_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkenterer.sqf";}];
					};
				};
			#endif
			};
		};
		sleep (8 + (random 5));
	}; // for "_i" from 0 to (count _vec_array - 1) do
}; //while {true} do 