//
// Play with some New Year gift
//

if ( isServer ) then
{
	private ["_musicObj", "_pos", "_treeObj"];

	//++++++++++++++++++++++++++++
	// create some New Year sound 
	//++++++++++++++++++++++++++++
	if ( isNil "new_year_radio" ) then
	{
		//_musicObj = getPos FLAG_BASE nearestObject 191919; // for radar tower on base
		_musicObj = FLAG_BASE nearestObject 81124; // for a litle house on base
		if ( !isNull _musicObj) then
		{
            _pos = getPos _musicObj;
            //_pos set [2, (_pos select 2) + 15.0]; // height of the tower
            _pos set [2, (_pos select 2) + 1.5]; // height of table in the house
		};
	}
	else
	{
		_musicObj = new_year_radio;	// let use radio set (while small one)
		_pos = getPos _musicObj;
	};

	if ( isNull _musicObj ) exitWith {};

	createSoundSource ["Music", _pos, [], 0]; // play eternal music for a New Year pleasure
};

if (true) exitWith {};

