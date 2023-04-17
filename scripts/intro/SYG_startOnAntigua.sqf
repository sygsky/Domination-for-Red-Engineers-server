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

hint localize "+++ SYG_startOnAntigua.sqf: started...";
[] execVM "scripts\intro\findAborigen.sqf";
_arr = [car1,car2,car3,car4,car5,car6,car7,car8,car9];
// { _x lock true} forEach _arr;
// [_veh_arr, _big_delay, _small_delay, "service_name_in_RPT", _lock_vehs_or_not]
[   _arr,     600,        90,           "antigua_vehs"     /*, true*/] execVM "scripts\motorespawn.sqf"; // as moto!!!

// 1. DC3 flight to the Antigua or simple drop from a plane