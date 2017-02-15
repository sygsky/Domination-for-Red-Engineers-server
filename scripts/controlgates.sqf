// controlgates.sqf : created by Sygsky. 16-NOV-2015
// control gates on base
//    Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
//    target (_this select 0): Object - the object which the action is assigned to
//    caller (_this select 1): Object - the unit that activated the action
//    ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
//    arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax

_arr = _this select 3;
if (! isNil "_arr" ) then
{
	_cnt = [ _arr select 1, _arr select 0] call SYG_execBarrierAction;
	hint localize format["controlgates.sqf: action %1 executed on %2 gate[s] by %3", _arr select 0, _cnt, name (_this select 1)];
};
