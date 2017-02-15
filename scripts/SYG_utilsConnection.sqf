//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// scripts/SYG_utilsConnection.sqf, script to process connect/disconnect events
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG__

#define arg(x) (_this select(x))
#define argp(param,x) ((param)select(x))
#define argopt(num,val) (if(count _this<=(num))then{val}else{arg(num)})
#define RANDOM_ARR_ITEM(ARR) (ARR select(floor(random (count ARR))))

#define DEFAULT_MAX_DISTANCE_TO_TARGET 1500
#define DEFAULT_MIN_GROUP_SIZE 5
#define MIN_POSSIBLE_GROUP_SIZE 2
#define NOT_POPULATE_LOADER_TO_TANK
#define NOT_POPULATE_MANY_GUNNERS_IN_HMMW_SUPPORT
#define ADD_1CARGO_TO_TRUCKS_AND_HMMW
// ACE_Binocular, ACE_LaserDesignator, ACE_LaserDesignatorMag, ACE_Laserbatteries

