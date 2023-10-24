/*
    IS NOT USED! Was created for an early version of Antigua, but its use was abandoned. Sounds (unlock%1) also not implemented
    scripts\intro\unlock_veh.sqf
	author: Sigolaev.v.a
    description:
        Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
        target (_this select 0): Object - the object which the action is assigned to
        caller (_this select 1): Object - the unit that activated the action
        ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
        arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
                                    may be "BOAT", "CAR", "WEAPON", "MEN", "RUMORS"

	returns: nothing
*/
_veh = _this select 0;
if (locked _veh ) exitWith {
    _veh lock false;
    hint localize format["+++ unlock_veh.sqf: veh %1 is %2", typeOf _veh, if (locked _veh) then {"locked"} else {"unlocked"}];
    _veh say (format["unlock%1", (floor (round 3)) + 1]); // play 1 of 3 unlock sounds
    _veh groupChat (localize "STR_ABORIGEN_CAR_UNLOCK_2"); // ""Vehicle unlocked, you're good to go.""
    _veh removeAction (_this select 2); // remove this action
};
_veh say "return"; // not locked, empty action