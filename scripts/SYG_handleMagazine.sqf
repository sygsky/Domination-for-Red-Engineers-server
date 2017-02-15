/*
 * Function to hanle with bomb at man inventory (among ACE environment and ammo names)
 * Params: 
 *         man - unit to handle with (needed)
 *         bombName - designated bomb name (needed). Used to replace first found replacer. Set to "" to only remove all named mags from inventory
 *         magNames2Replace (optional): ["mag1", "mag2" ...]" - named magazines for replacement. If not present, bomb will be tried to add, not to replace designated magazines
 * 		   addMode (optional): "ALL" - if present, bomb will replace ALL designated magazines in the list found in inventory of each unit or add as many bomb as possible
 *                   if no replaceing replacing names are designated
 *
 *			You can call as follow:  
 *          [_unit, ""] call fnc  
 *           or 	
 *          [_unit, "", []] call fnc;
 *
 * Returns: result of operation, number of bomb added/replaced, (+# if bomb[s] added/replaced, 0 - not changed, -#  if bomb[s] removed)
 * Example: 
 * [_unit, "ACE_Pipebomb"] execVM SYG_handleMagazine; // simply try to add 1 magazine if space present
 * [_unit, "ACE_Pipebomb",[], "ALL"] execVM SYG_handleMagazine; // try to add as many as possible magazines into empty space
 * [_unit, "ACE_Pipebomb", ["ACE_TimeBomb","ACE_Mine","ACE_Claymore_M"]] execVM SYG_handleMagazine; // replaces first found designated magazine from list with bombName
 * [_unit, "", ["ACE_TimeBomb","ACE_Mine","ACE_Claymore_M"]] execVM SYG_handleMagazine; // removes first found magazine designated in the list 
 * [_unit, "", ["ACE_TimeBomb","ACE_Mine","ACE_Claymore_M"], "ALL"] execVM SYG_handleMagazine; // tries to remove all designated in list magazines from unit inventory
 * [_unit, "ACE_Pipebomb", ["ACE_TimeBomb","ACE_Mine","ACE_Claymore_M"], "ALL"] execVM SYG_handleMagazine; // replaces all found designated magazine from list with the bombName
 *
 * Note: ACE western sabotage on base units has follow magazines: ["ACE_TimeBomb","ACE_Mine","ACE_Claymore_M"]. Use this list to handle with unit ammunition.
 */
	
private ["_unit", "_bombName", "_magz", "_put", "_cnt", "_loopCnt", "_replaceArr", "_i", "_ret", "_cont", "_mag"];	

_unit     = _this select 0;
_bombName = _this select 1;

_replaceArr  = [];
if ( count _this > 2 ) then
{
	_replaceArr  = _this select 2;
};
if ( _bombName in _replaceArr ) exitWith{  hint localize format["SYG_handleMagazine.sqf: bomb name %1 is in replace names", _bombName]; 0 };

if ( (_bombName == "") && ((count _replaceArr) == 0) ) exitWith { 0 }; // Nothing to replace, nothing to add

_replaceAll = false; // replace all designated magazines (true) or only first found (false - default)
if ( count _this > 3 ) then
{
	_replaceAll  = ((_this select 3) == "ALL");
};
 
_ret = 0;
_cont = true;
//
// Check if user simply wants to add bomb[s]
//
if ( (count _replaceArr) == 0 ) then // Simply add 1 or more bomb[s] to inventory, no replacement
{ 
	while { _cont } 	 do
	{
		_magz = magazines _unit;
		_cnt = count _magz; // number of magazines unit has in inventory before attempt to add one more
		_unit addMagazine _bombName; // add magazine now
		_magz = magazines _unit;
		if ( ((count _magz) > _cnt) && (_ret < 3 ))  then // was added sucessfully
		{
			_ret = _ret + 1;
			_cont = _replaceAll; // try to add more or exit after 3rd successfull adding
/*
			player globalChat format["magz cnt = %1, replace cnt = %2", count (magazines _unit), _ret ];
			sleep 0.1;
*/			
		}
		else // not added by any cause (e.g. full ammo etc)
		{
			if ( _ret == 0 ) then  { _ret = -1 }; // mark script exit action
			_cont = false; // nothing to do more as no place for magazines
		};
	};
};

if ( _ret > 0  ) exitWith { _ret }; // mission is completed
if (_ret == -1 ) exitWith { 0 }; // exit not adding any bomb

//
// Try to replace some item[s] from inventory
//
_i = 0;
_magz = magazines _unit;
_loopCnt = count _magz; // original magazines count
_cont = true;
while { _cont && (_i < _loopCnt) } do // step along all magazines unit has in inventory
{
	_mag = _magz select _i;
	if ( _mag in _replaceArr ) then // we found item to try to remove
	{
		//_cnt = count magazines _unit;
		_unit removeMagazine _mag; // try to remove in any case
		if ( (count magazines _unit)  != _loopCnt ) then // magazine removed sucessfully :o!
		{
			_ret = _ret - 1; // decrease remove counter
			if ( _bombName != "" ) then // order to replace magazine with bombName
			{
				_cont = _replaceAll; // Exit loop if replace only first designated. Continue if replace all designated magazines
				// magazine is removed, now try to replace it with designated one
				_unit addMagazine _bombName;
				if ( (count magazines _unit) == _loopCnt ) then // bomb was added to replace previously removed item
				{
					_ret = _ret + 2; // function is to replace, not to remove, so add 2 to bump replacement counter by +1
				}
				else
				{
					_cont = false; // not added
					_ret = 1;
				};
			};
		} else // error to remove;
		{
			_cont = false;
			_ret = -1;
		};
	};
	_i = _i + 1;
};

if (true) exitWith { _ret }; // return number of magazines removed/replaced

