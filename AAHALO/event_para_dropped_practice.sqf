/*
	AAHALO\event_para_dropped_practice.sqf

	author: Sygsky
	description: Event handler to check if player landed on base/circle/etc at practice jump
			Variants are (see AAHALO\event_para_dropped.sqf):
			1. Out of base territory
			2. On base territory
			3. On one of base circles
			4. On "AISPAWN" circle! Main target hit!

            Array passed to the next script: [vehicle, role, unit, false(not count score)]

	returns: nothing
*/
[_this select 0, _this select 1, _this select 2, false] execVM "AAHALO\event_para_dropped.sqf";
