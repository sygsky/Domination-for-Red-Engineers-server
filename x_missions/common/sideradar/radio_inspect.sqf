/*
    x_missions/common/sideradar/radio_inspect.sqf
    created 2022.06.01
	author: Sygsky, on #410 request by Rokse
	description: Inspect event handler for radio install SM

	Parameters array passed to the script upon activation in _this  variable is: [target, caller, ID, arguments]
    target (_this select 0): Object  - the object which the action is assigned to
    caller (_this select 1): Object  - the unit that activated the action
    ID (_this select 2): Number  - ID of the activated action (same as ID returned by addAction)
    arguments (_this select 3): Anything  - arguments given to the script if you are using the extended syntax

	changed:
	returns: nothing
*/

_id  = _this select 3;
_str = "STR_RADAR_NO";// "Received unreliable message"
// Radar itself
// "Radio communication mast - must be installed at a substantial height, on a horizontal surface."
if (_id == 0) then { _str = "STR_RADAR_01"; } else {
  	// first truck: "Truck #1, to carry the radio mast, take care of it!"
	if (_id == 1) then { _str = "STR_RADAR_11"; } else {
	 	// second truck: "Truck #2, to carry the radio mast, take care of it!"
		if (_id == 2) then { _str = "STR_RADAR_21"; };
	};
};
["msg_to_user", "", [_str], 0, 1, false] call SYG_msgToUserParser;
if (_str == "STR_RADAR_NO") then {
	player groupChat format["--- radio_init.sqf: expected _id must by 0, 1 or 2. Found '%3', exit ", _id];
};
