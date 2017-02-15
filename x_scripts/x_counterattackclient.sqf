// by Xeno
private ["_reason"];

if (!X_Client) exitWith {};

#include "x_macros.sqf"

_reason = _this select 0;

switch (_reason) do {
	case "start" : {
		__TargetInfo
		_s = format ["Похоже что враг не собирается просто так отдавать %1 и готовит контратаку. Занимайте оборонительные позиции и готовьте встречу...", _current_target_name];
		[_s, "HQ"] call XHintChatMsg;
	};
	case "start_real": {
		["Контратака началась!!! Удержите текущий город. Удачи... ... ...", "HQ"] call XHintChatMsg;
	};
	case "over" : {
		["Задача выполнена! Контратака отбита...", "HQ"] call XHintChatMsg;
	};
};

if (true) exitWith {};
