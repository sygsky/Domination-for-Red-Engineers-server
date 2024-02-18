// by Xeno: init.sqf
#include "x_setup.sqf"
#include "x_macros.sqf"

#include "i_common.sqf"

X_INIT = false;
X_Server = false; X_Client = false; X_JIP = false; X_SPE = false;
X_InstalledECS = isClass (configFile >> "cfgVehicles" >> "ECS_basic");

X_MP = (playersNumber east + playersNumber west + playersNumber resistance + playersNumber civilian) > 0;

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

hint localize format["+++ init.sqf: isServer = %1, X_Server = %2, X_Client = %3, X_JIP = %4, X_SPE = %5, X_MP = %6, X_INIT = %7, mission ""%8"" in world ""%9""",
	isServer, X_Server, X_Client, X_JIP, X_SPE, X_MP, X_INIT, missionName, worldName];

SYG_firesAreCreated  = false; // are fires on airbase created
publicVariable "SYG_firesAreCreated";

current_mission_counter = 0;    // side missions counter (init on server and client)

global_vars = []; // initiate global vars

if (isNil "XfRandomFloor") then {
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

//hint localize format["init.sqf: SYG_start_mission is %1", SYG_client_start call SYG_dateToStr];

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
    setViewDistance 10000; // try to use this command. What if it could make a furor?
	SYG_updateWeather = {
		// weather parameters
		//  fRainLess = random 0.34; //linear random
		fRainLess = (random 0.2915)^2; //tendency towards nicer weather in nice weather areas
		publicVariable "fRainLess";

		//fRainMore = 0.175 + random 0.375; //1.1 for better chance of actual thunderstorms
		fRainMore = 0.175 + (random 0.825)^2; //tendency towards cloudy weather in rainy weather areas
		publicVariable "fRainMore";

		//  fFogLess = random 0.33; //linear random
		fFogLess = (random 0.287)^2; //tendency towards less fog in fogless areas
		publicVariable "fFogLess";
		
		//fFogMore = 0.175 + random 0.125;
		fFogMore = 0.175 + random 0.825;
		publicVariable "fFogMore";
		
		hint localize format["+++ SYG_updateWeather: fRainLess %1, fRainMore %2, fFogLess %3, fFogMore %4", fRainLess, fRainMore, fFogLess, fFogMore];
	};

	call SYG_updateWeather;

//
// Function missionStart in multi-player (dedi or host server) must ( really?) show server computer REAL time
// but shows 1970-0-0-3
//
//SYG_client_start = missionStart;

//#define __DEBUG_ADD_VEHICLES__
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
        ["ACE_WeaponBox", [9672,9991,0], 270],

        ["ACE_UAZ",[9670,10000,0], 90],
        ["ACE_Bicycle",[9680,10000,0],90]
    ];
/*
    _vec = createVehicle ["ACE_Su30Mk_Kh29T", [9658,10021,0], [], 0, "NONE"];
    _vec setDir 90;
*/
//#ifdef __AI__
//	#ifdef __NO_AI_IN_PLANE__
//	_vec addEventHandler ["getin", {_this execVM "scripts\SYG_eventPlaneGetIn.sqf"}];
//	#endif
//#endif
#else
//	_vec = createVehicle ["ACE_AH1W_AGM_HE", [9658.247070,10020.545898,0], [], 0, "NONE"];
//	_vec setDir 90;
//	_vec = createVehicle ["ACE_Mi24D", [9678.247070,10020.545898,0], [], 0, "NONE"];
//	_vec setDir 90;
//	_vec = createVehicle ["D30", [9678,10021], [], 0, "NONE"];
//	_vec = createVehicle ["Stinger_Pod_East", [9668,10021], [], 0, "NONE"];
//	_vec = createVehicle ["TOW_TriPod_East", [9664,10021], [], 0, "NONE"];
#endif


#ifdef __DEFAULT__
#ifdef __ADDITIONAL_BASE_VEHICLES__
    [] execVM "scripts\addRndVehsOnBase.sqf"; // all positions in file are set for Sahrani only
#endif

#ifdef __SCUD__
    if (SYG_found_SCUD) then {
        hint localize "+++ SCUD addon gig_scud.sqf installed";
        [] execVM "scripts\addSCUD.sqf";
    } else {
        hint localize "*** SCUD addon gig_scud.sqf not installed";
    };
#endif
#endif
	FuncUnitDropPipeBomb = compile preprocessFileLineNumbers "scripts\unitDropPipeBombV2.sqf"; //+++ Sygsky: add enemy bomb-dropping ability
	[] spawn {
		private ["_arr"];
		sleep 120; // spawn motocycles on base after arrival ones
		_arr = [moto1,moto2,moto3,moto4,moto5,moto6];
		// Add ATV at shore near boat sea circle
#ifdef __ACE__
		private ["_moto7"];
		_moto7 = createVehicle ["ACE_ATV_HondaR", [8617,10081,0], [], 0, "NONE"];
		_moto7 setDir 90;
		_arr set [count _arr, _moto7];
#endif
		_arr spawn compile preprocessFileLineNumbers "scripts\motorespawn.sqf"; //+++ Sygsky: add N travelling motocycles at base
	};
	[] execVM "scripts\intro\sea_patrol.sqf"; // NOTE: if disable/remove this service, remove sidemission #57 too, as it depends on that

	if (d_weather) then {execVM "scripts\weather\weathergen2.sqf";};

	// create random list of targets
#ifdef __DEFAULT__
	if (_number_targets_h < 50) then { // random number of towns is already defined in number_targets
        // As many as possible big towns should be included into resulting array
        // And some small ones also may be randomly preselected or be totally absent if output count is too low (< 9)
        //               created cnt,       whole number, important indexes, unimportant indexes
        _params = [_number_targets_h, count target_names,  d_big_towns_inds,  d_small_towns_inds]; //
        _str = format["+++ init target town params: %1",_params ];
        hint localize _str;
        _arr = _params call XfIndexArrayWithPredefVals;
        maintargets_list = _arr;
		// maintargets_list = (count target_names) call XfRandomIndexArray;
	} else {
		switch (_number_targets_h) do {
			case 50: {maintargets_list = [3,4,2,0,1,7,6];}; // South Route: Chantoco, Somato, Arcadia, Cayo, Iguana, Dolores, Ortego
			case 60: {maintargets_list = [8,10,16,17];};	// North West Route: Corazol, Mercallilo, Pacamac, Hunapu
			case 70: {maintargets_list = [8,9,11,19,14,18];}; // North Middle Route: Corazol, Obregan, Bagango, Carmen, Eponia, Mataredo
			case 80: {maintargets_list = [8,15,9,11,12,13];}; // North East Route: Corazol, Everon, Obregan, Bagango, Masbete, Pita
			case 90: {
			    // 22 towns (maximum number) fill them from whole list.
			    // Paraiso/Chantico/Somato/Arcadia/Estrella/Cayo etc
			    maintargets_list = [5,3,4,2,20,0,1,7,6,8,15,9,10,11,12,13,19,14,18,16,17,21];
			}; // 22
			case 91: { // all smallest random target towns
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
    // Town ids =  2: Arcadia, 3: Chantico, 4: Somato, 5: Paraiso, 6: Ortego, 7: Dolores, 8: Corazol, 9: Obregan, 14: Eponia,
    // 20: Rahmadi, 21: Gaula, 22: Estrella, 28: Geraldo
#ifdef __TOWN_WEAK_DEFENCE__
    _first_array = [4]; // set some predefined towns at start, dont use optional town indexes here
#else
    _first_array = []; // no predefined town[s] at start, dont use optional town indexes here
#endif
    if ((count _first_array) > 0 ) then {
	    maintargets_list = _first_array + (maintargets_list - _first_array);
    	hint localize format["+++ MT goes first: %1", _first_array]
    };

    _str = format["+++ generated maintargets_list: %1",maintargets_list ];
    number_targets = count maintargets_list; // most correct definition of target towns is here!
    hint localize _str;

	//__DEBUG_SERVER("init.sqf", maintargets_list)
	// create random list of side missions
#ifdef __EASY_SM_GO_FIRST__
    sm_array = sm_array - easy_sm_array; // remove easiest side mission from common list
#endif

	if (d_random_sm_array) then {
		side_missions_random = sm_array call XfRandomArray;
	} else{
		side_missions_random = sm_array;
    };

#ifdef __EASY_SM_GO_FIRST__
    // adds easiest side missions to the head of common list
    side_missions_random = (easy_sm_array call XfRandomArrayInPlace) + side_missions_random;
    hint localize format["+++ __EASY_SM_GO_FIRST__, goes first: %1", side_missions_random];
#endif

//+++ Sygsky: move ranked player missions from the list beginning
#ifdef __DEFAULT__
    if (!isNil("ranked_sm_array") ) then {
        hint localize format["+++ ranked_sm_array = %1",ranked_sm_array];
        private ["_lowestPos","_rankedSMArr","_ind", "_newInd","_val"];
        _lowestPos = ranked_sm_array select 0; // first allowed position for missions that need some rank (to drive tanks, helis, airplanes)
        _rankedSMArr = ranked_sm_array select 1; // mission ids
        // forEach ranked_sm_array;
        {
            _ind = side_missions_random find _x;
            if ( (_ind >= 0) && (_ind < _lowestPos) ) then { // found, bump it to righter position in array
                _val = _rankedSMArr select 0;
                while { _val in _rankedSMArr } do {
                    _newInd = [_lowestPos, count side_missions_random] call XfGetRandomRangeInt;
                    _val = side_missions_random select _newInd;
                };
                side_missions_random set [_ind, _val];
                side_missions_random set [_newInd, _x];
            }
        } forEach _rankedSMArr;
    } else {
        hint localize "+++ ranked_sm_array = nil";
    };
#endif

    // Move radiomast SM #56 to the beginning of SM list at pos 1..10
    // ranked_sm_array = [... [[56],[1,10]] ...];

	// SM to place at first part of SM list between designated indexes, e.g. SM#56 must be at pos [1..10], and SM#2 will be at pos [1..57(maxind)] etc
	// Dynamic SM cant be first in list, that is all konvoys (20,21,22) and all pilots (51, 52, 54)
	_first_sm_array = [ [ [56],[1,10] ], [ [57],[3,12] ], [[2,3,53], [5, 1000]],[[20,21,22,51, 52, 54],[1, 1000]] ];
	hint localize format["+++ init.sqf: FirstSMArray(%1)= %2", count _first_sm_array, _first_sm_array];
	_fixed_id = []; // Rnown controlled SM ids, they can't be used to move out during changing positions
	{
		_x = _x select 0;
		if (typeName _x == "SCALAR") then { _x = [_x] };
		{ _fixed_id set [count _fixed_id, _x] } forEach _x;
	} forEach _first_sm_array;

	_fixed_id = _fixed_id + _first_array;

	for "_i" from 0 to (count _first_sm_array) -1 do {	// For each item in set of [[SM_list],[_list_range_start,_list_range_end]]
		_arr       = _first_sm_array select _i;
		_fsm_arr   = _arr select 0; // Next SM id list
		if (typeName _fsm_arr == "SCALAR") then { _fsm_arr = [_fsm_arr]}; // If single Id, pack it into array
		_fsm_range = _arr select 1; // The range for all id of SM in _fsm_arr
		hint localize format["+++ init.sqf: FirstSMArray - step %1, _fsm_arr %2, _fsm_range %3", _i + 1, _fsm_arr, _fsm_range];
		_range_start = (_fsm_range select 0) min ( (count side_missions_random) - 1 ); // Just in case prevent overflow of id
		_range_end   = (_fsm_range select 1) min ( (count side_missions_random) - 1 ); // Use array last index as max possible one
		if ( (_range_start < 0) || (_range_end < 0) || (_range_start > _range_end)) then {
    		hint localize format["--- init.sqf: controlled SM sub-list %1 has illegal range %2, skipped...", _fsm_range, _fsm_range];
		} else {
            for "_i" from 0 to (count _fsm_arr) - 1 do {
                _sm_id   = _fsm_arr select _i;  // For each SM id check it is already in range
                hint localize format["+++ init.sqf: FirstSMArray - ensure SM#%1 to be in the range %2:", _sm_id, _fsm_range];
                _sm_pos = side_missions_random find _sm_id; // Current pos of SM to from ones to be in range
                if (_sm_pos >= 0) then { // Found, put to the designated sub-range, e.g. [1..10] (indexes start from 0, end with (count side_missions_random -1))
                    if ((_sm_pos >= _range_start) && (_sm_pos <= _range_end) ) exitWith { // Already in range, skip exchange
                        hint localize format["+++ init.sqf: FirstSMArray - SM#%1 is already at pos %2 so is in designated range, skip it", _sm_id, _sm_pos ];
                    };
                    // Find new position for the SM id in the designated range
                    while { true } do {
                        _new_pos = floor( random (_range_end-_range_start + 1) ) + _range_start; // Get random position in the range, e.g. 5 in [1..10]
                        _moved_id = side_missions_random select _new_pos; // Get id of SM to exchange with current first one
                        if (! (_moved_id in _fixed_id )) exitWith { // If found id not in first SM list, echange it
                            side_missions_random set [_new_pos, _sm_id]; // Move first  SM to the pos into designated range
                            side_missions_random set [_sm_pos, _moved_id]; // Put found SM to first SM pos
                            hint localize format["+++ init.sqf: FirstSMArray - SM#%1 exchanged index from %2 to the ranged %3", _sm_id, _sm_pos, _new_pos ];
                        };
                    };
                } else { hint localize format["*** init.sqf: FirstSMArray - SM#%1 not found in the mission SM list, skipped...", _sm_id] };
            };
		};
	};

	//!!!!!!
	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	// insert special missions at the SM list head, may be used for the DEBUG purposes
	//++++++++++++++++++++++++++++++++++++++++++++++++++++
	// 4 - water tank, 5: king, 10 - arti above base (San Sebastian), 21:Convoy Korazol-Estrella, 24 - gazstation near Arcadia, 29 - tanks at Cabo Juventudo,
	// 32 - flag in Parato, 40-41 - prisoners in Tiberia and Tandag, 44 - heli prototype on San Tomas, 47 - factory near Somato,
	// 48 - transformer substations of Corazol, 49 - captain Grant, 50 - arti big SM in field, 51: pilots,
	// 54 - pilots at Hunapu, 55: new officer mission in the forest, 56: radiomast installation, 57 - sea devil boat capturing (november of 2023)
	//
	_first_array = []; // Allow testing ANY SM (#57 etc)
	if ( count _first_array > 0 ) then {
		side_missions_random = _first_array + (side_missions_random - _first_array);
		hint localize format["+++ SM _first_array: %1", _first_array];
	};


//    side_missions_random = side_missions_random - [40,41]; // temporarily remove all SM with prisoners (not work!!)

    hint localize format["+++ final SM array: %1", side_missions_random];

	//__DEBUG_SERVER("init.sqf",side_missions_random)

	current_target_index = -1; // main target index, not defined at start
	current_counter = 0;

	side_mission_resolved = false;

	counterattack = false;

	extra_mission_remover_array = [];
	extra_mission_vehicle_remover_array = [];
	SYG_owner_active_air_vehicles_arr = []; // list of player's vehicles in air
	check_trigger = objNull;
	create_new_paras = false;
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
	execVM "scripts\takeAirfield.sqf"; // first take airfield and only after its completion first town
	d_player_array_names = []; // ["EngineerACE",...] - known players list
	d_player_array_misc = []; // [[d_player_air_autokick, time, "EngineerACE", _score,"delta_1",_equipment_list_str],...] - known players data list
	d_placed_objs = []; // player's objects placed on the map
	
	[] spawn {
		//private ["_hnd","_srvDate"];
		/*
			script "srvtime.sqf" should be situated in Arma.exe root directory when started on server.
			I automatically create it with follow batch file used to start my server "Red-Engineers":
			---------------- start of srvtime.bat
			@echo off

			set dt=%date%
			rem example: 23.11.2015

			set tm=%time%
			rem example: 12:53:33.21

			echo SYG_client_start = [%dt:~6,4%,%dt:~3,2%,%dt:~0,2%,%tm:~0,2%,%tm:~3,2%,%tm:~6,2%]; > "C:\Program Files\ArmA\srvtime.sqf"

			start "" "C:\Program Files\ArmA\arma_server.exe -config=server.cfg -mod=@ACE;@SIX_Pack3 -name=server -pid=pids.log"
			--------------- end of srvtime.bat
		*/
		//_hnd = [] execVM "\srvtime.sqf";
		//waitUntil {scriptDone _hnd};

    	//+++ Sygsky: check New Year calendar period and create "Radio" object if yes
    	while {isNil "SYG_client_start"} do {sleep 60}; // wait for 1st user connection with known time and receiving real server time from him (this is Arma!!!)
        hint localize format["+++ init.sqf: New Year procedure, ""SYG_client_start"" detected %1", SYG_client_start];

    	if ( (argp(SYG_client_start,1) > 1) && (argp(SYG_client_start,1) < 12) ) exitWith {
    	    hint localize "+++ init.sqf: New Year procedure completed, month not DEC or JAN";
    	    false
    	}; // new year expected if only december or january is current month
    	if ( (argp(SYG_client_start,1) == 1) && (argp(SYG_client_start,2) > 10) ) exitWith {
            hint localize format["+++ init.sqf: New Year procedure completed, JAN day (%1) > 10   is out of range", argp(SYG_client_start,2)];
            false
    	}; // out of January NE days
        while {true} do {
            // now check NewYear period
            if ( call SYG_isNewYear ) exitWith {// make gift for a player on a New Year event
                hint localize format["+++ init.sqf: %1 -> New Year detected, give some musical present for players on base", (call SYG_getServerDate) call SYG_humanDateStr];
                private ["_veh","_snd","_pos"];
                _veh = "Vysilacka" createVehicle [0, 0, 0]; // "Radio" is deletable, Vysilacka is not deletable
                 // set radio on top of the table
                _pos = [ [ 9384.3, 9972.8, 1.6], [ 9384.3, 9971.6, 1.6] ] select (floor (random 2));
                _veh setPos _pos;
//                _veh setDir 90;
                sleep 5.512;	// wait until dropped to the underlying surface
                _snd = createSoundSource ["Music", (getpos _veh), [], 0];// only one source on the server should be created

            //	hint localize format["SoundSource created: %1, typeOf %2", _snd, typeOf _snd];

                _veh setVariable ["SoundSource", _snd];
                _vec addEventHandler [
                    "Killed",
                    {
                        deleteVehicle ((_this select 0) getVariable "SoundSource");
                        (_this select 0) setVariable ["SoundSource", nil];
                        hint localize format["*** init.sqf: N.Y. Music is killed by '%1'",name (_this select 1) ]
                    }
                ];
                [_veh,_snd] spawn {
	                private ["_veh","_snd"];
	                _veh = _this select 0;
	                _snd = _this select 1;
	                while { (alive _veh) && (alive _snd) } do {
	                	sleep 60; // each minute
	                	if ((_veh distance _snd) > 0.5) then {
	                		_snd setPos (getPos _veh); // move sound to its source
	                	};
	                };
                };
            };
            hint localize format["init.sqf: server date/time %1 -> New Year not detected, next check after 6 hours", (call SYG_getServerDate) call SYG_dateToStr];
            sleep 21600; // wait 6 hours to check new year next time after
        };
        hint localize "+++ init.sqf: New Year procedure completed";
	};
	
#ifdef __ACE__
	// ACE sys network uses onPlayerConnected too
	// not a good idea since a mission onPlayerConnected overwrites it or vice versa
	// means, it can only be used once

	// OnPlayer Connected DB
	if (isNil "ace_sys_network_OPCB") then {ace_sys_network_OPCB = []};
	ace_sys_network_OPCB set [count ace_sys_network_OPCB , {[_this select 0] execVM "x_scripts\x_serverOPC.sqf"} ];
	hint localize format["+++ ACE:ace_sys_network_OPCB count %1", count ace_sys_network_OPCB];

	// On Player Disconnect
	if (isNil "ace_sys_network_OPD") then {ace_sys_network_OPD = []};
	ace_sys_network_OPD set [ count ace_sys_network_OPD, {[_this select 0] execVM "x_scripts\x_serverOPD.sqf"}];
	hint localize format["+++ ACE:ace_sys_network_OPD count %1", count ace_sys_network_OPD];

#else
	onPlayerConnected "xhandle = [_this select 0] execVM ""x_scripts\x_serverOPC.sqf""";
	onPlayerDisconnected "xhandle = [_this select 0] execVM ""x_scripts\x_serverOPD.sqf""";
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
	//+++ Sygsky: remove map Zavora objects etc
	// hide default bargates on base on server only

	[] spawn {
        private ["_obj","_x"];
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
/**
        sleep 1.0;
        // removed event handlers as non-workable on embedded map objects
        // set island hotels to be more undestructible as usual
        {
            _obj = [10000,10000,0] nearestObject _x;
            if ( !isNull _obj ) then
            {
                if ( typeOf _obj == "Land_Hotel" ) then
                {
                    _obj addEventHandler ["hit",
                    {
                        (_this select 0) setDammage 0;
                    }];
                };
            };
        } forEach [172902,64642,555078];
        sleep 0.5;
*/
		// Disable jump flag on Antigua as it is too easy to reach base with it on initial jump
        // build flag on Antigua (by Yeti request)
        sleep 60; // wait 1 minute to ensure user to build flag on map
        [[17935.5,18920,0],false] execVM "x_scripts\x_createjumpflag1.sqf"; // build soviet flag + ammo box on antigua

        // create outdoor toilet ("Land_KBud")
		_obj = createVehicle ["Land_KBud", [0,0,0],[],0, "CAN_COLLIDE"];
		_obj setDir 270;
		_obj setPos [9438.9,9858.4,0];
		// TODO: add some action to toilet on client computer
#ifdef __ACE__
		// add some random equipment
		if ( (random 1) < 0.5 ) then {
            _cnt = _obj call SYG_housePosCount;
            _pos = floor (random _cnt);
            _pos = _obj buildingPos _pos;
            _pos set [2, (_pos select 2) + 0.55];
//          _pos set [0, (_pos select 0) - 0.25];
            _weaponHolder = "WeaponHolder" createVehicle [0,0,0];
            _weaponHolder setPos _pos;// [_weaponHolderPos, [], 0, "CAN_COLLIDE"];
            _item = (SYG_PISTOL_WPN_SET_WEST) call XfRandomArrayVal;
            _wpn = _item select 1;
            _mag = _item select 2;
            _weaponHolder addWeaponCargo [_wpn, 1];
            _weaponHolder addMagazineCargo [_mag, 4 ];
            hint localize format["*** init: %1 created in %2", _wpn, typeOf _obj];
		};
#endif
	};
#endif
	//+++ Sygsky: create and handle GRU items (computer, radiomast etc) on server
	[] spawn {
		// create GRU radio mast on the Pico de Perez
		d_radar = createVehicle["Land_radar", [14257.2,15166.2], [], 0, "CAN_COLLIDE"];
		d_radar setVehicleInit "this execVM ""x_missions\common\sideradar\radio_init.sqf""";
		d_radar addEventHandler ["killed", { _this execVM "x_missions\common\sideradar\radio_killed.sqf" } ]; // remove killed radar after some delay
		publicVariable "d_radar";
		sideradio_status = 2; // radio-relay is online!
		publicVariable "sideradio_status";
		d_radar_truck = objNull;
		publicVariable "d_radar_truck";

		waitUntil { sleep 10.737; current_target_index >= 0 };
		while { true } do {
			sleep 150+(random 300); // average delay 5 minutes to update
			call SYG_updateIntelBuilding; // update all GRU objects
		};
	};

	["INIT"] spawn compile preprocessFileLineNumbers "GRU_scripts\GRUServer.sqf"; // run in the scheduled envirinment

    //+++++++++++++++++++++++++++++++ SHORT NIGHT DEFINITIONS AND CODE SPAWN

    //       Night start,      morning start,  night skip from,    night skip to

    // Run short night script only on server, all info will be send to clients
    // Night is assumed to start from 19:45 (evening) and end at 04:36 (morning).
    // You can variate in future night start/end time and wanted night span.

    [SYG_startMorning, SYG_startDay, SYG_startEvening, SYG_startNight, SYG_nightSkipFrom, SYG_nightSkipTo] execVM "scripts\shortNightNew.sqf";

    hint localize format["*** init.sqf; shortNightNew.sqf: morning %1, day %2, evening %3, night %4, skipFrom %5, skipTo %6",
        SYG_startMorning,SYG_startDay,SYG_startEvening, SYG_startNight,SYG_nightSkipFrom, SYG_nightSkipTo];

    //-------------------------------

#ifdef __ACE__ // execute code if on server and ACE is defined

    #ifdef __MANDO_MISSILES_UPDATE__
    ace_sys_missiles_incomingMissile = compile (preprocessFileLineNumbers ("scripts\ACE\ace_mando_replacemissile.sqf")); // replace mando guidance missile range
    mando_scorefunc                  = compile (preprocessFileLineNumbers ("scripts\ACE\mando_score.sqf")); // replace mando score calculation
    //mando_missile_handler            = compile (preprocessFileLineNumbers ("scripts\ACE\mando_missile.sqf"));
    hint localize "*** __MANDO_MISSILES_UPDATE__ replaces some Mando routines with custom versions";
    #endif

#endif

#ifdef __ARRIVED_ON_ANTIGUA__
	[] execVM "scripts\intro\SYG_startOnAntigua.sqf";
#endif


};  // if (isServer)

// common (server + client ) code execution section

#ifdef __ACE__
ace_sys_network_WeatherSync_Disabled = true;
ace_sys_network_TimeSync_Disabled = true;
ACE_Sys_Ruck_SpawnRuckItemsOnDeath = false;
//ACE_Sys_Magazines_Debug = true;

#endif

if (!X_Client) exitWith {};
//============================================== CLIENT COMPUTER EXECUTION ONLY ======================================
waitUntil {X_Init};

#include "i_client2.sqf"

["INIT"] spawn compile preprocessFileLineNumbers "GRU_scripts\GRUClient.sqf";

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
#ifdef __DOSAAF_BONUS__
	_arr = _time_next_a select 6; // all info about DOSAAF vehicles (not detected and markered as detected)

	// 1st array contains original DOSAAF vehicles that are not detected
	{
		_x setVariable ["DOSAAF", ""];
		_x setVariable ["INSPECT_ACTION_ID", _x addAction [ localize "STR_CHECK_ITEM", "scripts\bonus\bonusInspectAction.sqf",[]]];
	} forEach (_arr select 0);
	hint localize format[ "+++ init.sqf bonus.INIT on client: non-monitored DOSAAF veh count = %1, INSPECT is set as the command for them.", count (_arr select 0) ];

	// 2nd array contains detected already markered and monitored DOSAAF vehicles
	{
		_x setVariable ["RECOVERABLE", false];
		// replace title with "Register" text
		_x setVariable ["INSPECT_ACTION_ID", _x addAction [ localize "STR_REG_ITEM", "scripts\bonus\bonusInspectAction.sqf",[]]];
	}forEach (_arr select 1);
	hint localize format[ "+++ init.sqf bonus.INIT on client: monitored DOSAAF veh count = %1, REGISTER is set as the command for them.", count (_arr select 1) ];

	client_bonus_markers_timestamp = time; // init timestamp
	_arr = []; sleep 0.01; _arr = nil;
#endif

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
// add new bargates at base on client comps only
[] spawn {
	private ["_pos","_zav","_x"];
	_pos = [9621,9874,0];
	// remove map hardcoded bar gates
	{
		_zav = _pos nearestObject _x;
		if ( !isNull _zav && alive _zav) then {
			_zav setDammage 1.1;
			sleep 0.1;
			deleteCollection _zav;
		};
	}forEach [353,355,362/* ,367 */];

};
#endif

// this code ensured to be run on client computer ONLY
if ( sec_kind == 3) then {
	private ["_target_array2","_current_target_name"];
	__TargetInfo
	//_target_array2 = target_names select current_target_index;_current_target_name = _target_array2 select 1;
	[_target_array2 select 0] call SYG_reammoTruckAround;
};

#ifdef __ACE__  // the section for ACE modified methods
if ( X_Client ) then {// runs only on client

    // Not change rucksack position (not move it automatically to the secondary gear slot)
#ifdef __EQUIP_OPD_ONLY__
	// store rucksack content each time on rucksack update dialog call (if really changed)
	SYG_playerRucksackContent = ""; // Player rucksack current content in text form changed on each rucksack update
    ACE_Sys_Ruck_Switch_WOBCheck = compile preprocessFileLineNumbers "scripts\ACE\storeRucksackContent.sqf";
    hint localize "+++ ACE_Sys_Ruck_Switch_WOBCheck replaced by custom version";
#endif
#ifndef __EQUIP_OPD_ONLY__
    ACE_Sys_Ruck_Switch_WOBCheck  = compile preprocessFileLineNumbers "nothing.sqf";
    hint localize "+++ ACE_Sys_Ruck_Switch_WOBCheck replaced by dummy version";
#endif

    // improve available magazines description
    ACE_Sys_Ruck_UI_UpdateDescriptionDisplay = compile preprocessFileLineNumbers "scripts\ACE\MyUpdateDescriptionDisplay.sqf";
    hint localize "+++ ACE_Sys_Ruck_UI_UpdateDescriptionDisplay replaced by custom version";

    #ifdef __JAVELIN__
        #ifndef __NO_RPG_CLONING__
    // Disable Javelin to rucksack load
    ACE_Sys_Ruck_CanPackMagToDummyMag = compile preprocessFileLineNumbers "scripts\ACE\CanPackMagToDummyMag.sqf";
    hint localize "+++ ACE_Sys_Ruck_CanPackMagToDummyMag replaced by custom version";

        #endif
    #endif

    #ifdef __NO_RPG_CLONING__
    // disables AT etc missiles cloning through rucksacks
    ACE_Sys_Ruck_PackInventoryMagToDummyMag = compile preprocessFileLineNumbers "scripts\ACE\PackInventoryMagToDummyMag.sqf";
    hint localize "+++ ACE_Sys_Ruck_PackInventoryMagToDummyMag replaced by custom version";
    #endif

    #ifdef __MOVE_EJECT_EVENT_TO_LIST_BOTTOM__
    hint localize "+++ ace_sys_eject... replaced by custom version";

    ace_sys_eject_ace_getin_eject   = compile preprocessFileLineNumbers "scripts\ACE\ace_getin_eject.sqf";
    ace_sys_eject_ace_init_eject    = compile preprocessFileLineNumbers "scripts\ACE\ace_init_eject.sqf";
    ace_sys_eject_ace_getin_jumpout = compile preprocessFileLineNumbers "scripts\ACE\ace_getin_jumpout.sqf";
    ace_sys_eject_ace_init_jumpout  = compile preprocessFileLineNumbers "scripts\ACE\ace_init_jumpout.sqf";
//    call compile preprocessFileLineNumbers "scripts\ACE\ace_sys_eject.sqf"; // still not used, need to investigate more

    #endif

    #ifdef __DISABLE_HIDE_UNCONSCIOUS__

    ACE_Sys_Wound_Net_fSetUnc       = compile preProcessFileLineNumbers "scripts\ACE\setUnc.sqf"; // stop setCaptive for unconsciones player
    hint localize "+++ ACE_Sys_Wound_Net_fSetUnc replaced by custom version";

    #endif

    #ifdef __MANDO_MISSILES_UPDATE__  // execute code if on client and ACE is defined

    mando_scorefunc                 = compile (preprocessFileLineNumbers ("scripts\ACE\mando_score.sqf")); // replace mando score calculation
    hint localize "+++ mando_scorefunc replaced by custom version";

    #endif

};
// No option to run any script on server as this code executed only on clients.
// See exit condition in upper lines: if (!X_Client) exitWith {};

#endif

// play (true) or not play (false) some extra sounds, including reborn and multiple deaths music to player
SYG_playExtraSounds = {
	d_rebornmusic_index == 0
};

//BG Ammo and Fuel truck functions (Gyuri test mission)

player exec "BG\datas.sqs";
player exec "BG\fuelTruck.sqs";
player exec "BG\ammoTruck.sqs";

if (true) exitWith {}