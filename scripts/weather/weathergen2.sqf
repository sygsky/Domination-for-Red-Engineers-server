// weathergen2.sqf - server cloud areas trajectory planner. 
// TODO: add sandstorm on desert regions only (south part of Sahrani)
private ["_world_center", "_y", "_x_max", "_x_start", "_y_start", "_y_ran", "_x_fog_start", "_x_fog_ran", "_y_fog_ran", "_rainy_helper", "_rainy2_helper", "_rainy3_helper", "_foggy_helper", "_counter", "_acc", "_randx", "_randy", "_fogdx","_fogdy"];

#include "x_macros.sqf"

if (!isServer) exitWith {};

//+++Sygsky: prohibite fog on main island in a period from 5:00 am to 19:00 pm with Y limits in lower two lines
#define FOG_DAY_Y_MIN 2500
#define FOG_DAY_Y_MAX 18500
#define FOG_DAY_X_MIN 0
#define FOG_DAY_X_MAX 21700
#define FOG_ON_ISLAND_MIN_TIME 5
#define FOG_ON_ISLAND_MAX_TIME 19
#define CLOUDY_X_STEP_SIZE 20
#define CLOUDY_Y_STEP_SIZE (-1 + (floor random 3))
#define FOG_X_STEP_SIZE 2
#define FOG_Y_STEP_SIZE (-1 + (floor random 3))

if (d_weather_sandstorm) then {d_weather_fog = false;};

_world_center = getArray(configFile>>"CfgWorlds">>worldName>>"centerPosition");

_x = (_world_center select 0) * 2; // world X width
_y = (_world_center select 1) * 2; // world Y height
_x_max = floor (_x / 1.2);
_x_start = floor (_x / 13.1);
_y_start = floor (_y / 5.87);
//_y_ran = floor (_y / 2.21);
_y_ran = floor (_y - _y_start);
hint localize format["weathergen2.sqf: _x_max %1, _x_start %2, _y_start %3, _y_ran %4", _x_max, _x_start, _y_start, _y_ran];

_x_fog_start = floor (_x / 2.275);
_x_fog_ran = floor (_x / 5);
_y_fog_ran = floor (_y / 4);
hint localize format["weathergen2.sqf: _x_fog_start %1, _x_fog_ran %2, _y_fog_ran %3", _x_fog_start, _x_fog_ran, _y_fog_ran];

_fogdx = 0;
_fogdy = 0;
	
_rainy_helper = [floor (_x / 8), floor (_y / 2),0];
_rainy2_helper = [floor (_x / 3), floor (_y - (_y / 8)),0];
_rainy3_helper = [floor (_x / 2), floor (_y / 5),0];
x_weather_array = [_rainy_helper,_rainy2_helper,_rainy3_helper];
_foggy_helper = [];
if (d_weather_fog) then {
	_foggy_helper = [floor(_x_fog_start+(random _x_fog_ran)),  floor (_x_fog_start+(random _y_fog_ran)),0];
	x_weather_array = x_weather_array + [_foggy_helper];
};
["x_weather_array",x_weather_array] call XSendNetVarClient;

_counter = 0;
_acc = 0;

_day = date select 2; // current day

while {true} do {
	if (X_MP) then {
	    if ((call XPlayersNumber) == 0) then
	    {
    		waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
	    };
	};
	__DEBUG_NET("weathergen2.sqf",(call XPlayersNumber))
	if ((_rainy_helper select 0) > _x_max) then {
		_randx = _x_start;
		_randy = _y_start+(random _y_ran);
		_rainy_helper = [_randx,_randy,0];
	};
	if ((_rainy2_helper select 0) > _x_max) then {
		_randx = _x_start;
		_randy = _y_start+(random _y_ran);
		_rainy2_helper = [_randx,_randy,0];
	};
	if ((_rainy3_helper select 0) > _x_max) then {
		_randx = _x_start;
		_randy = _y_start+(random _y_ran);
		_rainy3_helper = [_randx,_randy,0];
	};	
	// Bump rainy ellipses by 10-20 meters per turn on X, 0 on Y
	_rainy_helper = [(_rainy_helper select 0)+CLOUDY_X_STEP_SIZE,(_rainy_helper select 1) + CLOUDY_Y_STEP_SIZE,0];
	_rainy2_helper = [(_rainy2_helper select 0)+CLOUDY_X_STEP_SIZE,(_rainy2_helper select 1) + CLOUDY_Y_STEP_SIZE,0];
	_rainy3_helper = [(_rainy3_helper select 0)+CLOUDY_X_STEP_SIZE,(_rainy3_helper select 1) + CLOUDY_Y_STEP_SIZE,0];
	// fog behaviour is depended by daytime
	if (d_weather_fog) then {
		if(_counter <= 0) then { // change fog ellipse
			//+++Sygsky: disable for the day time between 5:00 and 19:00
			_fogdy = FOG_Y_STEP_SIZE;
			if ( (daytime >= FOG_ON_ISLAND_MAX_TIME) OR (daytime < FOG_ON_ISLAND_MIN_TIME) ) then // night time is foggy
			{
				_randx = _x_fog_start+(random _x_fog_ran);
				_randy = _x_fog_start+(random _y_fog_ran);
				_foggy_helper = [_randx,_randy,0];
				_counter = 300 + ceil(random 300); // set fog to spread on average about  450 turns of weather generator
				_fogdx = FOG_X_STEP_SIZE;
			}
			else // non-foggy daytime on island mainland
			{
				_randx = FOG_DAY_X_MIN + random (FOG_DAY_X_MAX-FOG_DAY_X_MIN);
				_randy = (FOG_DAY_Y_MIN-3000)+random 3000;
				_fogdx = FOG_X_STEP_SIZE;
				// before middle of daytime fog is south oriented, after middle of the day is on north
				if ( daytime > (FOG_ON_ISLAND_MAX_TIME+FOG_ON_ISLAND_MIN_TIME)/2 ) then {_randy = (FOG_DAY_Y_MAX+3000)-random 3000;_fogdy = -1.5;};
				_foggy_helper = [_randx,_randy,0];
				_counter = 200 + ceil(random 200); // set fog to spread on average about 300 turns of weather generator
				//hint localize format["weathergen2.sqf: bump fog out of mainland during day, time %1, counter %2,[%3,%4]", daytime call SYG_daytimeToStr, _counter, _randx, _randy];
			};
		}
		else
		{
			_foggy_helper = [(_foggy_helper select 0)+_fogdx,(_foggy_helper select 1)+ _fogdy,0]
		};
		_counter = (_counter - 1);
	};
	_acc = _acc + 1;
	if (_acc == 2) then {
		x_weather_array = [_rainy_helper,_rainy2_helper,_rainy3_helper];
		if (d_weather_fog) then {x_weather_array = x_weather_array + [_foggy_helper]};
		["x_weather_array",x_weather_array] call XSendNetVarClient;
		_acc = 0;
	};
	
	//+++ Sygsky: change weather each day
	if ( (date select 2) != _day) then
	{
		// it is time to change weather
		call SYG_updateWeather;
		_day = date select 2; // store new day value
		sleep 7.951;
	};
	//--- Sygsky: change weather each day when players are on
	
	sleep 3.011;
};