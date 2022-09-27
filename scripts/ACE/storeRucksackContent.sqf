/*
	scripts\ACE\storeRucksackContent.sqf
	author: Sygsky
	description: stores rucksack content in text format into the variable storeRucksackContent and send it to the server
	returns: nothing
*/
private ["_str"];
_str = player call SYG_getPlayerRucksackAsStr;
if (SYG_playerRucksackContent != _str) then { // As content was changed, send new one to the server to store over there without informative sound
    ["d_ad_wp", name player, _str] call XSendNetStartScriptServer; // reduced bunch of equipment (backpack_type+backpack_content+some_props)
	SYG_playerRucksackContent = _str; // store new content
	hint localize format["+++ storeRucksackContent.sqf: rucksack content = %1", _str];
};