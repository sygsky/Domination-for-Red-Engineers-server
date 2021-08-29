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
	class Funk {name="Funk";sound[]={\sounds\funk.ogg,db+20,1.0};titles[] = {};};
	class Ari {name="Ari";sound[]={\sounds\ari.ogg,db+30,1.0};titles[] = {};};
	class odinakovo {name="odinakovo";sound[]={\sounds\odinakovo.ogg,db+0,1.0};titles[] = {};};
	class slavianskiy {name="slavianskiy";sound[]={\sounds\slavianskiy.ogg,db+0,1.0};titles[] = {};};
    class vam_bileter {name="vam_bileter";sound[]={\sounds\vam_bileter.ogg,db+0,1.0};titles[] = {};};
	class highvoltage {name="highvoltage";sound[]={\sounds\highvoltage.ogg,db+0,1.0};titles[] = {};};
	class upsidedown {name="upsidedown";sound[]={\sounds\upside_down.ogg,db+0,1.0};titles[] = {};};
	//class horse {name="horse";sound[]={\sounds\horse.ogg,db+0,1.0};titles[] = {};};
	class Tank_GetIn {name="Tank_GetIn";sound[]={\sounds\Tank_GetIn.ogg,db+0,1.0};titles[] = {};};
	class APC_GetIn {name="APC_GetIn";sound[]={\sounds\APC_GetIn.ogg,db+0,1.0};titles[] = {};};
	class bicycle {name="bicycle";sound[]={\sounds\bicycle.ogg,db+0,1.0};titles[] = {};};
	class stalin_dal_prikaz {name="Soviet artillery himn";sound[]={\sounds\intro\vehicles\stalin_dal_prikaz.ogg,db+0,1.0};titles[] = {};};
	class healing {name="healing";sound[]={\sounds\healing.ogg,db+0,1.0};titles[] = {};}; // medic heal service

	//class patrol { name="patrol"; sound[]={\sounds\patrol.ogg,db-20,1.0}; titles[] = {}; }; // remove as non needed
//	class baraban { name="baraban"; sound[]={\sounds\baraban.ogg,db+0,1.0}; titles[] = {}; }; // removed as not interesting and ancient
	class kwai     { name="kwai";                          sound[]={\sounds\kwai.ogg,db+0,1.0};          titles[] = {}; };
	class invasion { name="invasion";                      sound[]={\sounds\invasion.ogg,db+0,1.0};      titles[] = {}; };
    class starwars { name="Star wars march";               sound[]= {\sounds\starwars.ogg,db-1,1.0};     titles[] = {};};
    class radmus   { name="radmus from old OFP campany";   sound[]= {\sounds\enemy\radmus.ogg,db-1,1.0}; titles[] = {};};
    class enemy    { name="Hans Zimmer - Barbarian horde"; sound[]= {\sounds\enemy\enemy.ogg,db-1,1.0};  titles[] = {};};
    class ortegogr { name="Found in one Arma mission (German)"; sound[]= {\sounds\enemy\ortegogr.ogg,db-1,1.0};  titles[] = {};};
    class desant   { name="Red Alert desant music"; sound[]= {\sounds\enemy\desant.ogg,db-1,1.0};  titles[] = {};}; // from Red Alert game, called only for 2st otwn occupied

    class no_more_waiting { name=""; sound[]= {\sounds\no_more_waiting.ogg,db-1,1.0}; titles[] = {};}; // very short sound (observer killed?)

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
	class fear      { name=""; sound[]=   {\sounds\fear.ogg,db-1,1.0}; titles[] = {}; };
	class bestie    { name="";  sound[]= {\sounds\bestie.ogg,db-1,1.0}; titles[] = {}; };
	class gamlet    { name=""; sound[] = {\sounds\gamlet.ogg,db+0,1.0}; titles[] = {}; };
	class fear3     { name=""; sound[]=   {\sounds\fear3.ogg,db-1,1.0}; titles[] = {}; };
	class heartbeat { name=""; sound[]=   {\sounds\heartbeat.ogg,db-1,1.0}; titles[] = {}; };
	class the_trap  { name=""; sound[]=   {\sounds\the_trap.ogg,db-1,1.0}; titles[] = {}; };
	class koschei   { name=""; sound[]=   {\sounds\koschei.ogg,db-1,1.0}; titles[] = {}; }; // from Soviet multfilm "The princess Frog"
	class sinbad_sckeleton { name=""; sound[]=   {\sounds\fear\sinbad_sckeleton.ogg,db-1,1.0}; titles[] = {}; }; // from "7th voyage of Sinbad "
	class fear4     { name=""; sound[]=   {\sounds\fear\fear4.ogg,db-1,1.0}; titles[] = {}; };
	class fear_Douce_Violence     { name=""; sound[]=   {\sounds\fear\fear_Douce_Violence.ogg,db-1,1.0}; titles[] = {}; };

	class teleport_from { name=""; sound[]=   {\sounds\short\teleport_from.ogg,db-1,1.0}; titles[] = {}; };
	class teleport_to   { name=""; sound[]=   {\sounds\short\teleport_to.ogg,db-1,1.0}; titles[] = {}; };

    class countdown10     {name = ""; sound[] = {\sounds\countdown10.ogg, db+10, 1.0}; titles[] = {}; };
    class countdown       {name = ""; sound[] = {\sounds\countdown.ogg, db+10, 1.0}; titles[] = {}; }; // Rammstein
    class countdown_alarm {name = ""; sound[] = {\sounds\countdown_alarm.ogg, db+10, 1.0}; titles[] = {}; };

    class return        {name = ""; sound[] = {\sounds\return.ogg, db+10, 1.0}; titles[] = {}; };
    class steal         {name = ""; sound[] = {\sounds\steal.ogg, db+10, 1.0}; titles[] = {}; };
    class arabian_death { name=""; sound[] = {\sounds\arabian_death.ogg,db+10,1.0}; titles[] = {};} // defeat sound
    class the_complex   { name=""; sound[] = {\sounds\the_complex.ogg,db+10,1.0}; titles[] = {};} // defeat sound by Kevin MacLeod

    class male_fuck_1 {name = ""; sound[] = {\sounds\fuck\male_fuckin_cunt.ogg, db+0, 1.0}; titles[] = {}; };

    class male_sorry_1 {name = ""; sound[] = {\sounds\fuck\male-i-am-so-sorry.ogg, db+0, 1.0}; titles[] = {}; };
    class male_sorry_2 {name = ""; sound[] = {\sounds\fuck\man-sorry-english.ogg, db+0, 1.0}; titles[] = {}; };
    class male_sorry_3 {name = ""; sound[] = {\sounds\fuck\man-sorry-english-1.ogg, db+0, 1.0}; titles[] = {}; };

// woman self-killed
    class female_shout_of_pain_1 {name = ""; sound[] = {\sounds\pain\female_shout_of_pain_1.ogg, db+0, 1.0}; titles[] = {}; };
    class female_shout_of_pain_2 {name = ""; sound[] = {\sounds\pain\female_shout_of_pain_2.ogg, db+0, 1.0}; titles[] = {}; };
    class female_shout_of_pain_3 {name = ""; sound[] = {\sounds\pain\female_shout_of_pain_3.ogg, db+0, 1.0}; titles[] = {}; };
    class female_shout_of_pain_4 {name = ""; sound[] = {\sounds\pain\female_shout_of_pain_4.ogg, db+0, 1.0}; titles[] = {}; };
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

// man self-killed. If append next scream, don't forget to edit method SYG_getSuicideScreamSound() in file SYG_utilsSound.sqf (increase harcoded number of screams)
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
    class message_received {name = ""; sound[] = {\sounds\short\received.ogg, db+10, 1.0}; titles[] = {}; };
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
    class school_ring   {name = ""; sound[] = {\sounds\gong\school-ring.ogg, db+10, 1.0}; titles[] = {}; };

    class liturgy_1     {name = ""; sound[] = {\sounds\liturgy\diamon_hand.ogg, db+10, 1.0}; titles[] = {}; };
    class liturgy_2     {name = ""; sound[] = {\sounds\liturgy\gospodu_pomolimsa.ogg, db+10, 1.0}; titles[] = {}; };
    class liturgy_3     {name = ""; sound[] = {\sounds\liturgy\ortodox_liturgy.ogg, db+10, 1.0}; titles[] = {}; };
    class liturgy_4     {name = ""; sound[] = {\sounds\liturgy\valaam_liturgy.ogg, db+10, 1.0}; titles[] = {}; };
    class liturgy_5     {name = ""; sound[] = {\sounds\liturgy\mon_nevskogo.ogg, db+10, 1.0}; titles[] = {}; };

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
    class game_over { name="Good Job";   sound[] = {\sounds\defeat\laughter\over,db+10,1.0}; titles[] = {}; } // War cry "game over"
    class get_some { name="Good Job";   sound[] = {\sounds\defeat\laughter\get_some.ogg,db+10,1.0}; titles[] = {}; } // War cry "get some"
    class go_go_go { name="Go-go-go";   sound[] = {\sounds\defeat\laughter\go_go_go.ogg,db+10,1.0}; titles[] = {}; } // War cry "go-go-gob"
    class cheater { name="cheater";   sound[] = {\sounds\defeat\laughter\cheater.ogg,db+10,1.0}; titles[] = {}; } // say "cheater"
    class busted { name="Busted";   sound[] = {\sounds\defeat\laughter\busted.ogg,db+10,1.0}; titles[] = {}; } // say "cheater"
    class greatjob1 { name="Great job 1";   sound[] = {\sounds\defeat\laughter\great-job1.ogg,db+10,1.0}; titles[] = {}; } // say "Great job 1"
    class greatjob2 { name="Great job 2";   sound[] = {\sounds\defeat\laughter\great-job1.ogg,db+10,1.0}; titles[] = {}; } // say "Great job"
    class fight { name="fight";   sound[] = {\sounds\defeat\laughter\fight.ogg,db+10,1.0}; titles[] = {}; } // say "fight"
    class handsup { name="put your hands up";   sound[] = {\sounds\defeat\laughter\Put_Your_Hands_Up.ogg,db+10,1.0}; titles[] = {}; } // say "put your hand up"
    class indeanwarcry { name="Indean war cry"; sound[] = {\sounds\defeat\laughter\indeanwarcry.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown47 { name="One dead"; sound[] = {\sounds\defeat\laughter\targetdown47.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class targetdown01 { name="Enemy down"; sound[] = {\sounds\defeat\laughter\targetdown01.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class bastards { name="Bastards"; sound[] = {\sounds\defeat\laughter\bastards.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class clear { name="Clear!"; sound[] = {\sounds\defeat\laughter\clear.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class shoot_MF { name="Shoot the motherfackers!"; sound[] = {\sounds\defeat\laughter\shoot_MF.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class target_neutralised { name="Target neutralized!"; sound[] = {\sounds\defeat\laughter\target_neutralised.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class tasty { name="Tasty!"; sound[] = {\sounds\defeat\laughter\tasty.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class doggy { name="Red Neck Doggy!"; sound[] = {\sounds\defeat\laughter\doggy.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat
    class score { name="Score!"; sound[] = {\sounds\defeat\laughter\score.ogg,db+10,1.0}; titles[] = {}; } // Some laughter on your defeat

    class exclamation1 { name="eclamation";   sound[] = {\sounds\defeat\exclamations\1.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation2 { name="eclamation";   sound[] = {\sounds\defeat\exclamations\2.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation3 { name="eclamation";   sound[] = {\sounds\defeat\exclamations\3.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation4 { name="eclamation";   sound[] = {\sounds\defeat\exclamations\4.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation5 { name="eclamation";   sound[] = {\sounds\defeat\exclamations\5.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class exclamation6 { name="eclamation";   sound[] = {\sounds\defeat\exclamations\6.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation
    class tanki { name="eclamation";   sound[] = {\sounds\defeat\exclamations\tanki.ogg,db+10,1.0}; titles[] = {}; } // say some exclamation

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

    class chiz_tanki_1   {name = "Чиж. 'По танку вдарила болванка...'"; sound[] = {\sounds\defeat\chiz_tanki_1.ogg, db+10, 1.0}; titles[] = {}; }; // "The tank was hit by a dummy..." song of the ensemble " Chizh"
    class chiz_tanki_2   {name = "Чиж. 'Нас извлекут из под обломков...'"; sound[] = {\sounds\defeat\chiz_tanki_2.ogg, db+10, 1.0}; titles[] = {}; }; // "We will be pulled from under the rubble..." song of the ensemble " Chizh"
    class whatsapp       {name = "From WhatsApp msg"; sound[] = {\sounds\defeat\whatsapp.ogg, db+10, 1.0}; titles[] = {}; }; // Some sound from one of WhatsApp messages

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
    class hisp1   { name=""; sound[] = {\sounds\sm\hostages\hisp_excl_1.ogg,db-1,1.0}; titles[] = {};};
    class hisp2   { name=""; sound[] = {\sounds\sm\hostages\hisp_excl_2.ogg,db-1,1.0}; titles[] = {};};
    class hisp3   { name=""; sound[] = {\sounds\sm\hostages\hisp_excl_3.ogg,db-1,1.0}; titles[] = {};};
    class hisp4   { name=""; sound[] = {\sounds\sm\hostages\hisp_excl_4.ogg,db-1,1.0}; titles[] = {};};

// SM 49
    class eng_grant_surrend { name=""; sound[] = {\sounds\sm\49\eng_grant_surrend.ogg,db-1,1.0}; titles[] = {};};
    class ger_grant_surrend { name=""; sound[] = {\sounds\sm\49\ger_grant_surrend.ogg,db-1,1.0}; titles[] = {};};
    class eng_grant_intro   { name=""; sound[] = {\sounds\sm\49\eng_grant_intro.ogg,db-1,1.0}; titles[] = {};};
    class ger_grant_intro   { name=""; sound[] = {\sounds\sm\49\ger_grant_intro.ogg,db-1,1.0}; titles[] = {};};

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

    class enemy_attacks_base   {name = "On base attack event in Russian"; sound[] = {\sounds\onbase\enemy_attack.ogg, db+10, 1.0}; titles[] = {};};    // base attack additional sound

	// TODO: use lower sound
    class lighthouse_1    {name = "Lighthouse 1"; sound[] = {\sounds\timeofday\night\lighthouse\Lighthouse_v01.ogg, db+10, 1.0}; titles[] = {};};    // Lighthouse 1
    class lighthouse_2    {name = "Lighthouse 1"; sound[] = {\sounds\timeofday\night\lighthouse\Lighthouse_v02.ogg, db+10, 1.0}; titles[] = {};};    // Lighthouse 2
    class lighthouse_3    {name = "Lighthouse 1"; sound[] = {\sounds\timeofday\night\lighthouse\Lighthouse_v03.ogg, db+10, 1.0}; titles[] = {};};    // Lighthouse 3
    class lighthouse_4    {name = "Lighthouse 1"; sound[] = {\sounds\timeofday\night\lighthouse\Lighthouse_v04.ogg, db+10, 1.0}; titles[] = {};};    // Lighthouse 4
    //

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
};
