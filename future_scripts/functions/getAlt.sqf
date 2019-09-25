/*---------------------------------------------------------------
getAlt function by Raptorsaurus (version 1.1)

v. 1.1, 11/25/05:  added ASL of terrain at object location and "over water"
	detection.  If the last array element is true the vehicle is over
	water, if it is false it is over ground.

Returns several types of altitude information for an object (ASL, AGL,
Terrain ASL at object location and over/in water status).

For ASL calculations this version uses an "emptydetector" for sea level
reference instead of a "gamelogic" out at sea and trigonometry as in the
original version.  For AGL this version gives two values, one based on
the "getPos obj select 2" command and one based on distance from a
"gamelogic" ground level reference.  Thus this altitude will also work
with certain addon aircraft that return strange values when using 
"getPos obj select 2" (some BAS aircraft, for instance, will have
"getPos obj select 2" values of zero that never change regarless of their
actual altitude).  Also returned is the above sea level altitude of the terrain
at the vehicle's location and a boolean indicating if the vehicle is over water.

Pass the vehicle or object name to the function.

Example:

_Alt = [_Plane] call getAlt
_ASL = _Alt select 0
_AGL1 = _Alt select 1 (standard altitude - using "getPos obj select 2")
_AGL2 = _Alt select 2 (special altitude - using "obj distance groundref") 
_tASL = _Alt select 3 (the terrain ASL at the ojects location)
_water = _Alt select 4 

Note: The two AGL values are different even for standard
BIS vehicles because the zero point of the vehicle model is not always
at ground level.  On some vehicles there may be as much as a 3.5 m difference
between AGL1 and AGL2

Initialize this function by putting this in your init.sqs:
getAlt = preprocessFile "getAlt.sqf"
---------------------------------------------------------------*/

// declare private variables
private ["_obj","_SLref", "_GLref","_ASL","_AGL1", "_AGL2", "_tASL", "_tide", "_water"];

_obj = _this select 0;
_water = false;

// Put Sea level reference and ground level reference, calculate tidal offset

_SLref = "emptyDetector" camCreate [0,0,0];
_GLref = "logic" camCreate [0,0,0];
_SLref setPos [0,0];
_GLref setPos [0,0,0];
_tide = _GLref distance _SLref;

_SLref setPos [getPos _obj select 0, getPos _obj select 1];
_GLref setPos [getPos _obj select 0, getPos _obj select 1, 0];

//Get ASL, AGL1, AGL2, terrain ASL and over water status

_ASL = _obj distance _SLref;
_AGL1 = getPos _obj select 2;
_AGL2 = _obj distance _GLref;
_tASL = _GLref distance _SLref;
if (abs (_tASL - _tide) < .01) then {_water = true};

deleteVehicle _SLref;
deleteVehicle _GLref;

[_ASL,_AGL1, _AGL2, _tASL, _water]