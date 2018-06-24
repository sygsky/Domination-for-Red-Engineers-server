// by Xeno, x_scripts/x_createjumpflag1.sqf - creates jump flag at designated point on designated coordinates
//
// call as: _flag = _pos execVM "x_scripts/x_createjumpflag1.sqf";
//
private ["_posi", "_ftype", "_flag"];
if (!isServer) exitWith {};

_posi = _this;

_ftype = (
    switch (d_own_side) do {
        case "EAST": {"FlagCarrierNorth"};
        case "WEST": {"FlagCarrierWest"};
        case "RACS": {"FlagCarrierSouth"};
    }
);

_flag = _ftype createVehicle _posi;
sleep 0.05;
jump_flags = jump_flags + [_flag];
if (d_own_side == "EAST") then //+++Sygsky: add more fun with the flag
{
    _flag setFlagTexture "\ca\misc\data\rus_vlajka.pac"; // set USSR flag
};
["new_jump_flag",_flag] call XSendNetStartScriptClient;

if (true) exitWith {_flag};
