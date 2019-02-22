// edit this file and then run setupcopy.bat

#define __RED_ENGINEERS_SERVER__

// uncomment to show markers for sidemissions, main targets, etc.
//#define __DEBUG__

// uncomment to build the Two Teams version
//#define __TT__

// uncomment the corresponding #define preprocessor command
// use only one at a time
// comment all for the Two Teams version
//#define __OWN_SIDE_WEST__
#define __OWN_SIDE_EAST__
//#define __OWN_SIDE_RACS__

// uncomment the corresponding #define preprocessor command
// select which version you want to create
// you can uncomment multiple versions
// comment all for the Two Teams version
#define __AI__
//#define __MANDO__
//#define __REVIVE__
#define __ACE__
//#define __CSLA__
//#define __P85__

// uncomment if you want a ranked version like in Evolution
#define __RANKED__

// #define __SCHMALFELDEN__ for Schmalfelden version, #define __UHAO__ for the UHAO version, #define __DEFAULT__ for the default Sahrani version
// uncomment the corresponding preprocessor command for the version you want. Default is __DEFAULT__
// use only one at a time
// comment all for the Two Teams version
#define __DEFAULT__
//#define __SCHMALFELDEN__
//#define __UHAO__

//#define __D_VER_NAME__ "Domination! One Team - West"
//#define __D_VER_NAME__ "Domination! One Team - A.C.E."
//#define __D_VER_NAME__ "Domination! One Team - A.C.E. RA"
// +++ Sygsky: #define __D_VER_NAME__ "Domination! One Team - A.C.E. East"
#define __D_VER_NAME__ $STR_INTRO_FULL
//#define __D_VER_NAME__ "Domination! One Team - West AI"
//#define __D_VER_NAME__ "Domination! One Team - West REVIVE"
//#define __D_VER_NAME__ "Domination! One Team - East"
//#define __D_VER_NAME__ "Domination! One Team - East AI"
//#define __D_VER_NAME__ "Domination! One Team - East Revive"
//#define __D_VER_NAME__ "Domination! One Team - CSLA"
//#define __D_VER_NAME__ "Domination! One Team - P85"
//#define __D_VER_NAME__ "Domination! One Team - Racs"
//#define __D_VER_NAME__ "Domination! One Team - Racs AI"
//#define __D_VER_NAME__ "Domination! One Team - Racs Revive"
//#define __D_VER_NAME__ "Domination! One Team - West Schmalfelden"
//#define __D_VER_NAME__ "Domination! One Team - West Mando"
//#define __D_VER_NAME__ "Domination! One Team - East Uhao"
//#define __D_VER_NAME__ "Domination! Two Teams"

// uncomment, if you want grass at mission start
//#define __WITH_GRASS_AT_START__

// uncomment, if you want the old intro
//#define __OLD_INTRO__

// if true then the old engineer (faster) script gets used
//#define __ENGINEER_OLD__

// if you are still running 1.14 comment the following line
#define __NO_PARABUG_FIX__

// comment if you don't want that super cool radio tower effect from Spooner and Loki
//#define __WITH_SCALAR__

// respawn delay after death
// doesn't get used in the revive version
#define D_RESPAWN_DELAY 10

//#define __SMMISSIONS_MARKER__

//+++ Sygsky: uncomment to add limited refuelling ability for engineers. Still not realized
#define __LIMITED_REFUELLING__

//+++ Sygsky: uncomment to debug new airkillers. Only for debug purposes
//#define __SYG_AIRKI_DEBUG__

//+++ Sygsky: uncomment to debug isledefence activity
//#define __SYG_ISLEDEFENCE_DEBUG__

//+++ Sygsky: uncomment to debug new base pipebombing
//#define __SYG_PIPEBOMB_DEBUG__

//+++ Sygsky: play New Year music on base
//#define __SYG_NEW_YEAR_GIFT__

//+++ Sygsky: show some info about governor state
#define __SYG_GOVERNOR_INFO__

//+++ enable player command menu to base flag for bargate animation
//#define __BARGATE_ANIM__

//+++ enable your equipment (weapn, magazines, ammo etc) to save on server by base flag menu new command
#define __STORE_EQUIPMENT__

#ifdef __ACE__

//+++ uncomment to rearm some plains, heli, cars (e.g. Su-34B to carry 12 FAB500M62 freefall bombs)
#define __REARM_SU34__

//+++ uncomment to replace ACE_Stryker_TOW with ACE_M60 and ACE_M60A3
#define __USE_M60__

// uncomment follow line to enable Javelin usage. javelin can't be put into any rucksack and stored in weapon cache (at flag on base)
#define __JAVELIN__

#endif

//+++ uncomment to run easiest side missions first, before all other
//#define __EASY_SM_GO_FIRST__

//+++ uncomment to create Su34 on the base,
// add 1000 score to allow get in,
// add some Vehicles and ammoBoxes on hills near Corazol and on base
//#define __DEBUG_ADD_VEHICLES__

// uncomment next line to add dome vehicles on the base
#define __ADDITIONAL_BASE_VEHICLES__

#define __SIDE_MISSION_PER_MAIN_TARGET_COUNT__ 2

// uncomment follow line if you want teleport available only if all services on base are valid
// #define __TELEPORT_ONLY_WHEN_ALL_SERVICES_ARE_VALID__

// uncomment follow line to enable jail system if: a) player has score less of equal .LE. then define value, b) new score value is lower than last score value
#define __JAIL_MAX_SCORE__ -15

// uncoment follow line if you don't want users to clone RPG and so on missiles using their rucksacks
//#define __NO_RPG_CLONING__

// comment to enable only engineers to repair and refuel, else anybody can repair with a defined penalty for each +1 engineer score but can't refuel
#define __NON_ENGINEER_REPAIR_PENALTY__ -5

// uncomment follow line to allow non-engineers use engineering fund
#define __REP_SERVICE_FROM_ENGINEERING_FUND__

// uncomment to allow add predefined scores (now 3) for factory supports, not subtract as was designated by Xeno
#define __ADD_SCORE_FOR_FACTORY_SUPPORT__ 3

// uncomment lower line to move air vehicle command "Eject" and "Лump out" to the command list bottom
#define __MOVE_EJECT_EVENT_TO_LIST_BOTTOM__