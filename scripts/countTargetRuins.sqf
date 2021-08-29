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

_msg = "STR_SYS_650";  _sound = "losing_patience"; // Many building destroyed

if (_new_ruins_cnt < 1) then { _msg = "STR_SYS_650_0"; _sound = "good_news"; } else {
	if (_new_ruins_cnt < 5) then { _msg = "STR_SYS_650_1";  _sound = "good_news"; };
};
// send corresponding message to all online players
["msg_to_user","", [[_msg, _new_ruins_cnt], ["STR_SYS_650_2"]], 5,3,false, _sound] call XSendNetStartScriptClient;


