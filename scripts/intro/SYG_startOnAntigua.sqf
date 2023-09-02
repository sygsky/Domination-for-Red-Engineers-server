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

#define __JOKE__

if (!isNil "antigua_initiated") exitWith {};

antigua_initiated = true;

CAR_TYPE_LIST =  ["Skoda","SkodaGreen","SkodaRed","SkodaBlue",
			  "hilux1_civil_1_open","hilux1_civil_2_covered","hilux1_civil_3_open",
			  "datsun1_civil_1_open","datsun1_civil_2_covered","datsun1_civil_3_open",
			  "Landrover","Landrover_Closed","Landrover_Police",
			  "car_sedan","car_hatchback"
#ifdef __JOKE__
			  ,"tractor" // This is for a joke only :o)
#endif
#ifdef __ACE__
			  ,"ACE_HMMWV","ACE_UAZ"
#else
			  ,"HMMWV","UAZ"
#endif
			  ];
// _moto_type_list = ["M1030","TT650G","TT650C"]; // Not needed

hint localize "+++ SYG_startOnAntigua.sqf: started...";
[] execVM "scripts\intro\findAborigen.sqf";
_arr = [car1,car2,car3,car4,car5,car6,car7,car8,car9];
// Replace some motorcycles with cars now
_rep_list = []; // Vehicles replaced index list
_car_list = []; // Car types list to replace vehs with
_cnt = count _arr;
for "_i" from 0 to 4 do {  // replace moto with 5 cars(0..4)

	_ind = floor(random _cnt); // index of moto to replace with car
	while {(_ind in _rep_list)} do { _ind = floor (random _cnt) }; // make it unique
	_rep_list set [count _rep_list, _ind];

	_car = CAR_TYPE_LIST call XfRandomArrayVal; // Select unique car type to replace select index of moto
	while {(_car in _car_list)} do { _car = CAR_TYPE_LIST call XfRandomArrayVal }; // find unique type among already selected
	_car_list set [count _car_list, _car];

	// replace moto[_ind] with car
	_moto = _arr select _ind;
	_moto_name = vehicleVarName _moto; // "car1" or "" if no name was assigned to the vehicle in the editor
	_pos = getPos _moto;
	deleteVehicle _moto;
	sleep 0.1;
	_car = createVehicle [_car, _pos, [], 0,"NONE"];
	_arr set [_ind, _car];
	if (_moto_name != "") then {_car setVehicleVarName _moto_name}; // store the same name of the orignal vehicle
	hint localize format["+++ SYG_startOnAntigua.sqf: moto index #%1(%2) replaced with %3", _ind, _moto_name, typeOf _car ];
};
_arr = _arr + [bicycle1,bicycle2,bicycle3];
hint localize format["+++ SYG_startOnAntigua.sqf: vehs are [%1]", _arr call SYG_objArrToTypeStr];
// { _x lock true} forEach _arr;
// [_veh_arr, _big_delay, _small_delay, "service_name_in_RPT", _lock_vehs_or_not, _ret_dist]
[   _arr,     600,        90,           "antigua_vehs"       , false            , 50 ] execVM "scripts\motorespawn.sqf"; // as moto!!!

// 1. DC3 flight to the Antigua or simple drop from a plane