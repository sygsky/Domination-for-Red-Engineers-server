// Music. Used to call methods like playMusic, defined in CfgMusic included in Description.ext

class CfgMusic {

	tracks[]={Varshavianka,Varshavianka_eng,warschawyanka_german,grant}; // TODO: try to access music classes from intto to get name text for printing during intro  video

//+++++++++++++++++++++++++++++++++++++++++++++ INTRO MUSIC +++++++++++++++++++++++++++++++++++++++++++

// Revolution day intro music
	class Varshavianka { name = "";sound[] = {\sounds\Varshavianka.ogg, db+20, 1.0};}; // russian
	class Varshavianka_eng { name = "";sound[] =  {\sounds\Varshavianka_eng.ogg, db+20, 1.0};}; // english
	class warschawyanka_german { name = "";sound[] =  {\sounds\warschawyanka_german.ogg, db+10, 1.0};}; // german

	class grant { name = ""; sound[] =  {\sounds\grant.ogg, db+20, 1.0}; };

// New year intro musics
	class snovymgodom   { name=""; sound[] = {\sounds\newyear\snovymgodom.ogg, db+20, 1.0};};
	class nutcracker    { name=""; sound[] = {\sounds\newyear\NutCracker.ogg, db+20, 1.0};};
    class home_alone    { name=""; sound[] = {\sounds\newyear\home_alone.ogg,db+10,1.0};}; // From "Home alone" american movie 1990
    class mountain_king { name=""; sound[] = {\sounds\newyear\mountain_king.ogg,db+10,1.0};}; // From "Home alone" american movie 1990
    class zastolnaya    { name=""; sound[] = {\sounds\newyear\zastolnaya.ogg,db-1,1.0};}; // intro New Year music
    class grig          { name=""; sound[]=   {\sounds\newyear\grig.ogg,db-1,1.0};    };
    class merry_xmas    { name=""; sound[] = {\sounds\newyear\merry_xmas.ogg,db+0,1.0};}; // Merry Xmas melody by Kevin Macleod
    class vangelis      { name=""; sound[] = {\sounds\newyear\vangelis.ogg,db+0,1.0};}; // Vangelis - "La petite fille de la mer", 1973

	class stavka_bolshe_chem { name=""; sound[]={\sounds\intro\stavka_bolshe_chem.ogg,db-1,1.0}; };
    class four_tankists { name="Czterej Pancerni i Pies, Polska Rzeczpospolita Ludowa film, 1960"; sound[] = {\sounds\intro\4tankists.ogg,db-1,1.0};} // from PRL film "4 tankists and dog"

    class burnash	{ name="";	      sound[]=   {\sounds\burnash.ogg,db-1,1.0};     };
    class johnny    { name="";        sound[]=   {\sounds\johnny.ogg,db-1,1.0};      };
    class druzba    { name="";        sound[]=   {\sounds\druzba.ogg,db-1,1.0};      };
    class adjutant  { name="";        sound[]=   {\sounds\adjutant.ogg,db-1,1.0};    };
    class vague     { name="";        sound[]=   {\sounds\intro\vague.ogg,db-1,1.0}; };
    class enchanted_boy     { name="";        sound[]=   {\sounds\intro\enchanted_boy.ogg,db-1,1.0}; };

    class          ahead_friends { name=""; sound[]= {\sounds\ahead_friends.ogg,db-1,1.0}; };
    class     mission_impossible { name=""; sound[]= {\sounds\mission_impossible.ogg,db-1,1.0}; };
    class               lastdime { name=""; sound[]= {\sounds\intro\lastdime.ogg,db-1,1.0};    };
//    class              lastdime1 { name=""; sound[]= {\sounds\intro\lastdime1.ogg,db-1,1.0};    };
    class              lastdime2 { name=""; sound[]= {\sounds\intro\lastdime2.ogg,db-1,1.0};    };
    class              lastdime3 { name=""; sound[]= {\sounds\intro\lastdime3.ogg,db-1,1.0};    };
    class      esli_ranili_druga { name=""; sound[]= {\sounds\intro\esli_ranili_druga.ogg,db-1,1.0};    };
    class        soviet_officers { name=""; sound[]= {\sounds\intro\holidays\feb_23\soviet_officers.ogg,db-1,1.0}; };
    class    travel_with_friends { name=""; sound[]= {\sounds\intro\travel_with_friends.ogg,db-1,1.0}; }; // Sovier children song
    class            on_thin_ice { name=""; sound[]= {\sounds\intro\on_thin_ice.ogg,db-1,1.0}; }; // from Soviet film "On thin ice"

//    class Art_Of_Noise_mono { name=""; sound[] = {\sounds\Art_Of_Noise_mono.ogg,db-1,1.0};} // used in intro
	class robinson_crusoe { name=""; sound[] = {\sounds\intro\robinson_crusoe.ogg,db-1,1.0};} // used in intro
    class dem_morgenrot_entgegen { name=""; sound[] = {\sounds\dem_morgenrot_entgegen.ogg,db-1,1.0};} // used in  intro
    class from_russia_with_love { name=""; sound[] = {\sounds\from_russia_with_love.ogg,db-1,1.0};} // used in  intro, only for resque players
    class prince_negaafellaga { name=""; sound[] = {\sounds\prince_negaafellaga.ogg,db-1,1.0};} // used in  intro
    class strelok { name=""; sound[] = {\sounds\strelok.ogg,db-1,1.0};} // used in  intro
    class bloody { name=""; sound[] = {\sounds\bloody.ogg,db-1,1.0};} // intro music from "Bloody diamond" movie
    class total_recall_mountain { name=""; sound[] = {\sounds\total_recall_mountain.ogg,db-1,1.0};} // intro music from "Total recall" movie (The Mountain)
//    class comrade_my { name=""; sound[] = {\sounds\comrade_my.ogg,db+10,1.0};} // intro music from Soviet song "Comrade mine"
    class capricorn1title { name=""; sound[] = {\sounds\capricorn1title.ogg,db+20,1.0};} // intro music from great american movie "Capricorn-1"
    class Letyat_perelyotnye_pticy_2nd { name=""; sound[] = {\sounds\Letyat_perelyotnye_pticy_2nd.ogg,db+20,1.0};} // intro music from Soviet great song (1950)
    class Letyat_perelyotnye_pticy_end { name=""; sound[] = {\sounds\Letyat_perelyotnye_pticy_end.ogg,db+20,1.0};} // intro music #2 (final verse) from the same Soviet great song (1950)

    class adagio { name=""; sound[] = {\sounds\adagio.ogg,db+20,1.0};}; // intro music from Soviet great film Gussar Ballad (1962)
    class ruffian { name=""; sound[] = {\sounds\ruffian.ogg,db+20,1.0};}; // intro music from Soviet great film Gussar Ballad (1962)
    class amigohome_ernst_bush { name=""; sound[] = {\sounds\amigohome_ernst_bush.ogg,db+0,1.0};}; // Ami go home by Ernsh Busch, DDR communust and great singer!
    class treasure_island_intro { name=""; sound[] = {\sounds\treasure_island_intro.ogg,db+0,1.0};}; // treasure island intro theme (from the eponymous soviet  film of 1971)
    class fear2 { name=""; sound[] = {\sounds\fear2.ogg,db+0,1.0};}; // Some feat music
    class chapaev { name=""; sound[] = {\sounds\chapaev.ogg,db+0,1.0};}; // USSR film Chapaev
    class cosmos { name=""; sound[] = {\sounds\cosmos.ogg,db+0,1.0};}; // Cosmic music
    class manchester_et_liverpool { name=""; sound[] = {\sounds\manchester_et_liverpool.ogg,db+0,1.0};}; // Well known melody
//    class ipanoram { name=""; sound[] = {\sounds\ipanoram.ogg,db+0,1.0};}; // Soviet political review Telecast "International panoram"
    class rider { name=""; sound[] = {\sounds\rider.ogg,db+0,1.0};}; // Dean Reed song "Rider"
    class hound_baskervill { name=""; sound[] = {\sounds\hound_baskervill.ogg,db+0,1.0};}; // USSR famous film "Hound of Baskervill hall"
    class condor { name=""; sound[] = {\sounds\condor.ogg,db+0,1.0};}; // El-Condor-Pasa by Leo Rojas
    class way_to_dock { name=""; sound[] = {\sounds\way_to_dock.ogg,db+0,1.0};}; // melody from Soviet film "Way to dock" ("Дорога к причалу")
    class Vremia_vpered_Sviridov { name=""; sound[] = {\sounds\Vremia_vpered_Sviridov.ogg,db+0,1.0};}; // melody from Soviet film "Way to dock" ("Дорога к причалу")
    class melody_by_voice { name=""; sound[] = {\sounds\melody_by_voice.ogg,db+0,1.0};}; // melody from Charles Wilp - Mad. Ave. Perfume Ad
//    class english_murder { name=""; sound[] = {\sounds\english_murder.ogg,db-1,1.0};} // intro music
    class tovarich_moy { name=""; sound[] = {\sounds\tovarich_moy.ogg,db-1,1.0};} // intro music, Soviet song about comrade
    class sovest1 { name=""; sound[] = {\sounds\intro\sovest1.ogg,db-1,1.0};} // intro music, Soviet song from film "consciousness"
    class sovest2 { name=""; sound[] = {\sounds\intro\sovest2.ogg,db-1,1.0};} // intro music, Soviet song from film "consciousness"
//    class morricone1 { name=""; sound[] = {\sounds\intro\morricone1.ogg,db-1,1.0};} // intro music, USA film "The Good, The Bad & The Ugly"
    class bond1 { name=""; sound[] = {\sounds\intro\bond1.ogg,db-1,1.0};} // intro music, one of the James Bond film main theme (don't remember)
    class bond { name=""; sound[] = {\sounds\bond.ogg,db-1,1.0};} // intro music, one of the James Bond film main theme (don't remember)
    class toccata { name="toccata-and-fugue-in-d-minor-by-kevin-macleod"; sound[] = {\sounds\intro\toccata.ogg,db-1,1.0};} // intro music, J.S. Bach tocatta
//    class smersh { name="SMERSH game OST"; sound[] = {\sounds\intro\smersh.ogg,db-1,1.0};} // intro music, SMERSH game OST
    class del_vampiro1 { name="L'amante del Vampiro, Italian film, 1960"; sound[] = {\sounds\intro\del_vampiro1.ogg,db-1,1.0};} // intro music, Italian film "L'amante del Vampiro"
    class del_vampiro2 { name="L'amante del Vampiro, Italian film, 1960"; sound[] = {\sounds\intro\del_vampiro2.ogg,db-1,1.0};} // intro music, Italian film "L'amante del Vampiro"
    class zaratustra { name="Thus Sprach Zarathustra, Richard Strauss"; sound[] = {\sounds\intro\zaratustra.ogg,db-1,1.0};} // intro music, "Thus Sprach Zarathustra", Richard Strauss
    class bolivar { name="'The roads we take' film music, 1962, Leonid Haiday"; sound[] = {\sounds\intro\bolivar.ogg,db-1,1.0};} // intro music
    class peregrinus { name="'Alexander Nevsky' film music by Sergei Prokofiev, 1938, episode 'Expectans Peregrinus'"; sound[] = {\sounds\intro\peregrinus.ogg,db-1,1.0};} // intro music

//+++++++++++++++++++++++++++++++++++++ MORZE for Rokse [LT] +++++++++++++++++++++++++++++++++++++++++++++++++++++
    class morze   { name="Morze about Sahrani island"; sound[] = {\sounds\intro\morze\morze.ogg,db+0,1.0};}; // Morze packed message in Russian...
    class morze2  { name="Real Morze (Canada)"; sound[] = {\sounds\intro\morze\morze2.ogg,db+0,1.0};}; // Morze real message (Canada)
    class morze_0 { name="Morzyanka";   sound[] = {\sounds\intro\morze\Morzyanka.ogg,db+0,1.0};}; // Morze
    class morze_2 { name="Morzyanka 2"; sound[] = {\sounds\intro\morze\Morzyanka2.ogg,db+0,1.0};}; // Morze
    class morze_3 { name="Morzyanka - USSR song"; sound[] = {\sounds\intro\morze\Morzyanka3.ogg,db+0,1.0};}; // Morze
    class morze_4 { name="Morzyanka 4"; sound[] = {\sounds\intro\morze\Morzyanka4.ogg,db+0,1.0};}; // Morze
    class morze_5 { name="Morzyanka 5"; sound[] = {\sounds\intro\morze\Morzyanka5.ogg,db+0,1.0};}; // Morze
    class morze_6 { name="Morzyanka 6"; sound[] = {\sounds\intro\morze\Morzyanka6.ogg,db+0,1.0};}; // Morze
    class morze_7 { name="Morzyanka 7"; sound[] = {\sounds\intro\morze\Morzyanka7.ogg,db+0,1.0};}; // Morze

    class hungarian_dances { name="Brams, Hungarian Dances"; sound[] = {\sounds\intro\hungarian_dances.ogg,db+0,1.0};}; // For Hungarian players
    class jrtheme { name="USA film jack Reacher theme"; sound[] = {\sounds\intro\jrtheme.ogg,db+0,1.0};}; // Simply majestic music
    class farewell_slavs { name="Farewell of Slavs, Russian march"; sound[] = {\sounds\intro\farewell_slavs.ogg,db+0,1.0};}; // Well known military march of old Russian Emmpire
    class jaws    {name = "Jaws Title"; sound[] = {\sounds\intro\jaws.ogg, db+10, 1.0};}; // from "Jaws" film

//------------------------------------- END of Intro music list --------------------------------------------------

//+++++++++++++++++++++++ Detect town music, if added, seek and add to the 'case "mt_spotted":' code in the file "x_netinitclient.sqf"

    class detected_Arcadia { name=""; sound[] = {\sounds\locations\Benny_Hill_Paradise_2006.ogg,db-1,1.0}; } // town detected music (Arcadia)
    class detected_Paraiso { name=""; sound[] = {\sounds\locations\Paraiso.ogg,db-1,1.0}; } // town detected music (Paraiso)
    class detected_Carmen  { name=""; sound[] = {\sounds\locations\toreador.ogg,db-1,1.0}; } // town detected music (Carmen)
    class detected_Rahmadi { name=""; sound[] = {\sounds\locations\Rahmadi.ogg,db-1,1.0}; } // town detected music (Rahmadi)
    class detected_Eponia  { name="Banzai, 1983"; sound[] = {\sounds\locations\Banzai.ogg,db-1,1.0}; } // town detected music (Eponia)

//+++++++++++++++++++++++ Holiday music

    class cosmos_1 { name="Earth attraction";                           sound[] = {\sounds\intro\holidays\apr_12\Earth_attraction.ogg,db-1,1.0}; } // Cosmonoutics day 12 of April
    class cosmos_2 { name="I trust, my friends";                        sound[] = {\sounds\intro\holidays\apr_12\I_trust_my_friends.ogg,db-1,1.0}; } // Cosmonoutics day 12 of April
    class cosmos_3 { name="You know what kind of guy He was (Gagarin)"; sound[] = {\sounds\intro\holidays\apr_12\YouKnowWhatKindOfGuyHeWas.ogg,db-1,1.0}; } // Cosmonoutics day 12 of April
    class lenin    { name="And again the battle continues";             sound[] = {\sounds\intro\holidays\apr_22\lenin.ogg,db-1,1.0}; } // Birthday of V.I. Lebin
    class lenin_1  { name="Day by day are years go";                    sound[] = {\sounds\intro\holidays\apr_22\lenin_1.ogg,db-1,1.0}; } // Birthday of V.I. Lebin
	class invasion { name="invasion";                                   sound[] = {\sounds\invasion.ogg,db+0,1.0};}; // Invasion - Shostakovitch
    class hugging_the_sky { name="Hugging the sky...";                  sound[] = {\sounds\intro\holidays\aug_18\hugging_the_sky.ogg,db-1,1.0}; } // Soviet air fleet day
    class we_teach_planes_to_fly { name="We teach planes to fly...";    sound[] = {\sounds\intro\holidays\aug_18\we_teach_planes_to_fly.ogg,db-1,1.0}; } // Soviet air fleet day
    class aviamarch_rus { name="Мы рождены чтоб сказку сделать былью";  sound[] = {\sounds\intro\holidays\aug_18\aviamarch_rus.ogg,db-1,1.0}; } // Soviet air fleet day
    class aviamarch_eng { name="We were born to make a fairy tale come true";  sound[] = {\sounds\intro\holidays\aug_18\aviamarch_eng.ogg,db-1,1.0}; } // Soviet air fleet day
    class aviamarch_ger { name="Drum höher und höher und höher..";      sound[] = {\sounds\intro\holidays\aug_18\aviamarch_ger.ogg,db-1,1.0}; } // Soviet air fleet day
    class communism { name="We will live in communism...";              sound[] = {\sounds\intro\holidays\nov_7\communism.ogg,db-1,1.0}; } // Last Soviet Constitution day (1977)
    class komsomol { name="И вновь продолжается бой";                   sound[] = {\sounds\intro\holidays\oct_29\komsomol.ogg,db-1,1.0}; } // Komsomal Day!(1918)
    class ddrhymn  { name="DDR Day";                                    sound[] = {\sounds\intro\ddrhymn.ogg,db-1,1.0}; } // DDR Day!(1949)
    class border_guards  { name="Day of Border Guards";                 sound[] = {\sounds\intro\holidays\may_28\border_guards.ogg,db-1,1.0}; } // Day of Border Guards
    class uchat_v_shkole { name="1st September - School day";           sound[] = {\sounds\intro\holidays\sep_1\uchat_v_shkole.ogg,db-1,1.0}; } // Day of School

//+++++++++++++++++++++++ Defeat music track list

    class thetrembler { name=""; sound[]=   {\sounds\thetrembler.ogg,db-1,1.0}; };
    class thefuture { name=""; sound[]=   {\sounds\thefuture.ogg,db-1,1.0}; };
    class vendetta { name=""; sound[] = {\sounds\vendetta.ogg,db-1,1.0}; };

    class aztecs { name=""; sound[] = {\sounds\aztecs.ogg,db-1,1.0}; };
    class aztecs2 { name=""; sound[] = {\sounds\aztecs2.ogg,db-1,1.0}; };
    class aztecs3 { name=""; sound[] = {\sounds\aztecs3.ogg,db-1,1.0}; };
    class aztecs4 { name=""; sound[] = {\sounds\aztecs4.ogg,db-1,1.0}; };
    class aztecs5 { name=""; sound[] = {\sounds\aztecs5.ogg,db-1,1.0}; };
    class aztecs6 { name=""; sound[] = {\sounds\aztecs6.ogg,db-1,1.0}; };
    class betrayed { name=""; sound[] = {\sounds\betrayed.ogg,db-1,1.0}; };
    class bolero { name=""; sound[] = {\sounds\bolero.ogg,db-1,1.0}; };
    class musicbox_silent_night { name=""; sound[] = {\sounds\musicbox_silent_night.ogg,db-1,1.0}; };

    class tezcatlipoca { name=""; sound[] = {\sounds\tezcatlipoca.ogg,db-1,1.0}; };
    class yma_sumac { name=""; sound[] = {\sounds\yma_sumac.ogg,db-1,1.0}; };
    class yma_sumac_2 { name=""; sound[] = {\sounds\yma_sumac_2.ogg,db-1,1.0}; };
    class village_ruins { name=""; sound[] = {\sounds\village_ruins.ogg,db-1,1.0}; };

    class pimbompimbom { name=""; sound[] = {\sounds\pimbompimbom.ogg,db-1,1.0};} // defeat music
    class Delerium_Wisdom { name=""; sound[] = {\sounds\Delerium_Wisdom.ogg,db-1,1.0};} // defeat music
    class mountains { name=""; sound[] = {\sounds\mountains.ogg,db-1,1.0};} // defeat music
    class Gandalf_Simades { name=""; sound[] = {\sounds\Gandalf_Simades.ogg,db-1,1.0};} // defeat music

    class end { name=""; sound[] = {\sounds\end.ogg,db-1,1.0};} // defeat music
    class whold { name=""; sound[] = {\sounds\whold.ogg,db-1,1.0};} // defeat music
    class arroyo { name=""; sound[] = {\sounds\arroyo.ogg,db-1,1.0};} // defeat music from Fallout-2

    class defeat2 { name=""; sound[] = {\sounds\defeat2.ogg,db+10,1.0};} // defeat sound
    class arabian_death { name=""; sound[] = {\sounds\arabian_death.ogg,db+10,1.0};} // defeat sound
    class the_complex { name=""; sound[] = {\sounds\the_complex.ogg,db+10,1.0};} // defeat sound by Kevin MacLeod
    class radionanny { name=""; sound[] = {\sounds\Radio_nanny_call_sign.ogg,db+10,1.0};} // defeat sound from Radio-nanny sign call
    class sinbad_baghdad { name=""; sound[] = {\sounds\defeat\sinbad_baghdad.ogg,db+10,1.0};} // defeat sound from film "7th voyage of Sinbad "
    class moon_stone {name = ""; sound[] = {\sounds\defeat\moon_stone.ogg, db+10, 1.0};}; // Famous Soviet singer Edvard Hill: "Moon stone" song
    class hound_chase    {name = ""; sound[] = {\sounds\hound_chase.ogg, db+10, 1.0};}; // chase from "Hound of Baskerville" Soviet film
    class take_five    {name = "Dave Brubeck"; sound[] = {\sounds\take_five.ogg, db+10, 1.0};}; // "Take Five" by Dave Brubeck

//+++++++++++++++++++++++ medieval defeats (death near castles)
    class medieval_defeat  { name=""; sound[] = {\sounds\medieval_defeat.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat1 { name=""; sound[] = {\sounds\medieval\bard-melody.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat2 { name=""; sound[] = {\sounds\medieval\dark-magic.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat3 { name=""; sound[] = {\sounds\medieval\logo.ogg,db+10,1.0};} // medievaldefeat sound
    class medieval_defeat4 { name=""; sound[] = {\sounds\medieval\medieval-introduction-2.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat5 { name=""; sound[] = {\sounds\medieval\medieval-introduction-3.ogg,db+10,1.0};} // medieval defeat sound

    class medieval_defeat6  { name=""; sound[] = {\sounds\medieval\nomen_est_omen_11.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat7  { name=""; sound[] = {\sounds\medieval\nomen_est_omen_13_1.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat8  { name=""; sound[] = {\sounds\medieval\nomen_est_omen_13_2.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat9  { name=""; sound[] = {\sounds\medieval\nomen_est_omen_13_3.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat10 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_15_1.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat11 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_15_2.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat12 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_3.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat13 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_4.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat14 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_5_1.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat15 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_5_2.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat16 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_6_1.ogg,db+10,1.0};} // medieval defeat sound
    class medieval_defeat17 { name=""; sound[] = {\sounds\medieval\nomen_est_omen_6_2.ogg,db+10,1.0};} // medieval defeat sound
    class village_consort { name=""; sound[] = {\sounds\medieval\village_consort.ogg,db+10,1.0};}       // medieval defeat sound by Kevin MacLeod

    class rammstein_1 { name=""; sound[] = {\sounds\ramm\rammstein_1.ogg,db+10,1.0};} // From "Rammstein" defeat sounds
    class rammstein_2 { name=""; sound[] = {\sounds\ramm\rammstein_2.ogg,db+10,1.0};} // From "Rammstein" defeat sounds
    class rammstein_3 { name=""; sound[] = {\sounds\ramm\rammstein_3.ogg,db+10,1.0};} // From "Rammstein" defeat sounds
    class rammstein_4 { name=""; sound[] = {\sounds\ramm\rammstein_4.ogg,db+10,1.0};} // From "Rammstein" defeat sounds
    class rammstein_5 { name=""; sound[] = {\sounds\ramm\rammstein_5.ogg,db+10,1.0};} // From "Rammstein" defeat sounds
    class rammstein_6 { name=""; sound[] = {\sounds\ramm\rammstein_6.ogg,db+10,1.0};} // From "Rammstein" defeat sounds
    class rammstein_7 { name=""; sound[] = {\sounds\ramm\rammstein_7.ogg,db+10,1.0};} // From "Rammstein" defeat sounds
    class rammstein_8 { name=""; sound[] = {\sounds\ramm\rammstein_8.ogg,db+10,1.0};} // From "Rammstein" defeat sounds
    class rammstein_9 { name=""; sound[] = {\sounds\ramm\rammstein_9.ogg,db+10,1.0};} // From "Rammstein" defeat sounds

    // ordinal defeats

    class metel       { name=""; sound[] = {\sounds\metel.ogg,db+0,1.0};} // defeat music from "Metel" of Pushkin novel
    class gayane1     { name=""; sound[] = {\sounds\gayane1.ogg,db+0,1.0};} // "Gayane" ballet
    class gayane2     { name=""; sound[] = {\sounds\gayane2.ogg,db+0,1.0};} // "Gayane" ballet
    class gayane3     { name=""; sound[] = {\sounds\gayane3.ogg,db+0,1.0};} // "Gayane" ballet
    class gamlet_hunt { name=""; sound[] = {\sounds\gamlet_hunt.ogg,db+0,1.0};} // "Hamlet" soviet movie
    class treasure_island_defeat { name=""; sound[] = {\sounds\treasure_island_defeat.ogg,db-1,1.0};} // "tresure island alarm theme" USSR movie of 1971 year
    class i_new_a_guy { name=""; sound[] = {\sounds\i_new_a_guy.ogg,db+10,1.0};}
    class decisions   { name=""; sound[] = {\sounds\decisions.ogg,db+5,1.0};};
    class whatsapp    {name = "From WhatsApp msg"; sound[] = {\sounds\defeat\whatsapp.ogg, db+10, 1.0};}; // Some sound from one of WhatsApp messages
    class stripped_voyage    {name = "From Stripped Voyage film"; sound[] = {\sounds\defeat\stripped_voyage, db+10, 1.0};}; // Some sound from Soviet film "Stripped Voyage" (196)
    //stripped_voyage.ogg


    class church_voice    {name = "church_voice"; sound[] = {\sounds\church\church_voice.ogg, db+10, 1.0};};
    class sorrow_1        {name = "sorrow_1"; sound[] = {\sounds\church\sorrow_1.ogg, db+10, 1.0};};
    class sorrow_2        {name = "sorrow_2"; sound[] = {\sounds\church\sorrow_2.ogg, db+10, 1.0};};
    class sorrow_3        {name = "sorrow_3"; sound[] = {\sounds\church\sorrow_3.ogg, db+10, 1.0};};
    class sorrow_4        {name = "sorrow_4"; sound[] = {\sounds\church\sorrow_4.ogg, db+10, 1.0};};

    class church_organ_1  {name = ""; sound[] = {\sounds\organ\church_organ_1.ogg, db+10, 1.0};};
    class haunted_organ_1 {name = ""; sound[] = {\sounds\organ\haunted_organ_1.ogg, db+10, 1.0};};
    class haunted_organ_2 {name = ""; sound[] = {\sounds\organ\haunted_organ_2.ogg, db+10, 1.0};};

    class sorcerie {name = ""; sound[] = {\sounds\sorcerie.ogg, db+10, 1.0};};
    class melody   {name = ""; sound[] = {\sounds\melody.ogg, db+10, 1.0};};

    // water splash effects
    class under_water_1   {name = ""; sound[] = {\sounds\defeat\water\under_water1.ogg, db+10, 1.0};};
    class under_water_2   {name = ""; sound[] = {\sounds\defeat\water\under_water2.ogg, db+10, 1.0};};
    class under_water_3   {name = ""; sound[] = {\sounds\defeat\water\under_water3.ogg, db+10, 1.0};};
    class under_water_4   {name = ""; sound[] = {\sounds\defeat\water\under_water4.ogg, db+10, 1.0};};
    class under_water_5   {name = ""; sound[] = {\sounds\defeat\water\under_water5.ogg, db+10, 1.0};};
    class under_water_6   {name = ""; sound[] = {\sounds\defeat\water\under_water6.ogg, db+10, 1.0};};
    class under_water_7   {name = ""; sound[] = {\sounds\defeat\water\under_water7.ogg, db+10, 1.0};};
    class under_water_8   {name = ""; sound[] = {\sounds\defeat\water\under_water8.ogg, db+10, 1.0};};
    class under_water_9   {name = ""; sound[] = {\sounds\defeat\water\under_water9.ogg, db+10, 1.0};};
    class fish_man_song   {name = ""; sound[] = {\sounds\defeat\water\fish_man_song.ogg, db+10, 1.0};};

	// internal submaribe effect sounds
    class submarine_sound_1   {name = ""; sound[] = {\sounds\submarine\submarine_sound_1.ogg, db+10, 1.0};};
    class submarine_sound_2   {name = ""; sound[] = {\sounds\submarine\submarine_sound_2.ogg, db+10, 1.0};};
    class submarine_sound_3   {name = ""; sound[] = {\sounds\submarine\submarine_sound_3.ogg, db+10, 1.0};};
    class submarine_sound_4   {name = ""; sound[] = {\sounds\submarine\submarine_sound_4.ogg, db+10, 1.0};};
    class submarine_sound_5   {name = ""; sound[] = {\sounds\submarine\submarine_sound_5.ogg, db+10, 1.0};};
    class submarine_sound_6   {name = ""; sound[] = {\sounds\submarine\submarine_sound_6.ogg, db+10, 1.0};};

};
