/*
    scripts\animDone.sqf
	author: Sygsky, by task #197
	description:
        2.2 AnimDone
        Trigerred everytime an animation is finished.
            Unknown MP behaviour. Probably local.
            Passed array: [unit, anim]
                unit: Object - Object the event handler is assigned to
                anim: String - Name of the anim that has been finished
	returns: nothing
*/

if ( ( _this select 1 ) in ["AinvPknlMstpSnonWnonDnon_medic_1" ])  then { // You healed somebody
    if ( SYG_lastAnimationType == _this select 1 ) then { // healing started and now completed
        private ["_str", "_nearestbase", "_nearmanList", "_points"];
        _nearestbase = (
            switch (d_own_side) do {
                case "WEST": {"SoldierWB"};
                case "EAST": {"SoldierEB"};
                case "RACS": {"SoldierGB"};
            }
        );
        // search nearest unconscious man nearby
		_nearmanList = nearestObjects [player, [_nearestbase], 3];
        if (count _nearmanList > 0) then {
            {
                if ( ( alive _x ) && ( _x != player ) && ( isPlayer _x ) && (damage _x > 0.05) ) then {
                    // add score, send information
                    _points = d_ranked_a select 7;
                    (format [localize "STR_MED_8", _points, name _x ] ) call XfHQChat; // "You get +%1 points for healing %2!"
                    player addScore _points;
                    ["say_sound", _x, "healing"] call XSendNetStartScriptClientAll;
                };
            } forEach _nearmanList;
        };
    };
};
// TODO: animDone: AmovPpneMstpSrasWrflDnon_healed - healed at medic when laying
// TODO: animDone: AinvPknlMstpSlayWrflDnon_healed2 - healed by medic when staying
// TODO: animDone: AinvPknlMstpSlayWrflDnon_healed - healed in mash
