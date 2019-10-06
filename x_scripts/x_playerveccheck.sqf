// by Xeno
//
// x_playerveccheck.sqf
//
// Prevents player from entering vehicles not allowed by his rank (or weapon).
// Added: allow any rank player entering any vehicle as cargo with any weapon
//
// 02-dec-2016 new rules:
// 1. All weapons are allowed for land vehicles
// 2. Only launchers are not allowed in helis
// 3. Only short rifles are allowed in aiplanes
//
if (!XClient) exitWith {};

#include "x_setup.sqf"

#define __DEBUG_PRINT__

#define INFORM_PERIOD 15 // seconds between sending inform on air battle vehicle status to the server

_sendInfoOnAirVehToServer = {
    ["veh_info", _this ] call XSendNetStartScriptServer; // inform server about battle vehicle activity
};

private ["_veh", "_not_allowed", "_needed_rank", "_index", "_last_send"];

_attempts_count = 0;
_last_send = time;

while { true } do {
	waitUntil {sleep 0.1; vehicle player != player};
	_veh = vehicle player;
	_not_allowed = false;
	_bulky_weapon = "";
	_needed_rank = "";
	_cargo = false;
	_role = "";
	_index = 0;
	_air_battle = false; // Is vehicle Battle Air one?
	if ((typeOf _veh) != "ACE_Bicycle") then
	{

        //+++ Sygsky:
        _role_arr = assignedVehicleRole player;
    #ifdef __DEBUG_PRINT__
        hint localize format["x_playerveccheck.sqf: player assigned as %1 to %2", _role_arr, typeOf _veh];
    #endif
        if ( count _role_arr > 0 ) then
        {
            _role = _role_arr select 0;
            if ( _role == "Cargo" ) then  { _cargo = true; };
        };
        //--- Sygsky;

        _player_not_GRU = isNil "player_is_on_town_raid";
        _enemy_vec = false; // if vehicle is enemy trophy one
        if ( _player_not_GRU ) then
        {
            #ifndef __TT__
            if (!((_veh in [HR1,HR2,HR3,HR4,MRR1,MRR2]) || _cargo) ) then
            #else
            if (!(_veh in [HR1,HR2,HR3,HR4,MRR1,MRR2,HRR1,HRR2,HRR3,HRR4,MRRR1,MRRR2])) then
            #endif
            {
                _index = (rank player) call XGetRankIndex;
                _vrs = d_ranked_a select 8;								 // ranks for:
                _indexsb = (toUpper (_vrs select 0)) call XGetRankIndex; // strike-base/m113/bmp
                _indexta = (toUpper (_vrs select 1)) call XGetRankIndex; // tank
                _indexheli = (toUpper (_vrs select 2)) call XGetRankIndex; // heli
                _indexplane = (toUpper (_vrs select 3)) call XGetRankIndex; // plane
                if (_veh isKindOf "LandVehicle") then {
                    if ( _veh isKindOf "BMP2" || _veh isKindOf "M113" || _veh isKindOf "Vulcan" || _veh isKindOf "StrykerBase" || _veh isKindOf "BRDM2") then {
                        if (!(_veh isKindOf "StrykerBase" || _veh isKindOf "BRDM2")) then // play light tracked armour entering sound
                        {
                            _veh say "APC_GetIn";
                        };
                        if ( _veh isKindOf "M113" || _veh isKindOf "Vulcan" || _veh isKindOf "StrykerBase" ) then
                        {
                            _indexsb = _indexsb - 1; // Entering enemy vehicle requires a lower rank
                            _enemy_vec = true;
                        };
                        if (_index < _indexsb) then {
                            _not_allowed = true;
                            _needed_rank = (_vrs select 0);
                        };
                    } else {
                        if (_veh isKindOf "Tank") then {
    #ifdef __ACE__
                            _veh say "Tank_GetIn";
    #endif
                            if (_veh isKindOf "M1Abrams" || _veh isKindOf "ACE_M60" || _veh isKindOf "ACE_M2A1") then
                            {
                                _indexta = _indexta - 1; // Entering enemy vehicle requires a lower rank
                                _enemy_vec = true;
                            };
                            if (_index < _indexta) then {
                                _not_allowed = true;
                                _needed_rank = (_vrs select 1);
                            };
                        };
                    };
                } else {
                    if (_veh isKindOf "Air") then {
                        if (_veh isKindOf "Helicopter" && !(_veh isKindOf "ParachuteBase")) then {
                            if (_veh isKindOf "AH6" || _veh isKindOf "ACE_Mi17" || _veh isKindOf "UH60MG") then {
                                if (_veh isKindOf "ACE_Mi17" && (_index < _indexta)) then { // always allowed to enter into "AH6" descendants
                                    _not_allowed = true;
                                    _needed_rank = (_vrs select 1);
                                };
                            } else {
                                //big heli are here
                                _air_battle = true;
                                // Western heli allowed to enter for any rank drivers
                                if ( !((_veh isKindof "AH1W" || _veh isKindOf "ACE_AH64_AGM_HE") && (_role == "Driver")) ) then
                                { // follow check for not western helicopter only
                                    if (_index < _indexheli) then
                                    {
                                        _not_allowed = true;
                                        _needed_rank = (_vrs select 2);
                                    };
                                };
                            };
                        } else {
                            if (_veh isKindOf "Plane" && (typeOf _veh != "RAS_Parachute")) then {
                                _air_battle = true;
                                if (_index < _indexplane) then {
                                    _not_allowed = true;
                                    _needed_rank = (_vrs select 3);
                                };
                            };
                        };
                    };
                };
            }
            else
            {
                if (_veh in [MRR1,MRR2] ) then
                {
                    _veh say "APC_GetIn";
                };
            };
            _bulky_weapon = player call SYG_getVecRoleBulkyWeapon;

    #ifdef __DEBUG_PRINT__
            if ( _bulky_weapon != "" ) then
            {
                hint localize format["x_playerveccheck.sqf: bulky weapon is ""%1""",_bulky_weapon];
            };
    #endif
            while { _cargo || ((((!_not_allowed) && (_bulky_weapon == "") ) ) && (vehicle player != player)) } do
            {
                sleep 0.666;
                _role_arr = assignedVehicleRole player;
                _new_role = if (count _role_arr > 0) then  { _role_arr select 0 } else {""};
                if ( _new_role != _role ) then
                {
                    _role = _new_role;
                    _cargo = (_role == "Cargo");
                    _bulky_weapon = player call SYG_getVecRoleBulkyWeapon;
                };
            };
        } // if ( _player_not_GRU ) then
        else // player is the GRU agent, check his options
        {
            // check for GRU on task allowed transport (not armed trucks, bicycle, motocycle, ATV etc)
            _not_allowed =  !(_veh isKindOf "Motorcycle" || _veh isKindOf "ACE_ATV_HondaR" || _veh isKindOf "Truck5t" || _veh isKindOf "Ural" || _veh isKindOf "Zodiac");
        };

        if ( _not_allowed || (_bulky_weapon != "") ) then
        {
            player action[ "Eject",_veh ];
            _attempts_count = _attempts_count + 1;
            if ( _role == "Driver" ) then
            {
                if (isEngineOn _veh) then { _veh engineOn false; };
            };
            if ( _player_not_GRU ) then
            {
                if (_not_allowed) then
                {
                    // "Ваше звание: %1. Вам не позволено использовать %3.\n\nТребуемое звание: %2."
                    [format [localize "STR_SYS_252", toLower(((rank player) call XGetRankStringLocalized)), _needed_rank call XGetRankStringLocalized,[typeOf _veh,0] call XfGetDisplayName], "HQ"] call XHintChatMsg;
                    hint localize format["--- player with rank index %1 ejected from %2", _index, typeOf _veh];
                }
                else // bulky weapon
                {
                    [format[localize "STR_SYS_252_BULKY",_bulky_weapon call SYG_readWeaponDisplayName,"STR_SYS_252_NUM" call SYG_getLocalizedRandomText], "HQ"] call XHintChatMsg; // вы зацепляетесь оружием за люк и отваливаетесь
    /*
                    call compile format["_index=%1;", localize "STR_SYS_252_NUM"];
                    _index = floor(random (_index));
                    [format[localize "STR_SYS_252_BULKY",_bulky_weapon call SYG_readWeaponDisplayName,localize (format["STR_SYS_252_%1",_index])], "HQ"] call XHintChatMsg; // вы зацепляетесь оружием за люк и отваливаетесь
    */
                    //hint localize format["x_playerveccheck.sqf: _index == %1, _attempts_count == %2, STR_SYS_252_NUM == %3, new str == ""%4""", _index, _attempts_count, localize "STR_SYS_252_NUM", localize (format["STR_SYS_252_%1",_index])];
                };
            }
            else
            {
                (localize "STR_GRU_38") call XfGlobalChat; // "No, no! I can't disobey orders about not using such vehicle during GRU task!"
            };
        }
        else // player allowed to be in vehicle
        {
            if ( _air_battle && !_cargo) then // periiodically send info to server about player battle air vehicle activity
            {
                [ _veh, "on" ] call _sendInfoOnAirVehToServer; // add info about to server
                hint localize format[ "+++ x_playerveccheck: start activity report on %1", typeOf _veh ];
            };
        };
	}
	else // ACE_Bicycle
	{
        _veh say "bicycle";
	};
	//hint localize format["x_playerveccheck.sqf: player is not assigned %1", _role_arr];
	waitUntil {sleep 0.2; vehicle player == player};
    if ( _air_battle && (!_cargo) &&  (!_not_allowed) && (_bulky_weapon == "") ) then // drop info
    {
        [ _veh, "off" ] call _sendInfoOnAirVehToServer; // drop info about this vehicle
        hint localize format["+++ x_playerveccheck: stop activity report on %1", typeOf _veh];
    };
};

if (true) exitWith {};
