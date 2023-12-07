//SYG_utilsGeom.sqf

#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))

#define X_POS 0
#define Y_POS 1
#define Z_POS 2

#define x(a) ((a)select 0)
#define y(a) ((a)select 1)
#define z(a) (if((count (a))>2)then{a select 2}else{0})

/**
 * Calculates in 2-D dimension, new vector returned
 * call:
 *      pnt3 = [pnt1,pnt2] call SYG_vectorAdd;
 */
SYG_vectorAdd = {
    private [ "_pnt1", "_pnt2" ];
	_pnt1 = _this select 0;
	_pnt2 = _this select 1;
	[x(_pnt1) + x(_pnt2), y(_pnt1) + y(_pnt2), 0]
};

/**
 * Calculates in 3-D dimension, new vector returned
 * call:
 *      pnt3 = [pnt1,pnt2] call SYG_vectorAdd3D;
 */
SYG_vectorAdd3D = {
    private [ "_pnt1", "_pnt2" ];
	_pnt1 = _this select 0;
	_pnt2 = _this select 1;
	[x(_pnt1) + x(_pnt2), y(_pnt1) + y(_pnt2), z(_pnt1) + z(_pnt2)]
};


/**
 * Calculates in 2-D dimension, new vector returned
 * =====================================================
 * call:
 *      pnt3 = [pnt1,pnt2] call SYG_vectorSub;
 */
SYG_vectorSub = {
    private [ "_pnt1", "_pnt2" ];
	_pnt1 = _this select 0;
	_pnt2 = _this select 1;
	[x(_pnt1) - x(_pnt2), y(_pnt1) - y(_pnt2), 0]
};

/**
 * Calculates in 3-D dimension, new vector returned
 * =====================================================
 * call:
 *      pnt3 = [pnt1,pnt2] call SYG_vectorSub; // Creates vector pnt2 -> pnt1
 */
SYG_vectorSub3D = {
    private [ "_pnt1", "_pnt2" ];
	_pnt1 = _this select 0;
	_pnt2 = _this select 1;
	[x(_pnt1) - x(_pnt2), y(_pnt1) - y(_pnt2), z(_pnt1) - z(_pnt2)]
};

/**
 * =======================================================
 * Detect distance of point to vector on the predefined plane of X,Y coordinates (2-D)
 * call:
 *      _pos = [p0,p1,p2] call SYG_pointOnVector;
 * where:
 *      p0 and p1 are point to form the vector _v = _p1-_p0
 *      p2 is tested point
 * returns:
 *       -dist if point p2 is on left side of vector [p0,p1]
 *       +dist if point p3 is on right side of vector [p0,p1]
 *        0 if point is on the vector [p0,p1]
 */
SYG_distPoint2Vector1 = {
	private ["_p0","_p1","_p2","_a","_b","_cross","_len"];
	_p0 = _this select 0;
	_p1 = _this select 1;
	_p2 = _this select 2;
//    _a = (argp(_p0,Y_POS) - argp(_p1,Y_POS)) * argp(_p2,X_POS) +
//         (argp(_p1,X_POS) - argp(_p0,X_POS)) * argp(_p2,Y_POS) +
//         argp(_p0,X_POS) * argp(_p1,Y_POS) - argp(_p1,X_POS)*argp(_p0,Y_POS);
//    _b = sqrt( [_p0,_p1] call SYG_distance2D);
//    _a / _b
	_a = [_p1,_p0] call SYG_vectorSub;
	_b = [_p2,_p0] call SYG_vectorSub;
	_cross = argp(_a,X_POS)*argp(_b,Y_POS) - argp(_a,Y_POS)*argp(_b,X_POS);
	_len = [_p0,_p1] call SYG_distance2D;
	//player groupChat format["a %1, b %2, cross %3, len %4, dist %5",_a,_b,_cross,_len, _cross / _len];
	_cross / _len
};

/**
 * =======================================================
 * Detect distance of point to vector on the predefined plane of X,Y coordinates (2-D)
 * call:
 *      _pos = [p1,p2,p3] call SYG_pointOnVector;
 * where:
 *      p1 and p2 are point to form the vector
 *      p3 is tested point
 * returns:
 *       distance from point ot vector
 *        0 if point is on the vector [p1,p2]
 */
SYG_distPoint2Vector = {
    abs (_this call SYG_distPoint2Vector1)
};

/**
 * Calculates dot product between 2 vectors [_p1,_p2] and [_p1,_p3] defined by 3 points:
 * _dot = [_p1,_p2,_p3] call SYG_dotProduct;
 * Where: _p1 is start point for vectors [_p1,_p2] and [_p1,_p3]
 *
 */
SYG_3pntDotProduct={
    private ["_v1", "_v2"];
    _v1 = [_this select 1,_this select 0] call SYG_vectorSub;
    _v2 = [_this select 2,_this select 0] call SYG_vectorSub;
    argp(_v1,X_POS) * argp(_v2,X_POS) +  argp(_v1,Y_POS) * argp(_v2,Y_POS)
};

/**
 * Calculates dot product between 2 vectors in 2D dimention
 * _dot = [_v1,_v2] call SYG_dotProduct;
 * Where: _p1 is start point for vectors [_p1,_p2] and [_p1,_p3]
 *
 */
SYG_vectorDotProduct={
    private ["_v1", "_v2"];
    _v1 = _this select 0;
    _v2 = _this select 1;
    argp(_v1,X_POS) * argp(_v2,X_POS) +  argp(_v1,Y_POS) * argp(_v2,Y_POS)
};

/**
 *  * Calculate in 2D, new vector returned
 * _pnt = [_pnt , coeff] call SYG_multiplyVector;
 */
SYG_multiplyVector = {
    private ["_pnt", "_coeff"];
    _pnt = _this select 0;
    _coeff = _this select 1;
    [x(_pnt) * _coeff, y(_pnt) * _coeff,  0]
};
/**
 * Calculate in 3D, new vector returned
 * _pnt = [_pnt , coeff] call SYG_multiplyVector3D;
 */
SYG_multiplyVector3D = {
    private ["_pnt", "_coeff"];
    _pnt = _this select 0;
    _coeff = _this select 1;
    [x(_pnt) * _coeff, y(_pnt) * _coeff,  z(_pnt) * _coeff]
};

/**
    https://nic-gamedev.blogspot.ru/2011/11/using-vector-mathematics-and-bit-of_08.html

    Vector3 GetClosestPointOnLineSegment(const Vector3& LinePointStart, const Vector3& LinePointEnd,
                                         const Vector3& testPoint)
    {
        const Vector3 LineDiffVect = LinePointEnd - LinePointStart;
        const float lineSegSqrLength = LineDiffVect.LengthSqr();

        const Vector3 LineToPointVect = testPoint - LinePointStart;
        const float dotProduct = LineDiffVect.dot(LineToPointVect);

        const float percAlongLine = dotProduct / lineSegSqrLength;

        if (  percAlongLine  < 0.0f ||  percAlongLine  > 1.0f )
        {
            // Point isn't within the line segment
            return Vector3::ZERO;
        }

        return ( LinePointStart + ( percAlongLine * ( LinePointEnd - LinePointStart ));
    }
 */
SYG_closestPointOnLineSegment = {
    private [ "_v1", "_v2","_dot","_sqr","_percAlongLine" ];
    _v1 = [_this select 1,_this select 0] call SYG_vectorSub; // main vector (p0,p1)
    _v2 = [_this select 2,_this select 0] call SYG_vectorSub; // vector from point (p0,p2)
    _dot = [_v1, _v2] call SYG_vectorDotProduct;
    _sqr = _v1 distance [0,0,0];
    _sqr = _sqr * _sqr;
    _percAlongLine = _dot / _sqr;
    // _str = format["p1 %6, p2 %7, p3 %8; v1 %4, v2 %5; dot %1, sqr %2, perc %3 ",_dot, _sqr, _percAlongLine, _v1, _v2, _this select 0,_this select 1,_this select 2];
    // player groupChat _str;
    // hint localize _str;
    if ( _percAlongLine <= 0 ) exitWith {_this select 0};
    if ( _percAlongLine >= 1 ) exitWith {_this select 1};
    [_this select 0, [_v1, _percAlongLine ] call SYG_multiplyVector] call SYG_vectorAdd
};
/**
 * =======================================================
 * Detect relation of point to vector on the predefined plane of X,Y coordinates
 * call:
 *      _pos = [p1,p2,p3] call SYG_pointOnVector;
 * where:
 *      p1 and p2 are point to form the vector
 *      p3 is tested point
 * returns:
 *       -1 if point p3 is on left side of vector [p1,p2] (for Sahrani S-W)
 *       +1 if point p3 is on right side of vector [p1,p2] (for Sahrani N-E)
 *        0 if point is on the vector [p1,p2]
 */
SYG_pointToVectorRel = {
	private ["_r"];
	_r = _this call SYG_distPoint2Vector1;
	if ( _r > 0.0 ) then {-1} else {if (_r < 0.0) then {1}else{0}}
};

/**
 * =======================================================
 * call: _rotpnt = [_center_pnt, _pnt2rot, _angle] call SYG_rotatePoint;
 *  Z coordinate is not changed anyway
    x' = x * cos(theta) -  y * sin(theta);
    y' = x * sin(theta) +  y * cos(theta);
	
	Note: Z coordinate of rotated point is set to 0
 */
SYG_rotatePointAroundPoint = {
	private ["_pnt1","_pnt2","_x","_y","_dx","_dy","_ang","_sin","_cos"];
	_pnt1 = _this select 0; // zero point
	_pnt2 = _this select 1; // rotated point
	_x = argp(_pnt1,0);
	_y = argp(_pnt1,1);
	_dx = argp(_pnt2,0)- _x;
	_dy = argp(_pnt2,1)- _y;
	_ang  = _this select 2;
	_sin = sin _ang;
	_cos = cos _ang;
	[ (_dx * _cos - _dy * _sin) + _x, (_dx * _sin + _dy * _cos) + _y, 0]
	//player groupChat format["SYG_rotatePointAroundPoint: pnt %1 rot by %2 to %3", _pnt, _ang, _pnt2];
};

// Position are in 3D format [X,Y,Z]
// adds difference point [dx,dy,dz] to the base point [X,Y,Z]
// _newPos = [_basePos, _posOff] call SYG_addDiff2Pos;
SYG_addDiff2Pos = {
    private [ "_pos", "_offs", "_newPos", "_x" ];
    _pos =  _this select 0;
    _offs = _this select 1;
    _newPos = [];
    {
        _newPos set [_x, argp(_pos,_x) + argp(_offs, _x)];
    } forEach [0,1,2];
    _newPos
};

//
// _newpos = [_basePos, _diffPos, _angle] call SYG_calcPosRotation;
// where _diffPos is vector of difference between _basePos and second point
//
SYG_calcPosRotation = {
    [ _this select 0, ([[0,0,0], _this select 1, -(_this select 2)] call SYG_rotatePointAroundPoint)] call SYG_addDiff2Pos;
};

//
// Calculates real position and direction of thing according to object (house)
// _posRelArr = [_house, _relArr] call SYG_calcRelArr;
//
// Where: _relArr = [[_dx,_dy,_dz], _ang]; _posRelArr = [[_x,_y,_z], _dir];
//
SYG_calcRelArr = {
    private ["_house","_houseDir","_thingObjArr","_thingRelPos","_thingAng","_thingPos","_thingDir"];
    _house = _this select 0;
    _houseDir = getDir _house;
    _thingObjArr = _this select 1;
    _thingRelPos = argp(_thingObjArr,0);
    _thingAng = argp(_thingObjArr,1);
    _thingPos = [_house modelToWorld [0,0,0], ([[0,0,0], _thingRelPos, -_houseDir] call SYG_rotatePointAroundPoint)] call SYG_addDiff2Pos;
    _thingDir = (_thingAng + _houseDir + 360) mod 360;
    [_thingPos, _thingDir]
};

/**
 * Creates array with info to store object position according to house
 *
 * call: _rel_arr = [_house, _unit] call SYG_worldObjectToModel;
 * where _rel_arr = [[_dx,_dy,_dz], _angle, _house_center_world_pos]; // _angle is object angle in house model space
 */
SYG_worldObjectToModel = {
    private ["_house","_unit","_pos"];
    //player groupChat format["SYG_worldObjectToModel: %1", _this];
    _house = _this select 0;
    _unit  = _this select 1;
    _pos   = _unit modelToWorld [0,0,0];
    [ _house worldToModel _pos, ((getDir _unit) - (getDir _house) + 360) mod 360, _house modelToWorld [0,0,0] ]
};

/**
 * Calculates point from house and relative offset to it
 *
 * call: _rel_arr = [_house, _off_arr] call SYG_modelObjectToWorld;
 * where _rel_arr = [_dx,_dy,_dz]
 */
SYG_modelObjectToWorld = {
    (_this select 0) modelToWorld (_this select 1)
};

/**
 * =======================================
 * call:
 *     _bool = [_p, _circle_center, _circle_radius] call SYG_pointInCircle;
 * Returns: TRUE if point is in circle or on bound, FALSE if totally out of circle
 */
SYG_pointInCircle = {
	( [_this select 0, _this select 1] call SYG_distance2D) <= (_this select 2)
//	( (_this select 0)  distance (_this select 1) ) <= (_this select 2)
};

// =======================================
// Ellipse in format [[center x, center y<, center z>], a<, b<,angle>>], with or without rotation
// call : _in_ellipse = [_pnt, _elli] call SYG_pointInEllipse;
// (x-x0)^2/a^2+(y-y0)^2/b^2 <= 1
SYG_pointInEllipse = { 
	private ["_pnt","_elli","_elli_center","_dx","_dy","_a","_b","_ret"];
	_elli = _this select 1;
	_ret = false;
	if ( count _elli == 2 ) exitWith { // it is circle
		//player groupChat "SYG_pointInEllipse: call SYG_pointInCircle";
		_this call SYG_pointInCircle
	};
    _pnt = (_this select 0) call SYG_getPos; // Point
    //player groupChat format["SYG_pointInEllipse: elli %1, pnt %2, rot %3", _elli,_pnt, argp(_elli,3)];
    _elli_center = _elli select 0;
    if ( count _elli > 3) then { // ellipse may be rotated
        if ( typeName (_elli select 3) == "SCALAR" ) then  { // Ellipse is rotated
			if ( _elli select 3 != 0 ) then  { // Ellipse is rotated, rotete point around ellipse center too
				_pnt = [ _elli_center, _pnt, _elli select 3] call SYG_rotatePointAroundPoint;
			};
        };
    };
    _dx = argp(_elli_center,0)- argp(_pnt,0);
    _dy = argp(_elli_center,1)- argp(_pnt,1);
    _a = argp(_elli,1);
    _b = argp(_elli,2);
    _ret = (((_dx*_dx)/(_a*_a)+(_dy*_dy)/(_b*_b))<=1.0);
	//player groupChat format["SYG_pointInEllipse = %1", _ret];
	_ret
};

// =======================================
//
// call : _in_rect = [_pnt, _rect_descr] call SYG_pointInRect;
// _rect_descr format: [[center x, center y<, center z>], a, b<, angle>], with or without rotation,
// Note: angle in Arma counted in CLOCKWISE direction!!!
// returns: true if point is in rect or false if out of rect
//
SYG_pointInRect = {
	private ["_pnt", "_rect","_rpnt"];
	_pnt  = (_this select 0) call SYG_getPos; // Point/object/ect to test be  in rect
	_rect = _this select 1;	// Rectangle description
	_rpnt = _rect select 0; // Rectangle central point
	//player groupChat format["SYG_pointInRect: rect %1, pnt %2, rot %3", _rect,_pnt, argp(_rect,3)];
	if ( count _rect > 3 ) then {// may be rotated
		if ( argp(_rect,3) != 0) then {
			_pnt = [_rpnt,_pnt,argp(_rect,3)] call SYG_rotatePointAroundPoint;
		};
	};
	//player groupChat format["SYG_pointInRect: rect %1, pnt %2", _rect,_pnt];
	((abs(argp(_pnt,0)-argp(_rpnt,0)) <= argp(_rect,1)) && (abs(argp(_pnt,1)-argp(_rpnt,1)) <= argp(_rect,2)))
};

/**
 * call: [_pnt1, _pnt2, dist] call SYG_elongate2;
 * returns end point of 2D vector [_pnt1, _pnt2] elongated with dist from _pnt2
 * _pnt1: initial point of vector, may be some object/marker etc
 * _pnt2: ending point of vector, may be some object/marker etc
 * dist in meters, may be negative
 */
SYG_elongate2 = {
	private ["_pnt1","_pnt2","_elongate","_dx","_dy"];
	_pnt1 = (_this select 0) call SYG_getPos;
	_pnt1 set [2, 0];
	_pnt2 = (_this select 1) call SYG_getPos;
	_pnt2 set [2, 0];
	_elongate = (_this select 2)/(_pnt1 distance _pnt2);

	_dx = x(_pnt2) - x(_pnt1); // (_pnt2 select 0) - (_pnt1 select 0);
	_dy = y(_pnt2) - y(_pnt1); //(_pnt2 select 1) - (_pnt1 select 1);

	[x(_pnt2) + _elongate *_dx, y(_pnt2) + _elongate * _dy, 0] // new point coordinates
};

/**
 * call: [_pnt1, _pnt2, dist] call SYG_elongate2Z;
 * returns end point of 3D vector [_pnt1, _pnt2] elongated with dist from _pnt2
 * _pnt1: initial point of vector, may be some object/marker etc
 * _pnt2: ending point of vector, may be some object/marker etc
 * dist in meters, may be negative
 */
SYG_elongate2Z = {
	private ["_pnt1","_pnt2","_elongate","_dx","_dy"];
	_pnt1 = _this select 0;
	if ( typeName _pnt1 == "OBJECT") then {_pnt1 = getPos _pnt1;};
	_pnt2 = _this select 1;
	if ( typeName _pnt2 == "OBJECT") then {_pnt2 = getPos _pnt2;};
	_elongate = (_this select 2)/(_pnt1 distance _pnt2);

	_dx = x(_pnt2) - x(_pnt1); // (_pnt2 select 0) - (_pnt1 select 0);
	_dy = y(_pnt2) - y(_pnt1); //(_pnt2 select 1) - (_pnt1 select 1);
	_dz = z(_pnt2) - z(_pnt1); //(_pnt2 select 2) - (_pnt1 select 2);
//	[(_pnt1 select 0) + _elongate *_dx, (_pnt1 select 1) + _elongate * _dy, (_pnt1 select 2) + _elongate * _dz] // new point coordinates
	[x(_pnt2) + _elongate *_dx, y(_pnt2) + _elongate * _dy, z(_pnt2)+ _elongate * _dz] // new point coordinates
};

/**
 * call: [_pnt1, _pnt2, _dist] call SYG_elongate1;
 * returns point on vector [_pnt1, _pnt2] with designated _dist from _pnt1 in the same direction as the vector from _pnt1 to _pnt2
 * _pnt1: initial point of vector
 * _pnt2: ending point of vector
 * dist in meters, may be negative
 */
SYG_elongate1 = {
	private ["_pnt1","_pnt2","_elongate","_dx","_dy"];
	_pnt1 = (_this select 0) call SYG_getPos;
	_pnt1 set [2, 0];
	_pnt2 = (_this select 1) call SYG_getPos;
	_pnt2 set [2, 0];
	_elongate = (_this select 2)/(_pnt1 distance _pnt2);

	_dx = x(_pnt2) - x(_pnt1); // (_pnt2 select 0) - (_pnt1 select 0);
	_dy = y(_pnt2) - y(_pnt1); //(_pnt2 select 1) - (_pnt1 select 1);

	[x(_pnt1) + _elongate *_dx, y(_pnt1) + _elongate * _dy, 0] // new point coordinates
};

/**
 * call: [_pnt1, _pnt2, speed(м/с)] call SYG_elongate2Z;
 * returns 3D vector of speed directed from pnt1 to pnt2
 * _pnt1: initial point of vector, may be some object/marker etc
 * _pnt2: ending point of vector, may be some object/marker etc
 * speend in meters per second, must be positive
 */
SYG_speedBetweenPoints2D = {
	private ["_pnt1","_pnt2","_elongate","_dx","_dy","_speed"];
	_pnt1 = (_this select 0) call SYG_getPos;
	_pnt2 = (_this select 1) call SYG_getPos;
	_speed = (_this select 2)/(_pnt1 distance _pnt2);

	_dx = x(_pnt2) - x(_pnt1);
	_dy = y(_pnt2) - y(_pnt1);
	[_speed *_dx, _speed * _dy, 0] // calculated speed vector 3D
};

/**
 * Gets any root from number
 * call as:
 * _res = [_num, _root_degree] call SYG_anyRoot;
 */
SYG_anyRoot = {
	exp(ln(_this select 0)/_this select 1)
};

/**
 * Gets cube root from number
 * call as:
 * _res = _num call SYG_cubeRoot;
 */
SYG_cubeRoot = {
	exp(ln(_this)/3)
};

// Angle in degrees
// call as: _angle = [_vec1, _vec2] call SYG_angleBetween2Vectors3D;
SYG_angleBetweenVectors3D = {
    private ["_v1","_v2","_sc","_L1","_L2","_tmp","_cos"];
    _v1 = _this select 0;
    _v2 = _this select 1;
    _sc = _this call SYG_vectorDotProduct;
    _L1 = _v1 distance [0,0,0];
    _L2 = _v2 distance [0,0,0];
    _tmp = _L1 * _L2;
    if ( _tmp == 0) exitWith {0};
    _cos = _sc / (_tmp);
    acos _cos
};

// Calculates average X and Y values of designated points array
// call: [_pnt1<,...,_pntN> ] call SYG_averPoint; // or
// or:   [_obj1<,...,_objN>] call SYG_averPoint; // or
//
SYG_averPoint = {
	private [ "_pnt", "_posX", "_posY", "_posZ", "_cnt", "_x" ];
	if ( typeName _this != "ARRAY" ) then { _this = [ _this ] };
	_posX = 0.0;
	_posY = 0.0;
	_posZ = 0.0;
	{
		_pnt = _x call SYG_getPos;
		_posX = _posX + (_pnt select 0);
		_posY = _posY + (_pnt select 1);
		if ( count _pnt > 2 ) then { _posZ = _posZ + ( _pnt select 2 ); };
	} forEach _this;
	_cnt = count _this;
	[_posX/_cnt, _posY/_cnt, _posZ/_cnt]
};

//
// Return size of the object as [dx,dy,dz]
// Call: _size = _obj call SYG_size3D;
SYG_objectSize3D = {
	private ["_vol","_p1","_p2"];
	_vol = boundingBox _this;
	_p1 = _vol select 0;
	_p2 = _vol select 1;
	[abs ( (_p1 select 0) - (_p2 select 0) ), abs ( (_p1 select 1) - (_p2 select 1) ), abs ( (_p1 select 2) - (_p2 select 2) )]
};