/*
    scripts\animChanged.sqf
	author: Sygsky
	description:
    2.1 AnimChanged
        Trigerred everytime a new animation is started. Global.
        Passed array: [unit, anim]
            unit: Object - Object the event handler is assigned to
            anim: String - Name of the anim that started
        returns: nothing
*/

private ["_str"];

SYG_lastAnimationType = _this select 1;

//_str = format[ "+++ animChanged: %1 at %2", SYG_lastAnimationType, time ];
//hint localize _str;
