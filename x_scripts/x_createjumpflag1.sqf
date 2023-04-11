// by Xeno, x_scripts\x_createjumpflag1.sqf - creates jump flag at any designated point on designated coordinates,
// it is not main target jump flag (see x_createjumpflag.sqf for this method).
// Called to create jump flags in any point, e.g. on Antigua.
//
// call as: _flag = [_pos, _is_town] execVM "x_scripts\x_createjumpflag1.sqf";
// if _is_town == true, this is town flag and no message is sent to player
// if _is_town == false, this is secret point and send message to players about secret point flag creation
//
private ["_posi", "_ftype", "_flag", "_is_town"];

if (!isServer) exitWith {
	hint localize format[ "--- x_createjumpflag1.sqf: !isServer, _this = %1", _this ];
};

#include "x_setup.sqf"

_posi = _this select 0;
_is_town = if ( (count _this) > 1) then {_this select 1} else {true}; // default is true , that is town flag creation requst

#ifdef __OWN_SIDE_WEST__
_ftype = "FlagCarrierWest";
#endif
#ifdef __OWN_SIDE_EAST__
_ftype = "FlagCarrierNorth";
#endif
#ifdef __OWN_SIDE_RACS__
_ftype = "FlagCarrierSouth";
#endif

_flag = _ftype createVehicle _posi;
sleep 0.05;
jump_flags set [ count jump_flags, _flag];

#ifdef __OWN_SIDE_EAST__
    //+++Sygsky: add more fun with flags
	_flag setFlagTexture "\ca\misc\data\rus_vlajka.pac"; // USSR flag image
#endif

// add flag to the clent list to set marker etc
["new_jump_flag",_flag, _is_town] call XSendNetStartScriptClient;

if (true) exitWith {_flag};
