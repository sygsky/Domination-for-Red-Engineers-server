// king_escape.sqf, created by Sygsky at 12-JUN-2016. Provides king (5th side mission) escape if enemy is detected in the hotel
//
// call (only on SERVER!!!):
//
//      _unit execVM "king_escape.sqf"
//

#include "x_setup.sqf"
#include "x_macros.sqf"

#define SEARCH_DISTANCE 400
#define WAIT_BEFORE_ESCAPE 60

if (isNil "king")  exitWith {hint localize "--- GRU_scripts\king_escape.sqf: king is nil";};
if (! alive king) exitWith {hint localize "--- GRU_scripts\king_escape.sqf: king is null or dead";};

sleep WAIT_BEFORE_ESCAPE + (random WAIT_BEFORE_ESCAPE);

private ["_center","_nbarr","_ind","_house","_pos","_old_pos"];

#ifdef __RANKED__
d_sm_p_pos = nil;
#endif

_nbarr = [];
_center = [];
if ( (random 1) <= 0.1428571) then // 1 of 7
{
    _center = [10412.7,7732.9,0];
    _nbarr = nearestObjects [_center, ["Land_kulna"], SEARCH_DISTANCE]; // find new kulna
}
else
{
    _center = [10750,7363,0];
    _nbarr = nearestObjects [_center, ["Land_hlaska","Land_bouda2_vnitrek"], SEARCH_DISTANCE];// find any hlaska (brown village house) or iron tower
};


if ( (count _nbarr) == 0) exitWith {
    hint localize format["--- king_escape.sqf: no building(s) %1 in range of %2 m. near %3",["Land_hlaska","Land_bouda2_vnitrekw","Land_kulna"], SEARCH_DISTANCE, _center];
};

_old_pos = position king;
_house = _nbarr call XfRandomArrayVal; // select house for escape
_pos = [_house, "RANDOM", king] call SYG_teleportToHouse;

sleep 0.1;
#ifdef __RANKED__
["d_sm_p_pos", position king] call XSendNetVarClient;
#endif

hint localize format["king_escape.sqf: king teleported to building %1 at pos %2", typeOf _house, _pos];
if (local king) then
{
	player groupChat format["king_escape.sqf: king teleported to building %1 at pos %2", typeOf _house, _pos]
};
king spawn {
    sleep 60 + random 60;
    call SYG_playRandomOFPTrack; // for more fun
    if (alive king) then
    {
        /* inform players about king escape and his new position */
        _dist = king distance _old_pos;
        // "Местные %1 сообщают, что король покинул здание и нашёл другое убежище, не далее %2 м."
        _mgs = ["STR_GRU_48",call SYG_getLocalMenRandomName, (round(_dist /100) max 1)* 100];
         ["msg_to_user","",[_msg]] call XSendNetStartScriptClient;
         hint localize "+++ king_escape.sqf: message sent to user about new king position";
    };
};
publicVariable "king"; // send info for all players