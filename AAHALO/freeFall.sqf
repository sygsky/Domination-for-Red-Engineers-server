_obj_jump = _this select 0;
_obj_jump setVariable["bool_freeFall",true];
deleteVehicle uh60p;

["Player_Track", position player,"ICON","ColorGreen",[0.5,0.5],"",0,"Arrow"] call XfCreateMarkerLocal;

_float_divingAngleMin = 0;
_float_divingAngleMax = 85;
_float_divingAngleApprox = 10;
_float_speedLimitMin = 40;
_float_speedLimitMax = 150;
_float_speedApprox = 2;
_float_fwdRatioMin = 0.1;
_float_fwdRatioMax = 0.8;
_float_turnApprox = 40;
_float_gravity = 10;
_float_nullZone = 0.1;
_float_delay = 0.01;
_float_camDist = 4;
_float_camOSize = 0.5;

_obj_camera = objNull;
_bool_camera = false;
if(count _this > 1)then{_bool_camera = true; _obj_camera = _this select 1;};

_float_gravABreak = 0.25*_float_gravity^2/_float_speedApprox;
_float_angleRange = _float_divingAngleMax - _float_divingAngleMin;
_float_limitRange = _float_speedLimitMax - _float_speedLimitMin;
_float_fwdRatioRange = _float_fwdRatioMax - _float_fwdRatioMin;
_float_camROSize = 0;
_float_mouseX = 0;
_float_mouseY = 0;
_float_mouseDir = 0;
_float_mouseDist = 0;
_float_maxDist = 0;
_float_angle = 80;

if(sqrt((vectorUp _obj_jump select 1)^2 + (vectorUp _obj_jump select 0)^2)!= 0)then {
	_float_angle = -1*atan((vectorUp _obj_jump select 2)/sqrt((vectorUp _obj_jump select 1)^2 + (vectorUp _obj_jump select 0)^2));
};
_float_dir = 90;
if((vectorUp _obj_jump select 0)!= 0)then {
	_float_dir = atan((vectorUp _obj_jump select 1)/(vectorUp _obj_jump  select 0));
};
_float_speedV = -1*(velocity _obj_jump select 2);
_float_speedH = 0;
_float_angleReq = 0;
_float_dirReq = 0;
_float_speedVReq = 0;
_float_angleCh = 0;
_float_dirCh = 0;
_float_speedVCh = 0;

_obj_ps = "#particlesource" createVehicleLocal getPos _obj_jump;
_obj_ps setParticleParams [["\Ca\Data\Cl_water",1,0,1],"","Billboard",1,2,[0,0,4],[0,0,0],0,1,1,0,[0.1,0.6],[[0.8,0.8,0.9,0.5]],[0],0,0,"","",_obj_jump];
_obj_ps setParticleRandom [0.5,[3,3,0],[0,0,0],0,0,[0,0,0,0],0,0];
_obj_ps setDropInterval 0.05;

_f__float_sqApprox = {
	_float_approxFac = _this select 0;
	_float_value = _this select 1;
	_float_return = 2*sqrt(_float_approxFac*abs _float_value);
	
	if(abs(_float_return*_float_delay)> abs _float_value)then {
		_float_return = 0;
	}else{
		if(_float_value<0)then{_float_return = -1*_float_return;};
	};
	_float_return;
};

while{_obj_jump getVariable "bool_freeFall"}do {
	_float_mouseX =(v__float_mousePos select 0)- 0.5;
	_float_mouseY = 0.5 -(v__float_mousePos select 1);
	
	_float_mouseDist = sqrt(_float_mouseX^2 + _float_mouseY^2);
	if(_float_mouseDist < 0)then{_float_mouseDist = 0.001};
	
	if(_float_mouseY > 0)then {
		_float_mouseDir = acos(_float_mouseX/_float_mouseDist);
	}else{
		_float_mouseDir = 360 - acos(_float_mouseX/_float_mouseDist);
	};
	
	_float_angleAmount = (_float_angle - _float_divingAngleMin)/_float_angleRange;
	
	if(abs(_float_mouseX)> abs(_float_mouseY))then {
		_float_maxDist = abs(0.5*_float_mouseDist/_float_mouseX);
	}else{
		_float_maxDist = abs(0.5*_float_mouseDist/_float_mouseY);
	};
	
	_float_angleReq = _float_divingAngleMin + _float_angleRange*(_float_mouseDist - _float_nullZone)/(_float_maxDist - _float_nullZone);
	if(_float_mouseDist < _float_nullZone)then{_float_angleReq = _float_divingAngleMin;};
	_float_dirReq = _float_mouseDir;
	_float_speedVReq = _float_speedLimitMin + _float_angleAmount*_float_limitRange;
	
	_float_angleCh =[_float_divingAngleApprox,_float_angleReq - _float_angle]call _f__float_sqApprox;
	if(abs(_float_dirReq - _float_dir)> 180)then {
		if(_float_dirReq > _float_dir)then {
			_float_dirCh =[_float_turnApprox,_float_dirReq - 360 - _float_dir]call _f__float_sqApprox;
		}else{
			_float_dirCh =[_float_turnApprox,_float_dirReq + 360 - _float_dir]call _f__float_sqApprox;
		};
	}else{
		_float_dirCh =[_float_turnApprox,_float_dirReq - _float_dir]call _f__float_sqApprox;
	};
	
	if((_float_speedVReq - _float_speedV)> _float_gravABreak)then {
		_float_speedVCh = _float_gravity;
	}else{
		_float_speedVCh =[_float_speedApprox,_float_speedVReq - _float_speedV]call _f__float_sqApprox;
	};
	_float_angle = _float_angle + _float_angleCh*_float_delay;
	_float_speedV = _float_speedV + _float_speedVCh*_float_delay;
	_float_dir = _float_dir + _float_dirCh*_float_delay;
	_float_speedH = _float_speedVReq*(_float_fwdRatioMin +(1 - _float_angleAmount)*_float_fwdRatioRange);
	_float_vX = cos _float_dir;
	_float_vY = sin _float_dir;
	_float_vZ = tan _float_angle;
	
	_obj_jump setVelocity [_float_speedH*_float_vX,_float_speedH*_float_vY,-1*_float_speedV];
	_obj_jump setVectorDir [-1*_float_vX*_float_vZ,-1*_float_vY*_float_vZ,-1*( ( -1*_float_vX )^2 + _float_vY^2 )];
	_obj_jump setVectorUp [_float_vX,_float_vY,-1*_float_vZ];

	if(_bool_camera && _obj_jump getVariable "bool_freeFall")then {
		_float_camROSize = (_float_camOSize*cos _float_angle)/2;
		_pos_jump = getPos _obj_jump;

		_obj_camera camSetPos [(_pos_jump select 0)+ _float_vX*_float_camROSize,(_pos_jump select 1)+ _float_vY*_float_camROSize,(_pos_jump select 2)+_float_camDist];
		_obj_camera camSetTarget [(_pos_jump select 0)+ _float_vX*_float_camROSize,(_pos_jump select 1)+ 1,0];
		_obj_camera camCommit 0;
	};
	
	showCinemaBorder false;
	"Player_Track" SetmarkerPosLocal position player;
	"Player_Track" SetmarkerDirLocal (180+getdir player);
	_display = finddisplay 856;
	_map = _display displayctrl 858;
	ctrlMapAnimClear _map;
	_map ctrlMapAnimAdd [0, 0.5, markerPos "Player_Track"];ctrlmapAnimCommit _map;
	ctrlSetText[857,format["%1",round(getPos _obj_jump select 2)]];
	_obj_ps setPos[getPos _obj_jump select 0,getPos _obj_jump select 1,(getPos _obj_jump select 2)-6];
	
	sleep _float_delay;
};
deleteMarkerLocal "Player_Track";
_obj_ps setDropInterval 0;
deleteVehicle _obj_ps;