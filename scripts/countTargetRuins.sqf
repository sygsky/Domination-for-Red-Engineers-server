/*
	scripts\countTargetRuins.sqf

	author: Sygsky
	description: counts number of ruins in finished main target town (#437)
	call as: _last_target_id execVM "scripts\countTargetRuins.sqf";
	returns: nothing
*/

_dummy = target_names select _this;
_current_target_pos = _dummy select 0;
_current_target_radius = _dummy select 2;
_list = _current_target_pos nearObjects ["Ruins", _current_target_radius];
_new_ruins_cnt = (count _list) - initial_ruins_count;

hint localize format["+++ countTargetRuins.sqf: new ruins count after %1 siege is %2", _dummy select 1, _new_ruins_cnt];

_msg = "STR_SYS_650";  _sound = "losing_patience"; // "The siege of the city destroyed buildings %1. The islanders are concerned!"
// "Not a single building was destroyed in the siege of the city. The islanders thank you!"
if (_new_ruins_cnt < 1) then { _msg = "STR_SYS_650_0"; _sound = "good_news"; } else {
	if (_new_ruins_cnt < 5) then { _msg = "STR_SYS_650_1";  _sound = "good_news"; }; // "Few buildings (%1) were destroyed during the liberation of the city. The islanders are grateful to you for your concern for the population!"
};
// send corresponding message to all online players
_arr = [[_msg, _new_ruins_cnt]];
if (_new_ruins_cnt > 0) then {
	_arr set [1,  ["STR_SYS_650_2"]]; // ""In the future, penalty points may be given for destroyed buildings!""
} ;
["msg_to_user","", _arr, 5,3,false, _sound] call XSendNetStartScriptClient;


