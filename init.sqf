// by Xeno: init.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

// add some debug units
//#define __DEBUG_ADD_VEHICLES__

#include "i_common.sqf"

X_INIT = false;
X_Server = false; X_Client = false; X_JIP = false;X_SPE = false;
X_InstalledECS = if (isClass (configFile >> "cfgVehicles" >> "ECS_basic")) then {true} else {false};

X_MP = (if (playersNumber east + playersNumber west + playersNumber resistance + playersNumber civilian > 0) then {true} else {false});

if (isServer) then {
	X_Server = true;
	if (!(isNull player)) then {X_Client = true;X_SPE = true;};
	X_INIT = true;
} else {
	X_Client = true;
	if (isNull player) then {
		X_JIP = true;
		[] spawn {waitUntil {!(isNull player)};X_INIT = true;};
	} else {
		X_INIT = true;
	};
};

hint localize format["+++ init.sqf: isServer = %1, X_Server = %2, X_Client = %3, X_JIP = %4, X_SPE = %5, X_MP = %6, X_INIT = %7", isServer, X_Server, X_Client, X_JIP, X_SPE, X_MP, X_INIT];

SYG_firesAreCreated  = false; // are fires on airbase created

current_mission_counter = 0;    // side missions counter (init on server and client)

global_vars = []; // initiate global vars

if (isNil "x_funcs1_compiled") then {
	call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_functions1.sqf";
	call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_netinit.sqf";
	if (isServer) then {
		call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_netinitserver.sqf";
	};
	if (X_Client) then {
		call compile preprocessFileLineNumbers "x_scripts\x_funcs\x_netinitclient.sqf";
	};
};
//+++ Sygsky: useful functions for client and server usage
call compile preprocessFileLineNumbers "scripts\SYG_utils.sqf";

//hint localize format["init.sqf: SYG_start_mission is %1", SYG_mission_start call SYG_dateToStr];

m_PIPEBOMBNAME = "ACE_PipeBomb"; // reset global/local bomb name

#include "i_server.sqf"
#include "i_client.sqf"

// Side missions
// include the mission setup file
#include "x_missions\x_missionssetup.sqf"

skipTime param2;

if (X_SPE) then {     // Server is by Player Executed
	date_str = date;
} else {
	date_str = [];
};

#ifdef __REVIVE__
execVM "r_init.sqf";
#endif

#ifdef __MANDO__
execVM "mando_missiles\mando_missileinit.sqf";
#endif

// Weather tuning and settings
if (isServer) then {
	call compile preprocessFileLineNumbers "x_scripts\x_initx.sqf";

    setViewDistance 6000; // try to use this command. What if it could make a splash?

	SYG_updateWeather = {
		// weather parameters
		//  fRainLess = random 0.34; //linear random
		fRainLess = (random 0.2915)^2; //tendency towards nicer weather in nice weather areas
		publicVariable "fRainLess";

		//fRainMore = 0.175 + random 0.375; //1.1 for better chance of actual thunderstorms
		fRainMore = 0.175 + (random 0.825)^2; //tendency towards nicer weather in rainy weather areas
		publicVariable "fRainMore";

		//  fFogLess = random 0.33; //linear random
		fFogLess = (random 0.287)^2; //tendency towards less fog in fogless areas
		publicVariable "fFogLess";
		
		//fFogMore = 0.175 + random 0.125;
		fFogMore = 0.175 + random 0.825;
		publicVariable "fFogMore";
		
		hint localize format["SYG_updateWeather: fRainLess %1, fRainMore %2, fFogLess %3, fFogMore %4", fRainLess, fRainMore, fFogLess, fFogMore];
	};

	call SYG_updateWeather;

//
// Function missionStart in multi-player (dedi or host server) must ( really?) show server computer REAL time
// but shows 1970-0-0-3
//
//SYG_mission_start = missionStart;

#ifdef __DEBUG_ADD_VEHICLES__
	// create vehicle to help isle defence activity debugging

    {
        _vec = createVehicle [_x select 0, _x select 1, [], 0, "NONE"];
        _vec setDir (_x select 2);
        _vec setPos (_x select 1);
    } forEach[
        ["ACE_HMMWV_GL", [14531,9927,0], -75],
        ["ACE_HMMWV_GAU19", [14536,9930,0], -75],
        ["ACE_HMMWV_TOW", [14526,9930,0], -75],
        ["ACE_Truck5t_Reammo", [14539,9925,0], -75],
        ["ACE_Truck5t_Repair", [14545,9928,0], -75],
        ["ACE_WeaponBox", [14539,9922,0], -75],
        ["ACE_WeaponBox", [9672,9991,0], 270]
    ];
	_vec = createVehicle ["ACE_Su30Mk_Kh29T", [9658.247070,10020.545898,0], [], 0, "NONE"];
	_vec setDir 90;
	if ( _vec call SYG_rearmAnySu34 ) then {hint localize "+++ ACE_Su34B rearmed"}
	else {hint localize "--- ACE_Su34B NOT rearmed !!!"};

    _medic_tent = createVehicle ["MASH", [9359.855469, 10047.625000,0], [], 0, "NONE"];
    _medic_tent setDir 189;
    ADD_HIT_EH(_medic_tent)
    ADD_DAM_EH(_medic_tent)

#endif	

	FuncUnitDropPipeBomb = compile preprocessFileLineNumbers "scripts\unitDropPipeBombV2.sqf"; //+++ Sygsky: add enemy bomb-dropping ability
	[moto1,moto2,moto3,moto4,moto5,moto6] spawn compile preprocessFileLineNumbers "scripts\motorespawn.sqf"; //+++ Sygsky: add N travelling motocycles at base

	if (d_weather) then {execVM "scripts\weather\weathergen2.sqf";};

	// create random list of targets
#ifdef __DEFAULT__
	if (_number_targets_h < 50) then { // random number of towns is already defined in number_targets
        // As many as possible big towns should be included into resulting array
        // And some small ones also may be randomly preselected or be totally absent if output count is too low (< 9)
        // created cnt, whole number, important indexes, unimportant indexes
        _params = [_number_targets_h, count target_names, d_big_towns_inds, d_small_towns_inds]; //
        _str = format["+++ init target town params: %1",_params ];
        hint localize _str;
        _arr = _params call XfIndexArrayWithPredefVals;
        maintargets_list = _arr;
		// maintargets_list = (count target_names) call XfRandomIndexArray;
	} else {
		switch (_number_targets_h) do {
			case 50: {maintargets_list = [3,4,2,0,1,7,6];};
			case 60: {maintargets_list = [8,10,16,17];};
			case 70: {maintargets_list = [8,9,11,19,14,18];};
			case 80: {maintargets_list = [8,15,9,11,12,13];};
			case 90: {
			    // 22 towns (maximum number) fill them from whole list.
			    // Paraiso/Chantico/Somato/Arkadia/Estrella/Cayo etc
			    maintargets_list = [5,3,4,2,20,0,1,7,6,8,15,9,10,11,12,13,19,14,18,16,17,21];
			}; // 22
			case 91: { // 8 smallest random target towns
			    maintargets_list = d_small_towns_inds call  XfRandomArray;
			};
		};
	};
#else
	maintargets_list = (count target_names) call XfRandomIndexArray;
#endif

    //++++++++++++++++++++++++++++++++++++++++++++++++++++
    // insert special towns at the list head
    //++++++++++++++++++++++++++++++++++++++++++++++++++++
    //_first_array = [5];   // 3: Chantico, 5: Paraiso, 8: Corazol, 20: Rahmadi, 21: Gaula|Estrella
    _first_array = [];
    maintargets_list = _first_array + (maintargets_list - _first_array);

    _str = format["+++ generated maintargets_list: %1",maintargets_list ];
    number_targets = count maintargets_list; // most correct definition of target towns is here!
    hint localize _str;

	__DEBUG_SERVER("init.sqf", maintargets_list)
	// create random list of side missions
#ifdef __EASY_SM_GO_FIRST__
    sm_array = sm_array - easy_sm_array; // remove easiest side mission from common list
#endif

	if (d_random_sm_array) then {
		side_missions_random = sm_array call XfRandomArray;
	}
	else
	{
		side_missions_random = sm_array;
    };

#ifdef __EASY_SM_GO_FIRST__
        easy_sm_array = easy_sm_array call XfRandomArray;
        // adds easiest side missions to the head of common list
        side_missions_random = easy_sm_array + side_missions_random;
        hint localize format["SM goes first: %1", side_missions_random];
#endif

//+++ Sygsky: move ranked player missions out of the list beginning
#ifdef __DEFAULT__
    hint localize format["+++ ranked_sm_array = %1",ranked_sm_array];
    if (!isNil("ranked_sm_array") ) then
    {
        private ["_lowestPos","_rankedSMArr","_ind", "_newInd","_val"];
        _lowestPos = ranked_sm_array select 0; // first allowed position for missions that need some rank (to drive tank,heli, airplane)
        _rankedSMArr = ranked_sm_array select 1; // mission ids
        // forEach ranked_sm_array;
        {
            _ind = side_missions_random find _x;
            if ( (_ind >= 0) && (_ind < _lowestPos) ) then // found, bump it to righter position in array
            {
                _val = _rankedSMArr select 0;
                while { _val in _rankedSMArr } do
                {
                    _newInd = [_lowestPos, count side_missions_random] call XfGetRandomRangeInt;
                    _val = side_missions_random select _newInd;
                };
                side_missions_random set [_ind, _val];
                side_missions_random set [_newInd, _x];
            }
        } forEach _rankedSMArr;
    };
#endif


    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //+ fill _first_array with sm numbers to go first in any case +
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    _first_array = []; // 5: king, 51: pilots, 21:Convoy Korazol-Estrella, 55: new officer mission in the forest
    side_missions_random = _first_array + (side_missions_random - _first_array);

	__DEBUG_SERVER("init.sqf",side_missions_random)

	current_target_index = -1;
	current_counter = 0;

	side_mission_resolved = false;

	counterattack = false;

	extra_mission_remover_array = [];
	extra_mission_vehicle_remover_array = [];
	check_trigger = objNull;
	create_new_paras = false;
	first_time_after_start = true;
	nr_observers = 0;
#ifdef __TT__
	[
		[ch1,"HR1",true],[ch2,"HR2",true],[ch3,"HR3",false],[ch4,"HR4",false],
		[chR1,"HRR1",true],[chR2,"HRR2",true],[chR3,"HRR3",false],[chR4,"HRR4",false]
	] execVM "x_scripts\x_helirespawn2.sqf";

	[
		[xvec1,1,"MR"],[xvec2,2,"MR"],[xvecR1,1,"MRR"],[xvecR2,2,"MRR"],
		[xmedvec,0,"MV"],[xmedvecR,0,"MVR"],[xvec3,1,"TR"],[xvec4,2,"TR"],
		[xvec5,3,"TR"],[xvecR3,1,"TRR"],[xvecR4,2,"TRR"],[xvecR5,3,"TRR"],
		[xvec6,4,"TTR"],[xvecR6,4,"TTRR"],[xvec7,5,"TRA"],[xvecR7,5,"TRAR"]
	] execVM "x_scripts\x_vrespawn2.sqf";
#else
	// [ch4,"HR4",false,1500] means, chopper 4 (wreck chopper) will respawn if no one entered the chopper during 1500 seconds since last check
	[[ch1,"HR1",true],[ch2,"HR2",true],[ch3,"HR3",false,1500],[ch4,"HR4",false,1500]] execVM "x_scripts\x_helirespawn2.sqf";
	
	// [xvec1,1,"MR"] means that defined in mission.sqm vehicle with name xvec1 will be stored with ID "MR1" in internal array
	// Also xvec6 (salvageUral) will be stored in variable TR7. xvec7-xvec10 are absent currently from mission.sqm
	// xvec1=BMP2_MHQ, xvec2=BMP2_MHQ, 
	// xvec3=ACE_Ural_Repair, xvec4=ACE_Ural_Refuel, xvec5=ACE_Ural_Reammo, xvec6=WarfareEastSalvageTruck, xvec11=ACE_Ural, 
	// other are absent
	// MR -> MRR, TR -> TR, TTR -> TR, TRA -> TR, MV -> MEDVEC
	[
		[xvec1,1,"MR"],[xvec2,2,"MR"],[xvec3,1,"TR"],[xvec4,2,"TR"],
		[xvec5,3,"TR"], [xvec6,7,"TTR"], [xvec7,6,"TR"], [xvec8,5,"TR"],
		[xvec9,4,"TR"], [xvec10,8,"TTR"], [xvec11,9,"TRA"], [xvec12,10,"TRA"],[xmedvec,0,"MV"]
	] execVM "x_scripts\x_vrespawn2.sqf";
#endif

	execVM "x_scripts\x_boatrespawn.sqf";
#ifdef __TT__
	[d_wreck_rep2,"STR_SYS_249"/* "Wreck Repair Point" */,x_heli_wreck_lift_types] execVM "x_scripts\x_repwreck.sqf";
	public_points = true;
#else
	[d_wreck_rep,"STR_SYS_249"/* "Wreck Repair Point" */,x_heli_wreck_lift_types] execVM "x_scripts\x_repwreck.sqf";
#endif
	d_check_boxes = [];
	no_more_observers = false;
	main_target_ready = false;
	mt_spotted = false;
	execVM "x_scripts\x_setupserver.sqf";
//	execVM "x_scripts\x_createnexttarget.sqf"; // start first town
	execVM "scripts\takeAirfield.sqf"; // first take airfield
	d_player_array_names = [];
	d_player_array_misc = []; // [d_player_air_autokick, time, "EngineerACE", _score,"delta_1",_equipment_list_str]
	d_placed_objs = [];
	
	[] spawn {
		private ["_hnd","_srvDate"];
		/*
			script "srvtime.sqf" should be situated in Arma.exe root directory when started on server.
			I automatically create it with follow batch file used to start my server "Red-Engineers":
			---------------- start of srvtime.bat
			@echo off

			set dt=%date%
			rem example: 23.11.2015

			set tm=%time%
			rem example: 12:53:33.21

			echo SYG_mission_start = [%dt:~6,4%,%dt:~3,2%,%dt:~0,2%,%tm:~0,2%,%tm:~3,2%,%tm:~6,2%]; > "C:\Program Files\ArmA\srvtime.sqf"

			start "" "C:\Program Files\ArmA\arma_server.exe -config=server.cfg -mod=@ACE;@SIX_Pack3 -name=server -pid=pids.log"
			--------------- end of srvtime.bat
		*/
		//_hnd = [] execVM "\srvtime.sqf";
		//waitUntil {scriptDone _hnd};

    	//+++ Sygsky: check New Year calendar period and create "Radio" object if yes
    	while {isNil "SYG_mission_start"} do {sleep 1}; // wait for 1st user connection and receiving real server time from him (this is Arma!!!)

    	if ( (argp(SYG_mission_start,1) > 1) && (argp(SYG_mission_start,1) < 12) ) exitWith {false}; // new year expected if only december or january is current month

    	if ( (argp(SYG_mission_start,1) == 12) || ( (argp(SYG_mission_start,1) == 1) && (argp(SYG_mission_start,1) < 10) ) ) then
    	{
            while {true} do
            {
                // now check NewYear period
                if ( call SYG_isNewYear ) exitWith
                { // make gift for a player on a New Year event
                    hint localize format["init.sqf: %1 -> New Year detected, give some musical present for players on base", _srvDate call SYG_humanDateStr];
                    private ["_vec","_snd"];
                    _vec = "Radio" createVehicle [0, 0, 0];
                     // set radio on top of the table
                    _vec setPos [ 9384.3, 9972.8, 1.5];
                    _vec setDir 90;
                    sleep 30.512;	// wait until dropped to ground
                    _snd = createSoundSource ["Music", (getpos _vec), [], 0];// only one source on the server should be created

                //	hint localize format["SoundSource created: %1, typeOf %2", _snd, typeOf _snd];

                    _vec setVariable ["SoundSource", _snd];
                    _vec addEventHandler ["Killed", { deleteVehicle ((_this select 0) getVariable "SoundSource"); (_this select 0) setVariable ["SoundSource", nil]; hint localize "init.sqf: N.Y. Music is killed"}];
                };
                sleep 3600; // wait 1 hour to check new year next hour
            };
		};
	};
	
#ifdef __ACE__
	// ACE sys network uses onPlayerConnected too
	// not a good idea since a mission onPlayerConnected overwrites it or vice versa
	// means, it can only be used once

	// OnPlayer Connected DB
	if (isNil "ace_sys_network_OPCB") then {ace_sys_network_OPCB = []};
	ace_sys_network_OPCB = ace_sys_network_OPCB + [{[_this select 0] execVM "x_scripts\x_serverOPC.sqf"}];
	hint localize format["ACE:ace_sys_network_OPCB = %1", ace_sys_network_OPCB];
	hint localize format["ACE:ace_sys_network_OPC = %1", ace_sys_network_OPC];

	// On Player Disconnect
	if (isNil "ace_sys_network_OPD") then {ace_sys_network_OPD = []};
	ace_sys_network_OPD = ace_sys_network_OPD + [{[_this select 0] execVM "x_scripts\x_serverOPD.sqf"}];
	hint localize format["ACE:ace_sys_network_OPD = %1", ace_sys_network_OPD];

#else
	onPlayerConnected "xhandle = [_name] execVM ""x_scripts\x_serverOPC.sqf""";
	onPlayerDisconnected "xhandle = [_name] execVM ""x_scripts\x_serverOPD.sqf""";
#endif

//#define __DEBUG_CREW_FILLING__
#ifdef __DEBUG_CREW_FILLING__
	__WaitForGroup
	__GetEGrp(_grp)
	// create and add vehicle crew
	_veh = createVehicle ["ACE_HMMWV_GMV2", [9695.0,9986.0,140.0], [], 0, "NONE"];
	__addRemoveVehi(_veh)
	[_veh, _grp, "ACE_SoldierWB_A"] call SYG_populateVehicle;
	{ 
		__addDead(_x)
		sleep 0.01;
	} forEach crew _veh;
#endif

#ifdef __DEFAULT__
	//+++ Sygsky: remove map Zavora objects 
	[] spawn {
        private ["_obj"];
		// Create new Zavoras on server ONLY
		// add animated bar gates somewhere on clients ONLY
		{
			_obj = createVehicle ["ZavoraAnim", [0,0,0],[],0, "CAN_COLLIDE"];
			sleep 0.01;
			if ( (count _x) >= 2 ) then { _obj setDir (_x select 1)};
			_obj setPos (_x select 0);
		} forEach [ 
			[[9532.405273,9760.648438,0.3],270], // at outer gate (to mainland)
			[[9524.4,9925.8,0.3],90],            // at inner gate (to airfield)
			[[9759.660156,9801.615234,0.3]]      // at forest and hill above Paraiso
				  ];
        sleep 1.0;
        // set island hotels to be more undestructible as usual
        {
            _obj = [10000,10000,0] nearestObject _x;
            if ( !isNull _obj ) then
            {
//                player groupChat "Hotel event handled to ""HIT""";
                if ( typeOf _obj == "Land_Hotel" ) then
                {
                    _obj addEventHandler ["hit",
                    {
//                        private [ "_str" ];
//                        _str = format["Hotel damaged with %1, dmg = %2",_this select 2,getDammage (_this select 0)];
//                        hint _str;
                        (_this select 0) setDammage 0;
                    }];
                };
            };
        } forEach [172902,64642,555078];

	};
#endif
	//+++ Sygsky: create and handle GRU computer on server
	[] spawn {
		waitUntil { sleep 10.737; current_target_index >= 0 };
		while { true } do
		{
			sleep 150+(random 300); // average delay 5 minutes to update
			call SYG_updateIntelBuilding; // update all GRU objects
		};
	};

	["INIT"] call compile preprocessFileLineNumbers "GRU_scripts\GRUServer.sqf";

}; // if (isServer)


//+++ Sygsky
// Run short night script on both server and client machines
// Night is assumed to start from 19:45 evening and end at 04:36 morning.
// You can variate in future night start/end time and wanted night span.
// Now it is 30 mins (first param eq 0.5), that means night run 17.7 times faster than real time in life.
// Longitivity of morning and evening is set to 30 minutes (last param eq 0.5)
SYG_shortNightStart  = 19.75;
SYG_eveningStart     = 18.30;
SYG_shortNightEnd    = 4.6;
SYG_morningEnd       = 7.0;
SYG_nightDuration    = 0.5;
SYG_twilightDuration = 0.5;
SYG_nightLength      = (24 - SYG_shortNightStart) + SYG_shortNightEnd;
SYG_nightSpeed       = SYG_nightLength/SYG_nightDuration;

#ifdef __OLD__

[SYG_shortNightStart, SYG_shortNightEnd, SYG_nightDuration, SYG_twilightDuration] execVM "scripts\shortNight.sqf";
hint localize format["init.sqf:shortNight.sqf: night start at %1, twilight span %2, morning start at %3, span %4, speed %5, night duration %6", SYG_shortNightStart,SYG_twilightDuration, SYG_shortNightEnd, SYG_nightLength, SYG_nightSpeed, SYG_nightDuration ];

#else

SYG_nightSkipFrom  = 21.0;
SYG_nightSkipTo    = 3.0;
//       Night start,         night end,         skip from,         skip to
[SYG_shortNightStart, SYG_shortNightEnd, SYG_nightSkipFrom, SYG_nightSkipTo] execVM "scripts\shortNight.sqf";
hint localize format["init.sqf; shortNight.sqf: evening at %1 up to %2, after skip to %3 and morning at% 4",
    SYG_eveningStart, SYG_nightSkipFrom, SYG_nightSkipTo, SYG_shortNightEnd ];

#endif


#ifdef __ACE__
ace_sys_network_WeatherSync_Disabled = true;
ace_sys_network_TimeSync_Disabled = true;
ACE_Sys_Ruck_SpawnRuckItemsOnDeath = false;
//ACE_Sys_Magazines_Debug = true;

#endif

if (!X_Client) exitWith {};
waitUntil {X_Init};

#include "i_client2.sqf"

["INIT"] call compile preprocessFileLineNumbers "GRU_scripts\GRUClient.sqf";

if (!X_SPE) then {
	waitUntil {count d_vars_array > 0};
	__DEBUG_NET("init.sqf",d_vars_array)

	#ifndef __TT__
	_bit_array = [d_vars_array select 0, 17] call XfNumToBitArray2;
	#endif
	#ifdef __TT__
	_bit_array = [d_vars_array select 0, 25] call XfNumToBitArray2;
	#endif

	mt_radio_down = _bit_array select 0;
	target_clear = _bit_array select 1;
	all_sm_res = _bit_array select 2;
	the_end = _bit_array select 3;
	mr1_in_air = _bit_array select 4;
	mr2_in_air = _bit_array select 5;
	ari_available = _bit_array select 6;
	ari2_available = _bit_array select 7;
	d_jet_service_fac_rebuilding = _bit_array select 8;
	d_chopper_service_fac_rebuilding = _bit_array select 9;
	d_wreck_repair_fac_rebuilding = _bit_array select 10;
	MRR1 setVariable ["d_ammobox", _bit_array select 11];
	MRR2 setVariable ["d_ammobox", _bit_array select 12];
	HR1 setVariable ["d_ammobox", _bit_array select 13];
	HR2 setVariable ["d_ammobox", _bit_array select 14];
	HR3 setVariable ["d_ammobox", _bit_array select 15];
	HR4 setVariable ["d_ammobox", _bit_array select 16];

	#ifdef __TT__
	mrr1_in_air = _bit_array select 17;
	mrr2_in_air = _bit_array select 18;
	MRRR1 setVariable ["d_ammobox", _bit_array select 19];
	MRRR2 setVariable ["d_ammobox", _bit_array select 20];
	HRR1 setVariable ["d_ammobox", _bit_array select 21];
	HRR2 setVariable ["d_ammobox", _bit_array select 22];
	HRR3 setVariable ["d_ammobox", _bit_array select 23];
	HRR4 setVariable ["d_ammobox", _bit_array select 24];
	#endif

	date_str = d_vars_array select 1;
	current_target_index = d_vars_array select 2;
	current_mission_index = d_vars_array select 3;
	ammo_boxes = d_vars_array select 4;
	sec_kind = d_vars_array select 5;
	resolved_targets = d_vars_array select 6;

	jump_flags = d_vars_array select 7;
	truck1_cargo_array = d_vars_array select 8;
	truck2_cargo_array = d_vars_array select 9;
	mt_radio_pos = d_vars_array select 10;
	d_ammo_boxes = d_vars_array select 11;
	d_wreck_marker = d_vars_array select 12;

	d_jet_service_fac = d_vars_array select 13;
	d_chopper_service_fac = d_vars_array select 14;
	d_wreck_repair_fac = d_vars_array select 15;

	fRainLess = d_vars_array select 16;
	fRainMore = d_vars_array select 17;
	fFogLess = d_vars_array select 18;
	fFogMore = d_vars_array select 19;
	_time_next_a = d_vars_array select 20;
	MRR1 setVariable ["d_ammobox_next", _time_next_a select 0];
	MRR2 setVariable ["d_ammobox_next", _time_next_a select 1];
	HR1 setVariable ["d_ammobox_next", _time_next_a select 2];
	HR2 setVariable ["d_ammobox_next", _time_next_a select 3];
	HR3 setVariable ["d_ammobox_next", _time_next_a select 4];
	HR4 setVariable ["d_ammobox_next", _time_next_a select 5];

	#ifdef __TT__
	MRRR1 setVariable ["d_ammobox_next", _time_next_a select 6];
	MRRR2 setVariable ["d_ammobox_next", _time_next_a select 7];
	HRR1 setVariable ["d_ammobox_next", _time_next_a select 8];
	HRR2 setVariable ["d_ammobox_next", _time_next_a select 9];
	HRR3 setVariable ["d_ammobox_next", _time_next_a select 10];
	HRR4 setVariable ["d_ammobox_next", _time_next_a select 11];
	#endif

#ifdef __TT__
	points_array = d_vars_array select 21;
#endif
} else {
	d_player_stuff = [d_player_air_autokick, time, name player, 0, ""];
}; // if (!X_SPE)

client_target_counter = count resolved_targets;

waitUntil {local player};

if (X_SPE) then {
	sleep 1;
} else {
	sleep 0.01;
};

execVM "x_scripts\x_jip.sqf"; // call for player intro and setup scripts

#ifdef __DEFAULT__
// hide default bargates on base on all client computers etc
[] spawn {
	private ["_pos","_zav","_arr"];
	_pos = [9621,9874,0];
	// remove map hardcoded bar gates
	{
		_zav = _pos nearestObject _x;
		if ( !isNull _zav AND alive _zav) then
		{
			_zav setDammage 1.1;
			sleep 0.1;
		};
	}forEach [353,355,362/* ,367 */];
    sleep 0.5;
	// build flag on Antigua (just in case)
	[17935.5,18920,0] execVM "x_scripts\x_createjumpflag1.sqf"; // build soviet flag + ammo box

};
#endif

// this code ensured to be run on client computer ONLY
if ( sec_kind == 3) then
{
	private ["_target_array2","_current_target_name"];
	__TargetInfo
	//_target_array2 = target_names select current_target_index;_current_target_name = _target_array2 select 1;
	[_target_array2 select 0] call SYG_reammoTruckAround;
};

#ifdef __ACE__
if ( !isServer ) then // use only on client
{
    // store rucksack position (not move automatically it to the secondary gear slot)
    ACE_Sys_Ruck_Switch_WOBCheck  = compile preprocessFileLineNumbers "nothing.sqf";
    // improve available magazines description
    ACE_Sys_Ruck_UI_UpdateDescriptionDisplay = compile preprocessFileLineNumbers "scripts\MyUpdateDescriptionDisplay.sqf";

#ifdef __JAVELIN__
    #ifndef __NO_RPG_CLONING__
    // Disable Javelin to rucksack load
    ACE_Sys_Ruck_CanPackMagToDummyMag = compile preprocessFileLineNumbers "scripts\CanPackMagToDummyMag.sqf";
    #endif
#endif

#ifdef __NO_RPG_CLONING__
    // disables AT etc missiles cloning through rucksacks
ACE_Sys_Ruck_PackInventoryMagToDummyMag = compile preprocessFileLineNumbers "scripts\PackInventoryMagToDummyMag.sqf";
#endif
};
#endif



if (true) exitWith {};