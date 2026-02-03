// Sounds. Used to call methods like playSound, say etc, defined in CfgSounds included in Description.ext

class CfgSounds {
	sounds[] = {
		Funk,Ari,odinakovo,slavianskiy,highvoltage,upsidedown,vam_bileter,Tank_GetIn,APC_GetIn

#ifdef __REVIVE__
		,DBrian_Im_hit, DBrian_Im_bleeding,DBrian_Medic,DBrian_Bastards,DBrian_Shit_Man_down,DBrian_Oh_no,
		DBrian_Fuck,DBrian_Fuck_it,DBrian_Shit,DBrian_Need_help,DBrian_A_little_help_here
#endif
#ifdef __WITH_SCALAR__
		,scalarDown
#endif
	};

#ifdef __MANDO__
#include "mando_missiles\mando_sounds.h"
#endif

    class USSR {name = ""; sound[] = {\sounds\USSR.ogg, db+10, 1.0};titles[] = {};};
	class Funk {name="Funk";sound[]={\sounds\short\funk.ogg,db+20,1.0};titles[] = {};};
	class Ari {name="Ari";sound[]={\sounds\short\ari.ogg,db+30,1.0};titles[] = {};};
	class odinakovo {name="odinakovo";sound[]={\sounds\odinakovo.ogg,db+0,1.0};titles[] = {};};
	class slavianskiy {name="slavianskiy";sound[]={\sounds\slavianskiy.ogg,db+0,1.0};titles[] = {};};
    class vam_bileter {name="vam_bileter";sound[]={\sounds\vam_bileter.ogg,db+0,1.0};titles[] = {};};
	class highvoltage {name="highvoltage";sound[]={\sounds\highvoltage.ogg,db+0,1.0};titles[] = {};};
	class upsidedown {name="upsidedown";sound[]={\sounds\short\upside_down.ogg,db+0,1.0};titles[] = {};};
	//class horse {name="horse";sound[]={\sounds\horse.ogg,db+0,1.0};titles[] = {};};
	class Tank_GetIn {name="Tank_GetIn";sound[]={\sounds\short\Tank_GetIn.ogg,db+0,1.0};titles[] = {};};
	class APC_GetIn {name="APC_GetIn";sound[]={\sounds\short\APC_GetIn.ogg,db+0,1.0};titles[] = {};};
	class bicycle {name="bicycle himn";sound[]={\sounds\bicycle.ogg,db+0,1.0};titles[] = {};};
	class bicycle_ring {name="bicycle ring";sound[]={\sounds\short\bicycle_ring_v1.ogg,db+0,1.0};titles[] = {};}; // From Arma-1 sound in weapons.pbo

	class stalin_dal_prikaz {name="Soviet artillery himn";sound[]={\sounds\intro\vehicles\stalin_dal_prikaz.ogg,db+0,1.0};titles[] = {};};
	class healing {name="healing";sound[]={\sounds\short\healing.ogg,db+0,1.0};titles[] = {};}; // medic heal service

//	class patrol { name="patrol"; sound[]={\sounds\patrol.ogg,db-20,1.0}; titles[] = {}; }; // remove as non needed
//	class baraban { name="baraban"; sound[]={\sounds\baraban.ogg,db+0,1.0}; titles[] = {}; }; // removed as not interesting and ancient
	class kwai     { name="kwai";                          sound[]={\sounds\kwai.ogg,db+0,1.0};          titles[] = {}; };
    class starwars { name="Star wars march";               sound[]= {\sounds\starwars.ogg,db-1,1.0};     titles[] = {};};
    class radmus   { name="radmus from old OFP campany";   sound[]= {\sounds\enemy\radmus.ogg,db-1,1.0}; titles[] = {};};
    class enemy    { name="Hans Zimmer - Barbarian horde"; sound[]= {\sounds\enemy\enemy.ogg,db-1,1.0};  titles[] = {};};
    class ortegogr { name="Found in one Arma mission (German)"; sound[]= {\sounds\enemy\ortegogr.ogg,db-1,1.0};  titles[] = {};};
    class desant   { name="Red Alert desant music"; sound[]= {\sounds\enemy\desant.ogg,db-1,1.0};  titles[] = {};}; // from Red Alert game, called only for 2st otwn occupied

    class no_more_waiting { name=""; sound[]= {\sounds\short\no_more_waiting.ogg,db-1,1.0}; titles[] = {};}; // very short sound (observer killed?)

    class parajump1 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_jump1.ogg,db-1,1.0}; titles[] = {};} // You jumped from vehicle sound 1
    class parajump2 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_jump2.ogg,db-1,1.0}; titles[] = {};} // You jumped from vehicle sound 2

    class freefall1 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_1.ogg,db-1,1.0}; titles[] = {};} // You are in free fall sound 1
    class freefall2 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_2.ogg,db-1,1.0}; titles[] = {};} // You are in free fall sound 2
    class freefall3 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_chorus_1.ogg,db-1,1.0}; titles[] = {};} // You are in free fall sound 3
    class freefall4 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_chorus_2.ogg,db-1,1.0}; titles[] = {};} // You are in free fall sound 4
    class freefall5 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_chorus_3.ogg,db-1,1.0}; titles[] = {};} // You are in free fall sound 5
    class freefall6 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_chorus_4.ogg,db-1,1.0}; titles[] = {};} // You are in free fall sound 6
    class freefall7 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_chorus_5.ogg,db-1,1.0}; titles[] = {};} // You are in free fall sound 7
    class freefall300m { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_300_m.ogg,db-1,1.0}; titles[] = {};} // You are in free fall sound 8

    class rippara1 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_rip_1.ogg,db-1,1.0}; titles[] = {};} // Rip parachute sound
    class rippara2 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_rip_2.ogg,db-1,1.0}; titles[] = {};} // Rip parachute sound
    class rippara3 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_rip_3.ogg,db-1,1.0}; titles[] = {};} // Rip parachute sound
    class rippara4 { name=""; sound[] = {\sounds\parajump\vozdushnye_potoki_rip_3.ogg,db-1,1.0}; titles[] = {};} // Rip parachute sound

    class heli_over_1 { name=""; sound[] = {\sounds\defeat\heli\3d_heli_sound.ogg,db-1,1.0}; titles[] = {};};
    class heli_over_2 { name=""; sound[] = {\sounds\defeat\heli\3d_heli_sound_2.ogg,db-1,1.0}; titles[] = {};};
    class heli_over_3 { name=""; sound[] = {\sounds\defeat\heli\3d_heli_sound_3.ogg,db-1,1.0}; titles[] = {};};
    class heli_over_4 { name=""; sound[] = {\sounds\defeat\heli\3d_heli_sound_4.ogg,db-1,1.0}; titles[] = {};};

    // Fear sounds
	class fear      { name=""; sound[]=  {\sounds\fear.ogg,db-1,1.0}; titles[] = {}; };
	class bestie    { name="";  sound[]= {\sounds\bestie.ogg,db-1,1.0}; titles[] = {}; };
	class gamlet    { name=""; sound[] = {\sounds\gamlet.ogg,db+0,1.0}; titles[] = {}; };
	class fear3     { name=""; sound[]=  {\sounds\fear3.ogg,db-1,1.0}; titles[] = {}; };
	class heartbeat { name=""; sound[]=  {\sounds\heartbeat.ogg,db-1,1.0}; titles[] = {}; };
	class the_trap  { name=""; sound[]=  {\sounds\the_trap.ogg,db-1,1.0}; titles[] = {}; };
	class koschei   { name=""; sound[]=  {\sounds\koschei.ogg,db-1,1.0}; titles[] = {}; }; // from Soviet multfilm "The princess Frog"
	class sinbad_skeleton { name=""; sound[]= {\sounds\fear\sinbad_skeleton.ogg,db-1,1.0}; titles[] = {}; }; // from "7th voyage of Sinbad "
	class fear4     { name=""; sound[]=  {\sounds\fear\fear4.ogg,db-1,1.0}; titles[] = {}; };
	class fear_Douce_Violence { name=""; sound[]= {\sounds\fear\fear_Douce_Violence.ogg,db-1,1.0}; titles[] = {}; };
	class boom      { name=""; sound[]=  {\sounds\fear\boom.ogg,db-1,1.0}; titles[] = {}; };
	class ihtiandr  { name=""; sound[]=  {\sounds\fear\fear_ihtiandr_capture.ogg,db-1,1.0}; titles[] = {}; };

	class teleport_from { name=""; sound[]=   {\sounds\short\teleport_from.ogg,db-1,1.0}; titles[] = {}; };
	class teleport_to   { name=""; sound[]=   {\sounds\short\teleport_to.ogg,db-1,1.0}; titles[] = {}; };

    class countdown10     {name = ""; sound[] = {\sounds\countdown10.ogg, db+10, 1.0}; titles[] = {}; };
    class countdown       {name = ""; sound[] = {\sounds\countdown.ogg, db+10, 1.0}; titles[] = {}; }; // Rammstein
    class countdown_alarm {name = ""; sound[] = {\sounds\countdown_alarm.ogg, db+10, 1.0}; titles[] = {}; };

    class return        {name = ""; sound[] = {\sounds\short\return.ogg, db+10, 1.0}; titles[] = {}; };
    class steal         {name = ""; sound[] = {\sounds\short\steal.ogg, db+10, 1.0}; titles[] = {}; };
    class arabian_death { name=""; sound[] = {\sounds\arabian_death.ogg,db+10,1.0}; titles[] = {};} // defeat sound
    class the_complex   { name=""; sound[] = {\sounds\the_complex.ogg,db+10,1.0}; titles[] = {};} // defeat sound by Kevin MacLeod

    class male_fuck_1 {name = ""; sound[] = {\sounds\fuck\male_fuckin_cunt.ogg, db+0, 1.0}; titles[] = {}; };

    class male_sorry_1 {name = ""; sound[] = {\sounds\fuck\male-i-am-so-sorry.ogg, db+0, 1.0}; titles[] = {}; };
    class male_sorry_2 {name = ""; sound[] = {\sounds\fuck\man-sorry-english.ogg, db+0, 1.0}; titles[] = {}; };
    class male_sorry_3 {name = ""; sound[] = {\sounds\fuck\man-sorry-english-1.ogg, db+0, 1.0}; titles[] = {}; };

// woman fucking  speech
    class woman_fuck {name = ""; sound[] = {\sounds\fuck\woman_fuck.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_fuck_2 {name = ""; sound[] = {\sounds\fuck\woman_fuck_2.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_fuck_3 {name = ""; sound[] = {\sounds\fuck\woman_fuck_3.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_fuck_4 {name = ""; sound[] = {\sounds\fuck\woman_fuck_4.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_fuck_5 {name = ""; sound[] = {\sounds\fuck\woman-mother-shit.ogg, db+0, 1.0}; titles[] = {}; };

    class woman_kidding {name = ""; sound[] = {\sounds\fuck\woman_kidding.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_sob {name = ""; sound[] = {\sounds\fuck\woman_sob.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_motherfucker {name = ""; sound[] = {\sounds\fuck\woman_motherfucker.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_svoloch {name = ""; sound[] = {\sounds\fuck\woman_svoloch.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_dont_trust {name = ""; sound[] = {\sounds\fuck\female-dont-trust-him.ogg, db+0, 1.0}; titles[] = {}; };

    class woman_excl1 {name = ""; sound[] = {\sounds\women\excl\woman_excl1.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_excl2 {name = ""; sound[] = {\sounds\women\excl\woman_excl2.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_excl3 {name = ""; sound[] = {\sounds\women\excl\woman_excl3.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_excl4 {name = ""; sound[] = {\sounds\women\excl\woman_excl4.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_excl5 {name = ""; sound[] = {\sounds\women\excl\woman_excl5.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_excl6 {name = ""; sound[] = {\sounds\women\excl\woman_excl6.ogg, db+0, 1.0}; titles[] = {}; };
    class woman_excl7 {name = ""; sound[] = {\sounds\women\excl\woman_excl7.ogg, db+0, 1.0}; titles[] = {}; };

// woman sorry etc
    class sorry_0  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-0.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_1  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-1.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_2  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-2.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_3  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-3.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_4  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-4.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_5  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-5.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_6  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-6.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_7  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-7.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_8  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-8.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_9  {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-9.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_10 {name = "Female sorry"; sound[] = {\sounds\women\sorry\female-sorry-10.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_11 {name = "Female kidding"; sound[] = {\sounds\women\sorry\are-you-kidding-me.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_12 {name = "Female sexy";  sound[] = {\sounds\women\sorry\sexy-voice.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_13 {name = "Female so sorry"; sound[] = {\sounds\women\sorry\female-my-fault.ogg, db+0, 1.0}; titles[] = {}; };
    class sorry_14 {name = "Female going to bed time"; sound[] = {\sounds\women\sorry\female-it-s-getting-close-to-bedtime.ogg, db+0, 1.0}; titles[] = {}; };

// man self-killed. If append next scream, don't forget to edit method SYG_getSuicideMaleScreamSound() in file SYG_utilsSound.sqf (increase harcoded number of screams)
    class male_scream_0  {name = ""; sound[] = {\sounds\suicide\male_scream_0.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_1  {name = ""; sound[] = {\sounds\suicide\male_scream_1.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_2  {name = ""; sound[] = {\sounds\suicide\male_scream_2.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_3  {name = ""; sound[] = {\sounds\suicide\male_scream_8.ogg, db+0, 1.0}; titles[] = {}; }; // 3rd was removed and replaced temporarily with 8th
    class male_scream_4  {name = ""; sound[] = {\sounds\suicide\male_scream_4.ogg, db+10, 1.0}; titles[] = {}; };
    class male_scream_5  {name = ""; sound[] = {\sounds\suicide\male_scream_5.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_6  {name = ""; sound[] = {\sounds\suicide\male_scream_6.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_7  {name = ""; sound[] = {\sounds\suicide\male_scream_7.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_8  {name = ""; sound[] = {\sounds\suicide\male_scream_8.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_9  {name = ""; sound[] = {\sounds\suicide\male_scream_9.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_10 {name = ""; sound[] = {\sounds\suicide\male_scream_10.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_11 {name = ""; sound[] = {\sounds\suicide\male_scream_11.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_12 {name = ""; sound[] = {\sounds\suicide\male_scream_12.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_13 {name = ""; sound[] = {\sounds\suicide\scream1.ogg, db+0, 1.0}; titles[] = {}; };
    class male_scream_14 {name = "Demonic woman scream on suicide"; sound[] = {\sounds\suicide\demonic_woman_scream.ogg, db+0, 1.0}; titles[] = {}; }; // demonic scream

// woman self-killed event
    class suicide_female_0 {name = ""; sound[] = {\sounds\suicide\woman_suicide_0.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_1 {name = ""; sound[] = {\sounds\suicide\woman_suicide_1.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_2 {name = ""; sound[] = {\sounds\suicide\woman_suicide_2.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_3 {name = ""; sound[] = {\sounds\suicide\woman_suicide_3.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_4 {name = ""; sound[] = {\sounds\suicide\woman_suicide_4.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_5 {name = ""; sound[] = {\sounds\suicide\woman_suicide_5.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_6 {name = ""; sound[] = {\sounds\suicide\woman_suicide_6.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_7 {name = ""; sound[] = {\sounds\suicide\woman_suicide_7.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_8 {name = ""; sound[] = {\sounds\suicide\woman_suicide_8.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_9 {name = ""; sound[] = {\sounds\suicide\woman_suicide_9.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_10 {name = ""; sound[] = {\sounds\suicide\woman_suicide_10.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_female_11 {name = ""; sound[] = {\sounds\suicide\woman_suicide_11.ogg, db+0, 1.0}; titles[] = {}; };


    class suicide_yeti_0 {name = "Special Yeti's scream on suicide"; sound[] = {\sounds\suicide\suicide_yeti.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_yeti_1 {name = "Special Yeti's scream on suicide"; sound[] = {\sounds\suicide\suicide_yeti_1.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_yeti_2 {name = "Special Yeti's scream on suicide"; sound[] = {\sounds\suicide\suicide_yeti_2.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_yeti_3 {name = "Special Yeti's scream on suicide"; sound[] = {\sounds\suicide\suicide_yeti_3.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_yeti_4 {name = "Special Yeti's scream on suicide"; sound[] = {\sounds\suicide\suicide_yeti_4.ogg, db+0, 1.0}; titles[] = {}; };

    class suicide_german_0 {name = "Special Germans scream on suicide"; sound[] = {\sounds\suicide\suicide_german_0.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_german_1{name = "Special Germans scream on suicide";  sound[] = {\sounds\suicide\suicide_german_1.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_german_2 {name = "Special Germans scream on suicide"; sound[] = {\sounds\suicide\suicide_german_2.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_german_3 {name = "Special Germans scream on suicide"; sound[] = {\sounds\suicide\suicide_german_3.ogg, db+0, 1.0}; titles[] = {}; };
    class suicide_german_4 {name = "Special Germans scream on suicide"; sound[] = {\sounds\suicide\suicide_german_4.ogg, db+0, 1.0}; titles[] = {}; };

    class losing_patience  {name = ""; sound[] = {\sounds\short\losing_patience.ogg,db-1,1.0}; titles[] = {};};
    class good_news        {name = ""; sound[] = {\sounds\short\good_news.ogg, db+10, 1.0}; titles[] = {}; };
//    class message_received {name = ""; sound[] = {\sounds\short\received.ogg, db+10, 1.0}; titles[] = {}; };
    class message_received {name = ""; sound[] = {\sounds\short\message_received.ogg, db+10, 1.0}; titles[] = {}; };
    class drum_fanfare     {name = ""; sound[] = {\sounds\short\drum_fanfare.ogg, db+10, 1.0}; titles[] = {}; };
    class hound_chase      {name = ""; sound[] = {\sounds\hound_chase.ogg, db+10, 1.0}; titles[] = {};}; // chase from "Hound of Baskerville" Soviet film

    class gong_0       {name = ""; sound[] = {\sounds\gong\clock-1x-gong.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_1       {name = ""; sound[] = {\sounds\gong\gong-01.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_2       {name = ""; sound[] = {\sounds\gong\gong-02.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_3       {name = ""; sound[] = {\sounds\gong\gong-03.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_4       {name = ""; sound[] = {\sounds\gong\gong-04.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_5       {name = ""; sound[] = {\sounds\gong\gong-05.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_6       {name = ""; sound[] = {\sounds\gong\gong-06.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_7       {name = ""; sound[] = {\sounds\gong\gong-07.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_8       {name = ""; sound[] = {\sounds\gong\gong-08.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_9       {name = ""; sound[] = {\sounds\gong\gong-09.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_10       {name = ""; sound[] = {\sounds\gong\magic-string-spell.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_11       {name = ""; sound[] = {\sounds\gong\gong-11.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_12       {name = ""; sound[] = {\sounds\gong\soapdramgong.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_13       {name = ""; sound[] = {\sounds\gong\gong-15.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_14       {name = "oriental game over"; sound[] = {\sounds\gong\oriental-game-over.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_15       {name = ""; sound[] = {\sounds\gong\Startlet.ogg, db+10, 1.0}; titles[] = {}; };
    class gong_16       {name = ""; sound[] = {\sounds\gong\sansula.ogg, db+10, 1.0}; titles[] = {}; };
    class school_ring   {name = ""; sound[] = {\sounds\gong\school-ring.ogg, db+10, 1.0}; titles[] = {}; };

    class liturgy_1     {name = ""; sound[] = {\sounds\liturgy\diamon_hand.ogg, db+10, 1.0}; titles[] = {}; };
    class liturgy_2     {name = ""; sound[] = {\sounds\liturgy\gospodu_pomolimsa.ogg, db+10, 1.0}; titles[] = {}; };
    class liturgy_3     {name = ""; sound[] = {\sounds\liturgy\ortodox_liturgy.ogg, db+10, 1.0}; titles[] = {}; };
    class liturgy_4     {name = ""; sound[] = {\sounds\liturgy\valaam_liturgy.ogg, db+10, 1.0}; titles[] = {}; };
    class liturgy_5     {name = ""; sound[] = {\sounds\liturgy\mon_nevskogo.ogg, db+10, 1.0}; titles[] = {}; };

    // Ordinal defeat sounds
	class thetrembler { name=""; sound[]=   {\sounds\thetrembler.ogg,db-1,1.0}; titles[] = {}; };
	class thefuture { name=""; sound[]=   {\sounds\thefuture.ogg,db-1,1.0}; titles[] = {}; };
	class vendetta { name=""; sound[] = {\sounds\vendetta.ogg,db-1,1.0}; titles[] = {}; };
    class aztecs { name=""; sound[] = {\sounds\aztecs.ogg,db-1,1.0}; titles[] = {}; };
    class aztecs2 { name=""; sound[] = {\sounds\aztecs2.ogg,db-1,1.0}; titles[] = {}; };
    class aztecs3 { name=""; sound[] = {\sounds\aztecs3.ogg,db-1,1.0}; titles[] = {}; };
    class aztecs4 { name=""; sound[] = {\sounds\aztecs4.ogg,db-1,1.0}; titles[] = {}; };
    class aztecs5 { name=""; sound[] = {\sounds\aztecs5.ogg,db-1,1.0}; titles[] = {}; };
    class aztecs6 { name=""; sound[] = {\sounds\aztecs6.ogg,db-1,1.0}; titles[] = {}; };
    class betrayed { name=""; sound[] = {\sounds\betrayed.ogg,db-1,1.0}; titles[] = {}; };
    class bolero { name=""; sound[] = {\sounds\bolero.ogg,db-1,1.0}; titles[] = {}; };
    class musicbox_silent_night { name=""; sound[] = {\sounds\musicbox_silent_night.ogg,db-1,1.0}; titles[] = {}; };

    class tezcatlipoca { name=""; sound[] = {\sounds\tezcatlipoca.ogg,db-1,1.0}; titles[] = {}; };
    class yma_sumac { name=""; sound[] = {\sounds\yma_sumac.ogg,db-1,1.0}; titles[] = {}; };
    class yma_sumac_2 { name=""; sound[] = {\sounds\yma_sumac_2.ogg,db-1,1.0}; titles[] = {}; };
    class village_ruins { name=""; sound[] = {\sounds\village_ruins.ogg,db-1,1.0}; titles[] = {}; };

    class pimbompimbom { name=""; sound[] = {\sounds\pimbompimbom.ogg,db-1,1.0}; titles[] = {}; }; // defeat music
    class Delerium_Wisdom { name=""; sound[] = {\sounds\Delerium_Wisdom.ogg,db-1,1.0}; titles[] = {}; }; // defeat music
    class mountains { name=""; sound[] = {\sounds\mountains.ogg,db-1,1.0}; titles[] = {}; }; // defeat music
    class Gandalf_Simades { name=""; sound[] = {\sounds\Gandalf_Simades.ogg,db-1,1.0}; titles[] = {}; }; // defeat music

    class end { name=""; sound[] = {\sounds\end.ogg,db-1,1.0}; titles[] = {}; }; // defeat music
    class whold { name=""; sound[] = {\sounds\whold.ogg,db-1,1.0}; titles[] = {}; }; // defeat music
    class arroyo { name=""; sound[] = {\sounds\arroyo.ogg,db-1,1.0}; titles[] = {}; }; // defeat music from Fallout-2

    class defeat2 { name=""; sound[] = {\sounds\defeat2.ogg,db+10,1.0}; titles[] = {}; }; // defeat sound
    class radionanny { name=""; sound[] = {\sounds\Radio_nanny_call_sign.ogg,db+10,1.0}; titles[] = {}; }; // defeat sound from Radio-nanny sign call
    class sinbad_baghdad { name=""; sound[] = {\sounds\defeat\sinbad_baghdad.ogg,db+10,1.0}; titles[] = {}; }; // defeat sound from film "7th voyage of Sinbad "
    class moon_stone {name = ""; sound[] = {\sounds\defeat\moon_stone.ogg, db+10,1.0}; titles[] = {}; }; // Famous Soviet singer Edvard Hill: "Moon stone" song
    class take_five    {name = "Dave Brubeck"; sound[] = {\sounds\defeat\take_five.ogg, db+10,1.0}; titles[] = {}; }; // "Take Five" by Dave Brubeck
    class holms { name="";      	           sound[] = {\sounds\defeat\holms.ogg,db-1,1.0}; titles[] = {};}; // "Шерлок Холмс", СССР


    class metel       { name=""; sound[] = {\sounds\metel.ogg,db+0,1.0}; titles[] = {}; }; // defeat music from "Metel" of Pushkin novel
    class gayane1     { name=""; sound[] = {\sounds\gayane1.ogg,db+0,1.0}; titles[] = {}; }; // "Gayane" ballet
    class gayane2     { name=""; sound[] = {\sounds\gayane2.ogg,db+0,1.0}; titles[] = {}; }; // "Gayane" ballet
    class gayane3     { name=""; sound[] = {\sounds\gayane3.ogg,db+0,1.0}; titles[] = {}; }; // "Gayane" ballet
    class gamlet_hunt { name=""; sound[] = {\sounds\gamlet_hunt.ogg,db+0,1.0}; titles[] = {}; }; // "Hamlet" soviet movie
    class treasure_island_defeat { name=""; sound[] = {\sounds\treasure_island_defeat.ogg,db-1,1.0}; titles[] = {}; }; // "tresure island alarm theme" USSR movie of 1971 year
    class i_new_a_guy { name=""; sound[] = {\sounds\i_new_a_guy.ogg,db+10,1.0}; titles[] = {}; };
    class decisions   { name=""; sound[] = {\sounds\decisions.ogg,db+5,1.0}; titles[] = {}; };;

    class stripped_voyage    {name = "From Stripped Voyage film"; sound[] = {\sounds\defeat\stripped_voyage.ogg, db+10,1.0}; titles[] = {}; }; // Some sound from Soviet film "Stripped Voyage" (196)
    class troshin    {name = "From Stripped Voyage film"; sound[] = {\sounds\defeat\troshin.ogg, db+10,1.0}; titles[] = {}; }; // From some song performed by Troshin
    class corrida_shaov    {name = ""; sound[] = {\sounds\defeat\corrida_shaov.ogg, db+10,1.0}; titles[] = {}; }; // From some song performed by Troshin
    class kavkazskaya_plennitsa    {name = ""; sound[] = {\sounds\defeat\kavkazskaya_plennitsa.ogg, db+10,1.0}; titles[] = {}; }; // From film "Kavkazskaya plennitsa", 1967


    class church_voice    {name = "church_voice"; sound[] = {\sounds\church\church_voice.ogg, db+10,1.0}; titles[] = {}; };
    class sorrow_1        {name = "sorrow_1"; sound[] = {\sounds\church\sorrow_1.ogg, db+10,1.0}; titles[] = {}; };
    class sorrow_2        {name = "sorrow_2"; sound[] = {\sounds\church\sorrow_2.ogg, db+10,1.0}; titles[] = {}; };
    class sorrow_3        {name = "sorrow_3"; sound[] = {\sounds\church\sorrow_3.ogg, db+10,1.0}; titles[] = {}; };
    class sorrow_4        {name = "sorrow_4"; sound[] = {\sounds\church\sorrow_4.ogg, db+10,1.0}; titles[] = {}; };

    class church_organ_1  {name = ""; sound[] = {\sounds\organ\church_organ_1.ogg, db+10,1.0}; titles[] = {}; };
    class haunted_organ_1 {name = ""; sound[] = {\sounds\organ\haunted_organ_1.ogg, db+10,1.0}; titles[] = {}; };
    class haunted_organ_2 {name = ""; sound[] = {\sounds\organ\haunted_organ_2.ogg, db+10,1.0}; titles[] = {}; };

    class sorcerie {name = ""; sound[] = {\sounds\sorcerie.ogg, db+10,1.0}; titles[] = {}; };
    class melody   {name = ""; sound[] = {\sounds\melody.ogg, db+10,1.0}; titles[] = {}; };

    // medieval defeats (death near castles)
    class medieval_defeat  { name=""; sound[] = {\sounds\medieval_defeat.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat1 { name=""; sound[] = {\sounds\medieval\bard-melody.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat2 { name=""; sound[] = {\sounds\medieval\dark-magic.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat3 { name=""; sound[] = {\sounds\medieval\logo.ogg,db+10,1.0}; titles[] = {}; } // medievaldefeat sound
    class medieval_defeat4 { name=""; sound[] = {\sounds\medieval\medieval-introduction-2.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat5 { name=""; sound[] = {\sounds\medieval\medieval-introduction-3.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound

    class medieval_defeat6  { name=""; sound[] = {\sounds\medieval\nomen_est_omen_11.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat7  { name=""; sound[] = {\sounds\medieval\nomen_est_omen_13_1.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat8  { name=""; sound[] = {\sounds\medieval\nomen_est_omen_13_2.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat9  { name=""; sound[] = {\sounds\medieval\nomen_est_omen_13_3.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat10 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_15_1.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat11 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_15_2.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat12 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_3.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat13 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_4.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat14 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_5_1.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat15 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_5_2.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat16 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_6_1.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class medieval_defeat17 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_6_2.ogg,db+10,1.0}; titles[] = {}; } // medieval defeat sound
    class village_consort { name=""; sound[] = {\sounds\medieval\village_consort.ogg,db+10,1.0}; titles[] = {}; }       // medieval defeat sound by Kevin MacLeod

    class rammstein_1 { name=""; sound[] = {\sounds\ramm\rammstein_1.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds
    class rammstein_2 { name=""; sound[] = {\sounds\ramm\rammstein_2.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds
    class rammstein_3 { name=""; sound[] = {\sounds\ramm\rammstein_3.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds
    class rammstein_4 { name=""; sound[] = {\sounds\ramm\rammstein_4.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds
    class rammstein_5 { name=""; sound[] = {\sounds\ramm\rammstein_5.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds
    class rammstein_6 { name=""; sound[] = {\sounds\ramm\rammstein_6.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds
    class rammstein_7 { name=""; sound[] = {\sounds\ramm\rammstein_7.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds
    class rammstein_8 { name=""; sound[] = {\sounds\ramm\rammstein_8.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds
    class rammstein_9 { name=""; sound[] = {\sounds\ramm\rammstein_9.ogg,db+10,1.0}; titles[] = {}; } // From "Rammstein" defeat sounds

    class pink_floyd { name=""; sound[] = {\sounds\defeat\pink_floyd.ogg,db+10,1.0}; titles[] = {}; } // Pink Floyd, from "Shine on you Crazy Diamond"
    class pink_floyd2 { name=""; sound[] = {\sounds\defeat\pink_floyd2.ogg,db+10,1.0}; titles[] = {}; } // Pink Floyd, from "Shine on you Crazy Diamond"

    // laughter of enemy on your defeat
    class laughter_1 { name="Laughter 1"; sound[] = {\sounds\defeat\laughter\1.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_2 { name="Laughter 2"; sound[] = {\sounds\defeat\laughter\2.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_3 { name="Laughter 3"; sound[] = {\sounds\defeat\laughter\3.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_4 { name="Laughter 4"; sound[] = {\sounds\defeat\laughter\4.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_5 { name="Laughter 5"; sound[] = {\sounds\defeat\laughter\5.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_6 { name="Laughter 6"; sound[] = {\sounds\defeat\laughter\6.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_7 { name="Laughter 7"; sound[] = {\sounds\defeat\laughter\7.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_8 { name="Laughter 8"; sound[] = {\sounds\defeat\laughter\8.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_9 { name="Laughter 9"; sound[] = {\sounds\defeat\laughter\9.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_10 { name="Laughter 10"; sound[] = {\sounds\defeat\laughter\10.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_11 { name="Laughter 11"; sound[] = {\sounds\defeat\laughter\11.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class laughter_12 { name="Laughter 12"; sound[] = {\sounds\defeat\laughter\12.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat

    class good_job { name="Good Job";   sound[] = {\sounds\defeat\laughter\goodjob.ogg,db+10,1.0}; titles[] = {}; } // War cry "good job"
    class game_over { name="Good Job";   sound[] = {\sounds\defeat\laughter\game_over.ogg,db+10,1.0}; titles[] = {}; } // War cry "game over"
    class get_some { name="Good Job";   sound[] = {\sounds\defeat\laughter\get_some.ogg,db+10,1.0}; titles[] = {}; } // War cry "get some"
    class go_go_go { name="Go-go-go";   sound[] = {\sounds\defeat\laughter\go_go_go.ogg,db+10,1.0}; titles[] = {}; } // War cry "go-go-gob"
    class cheater0 { name="cheater";   sound[] = {\sounds\defeat\laughter\cheater.ogg,db+10,1.0}; titles[] = {}; } // say "cheater"
    class cheater1 { name="cheater";   sound[] = {\sounds\defeat\laughter\cheater1.ogg,db+10,1.0}; titles[] = {}; } // say "cheater"
    class cheater2 { name="cheater";   sound[] = {\sounds\defeat\laughter\cheater2.ogg,db+10,1.0}; titles[] = {}; } // say "cheater"
    class cheater3 { name="cheater";   sound[] = {\sounds\defeat\laughter\cheater3.ogg,db+10,1.0}; titles[] = {}; } // say "cheater"
    class busted { name="Busted";   sound[] = {\sounds\defeat\laughter\busted.ogg,db+10,1.0}; titles[] = {}; } // say "busted"
    class greatjob1 { name="Great job 1";   sound[] = {\sounds\defeat\laughter\great-job1.ogg,db+10,1.0}; titles[] = {}; } // say "Great job 1"
    class greatjob2 { name="Great job 2";   sound[] = {\sounds\defeat\laughter\great-job1.ogg,db+10,1.0}; titles[] = {}; } // say "Great job"
    class fight { name="fight";   sound[] = {\sounds\defeat\laughter\fight.ogg,db+10,1.0}; titles[] = {}; } // say "fight"
    class handsup { name="put your hands up";   sound[] = {\sounds\defeat\laughter\Put_Your_Hands_Up.ogg,db+10,1.0}; titles[] = {}; } // say "put your hand up"
    class indeanwarcry { name="Indean war cry"; sound[] = {\sounds\defeat\laughter\indeanwarcry.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown01 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown01.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown17 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown17.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown18 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown18.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown19 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown19.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown24 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown24.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown27 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown27.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown36 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown36.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown37 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown37.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown38 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown38.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown47 { name="One dead";   sound[] = {\sounds\defeat\laughter\targetdown47.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class bastards { name="Bastards"; sound[] = {\sounds\defeat\laughter\bastards.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class clear { name="Clear!"; sound[] = {\sounds\defeat\laughter\clear.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class shoot_MF { name="Shoot the motherfackers!"; sound[] = {\sounds\defeat\laughter\shoot_MF.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class target_neutralised { name="Target neutralized!"; sound[] = {\sounds\defeat\laughter\target_neutralised.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class tasty { name="Tasty!"; sound[] = {\sounds\defeat\laughter\tasty.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class doggy { name="Red Neck Doggy!"; sound[] = {\sounds\defeat\laughter\doggy.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class score { name="Score!"; sound[] = {\sounds\defeat\laughter\score.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat

    class disagreement_tongue { name="joy laugh"; sound[] = {\sounds\defeat\laughter\disagreement_tongue.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class joy_yes             { name="joy laugh"; sound[] = {\sounds\defeat\laughter\joy_yes.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class disagreement        { name="disagreement"; sound[] = {\sounds\defeat\laughter\disagreement.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class surprize            { name="surprize"; sound[] = {\sounds\defeat\laughter\surprize.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class sarcasm             { name="sarcasm"; sound[] = {\sounds\defeat\laughter\sarcasm.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class yes_yes2            { name="yes yes"; sound[] = {\sounds\defeat\laughter\yes_yes2.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class busted2             { name="busted"; sound[] = {\sounds\defeat\laughter\busted2.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class joy_laugh2          { name="joy laugh"; sound[] = {\sounds\defeat\laughter\joy_laugh2.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class joy_laugh           { name="joy laugh"; sound[] = {\sounds\defeat\laughter\joy_laugh.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat

    class joy2           { name=""; sound[] = {\sounds\defeat\laughter\joy2.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class joy            { name=""; sound[] = {\sounds\defeat\laughter\joy.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class yeah           { name=""; sound[] = {\sounds\defeat\laughter\yeah.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class yes_yes        { name=""; sound[] = {\sounds\defeat\laughter\yes_yes.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class yes            { name=""; sound[] = {\sounds\defeat\laughter\yes.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class good_work      { name=""; sound[] = {\sounds\defeat\laughter\good_work.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class good_job_squad { name=""; sound[] = {\sounds\defeat\laughter\good_job_squad.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class we_ve_got_them { name=""; sound[] = {\sounds\defeat\laughter\we_ve_got_them.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class soldier_down   { name=""; sound[] = {\sounds\defeat\laughter\soldier_down.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class get_down       { name=""; sound[] = {\sounds\defeat\laughter\get_down.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class hi_is_down2    { name=""; sound[] = {\sounds\defeat\laughter\hi_is_down2.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class hi_is_down     { name=""; sound[] = {\sounds\defeat\laughter\hi_is_down.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class enemy_down     { name=""; sound[] = {\sounds\defeat\laughter\enemy_down.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class auf_wiedersehen{ name=""; sound[] = {\sounds\defeat\laughter\auf_wiedersehen.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat

    // next pack of mock sounds
    class blah_blah_blah    { name=""; sound[] = {\sounds\defeat\laughter\blah-blah-blah.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class horks_and_spits   { name=""; sound[] = {\sounds\defeat\laughter\horks_and_spits.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class man_you_suck      { name=""; sound[] = {\sounds\defeat\laughter\man_you_suck.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class mocking_laugh     { name=""; sound[] = {\sounds\defeat\laughter\mocking_laugh.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class mocking_laugh_1   { name=""; sound[] = {\sounds\defeat\laughter\mocking_laugh_1.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class mocking_laugh_2   { name=""; sound[] = {\sounds\defeat\laughter\mocking_laugh_2.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class mocking_laugh_6   { name=""; sound[] = {\sounds\defeat\laughter\mocking_laugh_6.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class mommas_boy        { name=""; sound[] = {\sounds\defeat\laughter\mommas_boy.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class silly_noise       { name=""; sound[] = {\sounds\defeat\laughter\silly_noise.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class you_got_no_skills { name=""; sound[] = {\sounds\defeat\laughter\you_got_no_skills.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat

    class exclamation1 { name="";   sound[] = {\sounds\defeat\exclamations\1.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation2 { name="";   sound[] = {\sounds\defeat\exclamations\2.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation3 { name="";   sound[] = {\sounds\defeat\exclamations\3.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation4 { name="";   sound[] = {\sounds\defeat\exclamations\4.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation5 { name="";   sound[] = {\sounds\defeat\exclamations\5.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation6 { name="";   sound[] = {\sounds\defeat\exclamations\6.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class tanki { name="eclamation";   sound[] = {\sounds\defeat\tanki.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation


	// internal submarine effect sounds
    class submarine_sound_1   {name = ""; sound[] = {\sounds\submarine\submarine_sound_1.ogg, db+10, 1.0}; titles[] = {};};
    class submarine_sound_2   {name = ""; sound[] = {\sounds\submarine\submarine_sound_2.ogg, db+10, 1.0}; titles[] = {};};
    class submarine_sound_3   {name = ""; sound[] = {\sounds\submarine\submarine_sound_3.ogg, db+10, 1.0}; titles[] = {};};
    class submarine_sound_4   {name = ""; sound[] = {\sounds\submarine\submarine_sound_4.ogg, db+10, 1.0}; titles[] = {};};
    class submarine_sound_5   {name = ""; sound[] = {\sounds\submarine\submarine_sound_5.ogg, db+10, 1.0}; titles[] = {};};
    class submarine_sound_6   {name = ""; sound[] = {\sounds\submarine\submarine_sound_6.ogg, db+10, 1.0}; titles[] = {};};

    // Period of the day sounds
    class morning_1 { name="Morning: alarm-clock"; sound[] = {\sounds\timeofday\morning\alarm-clock.ogg,db+10,1.0}; titles[] = {}; } // Morning: alarm clock
    class morning_2 { name="Morning: USSR Morozko film, 1964"; sound[] = {\sounds\timeofday\morning\morozko.ogg,db+10,1.0}; titles[] = {}; } // Morning: Morozko film
    class morning_3 { name="Morning: the cry of a unnamed cock"; sound[] = {\sounds\timeofday\morning\rooster.ogg,db+10,1.0}; titles[] = {}; } // Morning: cook cry

    class evening_1 { name="Evening: ""Moscow nights"""; sound[] = {\sounds\timeofday\evening\podmoskv.ogg,db+10,1.0}; titles[] = {}; } // Evening nights (rus)
    class evening_2 { name="Evening: ""Moscow nights""  in Chinese"; sound[] = {\sounds\timeofday\evening\podm_vech_china.ogg,db+10,1.0}; titles[] = {}; } // Evening nights (chinese)
    class evening_3 { name="Evening: ""Moscow nights"" in Japan, women's voices"; sound[] = {\sounds\timeofday\evening\podm_vech_jap.ogg,db+10,1.0}; titles[] = {}; } // Evening nights (japan, women)
    class evening_4 { name="Evening: ""Moscow nights"" in Japan, men's voices"; sound[] = {\sounds\timeofday\evening\podm_vech_jap2.ogg,db+10,1.0}; titles[] = {}; } // Evening (japan, men)
    class evening_5 { name="Evening: ""The Evening bells"""; sound[] = {\sounds\timeofday\evening\vechernij_zvon.ogg,db+10,1.0}; titles[] = {}; } // The Evening bells (Nikolay Gedda)
    class evening_6 { name="Evening: ""Evening harmonica"""; sound[] = {\sounds\timeofday\evening\troshin-garmon.ogg,db+10,1.0}; titles[] = {}; } // Evening harmonica (Troshin)
    class evening_7  {name = ""; sound[] = {\sounds\timeofday\evening\shaov_dvijuha_evening.ogg, db+10, 1.0}; titles[] = {};}; // shaov_dvijuha_evening

    class night_1 { name="Night: bird?"; sound[] = {\sounds\timeofday\night\amb2.ogg,db+10,1.0}; titles[] = {}; } // Evening nights (rus)
    class night_2 { name="Night: wolfs?"; sound[] = {\sounds\timeofday\night\amb3.ogg,db+10,1.0}; titles[] = {}; } // Evening nights (chinese)
    class night_3 { name="Night: Cool Vibes by Kevin MacLeod"; sound[] = {\sounds\timeofday\night\night.ogg,db+10,1.0}; titles[] = {}; } // Evening nights (japan, women)
    class night_4 { name="Night: real nightingail"; sound[] = {\sounds\timeofday\night\night_birds.ogg,db+10,1.0}; titles[] = {}; } // Evening (japan, men)
    class night_5 { name="Night: Gavriil Popov, 1998, OST 'Okraina'"; sound[] = {\sounds\timeofday\night\night2.ogg,db+10,1.0}; titles[] = {}; } // The Evening bells (Nikolay Gedda)
    class night_6 { name="Night: Steve Roach, Kevin Braheny, Michael Stearns - album 'Desert Solitare', 1989"; sound[] = {\sounds\timeofday\night\night_labyrinth.ogg,db+10,1.0}; titles[] = {}; } // Some music for night period

    // ordinal defeats
    class armory1  { name=""; sound[] = {\sounds\short\armory\armory1.ogg,db+10,1.0}; titles[] = {}; } // Armory store event 1
    class armory2  { name=""; sound[] = {\sounds\short\armory\armory2.ogg,db+10,1.0}; titles[] = {}; } // Armory store event 2
    class armory3  { name=""; sound[] = {\sounds\short\armory\armory3.ogg,db+10,1.0}; titles[] = {}; } // Armory store event 3
    class armory4  { name=""; sound[] = {\sounds\short\armory\armory4.ogg,db+10,1.0}; titles[] = {}; } // Armory store event 4
    class armory5  { name=""; sound[] = {\sounds\short\armory\armory5.ogg,db+10,1.0}; titles[] = {}; } // Armory sound event 5

    class chiz_tanki_1   {name = "Чиж. 'По танку вдарила болванка...'"; sound[] = {\sounds\defeat\chiz_tanki_1.ogg, db+10, 1.0}; titles[] = {}; }; // "The tank was hit by a dummy..." song of the ensemble " Chizh"
    class chiz_tanki_2   {name = "Чиж. 'Нас извлекут из под обломков...'"; sound[] = {\sounds\defeat\chiz_tanki_2.ogg, db+10, 1.0}; titles[] = {}; }; // "We will be pulled from under the rubble..." song of the ensemble " Chizh"
    class tanki_grohotaly   {name = "На поел танки грохотали из фильма 'На войне как на войне' (1968)"; sound[] = {\sounds\defeat\tanki_grohotaly.ogg, db+10, 1.0}; titles[] = {}; }; // "Tanks rumbled in the field" "Tanks were rumbling in the field" folk song from the war 1941-1945 times

    class whatsapp       {name = "From WhatsApp msg"; sound[] = {\sounds\defeat\whatsapp.ogg, db+10, 1.0}; titles[] = {}; }; // Some sound from one of WhatsApp messages
    class upbeat         {name = "From WhatsApp msg"; sound[] = {\sounds\defeat\upbeat.ogg, db+10, 1.0}; titles[] = {}; }; // Some sound from one of WhatsApp messages
    class kk_jungles     {name = "King-Kong"; sound[] = {\sounds\defeat\kk-jungles.ogg, db+10, 1.0}; titles[] = {}; }; // Sound from film "King-Kong" (1976)
    class shaov_defeat   {name = ""; sound[] = {\sounds\defeat\shaov_dvijuha_defeat.ogg, db+10, 1.0}; titles[] = {};};

    // Ranks messages
    // for Russian language only
    class sergeant_eng_1   {name = "Yes Sergeant"; sound[] = {\sounds\intro\ranks\seargent-eng-1.ogg, db+10, 1.0}; titles[] = {}; };
    class corporal_eng_1   {name = "Yes Corporal"; sound[] = {\sounds\intro\ranks\corporal-eng-1.ogg, db+10, 1.0}; titles[] = {}; };

    class captain_rus_1   {name = "Captain please smile, USSR film 'Captain grant children'"; sound[] = {\sounds\intro\ranks\captain-rus-1.ogg, db+10, 1.0}; titles[] = {}; };
    class captain_rus_2   {name = "Captain pull up!, USSR film 'Captain grant children'"; sound[] = {\sounds\intro\ranks\captain-rus-2.ogg, db+10, 1.0}; titles[] = {}; };
    class colonel_rus_1   {name = "Полковнику никто не пишет, Би-2 (херня ансамбль)"; sound[] = {\sounds\intro\ranks\colonel-rus-1.ogg, db+10, 1.0}; titles[] = {}; }; // "Nobody write to colonel" song of Bi-2 band
    class colonel_rus_2   {name = "Полковника никто не ждёт, Би-2 (херня ансамбль)";  sound[] = {\sounds\intro\ranks\colonel-rus-2.ogg, db+10, 1.0}; titles[] = {}; }; // "Nobody waits for the colonel" song of Bi-2 band

    class damaged         {name = "Damaged, by robot woman"; sound[]  = {\sounds\women\damaged.ogg, db+10, 1.0}; titles[] = {};};
    class damaging        {name = "Damaging, by robot woman"; sound[] = {\sounds\women\damaging.ogg, db+10, 1.0}; titles[] = {};};
    class teleporter_disabled {name = "Disabled, by robot woman"; sound[] = {\sounds\women\teleporter_disabled.ogg, db+10, 1.0}; titles[] = {};};

//    class teleporter_enabled  {name = "Enabled by robot woman"; sound[] = {\sounds\women\teleporter_enabled.ogg, db+10, 1.0}; titles[] = {};};
//    class first_teleporter  {name = "1st tp by robot woman"; sound[] = {\sounds\women\first_teleporter.ogg, db+10, 1.0}; titles[] = {};};
//    class second_teleporter  {name = "2nd tp by robot woman"; sound[] = {\sounds\women\second_teleporter.ogg, db+10, 1.0}; titles[] = {};};
    class base  {name = "2nd by robot woman"; sound[] = {\sounds\women\base.ogg, db+10, 1.0}; titles[] = {};};
    class warning  {name = "warning by robot woman"; sound[] = {\sounds\women\warning.ogg, db+10, 1.0}; titles[] = {};};
    class down  {name = "down by robot woman"; sound[] = {\sounds\women\down.ogg, db+10, 1.0}; titles[] = {};};
    class disabled  {name = "disabled by robot woman"; sound[] = {\sounds\women\disabled.ogg, db+10, 1.0}; titles[] = {};};
    class one  {name = "one by robot woman"; sound[] = {\sounds\women\one.ogg, db+10, 1.0}; titles[] = {};};
    class two  {name = "two by robot woman"; sound[] = {\sounds\women\two.ogg, db+10, 1.0}; titles[] = {};};
    class crashed  {name = "crashed by robot woman"; sound[] = {\sounds\women\crashed.ogg, db+10, 1.0}; titles[] = {};};

//    class beep     {name = "beep once"; sound[] = {\sounds\short\beep.ogg, db+10, 1.0}; titles[] = {};};
//    class beepbeep  {name = "beep twice"; sound[] = {\sounds\short\beepbeep.ogg, db+10, 1.0}; titles[] = {};};

    class set_marker  {name = "beep twice"; sound[] = {\sounds\short\set_marker.ogg, db+10, 1.0}; titles[] = {};};
    class on          {name = "switch on"; sound[] = {\sounds\short\on.ogg, db+10, 1.0}; titles[] = {};};
    class off         {name = "switch off"; sound[] = {\sounds\short\off.ogg, db+10, 1.0}; titles[] = {};};


// SM hostages
    class hisp1   { name=""; sound[] = {\sounds4\sm\hostages\hisp_excl_1.ogg,db-1,1.0}; titles[] = {};};
    class hisp2   { name=""; sound[] = {\sounds\sm\hostages\hisp_excl_2.ogg,db-1,1.0}; titles[] = {};};
    class hisp3   { name=""; sound[] = {\sounds\sm\hostages\hisp_excl_3.ogg,db-1,1.0}; titles[] = {};};
    class hisp4   { name=""; sound[] = {\sounds\sm\hostages\hisp_excl_4.ogg,db-1,1.0}; titles[] = {};};

// SM 49
    class eng_grant_surrend { name=""; sound[] = {\sounds\sm\49\eng_grant_surrend.ogg,db-1,1.0}; titles[] = {};};
    class ger_grant_surrend { name=""; sound[] = {\sounds\sm\49\ger_grant_surrend.ogg,db-1,1.0}; titles[] = {};};
    class eng_grant_intro   { name=""; sound[] = {\sounds\sm\49\eng_grant_intro.ogg,db-1,1.0}; titles[] = {};};
    class ger_grant_intro   { name=""; sound[] = {\sounds\sm\49\ger_grant_intro.ogg,db-1,1.0}; titles[] = {};};

    class money1 { name="Money by Pink Floyd";                sound[] = {\sounds\sm\45\money.ogg,db-1,1.0}; titles[] = {};}; // Money by Pink Floyd
    class money2 { name="Money by Pink Floyd prelude";        sound[] = {\sounds\sm\45\money1.ogg,db-1,1.0}; titles[] = {};}; // Coins dropping, by Pink Floyd

    class pilots_resque1 { name="Resque mission sound intro"; sound[] = {\sounds\sm\pilots\pilots_resque1.ogg,db-1,1.0}; titles[] = {};};
    class pilots_resque2 { name="Resque mission sound intro"; sound[] = {\sounds\sm\pilots\pilots_resque2.ogg,db-1,1.0}; titles[] = {};};
    class pilots_resque3 { name="Resque mission sound intro"; sound[] = {\sounds\sm\pilots\pilots_resque3.ogg,db-1,1.0}; titles[] = {};};

    class flag_captured  { name="Captured flag";              sound[] = {\sounds\sm\flag\flag_captured.ogg,db-1,1.0}; titles[] = {};};
    class flag_lost      { name="Lost flag";                  sound[] = {\sounds\sm\flag\flag_lost.ogg,db-1,1.0}; titles[] = {};};

// SM 57: capturing sea devil
    class sea_devil1     { name=""; sound[] = {\sounds\sm\57\sailing_too_long.ogg,db-1,1.0}; titles[] = {};}; // Song about "Sea devil" from USSR film "The Amphibian man"
    class sea_devil2     { name=""; sound[] = {\sounds\sm\57\sea_devil.ogg,db-1,1.0}; titles[] = {};}; // "Sea devil" exclamation

    // water splash effects
    class under_water_1   {name = ""; sound[] = {\sounds\defeat\water\under_water1.ogg, db+10, 1.0}; titles[] = {};};
    class under_water_2   {name = ""; sound[] = {\sounds\defeat\water\under_water2.ogg, db+10, 1.0}; titles[] = {};};
    class under_water_3   {name = ""; sound[] = {\sounds\defeat\water\under_water3.ogg, db+10, 1.0}; titles[] = {};};
    class under_water_4   {name = ""; sound[] = {\sounds\defeat\water\under_water4.ogg, db+10, 1.0}; titles[] = {};};
    class under_water_5   {name = ""; sound[] = {\sounds\defeat\water\under_water5.ogg, db+10, 1.0}; titles[] = {};};
    class under_water_6   {name = ""; sound[] = {\sounds\defeat\water\under_water6.ogg, db+10, 1.0}; titles[] = {};};
    class under_water_7   {name = ""; sound[] = {\sounds\defeat\water\under_water7.ogg, db+10, 1.0}; titles[] = {};};
    class under_water_8   {name = ""; sound[] = {\sounds\defeat\water\under_water8.ogg, db+10, 1.0}; titles[] = {};};
    class under_water_9   {name = ""; sound[] = {\sounds\defeat\water\under_water9.ogg, db+10, 1.0}; titles[] = {};};
    class fish_man_song   {name = ""; sound[] = {\sounds\defeat\water\fish_man_song.ogg, db+10, 1.0}; titles[] = {};};

    class enemy_attacks_base {     name = "On base attack event in Russian"; sound[] = {\sounds\onbase\enemy_attack.ogg, db+10, 1.0}; titles[] = {};};    // base attack additional sound
    class enemy_attacks_base_robot {name = "On base attack event by female robot"; sound[] = {\sounds\onbase\enemy_attack_robot_voice.ogg, db+10, 1.0}; titles[] = {};};    // ...

    class tuman {name = "Fog has fallen on airfield runway"; sound[] = {\sounds\weather\tuman.ogg, db+10, 1.0}; titles[] = {};};    // Song of and by Yuri Vizbor

	// Lighthouse sounds
    class lighthouse_1    {name = "Lighthouse 1"; sound[] = {\sounds\timeofday\night\lighthouse\Lighthouse_v01.ogg, db+10, 1.0}; titles[] = {};};    // Lighthouse 1
    class lighthouse_2    {name = "Lighthouse 2"; sound[] = {\sounds\timeofday\night\lighthouse\Lighthouse_v02.ogg, db+10, 1.0}; titles[] = {};};    // Lighthouse 2
    class lighthouse_3    {name = "Lighthouse 3"; sound[] = {\sounds\timeofday\night\lighthouse\Lighthouse_v03.ogg, db+10, 1.0}; titles[] = {};};    // Lighthouse 3
    class lighthouse_4    {name = "Lighthouse 4"; sound[] = {\sounds\timeofday\night\lighthouse\Lighthouse_v04.ogg, db+10, 1.0}; titles[] = {};};    // Lighthouse 4
    class lighthouse_5    {name = "Lighthouse 5"; sound[] = {\sounds\timeofday\night\lighthouse\lhhorn01.ogg.ogg, db+10, 1.0}; titles[] = {};};      // Lighthouse 5
    class lighthouse_6    {name = "Lighthouse 6"; sound[] = {\sounds\timeofday\night\lighthouse\lhhorn02.ogg, db+10, 1.0}; titles[] = {};};    		 // Lighthouse 6

    // power down sounds
    class powerdown1    {name = ""; sound[] = {\sounds\short\power_down\PowerDown1.ogg, db+10, 1.0}; titles[] = {};};
    class powerdown2    {name = ""; sound[] = {\sounds\short\power_down\PowerDown2.ogg, db+10, 1.0}; titles[] = {};};
    class powerdown3    {name = ""; sound[] = {\sounds\short\power_down\PowerDown3.ogg, db+10, 1.0}; titles[] = {};};
    class powerdown4    {name = ""; sound[] = {\sounds\short\power_down\PowerDown4.ogg, db+10, 1.0}; titles[] = {};};
    class powerdown5    {name = ""; sound[] = {\sounds\short\power_down\PowerDown5.ogg, db+10, 1.0}; titles[] = {};};
    class powerdown6    {name = ""; sound[] = {\sounds\short\power_down\PowerDown6.ogg, db+10, 1.0}; titles[] = {};};
    class teleport_dmg  {name = ""; sound[] = {\sounds\short\power_down\teleport_dmg.ogg, db+10, 1.0}; titles[] = {};};
    class tvpowerdown   {name = ""; sound[] = {\sounds\short\power_down\tvtower_powerdown.ogg, db+10, 1.0}; titles[] = {};};
    class towerdown     {name = ""; sound[] = {\sounds\radio\towerDown.ogg, db+10, 1.0}; titles[] = {};};


#ifdef __WITH_SCALAR__
	class scalarDown {name="scalarDown";sound[] = {"\sounds\scalarDown.ogg",1,1};titles[] = {};};
#endif

#ifdef __REVIVE__
	class DBrian_Im_hit {
		name="Brian_Im_hit";
		sound[]={"\sounds\UNIV_v05.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Im_bleeding {
		name="Brian_Im_bleeding";
		sound[]={"\sounds\UNIV_v06.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Medic {
		name="Brian_Medic";
		sound[]={"\sounds\UNIV_v07.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Bastards {
		name="Brian_Bastards";
		sound[]={"\sounds\UNIV_v10.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Shit_Man_down {
		name="Brian_Shit_Man_down";
		sound[]={"\sounds\UNIV_v11.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Oh_no {
		name="Brian_Oh_no";
		sound[]={"\sounds\UNIV_v18.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Fuck {
		name="Brian_Fuck";
		sound[]={"\sounds\UNIV_v24.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Fuck_it {
		name="Brian_Fuck_it";
		sound[]={"\sounds\UNIV_v25.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Shit {
		name="Brian_Shit";
		sound[]={"\sounds\UNIV_v31.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_Need_help {
		name="Brian_Need_help";
		sound[]={"\sounds\UNIV_v50.ogg",0.05,1.0};
		titles[]={};
	};
	class DBrian_A_little_help_here {
		name="Brian_A_little_help_here";
		sound[]={"\sounds\UNIV_v51.ogg",0.05,1.0};
		titles[]={};
	};
#endif

//+++++++++++++++++++++++++++++++++++++++++++++ INTRO MUSIC +++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++ Detect town music, if added, seek and add to the 'case "mt_spotted":' code in the file "x_netinitclient.sqf"

    class detected_Arcadia { name=""; sound[] = {\sounds\locations\Benny_Hill_Paradise_2006.ogg,db-1,1.0}; titles[] = {}; }; // town detected music (Arcadia)
    class detected_Paraiso { name=""; sound[] = {\sounds\locations\Paraiso.ogg,db-1,1.0}; titles[] = {}; }; // town detected music (Paraiso)
    class detected_Carmen  { name=""; sound[] = {\sounds\locations\toreador.ogg,db-1,1.0}; titles[] = {}; }; // town detected music (Carmen)
    class detected_Rahmadi { name=""; sound[] = {\sounds\locations\Rahmadi.ogg,db-1,1.0}; titles[] = {}; }; // town detected music (Rahmadi)
    class detected_Eponia  { name="Banzai, 1983"; sound[] = {\sounds\locations\Banzai.ogg,db-1,1.0}; titles[] = {}; }; // town detected music (Eponia)
    class detected_Cayo    { name="Cayo"; sound[] = {\sounds\locations\Cayo_Hottabych.ogg,db-1,1.0}; titles[] = {}; }; // town detected music (Cayo, from soviet film "Old man Hottabych", 1958)

// Revolution day intro music
	class Varshavianka         { name = "";sound[] = {\sounds\Varshavianka.ogg, db+20, 1.0}; titles[] = {};}; // russian
	class Varshavianka_eng     { name = "";sound[] =  {\sounds\Varshavianka_eng.ogg, db+20, 1.0}; titles[] = {};}; // english
	class warschawyanka_german { name = "";sound[] =  {\sounds\warschawyanka_german.ogg, db+10, 1.0}; titles[] = {};}; // german

	class grant { name = ""; sound[] =  {\sounds\grant.ogg, db+20, 1.0}; titles[] = {};};

// New year intro musics
	class snovymgodom   { name=""; sound[] = {\sounds\newyear\snovymgodom.ogg, db+20, 1.0}; titles[] = {};};
	class nutcracker    { name=""; sound[] = {\sounds\newyear\NutCracker.ogg, db+20, 1.0}; titles[] = {};};
    class home_alone    { name=""; sound[] = {\sounds\newyear\home_alone.ogg,db+10,1.0}; titles[] = {};}; // From "Home alone" american movie 1990
    class zastolnaya    { name=""; sound[] = {\sounds\newyear\zastolnaya.ogg,db-1,1.0}; titles[] = {};}; // intro New Year music
    class grig          { name=""; sound[]=   {\sounds\newyear\grig.ogg,db-1,1.0}; titles[] = {};};
    class merry_xmas    { name=""; sound[] = {\sounds\newyear\merry_xmas.ogg,db+0,1.0}; titles[] = {};}; // Merry Xmas melody by Kevin Macleod
    class vangelis      { name=""; sound[] = {\sounds\newyear\vangelis.ogg,db+0,1.0}; titles[] = {};}; // Vangelis - "La petite fille de la mer", 1973

	class stavka_bolshe_chem { name=""; sound[]={\sounds\intro\stavka_bolshe_chem.ogg,db-1,1.0}; titles[] = {};};
    class four_tankists { name="Czterej Pancerni i Pies, Polska Rzeczpospolita Ludowa film, 1960"; sound[] = {\sounds\intro\4tankists.ogg,db-1,1.0}; titles[] = {};}; // from PRL film "4 tankists and dog"

	// define some music (for Rokse [LT]) as sounds to debug "burnash","johnny","druzba","adjutant","vague","enchanted_boy","ahead_friends","mission_impossible","lastdime","lastdime2","lastdime3","esli_ranili_druga","soviet_officers","travel_with_friends","on_thin_ice:
	class burnash	{ name="";	      sound[]=   {\sounds\burnash.ogg,db-1,1.0}; titles[] = {};    };
	class johnny    { name="";        sound[]=   {\sounds\johnny.ogg,db-1,1.0}; titles[] = {};     };
	class druzba    { name="";        sound[]=   {\sounds\druzba.ogg,db-1,1.0}; titles[] = {};    };
	class adjutant  { name="";        sound[]=   {\sounds\adjutant.ogg,db-1,1.0}; titles[] = {};    };
//	class vague     { name="";        sound[]=   {\sounds\intro\vague.ogg,db-1,1.0}; titles[] = {};  };
	class enchanted_boy { name="";    sound[]=   {\sounds\intro\enchanted_boy.ogg,db-1,1.0}; titles[] = {}; };
	class dangerous_chase { name="";    sound[]=   {\sounds\intro\dangerous_chase.ogg,db-1,1.0}; titles[] = {}; }; // From Japab file 1976

	class          ahead_friends { name=""; sound[]= {\sounds\ahead_friends.ogg,db-1,1.0}; titles[] = {}; };
	class     mission_impossible { name=""; sound[]= {\sounds\mission_impossible.ogg,db-1,1.0}; titles[] = {}; };
	class               lastdime { name=""; sound[]= {\sounds\intro\lastdime.ogg,db-1,1.0}; titles[] = {};  };
//    class              lastdime1 { name=""; sound[]= {\sounds\intro\lastdime1.ogg,db-1,1.0};  titles[] = {};    };
	class              lastdime2 { name=""; sound[]= {\sounds\intro\lastdime2.ogg,db-1,1.0}; titles[] = {};    };
	class              lastdime3 { name=""; sound[]= {\sounds\intro\lastdime3.ogg,db-1,1.0}; titles[] = {};  };
	class      esli_ranili_druga { name=""; sound[]= {\sounds\intro\esli_ranili_druga.ogg,db-1,1.0}; titles[] = {};    };
	class        soviet_officers { name=""; sound[]= {\sounds\intro\holidays\feb_23\soviet_officers.ogg,db-1,1.0}; titles[] = {};  };
//	class    travel_with_friends { name=""; sound[]= {\sounds\intro\travel_with_friends.ogg,db-1,1.0}; titles[] = {};  }; // Sovier children song
	class            on_thin_ice { name=""; sound[]= {\sounds\intro\on_thin_ice.ogg,db-1,1.0}; titles[] = {};  }; // from Soviet film "On thin ice"

//    class Art_Of_Noise_mono { name=""; sound[] = {\sounds\Art_Of_Noise_mono.ogg,db-1,1.0}; titles[] = {}; }; // used in intro
//	class robinson_crusoe { name=""; sound[] = {\sounds\intro\robinson_crusoe.ogg,db-1,1.0}; titles[] = {};}; // used in intro
    class dem_morgenrot_entgegen { name=""; sound[] = {\sounds\dem_morgenrot_entgegen.ogg,db-1,1.0}; titles[] = {};}; // used in  intro
    class from_russia_with_love { name=""; sound[] = {\sounds\from_russia_with_love.ogg,db-1,1.0}; titles[] = {};}; // used in  intro, only for resque players
//    class prince_negaafellaga { name=""; sound[] = {\sounds\prince_negaafellaga.ogg,db-1,1.0}; titles[] = {};}; // used in  intro
    class strelok { name=""; sound[] = {\sounds\strelok.ogg,db-1,1.0}; titles[] = {};}; // used in  intro
    class bloody { name=""; sound[] = {\sounds\bloody.ogg,db-1,1.0}; titles[] = {};}; // intro music from "Bloody diamond" movie
    class total_recall_mountain { name=""; sound[] = {\sounds\total_recall_mountain.ogg,db-1,1.0}; titles[] = {};}; // intro music from "Total recall" movie (The Mountain)
//    class comrade_my { name=""; sound[] = {\sounds\comrade_my.ogg,db+10,1.0}; titles[] = {}; }; // intro music from Soviet song "Comrade mine"
    class capricorn1title { name=""; sound[] = {\sounds\capricorn1title.ogg,db+20,1.0}; titles[] = {};}; // intro music from great american movie "Capricorn-1"
    class Letyat_perelyotnye_pticy_2nd { name=""; sound[] = {\sounds\Letyat_perelyotnye_pticy_2nd.ogg,db+20,1.0}; titles[] = {};}; // intro music from Soviet great song (1950)
    class Letyat_perelyotnye_pticy_end { name=""; sound[] = {\sounds\Letyat_perelyotnye_pticy_end.ogg,db+20,1.0}; titles[] = {};}; // intro music #2 (final verse) from the same Soviet great song (1950)

//    class adagio { name=""; sound[] = {\sounds\adagio.ogg,db+20,1.0}; titles[] = {};}; // intro music from Soviet great film Gussar Ballad (1962)
    class ruffian { name=""; sound[] = {\sounds\ruffian.ogg,db+20,1.0}; titles[] = {};}; // Intro music from the French film
    class amigohome_ernst_bush { name=""; sound[] = {\sounds\amigohome_ernst_bush.ogg,db+0,1.0}; titles[] = {};}; // Ami go home by Ernsh Busch, DDR communust and great singer!
    class treasure_island_intro { name=""; sound[] = {\sounds\treasure_island_intro.ogg,db+0,1.0}; titles[] = {};}; // treasure island intro theme (from the eponymous soviet  film of 1971)
    class fear2 { name=""; sound[] = {\sounds\fear2.ogg,db+0,1.0}; titles[] = {};}; // Some fear music
//    class chapaev { name=""; sound[] = {\sounds\chapaev.ogg,db+0,1.0}; titles[] = {};}; // USSR film Chapaev
//    class cosmos { name=""; sound[] = {\sounds\cosmos.ogg,db+0,1.0}; titles[] = {};}; // Cosmic music
    class manchester_et_liverpool { name=""; sound[] = {\sounds\weather\manchester_et_liverpool.ogg,db+0,1.0}; titles[] = {};}; // Well known melody
    class rider { name=""; sound[] = {\sounds\rider.ogg,db+0,1.0}; titles[] = {};}; // Dean Reed song "Rider"
    class hound_baskervill { name=""; sound[] = {\sounds\hound_baskervill.ogg,db+0,1.0}; titles[] = {};}; // USSR famous film "Hound of Baskervill hall"
    class condor { name=""; sound[] = {\sounds\condor.ogg,db+0,1.0}; titles[] = {};}; // El-Condor-Pasa by Leo Rojas
    class way_to_dock { name=""; sound[] = {\sounds\way_to_dock.ogg,db+0,1.0}; titles[] = {};}; // melody from Soviet film "Way to dock" ("Дорога к причалу")
    class Vremia_vpered_Sviridov { name=""; sound[] = {\sounds\Vremia_vpered_Sviridov.ogg,db+0,1.0}; titles[] = {};}; // melody from Soviet film "Way to dock" ("Дорога к причалу")
    class melody_by_voice { name=""; sound[] = {\sounds\melody_by_voice.ogg,db+0,1.0}; titles[] = {};}; // melody from Charles Wilp - Mad. Ave. Perfume Ad
    class tovarich_moy { name=""; sound[] = {\sounds\tovarich_moy.ogg,db-1,1.0}; titles[] = {};};// intro music, Soviet song about comrade
    class sovest1 { name=""; sound[] = {\sounds\intro\sovest1.ogg,db-1,1.0}; titles[] = {};}; // intro music, Soviet song from film "consciousness"
    class sovest2 { name=""; sound[] = {\sounds\intro\sovest2.ogg,db-1,1.0}; titles[] = {};}; // intro music, Soviet song from film "consciousness"
    class bond { name=""; sound[] = {\sounds\intro\bond.ogg,db-1,1.0}; titles[] = {};}; // intro music, one of the James Bond film main theme (don't remember)
//    class bond1 { name=""; sound[] = {\sounds\intro\bond1.ogg,db-1,1.0}; titles[] = {};}; // intro music, one of the James Bond film main theme (don't remember)
    class toccata { name="toccata-and-fugue-in-d-minor-by-kevin-macleod"; sound[] = {\sounds\intro\toccata.ogg,db-1,1.0}; titles[] = {};}; // intro music, J.S. Bach tocatta
//    class del_vampiro1 { name="L'amante del Vampiro, Italian film, 1960"; sound[] = {\sounds\intro\del_vampiro1.ogg,db-1,1.0}; titles[] = {};}; // intro music, Italian film "L'amante del Vampiro"
//    class del_vampiro2 { name="L'amante del Vampiro, Italian film, 1960"; sound[] = {\sounds\intro\del_vampiro2.ogg,db-1,1.0}; titles[] = {};}; // intro music, Italian film "L'amante del Vampiro"
    class zaratustra { name="Thus Sprach Zarathustra, Richard Strauss"; sound[] = {\sounds\intro\zaratustra.ogg,db-1,1.0}; titles[] = {};}; // intro music, "Thus Sprach Zarathustra", Richard Strauss
    class bolivar { name="'The roads we take' film music, 1962, Leonid Haiday"; sound[] = {\sounds\intro\bolivar.ogg,db-1,1.0}; titles[] = {};}; // intro music
    class peregrinus { name="'Alexander Nevsky' film music by Sergei Prokofiev, 1938, episode 'Expectans Peregrinus'"; sound[] = {\sounds\intro\peregrinus.ogg,db-1,1.0}; titles[] = {};}; // intro music

//+++++++++++++++++++++++++++++++++++++ MORZE for Rokse [LT] +++++++++++++++++++++++++++++++++++++++++++++++++++++
    class morze   { name="Morze about Sahrani island"; sound[] = {\sounds\intro\morze\morze.ogg,db+0,1.0}; titles[] = {};}; // Morze packed message in Russian...
    class morze2  { name="Real Morze (Canada)"; sound[] = {\sounds\intro\morze\morze2.ogg,db+0,1.0}; titles[] = {};}; // Morze real message (Canada)
    class morze_0 { name="Morzyanka";   sound[] = {\sounds\intro\morze\Morzyanka.ogg,db+0,1.0}; titles[] = {};}; // Morze
    class morze_2 { name="Morzyanka 2"; sound[] = {\sounds\intro\morze\Morzyanka2.ogg,db+0,1.0}; titles[] = {};}; // Morze
    class morze_3 { name="Morzyanka - 1965 USSR song"; sound[] = {\sounds\intro\morze\Morzyanka3.ogg,db+0,1.0}; titles[] = {};}; // Morze
    class morze_4 { name="Morzyanka 4"; sound[] = {\sounds\intro\morze\Morzyanka4.ogg,db+0,1.0}; titles[] = {};}; // Morze
    class morze_5 { name="Morzyanka 5"; sound[] = {\sounds\intro\morze\Morzyanka5.ogg,db+0,1.0}; titles[] = {};}; // Morze
    class morze_6 { name="Morzyanka 6"; sound[] = {\sounds\intro\morze\Morzyanka6.ogg,db+0,1.0}; titles[] = {};}; // Morze
    class morze_7 { name="Morzyanka 7"; sound[] = {\sounds\intro\morze\Morzyanka7.ogg,db+0,1.0}; titles[] = {};}; // Morze

    class hungarian_dances { name="Brams, Hungarian Dances"; sound[] = {\sounds\intro\hungarian_dances.ogg,db+0,1.0}; titles[] = {};}; // For Hungarian players
//    class jrtheme { name="USA film jack Reacher theme"; sound[] = {\sounds\intro\jrtheme.ogg,db+0,1.0}; titles[] = {};}; // Simply majestic music
    class farewell_slavs { name="Farewell of Slavs, Russian march"; sound[] = {\sounds\intro\farewell_slavs.ogg,db+0,1.0}; titles[] = {};}; // Well known military march of old Russian Emmpire
//    class jaws    {name = "Jaws Title"; sound[] = {\sounds\intro\jaws.ogg, db+10, 1.0}; titles[] = {};}; // from "Jaws" film
    class wild_geese {name = "Film 'The Wild Geese' theme"; sound[] = {\sounds\intro\wild_geese.ogg, db+10, 1.0}; titles[] = {};}; // from "The Wild geese" film
    class pink_floyd_diamond {name = ""; sound[] = {\sounds\intro\pink_floyd_diamond.ogg, db+10, 1.0}; titles[] = {};}; // Pink Floyd "Shine on you Crazy Diamond" 1975, intro
    class desperate_housewives {name = ""; sound[] = {\sounds\intro\desperate_housewives.ogg, db+10, 1.0}; titles[] = {};}; // Film "Desperate housewives", 2004, USA
    class squid_game {name = ""; sound[] = {\sounds\intro\squid_game.ogg, db+10, 1.0}; titles[] = {};}; // Film "Squid Game", 2021, South Korea

//+++++++++++++++++++++++ Holiday music

    class cosmos_1 { name="Earth attraction";                           sound[] = {\sounds\intro\holidays\apr_12\Earth_attraction.ogg,db-1,1.0}; titles[] = {};}; // Cosmonoutics day 12 of April
    class cosmos_2 { name="I trust, my friends";                        sound[] = {\sounds\intro\holidays\apr_12\I_trust_my_friends.ogg,db-1,1.0}; titles[] = {};}; // Cosmonoutics day 12 of April
    class cosmos_3 { name="You know what kind of guy He was (Gagarin)"; sound[] = {\sounds\intro\holidays\apr_12\YouKnowWhatKindOfGuyHeWas.ogg,db-1,1.0}; titles[] = {};}; // Cosmonoutics day 12 of April
    class lenin    { name="And again the battle continues";             sound[] = {\sounds\intro\holidays\apr_22\lenin.ogg,db-1,1.0}; titles[] = {};}; // Birthday of V.I. Lebin
    class lenin_1  { name="Day by day are years go";                    sound[] = {\sounds\intro\holidays\apr_22\lenin_1.ogg,db-1,1.0}; titles[] = {};}; // Birthday of V.I. Lebin
	class invasion { name="invasion";                                   sound[] = {\sounds\invasion.ogg,db+0,1.0}; titles[] = {};}; // Invasion - Shostakovitch
    class hugging_the_sky { name="Hugging the sky...";                  sound[] = {\sounds\intro\holidays\aug_18\hugging_the_sky.ogg,db-1,1.0}; titles[] = {};}; // Soviet air fleet day
    class we_teach_planes_to_fly { name="We teach planes to fly...";    sound[] = {\sounds\intro\holidays\aug_18\we_teach_planes_to_fly.ogg,db-1,1.0}; titles[] = {};}; // Soviet air fleet day
    class aviamarch_rus { name="Мы рождены чтоб сказку сделать былью";  sound[] = {\sounds\intro\holidays\aug_18\aviamarch_rus.ogg,db-1,1.0}; titles[] = {};}; // Soviet air fleet day
    class aviamarch_eng { name="We were born to make a fairy tale come true";  sound[] = {\sounds\intro\holidays\aug_18\aviamarch_eng.ogg,db-1,1.0}; titles[] = {};}; // Soviet air fleet day
    class aviamarch_ger { name="Drum höher und höher und höher..";      sound[] = {\sounds\intro\holidays\aug_18\aviamarch_ger.ogg,db-1,1.0}; titles[] = {};}; // Soviet air fleet day
    class communism { name="We will live in communism...";              sound[] = {\sounds\intro\holidays\nov_7\communism.ogg,db-1,1.0}; titles[] = {};}; // Last Soviet Constitution day (1977)
    class komsomol { name="И вновь продолжается бой";                   sound[] = {\sounds\intro\holidays\oct_29\komsomol.ogg,db-1,1.0}; titles[] = {};}; // Komsomal Day!(1918)
    class ddrhymn  { name="DDR Day";                                    sound[] = {\sounds\intro\ddrhymn.ogg,db-1,1.0}; titles[] = {};}; // DDR Day!(1949)
    class border_guards  { name="Day of Border Guards";                 sound[] = {\sounds\intro\holidays\may_28\border_guards.ogg,db-1,1.0}; titles[] = {};}; // Day of Border Guards
    class uchat_v_shkole { name="1st September - School day";           sound[] = {\sounds\intro\holidays\sep_1\uchat_v_shkole.ogg,db-1,1.0}; titles[] = {};}; // Day of School
    class march_of_soviet_tankmen { name="2nd Sunday of September ";    sound[] = {\sounds\intro\holidays\tankist_day\march_of_soviet_tankmen.ogg,db-1,1.0}; titles[] = {};}; // Day of School
    // march_of_soviet_tankmen.ogg
    class Hungary    { name="Hungary day";                              sound[] = {\sounds\intro\holidays\Hungary.ogg,db-1,1.0}; titles[] = {};}; // Day of Hungarian Peple Republic
    class kk_the_hole { name="King-Kong film, the hole";                sound[] = {\sounds\intro\kk_the_hole.ogg,db-1,1.0}; titles[] = {};}; // Kin-Kong 1976 film, The hole eposode
    class jimmy_dont_miss { name="";                					sound[] = {\sounds\intro\jimmy_dont_miss.ogg,db-1,1.0}; titles[] = {};}; // Kin-Kong 1976 film, The hole eposode
    class everybody_knows { name="";                					sound[] = {\sounds\intro\everybody_knows.ogg,db-1,1.0}; titles[] = {};}; // "War Dogs" 2016, final titles songs
    class cosma_maldonne { name="";                					    sound[] = {\sounds\intro\cosma_maldonne.ogg,db-1,1.0}; titles[] = {};}; // "Vladimir Cosma - Maldonne" film


//--------------------------------------------- INTRO/DESANTSM MUSIC -------------------------------------------

    class usa_desant_heli { name="Babyyyyyyy";                          sound[] = {\sounds\intro\vehicles\usa_desant_heli.ogg,db-1,1.0}; titles[] = {};}; // Baby-y-y-y-y...

    class Oberon { name="Oberon (Yuri Vizbbor song)";                   sound[] = {\sounds\intro\players\Oberon.ogg,db-1,1.0}; titles[] = {};}; // Song for player "Oberon"
    class faces_of_war_flavi { name="";                                 sound[] = {\sounds\intro\players\faces_of_war_flavi.ogg,db-1,1.0}; titles[] = {};}; // Song for player "Flavi"

    class radionoise_0 { name="";                   	                sound[] = {\sounds\radio\radionoise_0.ogg,db-1,1.0}; titles[] = {};}; // radio ininteligible
    class radionoise_1 { name="";               	                    sound[] = {\sounds\radio\radionoise_1.ogg,db-1,1.0}; titles[] = {};}; // radio ininteligible
    class radionoise_2 { name="";           	                        sound[] = {\sounds\radio\radionoise_2.ogg,db-1,1.0}; titles[] = {};}; // radio ininteligible
    class radionoise_3 { name="";       	                            sound[] = {\sounds\radio\radionoise_3.ogg,db-1,1.0}; titles[] = {};}; // radio ininteligible
    class radionoise_4 { name="";   	                                sound[] = {\sounds\radio\radionoise_4.ogg,db-1,1.0}; titles[] = {};}; // radio ininteligible
    class radionoise_5 { name="";	                                    sound[] = {\sounds\radio\radionoise_5.ogg,db-1,1.0}; titles[] = {};}; // radio ininteligible

    class radio_1 { name="";                    	                    sound[] = {\sounds\radio\radio_1.ogg,db-1,1.0}; titles[] = {};}; //
    class radio_2 { name="";                	                        sound[] = {\sounds\radio\radio_2.ogg,db-1,1.0}; titles[] = {};}; //
    class radio_3 { name="";            	                            sound[] = {\sounds\radio\radio_3.ogg,db-1,1.0}; titles[] = {};}; //
    class radio_4 { name="";        	                                sound[] = {\sounds\radio\radio_4.ogg,db-1,1.0}; titles[] = {};}; //
    class radio_5 { name="";    	                                    sound[] = {\sounds\radio\radio_5.ogg,db-1,1.0}; titles[] = {};}; //
	class radio_6 { name="";	                                        sound[] = {\sounds\radio\radio_6.ogg,db-1,1.0}; titles[] = {};}; //
    class radio_7 { name="";                        	                sound[] = {\sounds\radio\radio_7.ogg,db-1,1.0}; titles[] = {};}; //
    class radio_8 { name="";                        	                sound[] = {\sounds\radio\mayak_1.ogg,db-1,1.0}; titles[] = {};}; //
    class radio_9 { name="";                        	                sound[] = {\sounds\radio\mayak_2.ogg,db-1,1.0}; titles[] = {};}; //

    class counterattack { name="counterattack";                         sound[] = {\sounds\radio\start_counterattack.ogg,db-1,1.0}; titles[] = {};}; // start counterattack
    class enemy_spotted { name="";                                      sound[] = {\sounds\radio\enemy_spotted.ogg,db-1,1.0}; titles[] = {};}; // typewriter click
    class enemy_activity { name="";                                     sound[] = {\sounds\radio\enemy_activity.ogg,db-1,1.0}; titles[] = {};}; // typewriter click

    class truck_door_1 { name="";                                       sound[] = {\sounds\short\door_close\truck_door_close_1.ogg,db-1,1.0}; titles[] = {};}; // truck door close 1
    class truck_door_2 { name="";                                       sound[] = {\sounds\short\door_close\truck_door_close_2.ogg,db-1,1.0}; titles[] = {};}; // 2
    class truck_door_3 { name="";                                       sound[] = {\sounds\short\door_close\truck_door_close_3.ogg,db-1,1.0}; titles[] = {};}; // 3
    class truck_door_4 { name="";                                       sound[] = {\sounds\short\door_close\truck_door_close_4.ogg,db-1,1.0}; titles[] = {};}; // 4

    class rusty_mast_1 { name="";                                       sound[] = {\sounds\short\rusty_mast\rusty_mast_1.ogg,db-1,1.0}; titles[] = {};}; // rusty mast scrape 1
    class rusty_mast_2 { name="";                                       sound[] = {\sounds\short\rusty_mast\rusty_mast_2.ogg,db-1,1.0}; titles[] = {};}; // 2
    class rusty_mast_3 { name="";                                       sound[] = {\sounds\short\rusty_mast\rusty_mast_3.ogg,db-1,1.0}; titles[] = {};}; // 3
    class rusty_mast_4 { name="";                                       sound[] = {\sounds\short\rusty_mast\rusty_mast_4.ogg,db-1,1.0}; titles[] = {};}; // 4
    class rusty_mast_5 { name="";                                       sound[] = {\sounds\short\rusty_mast\rusty_mast_5.ogg,db-1,1.0}; titles[] = {};}; // 5

    class button_1     { name="";                                       sound[] = {\sounds\short\button_1.ogg,db-1,1.0}; titles[] = {};}; //
    class repair_short { name="";                                       sound[] = {\sounds\short\repair_short.ogg,db-1,1.0}; titles[] = {};}; //

    class typewriter   { name="";                                       sound[] = {\sounds\short\typewriter.ogg,db-1,1.0}; titles[] = {};}; // typewriter click
    class atmos        { name="";                                       sound[] = {\sounds\short\atmos.ogg,db-1,1.0}; titles[] = {};}; // atmospheric drums

    class unlock1      { name = "";                                     sound[] = {\sounds\short\unlock1.ogg,db-1,1.0}; titles[] = {};}; // unlock sound 1
    class unlock2      { name = "";                                     sound[] = {\sounds\short\unlock2.ogg,db-1,1.0}; titles[] = {};}; // unlock sound 2
    class unlock3      { name = "";                                     sound[] = {\sounds\short\unlock3.ogg,db-1,1.0}; titles[] = {};}; // unlock sound 3

	// Spanish/English speech from aborigen on Antigua
    class adios       { name = "";                                     sound[] = {\sounds\men\excl\spain\adios.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Adios"
    class hola        { name = "";                                     sound[] = {\sounds\men\excl\spain\hola.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hola"
    class pamal       { name = "";                                     sound[] = {\sounds\men\excl\spain\pamal.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Pamal"
    class porque      { name = "";                                     sound[] = {\sounds\men\excl\spain\porque.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Porque"

    class hey_chico   { name = "";                                     sound[] = {\sounds\men\excl\spain\Hey_chico.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hey chico"
    class come_again_spa   { name = "";                                sound[] = {\sounds\men\excl\spain\Come_again_spa.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hey chico"
    class come_again_eng   { name = "";                                sound[] = {\sounds\men\excl\spain\Come_again_eng.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hey chico"
    class buenos_dias_amigo { name = "";                               sound[] = {\sounds\men\excl\spain\Buenos_dias_amigo.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hey chico"
    class local_partisan_spa { name = "";                              sound[] = {\sounds\men\excl\spain\local_partisan_spa.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hey chico"
    class local_partisan_eng { name = "";                              sound[] = {\sounds\men\excl\spain\local_partisan_eng.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hey chico"

    class cantar1 { name = "";                              sound[] = {\sounds\men\excl\spain\cantar1.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hey chico"
    class no_way_jose { name = "";                              sound[] = {\sounds\men\excl\spain\no_way_jose.ogg,db-1,1.0}; titles[] = {};}; // Spain islander says "Hey chico"

    class naval       { name = "";                                     sound[] = {\sounds\short\Naval-Patrol-Horn.ogg,db-1,1.0}; titles[] = {};}; // Sea patrol detected sound

//    class spell_1	{ name = "";                                       sound[] = {\sounds\short\spells\Spell-Suta-Buhna-Muhkanash.ogg,db-1,1.0}; titles[] = {};}; //
//    class spell_2	{ name = "";                                       sound[] = {\sounds\short\spells\Spell-Trehgorus-Sha.ogg,db-1,1.0}; titles[] = {};}; //
//    class spell_3	{ name = "";                                       sound[] = {\sounds\short\spells\Spell-Paragosy-Avanagh.ogg,db-1,1.0}; titles[] = {};}; //
//    class spell_4	{ name = "";                                       sound[] = {\sounds\short\spells\Spell-Zemana-Aztilin.ogg,db-1,1.0}; titles[] = {};}; //
    class spell_5	{ name = "";                                       sound[] = {\sounds\short\spells\Spell-Abes-Fabes-Cartoflyabes.ogg,db-1,1.0}; titles[] = {};}; //
//    class spell_6	{ name = "";                                       sound[] = {\sounds\short\spells\Spell-Crevall-Asortium-Antimus.ogg,db-1,1.0}; titles[] = {};}; //
//    class spell_7	{ name = "";                                       sound[] = {\sounds\short\spells\Spell-Engory-Helleye.ogg,db-1,1.0}; titles[] = {};}; //
    class spell_8	{ name = "";                                       sound[] = {\sounds\short\spells\curse_upon_you.ogg,db-1,1.0}; titles[] = {};}; //
    class spell_wrong	{ name = "";                                       sound[] = {\sounds\short\spells\Spell-Wrong-Sound.ogg,db-1,1.0}; titles[] = {};}; // Wrong  spell sound

    class three_kinds { name = "";                                     sound[] = {\sounds\short\three_kinds.ogg,db-1,1.0}; titles[] = {};}; //


// Naval-Patrol-Horn.ogg

};
