/* Arma-2 script
 Это скрипт кружение камеры вокруг выбраного обзекта.
 Очень хорош если вам необходимо покружить камеру.
 Пример:
 _camScript = [_camera, player, [220, 3], [12, 1.8], [225, 110], 12] execVM "cam_panShot.sqf";
 
  Author:
   rьbe
   
  Description:
   camera script. Pan shot (circular flight) around a target. 
   
   This cam script has `critical death` counteractive measures. That is if the target is !alive 
   the cam could evt. jump to a 0-0-0 sea position... thus, if the target has moved too far in 
   one cycle, we replace it with a fake target, ... a game logic at the position before the jump 
   of the now non-existing target.
   
     ^^ this is especially usefull for targets like projectiles/shells and such, which go nil
        the moment they die.
        
     -> if you write your own cam script relying on cam_panShot.sqf you need to get the cameras
        target after every call to cam_panShot.sqf since it may have been replaced with a fake 
        target (see cam_panShotFollow.sqf for an example)
        
        ## _camScript = [_cam, _target, [_d0, _d1], [_h0, _h1, "%1^2"], [_a0, _a1], _t] execVM "cam_panShot.sqf";
        ## sleep _t;
        ##
        ## // the target may have been replaced
        ## _target = camTarget _cam;
        
   - If you pass an object as a target instead of a position, the panshot will add the movement
   vector of the target to its calculated camera-path (the shot will be `attached` to the object.) 
   
   To be sure to get a smooth shot (ignoring any movement of the target), you'll have to
   pass a position instead, though your target could move out of the cam focus now, hehe.
   
   - For panshot with a large angle-range, you may need to tweak your numbers to get the desired
     direction (clock-/counterclockwise)...
     E.g. [320,15] will go all the way counter the clock. Chances are [-40, 15] is what you really want.
   
  Parameter(s):
   _this select 0: camera (object)
   _this select 1: target (object/position OR array [object, offsetMatrix])
   _this select 2: distance [start, end, f] (number OR array of two numbers and an optional time-function-string)
   _this select 3: height [start, end, f, relToTarget] (^^ + integer to toggle to what height relates to, default = 1/ auto relToTarget)
                   - relToTarget (only works with objects as targets/not with positions):
                     0: height of the cam relates always to the ground-level beneath the cam
                     1: auto: height of the cam corrects for a height-drop (if the target is abs. higher than the cam)
                     2: height of the cam always relates to the target (acts like an offset). BEWARE: if the cam is abs. higher
                        than the target, the cam will most likely be pushed to the ground (very ugly!)
                        -> 0: not relative (consider h to ground), 1: auto. adjustment, 2: forced relative (h to target) 
   _this select 4: angle [start, end, f, absolute] (^^ + boolean to toggle absolute/relative angles, default = true/absolute)
                   - you may pass false as the 4th arg. to switch on relative angles (only works if _this select 1 is an object) 
                     - rel. 0 = frontShot, rel. 180 = backShot
                   -> for your comfort, you can also pass [start, end, absolute] and no time-function
   _this select 5: duration in seconds (number)
   
   
    Optional offset-matrix ([x, y, z] OR [x, y, z, memPoint]):
     if you use an offset-matrix (attachTo actual target), camTarget will return a fake target.
     You can find the actual target again with ((camTarget _cam) getVariable "originalCamTarget");
     If there is no fake target, "originalCamTarget" will be objNull.
     
     - you can pass a memory point (string) in the same array as 4th argument, since we attach the
       fake target to the actual target (see attachTo).
     
     -> with this you can easily achieve special shots like: frog shots and the like..
     
     -> in case you make a more elaborate cam script on top of this, you need to implement the
        `attach-fake-object-to-target` strategy at this higher level and simply pass the resulting
        fake-target to this script without any matrix... (see cam_panShotFollowClocked.sqf)
   
    Optional time-function, f (string): 
     they take one number (progress of the cam flight from 0 to 1) and should return a number
     from 0 to 1 aswell. 
    
     time function examples:
      - linear (default): "%1"
      - accelerate: "%1^2"
      - decelerate: "%1^0.5"
      - "" will be ignored/interpreted as "%1"
   
  Examples:
   // create camera
   _cam = "camera" camCreate [0, 0, 0]; 
   _cam cameraEffect ["internal","back"];
   _cam camSetFOV 0.7;
     
   // example one 
   _camScript = [_cam, player, [220, 3], [12, 1.8], [225, 110], 12] execVM "cam_panShot.sqf";
   waitUntil{scriptDone _camScript};  
   
   // example two (will stay a long time circling in the air an then fall onto the player)
   _dir = direction player;
   _camScript = [_cam, player, [440, 3, "%1^2"], [240, 1.8, "%1^5"], [(_dir + 720), _dir, "%1^0.5", false], 12] execVM "cam_panShot.sqf";
   waitUntil{scriptDone _camScript};
   
   // delete camera
   //_cam cameraEffect["terminate", "back"];
   //camDestroy _cam;   
  
*/

private ["_cam", "_target", "_dist", "_height", "_angle", "_pos", "_followTarget", "_heightASL", "_zBuffer", "_offsetMatrix", "_memPoint", "_t0", "_t1", "_fsDist", "_fsDir", "_fsHeight", "_absoluteAngle", "_originalTarget", "_fakeTarget"];

_cam      = _this select 0;
_target   = _this select 1;
_distance = _this select 2;
_height   = _this select 3;
_angle    = _this select 4;
_duration = _this select 5;

if ((typeName _distance) != "ARRAY") then { _distance = [(_this select 2), (_this select 2)]; };
if ((typeName _height) != "ARRAY") then { _height = [(_this select 3), (_this select 3)]; };
if ((typeName _angle) != "ARRAY") then { _angle = [(_this select 4), (_this select 4)]; };

_pos = _target;
_followTarget = true;
_heightASL = 1;
_zBuffer = 0.998;
_offsetMatrix = [];
_memPoint = "";

if ((typeName _target) == "ARRAY") then
{
   if ((typeName (_target select 1)) == "ARRAY") then
   {
      // we have an object and an offset-matrix
      _copy = + _target;
      _target = _copy select 0;
      _pos = position _target;
      // do we have a mempoint?
      if ((count (_copy select 1)) > 3) then
      {
         _offsetMatrix = [((_copy select 1) select 0), ((_copy select 1) select 1), ((_copy select 1) select 2)];
         _memPoint = ((_copy select 1) select 3);
      } else {
         _offsetMatrix = _copy select 1;
      };
   } else {
     // we have a position!
     _heightASL = 0;
     _followTarget = false;
   };
} else {
   _pos = position _target;
};


_t0 = time;
_t1 = 0;

_fsDist = "%1";
_fsHeight = "%1";
_fsDir = "%1";

_absoluteAngle = true;
_originalTarget = objNull;
_fakeTarget = [];

if ((count _distance) > 2) then 
{ 
   if ((_distance select 2) != "") then
   {
      _fsDist = (_distance select 2); 
   };
};
if ((count _height) > 2) then 
{ 
   if ((_height select 2) != "") then
   {
      _fsHeight = (_height select 2); 
   };
};
if (_followTarget && ((count _height) > 3)) then
{
   _heightASL = _height select 3;
};
if ((count _angle) > 2) then 
{ 
   switch (typeName (_angle select 2)) do
   {
      case "BOOL": {
         _absoluteAngle = _angle select 2;
      };
      case "STRING": {
         if ((_angle select 2) != "") then
         {
            _fsDir = (_angle select 2);
         };
      };
   };
};
if ((count _angle) > 3) then
{
   _absoluteAngle = _angle select 3;
};


// if we use an offset-matrix we create a fake target and attach it
// to our real target.
// this is not only easier to programm, but it ensures, that we can
// rely on the call camTarget
if ((count _offsetMatrix) > 0) then
{
   _fakeTarget set [0, (createGroup sideLogic)];
   _fakeTarget set [1, ((_fakeTarget select 0) createUnit ["Logic", _pos, [], 0, "NONE"])];
   (_fakeTarget select 1) setVariable ["exitCamScript", false];
   (_fakeTarget select 1) setVariable ["originalCamTarget", _target];
   (_fakeTarget select 1) setDir _dir;
   if (_memPoint != "") then
   {
      (_fakeTarget select 1) attachTo [_target, _offsetMatrix, _memPoint];
   } else {
      (_fakeTarget select 1) attachTo [_target, _offsetMatrix];
   };
   _originalTarget = _target;
   _target = (_fakeTarget select 1);
};

while {_t1 < _duration} do
{
   _t1 = (time - _t0);
   _t = _t1 / _duration;
   
   _tDist = call compile format[_fsDist, _t];
   _tDir = call compile format[_fsDir, _t];
   _tHeight = call compile format[_fsHeight, _t];
   
   _dist = (_distance select 0) + (((_distance select 1) - (_distance select 0)) * _tDist);
   _dir = ((_angle select 0) + (((_angle select 1) - (_angle select 0)) * _tDir));
   
   if (!_absoluteAngle && _followTarget) then
   {
      _dir = (direction _target) - _dir;
   };
   
   _zBase = 0;
   
   // we may need to create a fake target to prevent 0-0-0 sea shots...
   // our check should be fair enough (noone is that fast, checking only
   // the x-axis should work in practically all cases too..)
   //  if the target is on sideLogic, we don't do anything (logic's don't suddenly die, 
   //  and this is probably already a fake target anyway!)
   if (((side _target) != sideLogic) && ((abs ((_pos select 0) - ((position _target) select 0))) > 200)) then
   {
      _fakeTarget set [0, (createGroup sideLogic)];
      _fakeTarget set [1, ((_fakeTarget select 0) createUnit ["Logic", _pos, [], 0, "NONE"])];
      (_fakeTarget select 1) setVariable ["exitCamScript", false];
      (_fakeTarget select 1) setVariable ["originalCamTarget", _target];
      (_fakeTarget select 1) setDir (_dir + 5);
      _originalTarget = _target;
      _target = (_fakeTarget select 1);
   };
   
   if (_followTarget) then
   {
      _pos = position _target;
      _zBase = _pos select 2;
      if ((count _offsetMatrix) > 2) then
      {
         _zBase = _zBase - (_offsetMatrix select 2);
      };
   };
   _x = (_pos select 0) + ((sin _dir) * _dist);
   _y = (_pos select 1) + ((cos _dir) * _dist);
   _tgtZOffset = (_height select 0) + (((_height select 1) - (_height select 0)) * _tHeight);
   _z = _zBase + _tgtZOffset; 
   
   // # default: cam height is height above ground level # //
   // we have to blindly commit anyway, so we can get a probe with getPosASL
   // so we can check if we need to correct the cam's height with a second 
   // call to camCommit...
   _cam camSetPos [_x, _y, _z];
   _cam camSetTarget _target;
   _cam camCommit 0;
   
   // # forced relative height to target, no matter what... # //
   // h is relative to the target and not to the ground-level below the cam!
   if (_heightASL == 2) then
   {
      _camZ = (getPosASL _cam) select 2;
      _tgtZ = (getPosASL _target) select 2;
      _errZ = _z + (_tgtZOffset - (_camZ - _tgtZ));
      _cam camSetPos [_x, _y, _errZ];
      _cam camSetTarget _target;
      _cam camCommit 0;
   };
   // # auto: we try to set the height rel. to the target, unless we would end up in the ground... # //
   // target needs to be higher than the cam if set to auto.
   // we have to slowly introduce the correction, not to produce a skip... (thats what our _zBuffer is for)
   if (_heightASL == 1) then
   { 
      _camZ = (getPosASL _cam) select 2;
      _tgtZ = (getPosASL _target) select 2;
      if ((_tgtZ + _tgtZOffset) > _camZ) then
      {
         _zBuffer = _zBuffer^0.875;
      } else {
         _zBuffer = _zBuffer^1.125;
      };
      _errZ = _z + (_zBuffer * (_tgtZOffset - (_camZ - _tgtZ)));
      // cam in the ground correction (forced minimum height above ground)
      if (_errZ < 0.3) then { _errZ = 0.3 + (0.3 * _zBuffer); };
      _cam camSetPos [_x, _y, _errZ];
      _cam camSetTarget _target;
      _cam camCommit 0;
   };
   
   sleep 0.001;   
};

// we may need to clean up our fakeTarget, though we shouldn't 
// delete it immediately provoking another ugly jump to 0-0-0 
// we wanna prevent in the first place.. haha 
//  it doesn't hurry anyway so...
if ((count _fakeTarget) > 0) then
{
   [_fakeTarget, _cam] spawn {
      _fakeVeh = (_this select 0) select 1;
      _fakeGrp = (_this select 0) select 0;
      _cam = _this select 1;
      
      while {!(isNull _fakeVeh)} do
      {
         // we can safely delete the fake target, once it isn't  
         // the target of the cam anymore.
         if ((camTarget _cam) != _fakeVeh) exitWith
         {
            sleep 2;
            deleteVehicle _fakeVeh;
            deleteGroup _fakeGrp;
         };
         sleep 3;
      };
   };
};