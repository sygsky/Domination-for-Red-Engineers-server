/*
	author: Sygsky
	description: none
	returns: nothing
*/

private [""];
/*
    parameters used in format params, iвы (1..N):
    01: AI name,
    02: AI pos,
    03: nearest settlement name,
    04: random settlement name
    05: one of settlement name
    06: current target town name or "" if no
    07: player name,
    08: player position
    09: target point
    10: is leader of group
    11: current size of group
    12: initial size of group

    Any line of question 2-d array contains:
    1. Id (offset) of item, start at 0
    2.1. Or array of probabilities of AI answer, summary of all probs MUST be 1.0!
    2.2. Or code to check exit: returns true if remove this item on exit, else returns false. _this is index of answer selected
        if not array, probs are all equals 1/n.
    3. Questions to AI
    4. Texts for answers
    5. Code to execute on goal reached
    6. Code to execute on goal not reached

*/

_mainArray =
[
    [0,1,2,3], // Start array to be shown as dialog sequence
    [ 0, [[1,0.75],[2,0.25]], "What is your name ?", ["%1","I'm not chief in this group, find and ask him about anything"]],
    [ 1, {_this == 2}, "Do you smoke?", ["None", "Yes", "Not your business, sorry", "I'm too young, h-m..."]],
    [ 2, {_this < 2}, "Are you married?", ["Yes", "Not", "Not your business?", "How about you?"]],
    [ 3, {_this > 0}, "Where are you living?", ["In %4", "And you?"]]
];
typeName _this;