/**
	author: Sygsky
	description: none
	returns: nothing

	Becomeldr.sqs by THobson

	 The script allows you to become leader of your group, regardless of your rank or others in your group
 	Simply name your new leader and run the script.

 	[myguy] exec "becomeldr.sqs"
*/

private ["_newleader","_units"];

_newleader = _this select 0;
_units = units (group _newleader);
_units = _units - [_newleader];
_units join grpNull;
_units join _newleader;

