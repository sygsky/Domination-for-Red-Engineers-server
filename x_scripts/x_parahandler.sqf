// by Xeno: x_scripts\x_parahandler.sqf
private ["_current_target_pos","_dummy","_end_pos","_start_pos","_vecs","_num_p","_attack_pos","_fly_height","_tmp"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

_dummy = target_names select current_target_index;
_current_target_pos = _dummy select 0;
_vecs = 1;

#ifdef __DEFAULT__
_spec_names_arr = ["Mataredo", "Everon"];
_start_pnt_arr  = [d_para_end_positions select 2, d_para_end_positions select 0];
_end_pnt_arr    = [d_para_end_positions select 0, d_para_end_positions select 1];
#endif

sleep 333.325;
while {!mt_radio_down} do {
	if (create_new_paras) then {
		if (X_MP) then {
			waitUntil {sleep (1.012 + random 1);(call XPlayersNumber) > 0};
		};
		//__DEBUG_NET("x_parahandler.sqf",(call XPlayersNumber))
		_start_pos = d_para_start_positions select (floor random (count d_para_start_positions));
		_end_pos = d_para_end_positions select (floor random (count d_para_end_positions));
		_fly_height = 100;
#ifdef __DEFAULT__		
		_tmp = _spec_names_arr find (_dummy select 1 ); // use special start point for some marine cities
		if ( _tmp >= 0 ) then {
			_start_pos = _start_pnt_arr select _tmp;
			_end_pos   = _end_pnt_arr select _tmp;
		};
/*
 		if ( (_dummy select 1 ) == "Mataredo" ) then  // always use NW start point for Mataredo else paratroopers are dpopped into the water
		{
			_start_pos = [982.0,24545.0,0]; // in sea on NW from Mataredo
		};
 */		
		if ( (_dummy select 1 ) in  d_mountine_towns/* ["Pacamac", "Hunapu", "Masbete"] */ ) then {  // fly at higher height to prevent collision with mountine slopes
			_fly_height = 350;
		};
#endif		
		_num_p = (call XPlayersNumber);
/* 		if (_num_p < 11) then {
			_vecs = 1;
		} else {
			if (_num_p < 21) then {
				_vecs = 2;
			} else {
				_vecs = 3;
			};
		};
 */		_vecs = floor(_num_p / 6) + 1;
		create_new_paras = false;
		_attack_pos = [_current_target_pos,200] call XfGetRanPointCircle;
#ifdef __DEFAULT__

        if ((_dummy select 1)  == "Everon") then {
            _attack_pos set [1, (_attack_pos select 1) + 200 ]; //shift +200 meters to north (landing not to sea)
        } else {
            if ((_dummy select 1)  == "Mataredo") then {
                _attack_pos set [1, (_attack_pos select 1) -150 ]; //shift -150 meters to south (landing not to sea)
            };
        };
#endif
		sleep 0.01;
		[_start_pos,_attack_pos,_end_pos,_vecs, _fly_height] execVM "x_scripts\x_createpara3xcargopopulated.sqf";
	};
	sleep 7.213;
};

if (true) exitWith {};
