/*
    future_scripts/findProbableGoal.sqf
	author: http://www.flashpoint.ru/threads/определение-вероятной-цели-бота.38839/
	description: finds most probable target for the designated unit
	returns: nothing
*/

// sqf

//
// Constants
//

#define mcrMaxScanDistance 120
#define mcrCriticalAimPointDistance 1

//
// Macro
//

#define arg(x) (_this select x)
#define x(a) ((a) select 0)
#define y(a) ((a) select 1)
#define z(a) ((a) select 2)

_upDegrees =
[
    "None",               // -1
    "Dead",               //  0
    "AT weapon",          //  1
    "Binoc lying",        //  2
    "Lying no weapon",    //  3
    "Lying",              //  4
    "Handgun lying",      //  5
    "Crouch",             //  6
    "Handgun crouch",     //  7
    "Combat",             //  8
    "Handgun stand",      //  9
    "Stand",              // 10
    "Swimming",           // 11
    "No weapon",          // 12
    "Binoc",              // 13
    "Binoc stand"         // 14
];

_getUpDegree = {
    if(isNull _this)then{ "" }else{
        _upDegrees select (
            ((getNumber ([_this, "upDegree"] call _readAction)) + 1) % count _upDegrees
        )
    }
};

// Читает заданное свойство из текущего Actions юнита
// [юнит, свойство] call _readAction
_readAction = {
    private "_moves";
    _moves = getText (
        configFile >> "CfgVehicles" >> (typeOf arg(0)) >> "moves"
    ));
    configFile >> _moves >> "Actions" >>
        getText (
            configFile >> _moves >> "States" >> animationState arg(0) >> "actions"
        ) >> arg(1)
};

/////////////////////////////////

_unit = _this;

// Ground level
_groundLevel = "emptydetector" createVehicleLocal [0,0,0];

// Позиция объекта над уровнем моря. Родной getPosASL врет когда объект на крыше здания или на мосту. Вот мля уроды разрабы.
/*
_fixGetPosASL = {
    private "_pos";
    _pos = getPos _this;
    _groundLevel setpos _pos;
    [x(_pos), y(_pos), (_this distance _groundLevel) + z(getPosASL _groundLevel)]
};
*/
_fixGetPosASL = {
    _this modelToWorld [0, 0, z(getPosASL _this) - z(getpos _this)]
};

// Возвращает позицию точки прицеливания для указаной дистанции
// _this - дистанция, _uPos - позиция юнита, _wPos - единичный вектор направления оружия юнита
_getAimPos = {
    [
        x(_uPos) + x(_wPos) * _this,
        y(_uPos) + y(_wPos) * _this,
        z(_uPos) + z(_wPos) * _this
    ]
};

waitUntil {

    // оружие = если юнит не технике, то "руки", иначе первое оружие техники в которой сидит юнит
    _weapon = if(_unit == vehicle _unit)then{"throw"}else{
        weapons vehicle _unit select 0
    };
    // позиция юнита над уровнем моря
    _uPos = _unit call _fixGetPosASL;
    // направление (единичный вектор) ствола оружия юнита (или техники в которой он сидит)
    _wPos = vehicle _unit weaponDirection _weapon;
    // в mcrMaxScanDistance метрах в направлении "взгляда" ствола юнита берется позиция
    _searchPos = mcrMaxScanDistance call _getAimPos;
    // "потенциальные цели" -- боты, находящиеся в пределах оружности с центром в _searchPos
    //  и радиусом mcrMaxScanDistance, в которых, возможно, целится юнит
    _targets = (_searchPos nearObjects ["man", mcrMaxScanDistance]) - [_unit];

    // будем сюда записывать наиближайшего к линии прицеливания бота
    _probableTarget = objnull;
    // будем сюда записывать растояние от линии прицеливания до этого бота
    _probableAimDist = 1e+10;

    { // цикл по всем "потенциальным целям"
        if(alive _x)then{

// Прим. Юзание bounding box не дает должного улучшения точности
// BB для ботов мало зависит от текущей анимации, то есть это не "честный" высчитываемый bounding,
// а достаточно левая штука -- для ботов есть всего два вида BB лежачий и для всех других положений.
// При этом коррекцию на высоту все равно делать надо, и гемороя с ASL и "above ground level" позициями не оберешся)
// Лучче просто делать поправки в зависимости от анимации (для этого здесь указан код с их чтением), или даже самопальный фэйк-bounding на основе этих данных. Но это здесь не реализовано.

            // коррекция (ведь бот находится в анимации)
            _xPos = _x call _fixGetPosASL;
            _xPos set [2, z(_xPos) - .7];
            // растояние от очередного бота (_x) до линии прицеливания
            _aimDist = (_unit distance _x call _getAimPos) distance _xPos;
            // если новое растояние меньше старого, то обновить данные
            if(_aimDist < _probableAimDist)then{
                _probableAimDist = _aimDist;
                _probableTarget = _x;
            }
        }
    } foreach _targets;

    _isTakesAim = _probableAimDist < mcrCriticalAimPointDistance;

    hint (

        "\nIs Takes Aim: "        + (str _isTakesAim) +

        "\nProbable Target: "   + (str _probableTarget) +
        "\nAim Distance: "      + (str _probableAimDist) +

        "\nUnit pos: "      + (driver _unit call _getUpDegree) +
        "\nTarget pos: "    + (_probableTarget call _getUpDegree)
    );

    sleep .01;
    !alive _unit

};

deleteVehicle _groundLevel;
