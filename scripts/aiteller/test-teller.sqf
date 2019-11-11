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
    03: random settlemet name
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
    [1,2,3,4], // intial options availablestart questionssome start parameters, different for each call
    [ 1, [[1,0.5],[2,0.5]], "What is you name ?", ["%0","I'm not chief in this group, find and ask him about anything"]],
    [ 2, 0, "Do you smoke?", ["None", "Not you business"]],
    [ 3, 0, "Are you married?", ["yes", "not", "Not you business", "How about you"]],
    [ 4, 0, "Whre are you linving?", ["In %4", "And you?"]]
];