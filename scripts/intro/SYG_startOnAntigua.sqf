/*
	scripts\intro\SYG_startOnAntigua.sqf:
		process arrival on Antigua while you not visited the base. Runs only on server
	author: Sygsky
	description: creates ammobox, aborigen, prepare aborigen to meet player
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

if (!isNil "antigua_initiated") exitWith {};

antigua_initiated = true;

_veh_list =  ["Skoda","SkodaGreen","SkodaRed","SkodaBlue",
			  "hilux1_civil_1_open","hilux1_civil_2_covered","hilux1_civil_3_open",
			  "datsun1_civil_1_open","datsun1_civil_2_covered","datsun1_civil_3_open",
			  "Landrover","Landrover_Closed","Landrover_Police",
			  "car_sedan","car_hatchback"];
_moto_list = ["M1030","TT650G","TT650C"];

hint localize "+++ SYG_startOnAntigua.sqf: started...";
[] execVM "scripts\intro\findAborigen.sqf";
_arr = [car1,car2,car3,car4,car5,car6,car7,car8,car9];
// TODO: replace some motorcycles with cars now
_rep_list = [];
_car_list = [];
_cnt = count _arr;
for "_i" from 1 to 4 do {

	_ind = random _cnt;
	while {(_ind in _rep_list)} do { _ind = random _cnt };
	_rep_list set [count _rep_list, _ind];

	_car = _veh_list call XfRandomArrayVal;
	while {(_car in _car_list)} do { _car = _veh_list call XfRandomArrayVal };
	_car_list set [count _car_list, _car];

	// replace moto[_ind] with car
	_moto = _arr select _ind;
	_pos = getPos _moto;
	deleteVehicle _moto;
	sleep 0.1;
	_arr set [_ind, createVehicle [_car, _pos,[],3,"NONE"]];
};
hint localize format["+++ SYG_startOnAntigua.sqf: vehs are [%1]", _arr call SYG_objArrToTypeStr];
// { _x lock true} forEach _arr;
// [_veh_arr, _big_delay, _small_delay, "service_name_in_RPT", _lock_vehs_or_not]
[   _arr,     600,        90,           "antigua_vehs"     /*, true*/] execVM "scripts\motorespawn.sqf"; // as moto!!!

// 1. DC3 flight to the Antigua or simple drop from a plane