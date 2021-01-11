/*
	author: Sygsky
	description: none
	returns: nothing
*/

private [""];
/*
    parameters used in format answer, offsets:
    00: AI name,
    01: AI pos,
    02: nearest settlement name,
    03: random settlement name
    04: one of settlement name
    05: current target town name or "" if no
    06: player name,
    07: player position
    08: target point
    09: is leader of group
    10: current size of group
    12: initial size of group
*/

_mainArray =
[
    [1,2,3,4], // initial options available after start, different for each call
    [ 1, [[1,0.5],[2,0.5]], "What is you name ?", ["%0","I'm not chief in this group, find and ask him about anything"]],
    [ 2, {_this == 2}, "Do you smoke?", ["None", "Yes", "Not you business, sorry", "I'm too young, h-m..."]],
    [ 3, {_this < 2}, "Are you married?", ["yes", "not", "not you business", "how about you"]],
    [ 4, {_this > 0}, "Where are you living?", ["In %4", "And you?"]]
];
typeName _this;