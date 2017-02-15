/*+++ Sygsky: attack base function
 * 
 * Helps sabotage group to siege the base
 *
 */

private [ "_grp_array", "_paragrp", "_attack_pos" ];

_grp_array this select 0;
_paragrp this select 1;
_attack_pos this select 2;

while ( ({alive _x} count units _paragrp ) > 0) do // while at least one man in group is still alive
{
	sleep 0.113;
//	_grp_array = [_paragrp, [position _leader select 0, position _leader select 1, 0], 0,[d_base_array select 0,d_base_array select 1,d_base_array select 2,0],[],-1,1,[],300,1];
	_grp_array execVM "x_scripts\x_groupsm.sqf";
	sleep 0.112;
	[_paragrp, _attack_pos] execVM "x_scripts\x_sabotage.sqf";
}
if ( true } exitWith {};