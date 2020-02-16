/*
    scripts\checkAIEnterer.sqf: called on client comp only
	author: Sygsky
	description: checks that AI can't visit air vehicle with his owner in role GRU specialist as pilot
	returns: nothing
*/

private ["_role_arr","_sound","_do"];
_do = true;
while {(alive _this) && ((vehicle player) != player) && _do} do {
    if ( count (crew _this) > 1 ) then {
        // check if AI in vehicle is in role "Gunner"
        {
            if ( alive _x && !isPlayer _x ) then
            {
                if ( group _x == group player ) then {
                    _role_arr = assignedVehicleRole _x;
                    if ( count _role_arr > 0 ) then
                    {
                        if ( _role_arr select 0 == "Turret" )  then {
                            if ( _x call SYG_isWoman) then
                            {
                                if (round 10 > 9) // 1 time from 10 woman AI will agree to be a gunner of battle heli
                                then
                                {
                                    ["say_sound", _x, format["sorry_%1", 12 + floor(random 3)] ] call XSendNetStartScriptClientAll; // Woman say "Sorry" etc 12..14
                                    _do = false;
                                }
                                else
                                {
                                    ["say_sound", _x, format["sorry_%1",floor(random 12)] ] call XSendNetStartScriptClientAll; // Woman say "Sorry" etc in 0..11
                                };
                            };
                            if (_do) then
                            {
                                _msg = "STR_MAP_NUM" call SYG_getRandomText;
                                [_this, (localize _msg) call XfRemoveLineBreak] call XfVehicleChat;
                                _x action[ "Eject",_this ]; // get out from vehicle
                            };
                        };
                    };
                };
            };
            if (!_do) exitWith{};
        } forEach crew _this;
    };
    sleep (1 + (random 2));
};
