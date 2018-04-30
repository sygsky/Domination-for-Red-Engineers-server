// Replacer of ACE internal module to disable Javelin loding to the rucksack

if (isNil "_this") exitWith { false };
if (_this == "ACE_Javelin") exitWith { false }; // No Javelins in client rucksack

private["_return","_confMag","_confEUM","_confBase","_confTypePDM","_confTypeBase"];

_return = false;
//Discovering if we have a full instances of a multiuse item to pack can be very slow.
//We won't check for that until the user actually tries to pack the item.

_confMag = configFile >> "CfgMagazines";
_confEUM = _confMag >> _this;
_confBase = inheritsFrom _confEUM;
_confTypePDM = _confEUM >> "ACE_PackDummyMag";
_confTypeBase = _confBase >> "ACE_PackDummyMag";

//Each type of EUM must reference a unique type of PDM
_return = isText(_confTypePDM);
if (_return && isText(_confTypeBase)) then
{
    if (getText(_confTypePDM) == getText(_confTypeBase)) then
    {
        //Unless it is in the mag checker, then we will assume this behavior is intentional. This is for ace_sys_magazines.
        if (!(_this in getArray(configFile >> "CfgWeapons" >> getText (_confMag >> getText(_confTypePDM) >> "ACE_MagChecker")>> "magazines"))) then
        {
            _return = false
        }
    }
};
_return