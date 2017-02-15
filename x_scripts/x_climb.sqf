// by Xeno
private ["_objId", "_obj", "_pos_p", "_pos_o", "_angle", "_dist", "_x", "_y", "_x1", "_y1"];
_objId = parseNumber (d_obstacle);
sleep 0.01;
_obj = position player nearestObject _objId;
_pos_p = position player;
_pos_o = position _obj;
_angle =((_pos_p select 0)-(_pos_o select 0))atan2((_pos_p select 1)-(_pos_o select 1));
_dist = _pos_p distance _pos_o;_x = _pos_o select 0;_y = _pos_o select 1;
_x1 = _x - (_dist * sin _angle);
_y1 = _y - (_dist * cos _angle);
sleep 1.21;
if (alive player) then {player setPos [_x1,_y1,0]};

if (true) exitWith {};
