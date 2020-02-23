/*
    scripts\checkAIEnterer.sqf: called on client comp only
	author: Sygsky
	description: checks that AI can't visit air vehicle with his owner in role GRU specialist as pilot
	returns: nothing
*/

#define TIME_TO_NEXT_ATTEMPT 30 // time between attempts to enter

private ["_role_arr","_sound","_enter","_gunner","_time","_diff"];
_enter = false; // no request to enter was produced
_time = time; // allow request to enter
while {(alive _this) && ((vehicle player) != player) && ((player distance FLAG_BASE) < 2000)} do {
    if ( count (crew _this) > 1 ) then {
        // check if AI in vehicle is in role "Gunner"
		_gunner = false;
        {
            if ( alive _x && !isPlayer _x ) then
            {
                if ( group _x == group player ) then {
                    _role_arr = assignedVehicleRole _x;
                    if ( count _role_arr > 0 ) then {
                        if ( ( _role_arr select 0 == "Turret" ) )  then { // AI is sitting in gunner nest
							_gunner = true;
                            if ( !_enter ) then // entered on this loop step only
                            {
                                if ( time < _time ) then { // attempt requested too soon
									_diff = _time - time;
                                    [_this, format[localize "STR_AI_14", round(_diff/5)*5 max 1]] call XfVehicleChat;
                                } else { // time to request
                                    if ( _x call SYG_isWoman ) then
                                    {
                                        // 1/3 probability that woman AI will agree to be a gunner of battle heli
                                        if ((random 9) < 3) then {
                                            //hint localize format["+++ checkAIEnterer: woman entered"];
                                            _msg = "STR_AI_13_NUM" call SYG_getRandomText;
                                            [_this, localize _msg] call XfVehicleChat;
                                            ["say_sound", _x, format["sorry_%1", 12 + floor(random 3)] ] call XSendNetStartScriptClientAll; // Woman say "Sorry" etc 12..14
                                            _enter = true; // entrance allowed
											_time = time;  // mark time to allow test
                                        }
                                        else // AI leave battle heli in this case
                                        {
                                            //hint localize format["+++ checkAIEnterer: woman ejected"];
                                            ["say_sound", _x, format["sorry_%1",floor(random 12)] ] call XSendNetStartScriptClientAll; // Woman say "Sorry" etc in 0..11
                                        };
                                    } else {
										if ( (_x isKindOf "SoldierWPilot") or ( _x isKindOf "SoldierEPilot")) then {
                                            _msg = "STR_AI_13_NUM" call SYG_getRandomText;
                                            [_this, localize _msg] call XfVehicleChat;
                                            _enter = true; // entrance allowed
											_time = time;  // mark time to allow test
										};
									};
                                    if (!_enter) then { // entrance not allowed
                                        _msg = "STR_AI_12_NUM" call SYG_getRandomText; // print message to disagree entering
                                        [_this, localize _msg] call XfVehicleChat;
										_time = time + TIME_TO_NEXT_ATTEMPT; // mark time of next attempt
                                    };
                                };
                            };
							if (!_enter) then { _x action[ "Eject",_this ];}; // entrance not allowed
                        };
                    };
                };
            };
        } forEach crew _this;
        if( !_gunner && _enter) then {_enter = false};
    };
    sleep (1 + (random 2));
};
