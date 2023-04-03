// edit this file and then run setupcopy.bat

// Mark this code to be run under "Red Engineer" full mission, not debug one
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

// if you are still running 1.14 comment the following line
#define __NO_PARABUG_FIX__

// comment if you don't want that super cool radio tower effect from Spooner and Loki
//#define __WITH_SCALAR__

// respawn delay after death
// doesn't get used in the revive version
#define D_RESPAWN_DELAY 10

//#define __SMMISSIONS_MARKER__

//+++ Sygsky: uncomment to add limited refueling ability for engineers
#define __LIMITED_REFUELING__

//+++ Sygsky: uncomment to debug new airkillers. Only for debug purposes
//#define __SYG_AIRKI_DEBUG__

//+++ Sygsky: uncomment to debug isledefence activity
//#define __SYG_ISLEDEFENCE_DEBUG__

//+++ Sygsky: uncomment to debug new base pipebombing
//#define __SYG_PIPEBOMB_DEBUG__

//+++ Sygsky: show some info about governor state
#define __SYG_GOVERNOR_INFO__

//+++ enable player command menu to base flag for bargate animation
//#define __BARGATE_ANIM__

//+++ enable your equipment (weapn, magazines, ammo etc) to save on server by base flag menu new command
#define __STORE_EQUIPMENT__

#ifdef __ACE__

//+++ uncomment to rearm some plains, heli, cars (e.g. Su-34B to carry 12 FAB500M62 freefall bombs)
#define __REARM_SU34__

//+++ uncomment to replace ACE_Stryker_TOW with ACE_M60 and ACE_M60A3 in towns
#define __USE_M60__

// uncomment follow line to enable Javelin usage. Javelin also can't be put into any rucksack and stored in weapon cache (at flag on base)
#define __JAVELIN__

//+++ uncomment to enable the appearance of an unconscious player to enemies
#define __DISABLE_HIDE_UNCONSCIOUS__

// comment it out to disable mando missiles long hand
#define __MANDO_MISSILES_UPDATE__

#endif

//+++ uncomment to run easiest side missions first, before all other
//#define __EASY_SM_GO_FIRST__

// uncomment next line to add dome vehicles on the base
#define __ADDITIONAL_BASE_VEHICLES__

#define __SIDE_MISSION_PER_MAIN_TARGET_COUNT__ 2

// uncomment follow line if you want teleport available only if all services on base are valid
// #define __TELEPORT_ONLY_WHEN_ALL_SERVICES_ARE_VALID__

// uncomment follow line to enable jail system if: a) player has score less of equal .LE. then define value, b) new score value is lower than last score value
#define __JAIL_MAX_SCORE__ -15

// uncoment follow line if you don't want users to clone RPG and so on missiles using their rucksacks
//#define __NO_RPG_CLONING__

// comment to enable only engineers to repair and refuel, else anybody can repair with a defined penalty for each +1 engineer score (can't refuel not realized)
#define __NON_ENGINEER_REPAIR_PENALTY__ -5

// uncomment follow line to allow non-engineers use engineering fund
#define __REP_SERVICE_FROM_ENGINEERING_FUND__

// uncomment to allow add predefined scores (now 3) for factory supports, not subtract as was designated by Xeno
//#define __ADD_SCORE_FOR_FACTORY_SUPPORT__ 3

// uncomment lower line to move air vehicle command "Eject" and "Jump out" to the command list bottom
#define __MOVE_EJECT_EVENT_TO_LIST_BOTTOM__

//uncomment to disable jump from base flag pole without parachute pack, to be more serious :o)
//#define __DISABLE_PARAJUMP_WITHOUT_PARACHUTE__

// uncomment next line to prevent enemy land vehicle overturning
#define __PREVENT_OVERTURN__

// comment it out to use the new score system, with lower values per rank
#define __OLD_SCORES__

// uncomment to disable GRU specalist to be pilot for battle air vehicles ( "SU", "Ka-50" etc), allow only "Mi-17 PKT" etc
#define __DISABLE_GRU_BE_PILOTS__

// uncomment to allow shotgun armed AI soldiers
#define __ALLOW_SHOTGUNS__

// uncomment lower line to disable teleport on MHQ damaged more then designated in define
#define __NO_TELEPORT_ON_DAMAGE__ 0.5 // MHQ damage limit to prevent its teleport functionality

// uncomment to allow SCUD added on base. Needs addon gig_scud.pbo, else mission and client not start
//#define __SCUD__

// #385: uncomment to allow lock vehicles on recapture towns procedure
//#define __LOCK_ON_RECAPTURE__

//+++ uncomment to create Su34 on the base,
// add 1500 score to allow get in,
// add some Vehicles and ammoBoxes on hills near Corazol and on base
// #define __DEBUG_ADD_VEHICLES__

// support for SPPM markers and options
#define __SPPM__ 40

#define __NO_AI_IN_PLANE__ // prevents AI to enter plane as driver/pilot, gunner or commaner. Cargo role is allowed

// If defined allows to get a weak defence force to the town, (no cars and tanks) only some infantry and statics
//#define __TOWN_WEAK_DEFENCE__

// uncomment lower line to allow 1st side mission fast start, else long time to start
//#define __FAST_START_SM__

// Comment line to stop Sahrani lighthouse howler sounds
#define __LH_HOWLER__

// uncomment to disable teleport near large metall masses in designated distance
#define __TELEPORT_DEVIATION__ 20

// uncomment to allow only vehicle BEFORE 1985 inclusivelly
//#define __VEH_1985__

// uncomment to get bonuses not on base but near finished towns or SM
#define __DOSAAF_BONUS__

// comment to allow reammo if loaf/unload static weapon to/from salvage tru	ck
#define __NO_REAMMO_IN_SALVAGE__

// comment to allow storing full equipment on base flag, else only rucksack is stored on flag base, all other equipment is stored OnPlayerDisconnecting
#define __EQUIP_OPD_ONLY__

// comment to disable player parajump on connection and base reach procedure, number is delta time after last disconnection to allow next parajump.
// If current delta time is greater then this number, jump is produced, is less not produced
#define __CONNECT_ON_PARA__ 1800

// please not comment lower line, only change it to any of follow values: 1500, 2000, 2500, 3000, 3500, 4000, 5000, 6000, 7000, 8000, 9000, 10000
#define DEFAULT_VIEW_DISTANCE 3500

// Uncomment to disable first time arrival on the Antigua island, not on the base or do paradrops near it
#define __ARRIVED_ON_ANTIGUA__ ["Snooper","EngineerACE"]