/*
	scripts\ACE\storeRucksackContent.sqf
	author: Sygsky
	description: stores rucksack content in text format into the variable storeRucksackContent and send it to the server
	returns: nothing
*/
private ["_str"];
_str = player call SYG_getPlayerEquipAsStr;
if (SYG_playerRucksackContent != _str) then { // As content was changed, send new one to the server to store over there without informative sound
    ["d_ad_wp", name player, _str] call XSendNetStartScriptServer; // whole bunch of equipment (weapons+magazines+backpack_content)
	SYG_playerRucksackContent = _str; // store new content
	hint localize format["+++ storeRucksackContent.sqf: player equip = %1", _str];
};