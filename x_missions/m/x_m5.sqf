// by Xeno
private ["_vehicle"];
#include "x_setup.sqf"
#include "x_macros.sqf"

#define __Poss _poss = x_sm_pos select 0;
#define __PossAndOther _poss = x_sm_pos select 0;_pos_other = x_sm_pos select 1;

x_sm_pos = [[10269.6,7353.71,0], [10268.4,7313.75,0]];  // index: 5,   King of Sedia at hotel in Vallejo
x_sm_type = "normal"; // not "convoy"

_new_pos_arr = [[10412.7,7732.9,0],[10329.0,7621.2,0],[10513.5,7834.5,0]];

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client) then {
	current_mission_text = localize "STR_SYS_143"; //"Стало известно, что король Sedia придается плотским утехам в отеле вблизи Vallejo. Он является хорошим другом и ставленником вражеского правительства. Уничтожьте его!";
	current_mission_resolved_text = localize "STR_SYS_144"; //"Король наказан! Молодцы, ребята!";
};

if (call SYG_isSMPosRequest) exitWith {argp(x_sm_pos,0)}; // it is request for pos, not SM execution

if (isServer) then {

	__PossAndOther
	__WaitForGroup
	__GetEGrp(_newgroup)

    hint localize format["+++ king hotel _poss %1", _poss];
	_nbuilding = _poss nearestObject 172902; // hotel at vallejo
	_king_id = [55,57,58,59,60,67,69,70,71,80,81,82,94,96,98,118,120,129,131,142,144,158,160,180,182,184,191,195,204,206,218,220,221,224]; // good pos for king
	_pos_id = _king_id call XfRandomArrayVal; // pos id in hotel
	_bpos = _nbuilding buildingPos _pos_id; // pos coordinate

	king = _newgroup createUnit ["King", _bpos, [], 0, "FORM"];
	king setPos _bpos;
    hint localize format["+++ king is at hotel pos %1", _pos_id];
	[king] join _newgroup;

//	publicVariable "king";  // is will be PV in king_escape.sqf
	
	//+++ Sygsky: rearm with random pistol
	if (d_enemy_side != "EAST") then
	{
		sleep 0.5;
		king call SYG_rearmPistolero;
	};
	//--- Sygsky
	
	#ifndef __TT__
	king addEventHandler ["killed", {_this call XKilledSMTargetNormal}];
	king addEventHandler ["killed", { deleteVehicle SYG_sm_trigger;}];
	#endif
	#ifdef __TT__
	king addEventHandler ["killed", {_this call XKilledSMTargetTT}];
	#endif

	// hotel has 266 building positions
	_nbuilding = nearestBuilding king;
	// these are hotel positions in rooms with no door !!!!
	//_no_list = [86,87,88,89,148,149,150,151,177,178,179,188,189,190];//,200,201,202];//,210,211,212,213,215,216,217];//230,231,232,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,262,263,264,265];
	_no_list = [86,87,88,89,148,149,150,151,210,211,212,213,262,263,264,265]; // no door positions

    // create hut at random position somewhere higher along hotel canyon
    _new_pos = _new_pos_arr call XfRandomArrayVal;
    _kulna   = createVehicle ["Land_kulna", _new_pos, [], 0, "CAN_COLLIDE"];
    sleep 0.5;
    _kulna setDir random 360;
    _pos = _kulna buildingPos 0;
    //king setPos (_pos);
    __AddToExtraVec(_kulna)
    //hint localize format["King is relaxing at kulna #%1 with pos %2", _ind, _pos];


	sleep 2.123;
	_grps = ["specops", 2, "basic", 1, _poss,0] call XCreateInf;
	{
		{
			_bpos = floor random 266;
			while {_bpos in _no_list} do {_bpos = floor random 266;};
			_x setPos (_nbuilding buildingPos _bpos);
			_x disableAI "MOVE";
		} forEach units _x;
		sleep 0.01;
	} forEach _grps;
	_cnt = (_grps select 0) call SYG_rearmSpecopsGroup;
#ifdef __DEBUG__		
	hint localize format["%1 x_m5.sqf: %2 of %3 specops rearmed", call SYG_missionTimeInfoStr, _cnt, count units (_grps select 0)];
#endif

	sleep 2.222;
	["shilka", 1, "bmp", 1, "tank", 1, _pos_other,1,80,true] spawn XCreateArmor;
	_leader = leader _newgroup;
	_leader setRank "COLONEL";
	_newgroup allowFleeing 0;
	_newgroup setBehaviour "AWARE";

	// play with trigger to allow king escaping
    SYG_sm_trigger = objNull;
    SYG_sm_trigger = createTrigger["EmptyDetector",[10270.306641,7384.357422,69.139999]];
    SYG_sm_trigger setTriggerArea [21.0, 20.5, -1, true];
    SYG_sm_trigger setTriggerActivation ["EAST", "WEST D", false];
    SYG_sm_trigger setTriggerStatements["this", "king execVM ""GRU_scripts\king_escape.sqf""; hint localize format[""king trigger (%1) deleted"", SYG_sm_trigger]; deleteVehicle SYG_sm_trigger;", ""];

};

if (true) exitWith {};