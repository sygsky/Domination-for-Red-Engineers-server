// траектория снаряда при наличии сопротивления воздуха
// Use it for tracing shell firing from the artillery muzzle.
// The shell itself found after shoot, must be presaved somewhere, e.g. in the point with Z/X/Y = 10000 m.
// get shell speed vector  [_VX, _VY, _VZ] and weight
_t  = 0;//									t:=0 {c} {время};
_tt = 0.05;//								tt:=0.001 {c} {шаг интегрирования};
_V0 = 662;//								V0:=662{м/c} {начальная скорость снаряда};
_g  = 9.81;//								g:=9.8 {м/сс} {ускорение свободного падения};
_p0 = 0.029;//								p0:=0.029 {кг/ммм} {плотность воздуха};
_k  = 0.05;//								k:=0.05; {геометрический коэффициент сопротивления};
_fg = 55;//									fg:=55{градусы}; f:=fg*Pi/180 {перевод градусов в радианы};
_VX = _V0 * cos(_fg);// 						VX:=V0*cos(f);
_VY = _V0 * sin(_fg);//						VY:=V0*sin(f){составляющие начальной скорости};
_X  = 0;//									X:=0 {м};
_Y  = 0;//									Y:=0 {м} {начальные координаты снаряда};
_m  = 6.3; //								m:=6.3{кг} {масса снаряда};
_ks = _k * _p0 / (2*m);//					ks:=k*p0/(2*m){результирующий коэффициент сопротивления};
for "_i" from 1 to 500000 do {//			For i:=1 to 500000 do begin
	if (_Y < 0) exitWith {};// 						if Y<0 then Goto 5;
		_VX = _VX - (_g - _ks * abs(_VX) * _VX) * _VX * _tt;//		VX:=VX-ks*Abs(VX)*VX*tt;
		_VY = _VY - (_g + _ks * abs(_VY) * _VY) * _tt; //			VY:=VY-(g+ks*Abs(VY)*VY)*tt;
		_X = _X + _VX * _tt;//										X:=X+VX*tt;
		_Y = _Y + _VY * _tt;//										Y:=Y+VY*tt;
		sleep 0.05;//							5:t:=t+tt;
		//										SetPixel(X0+round(X*40*MasX),Y0-round(Y*40*MasY), clBlack);

}; //										end;