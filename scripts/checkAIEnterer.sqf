/*
    scripts\checkAIEnterer.sqf: called on client comp only
	author: Sygsky
	description: checks that AI can't visit air vehicle with his owner in role GRU specialist as pilot
	returns: nothing
*/

private ["_role_arr","_sound"];

while {(alive _this) && ((vehicle player) != player)} do {
    if ( count (crew _this) > 1 ) then {
        // check if AI in vehicle is in role "Gunner"
        {
            if ( alive _x && !isPlayer _x ) then
            {
                if ( group _x == group player ) then {
                    _role_arr = assignedVehicleRole _x;
                    if ( count _role_arr > 0 ) then
                    {
                        if ( _role_arr select 0 == "Turret" )  exitWith {
                            _x action[ "Eject",_this ]; // get out from vehicle
                            if ( _x call SYG_isWoman) then
                            {
                                ["say_sound", _x, format["sorry_%1",floor(random 13)] ] call XSendNetStartScriptClientAll; // Woman say "Sorry" etc
                            };
                            _msg = "STR_AI_12_" + str(floor (random 4));
                            [_this, (localize _msg) call XfRemoveLineBreak] call XfVehicleChat;
                        };
                    };
                };
            };
        } forEach crew _this;
    };
    sleep (1 + (random 2));
};
