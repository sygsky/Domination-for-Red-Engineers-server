// init include client
if (X_Client) then {
    // 0 = player markers turned off
    // 1 = player markers with player names and healthess
    // 2 = player markers without player names
    // 3 = player markers with roles but no name
    // 4 = player markers with player health, no name
    d_show_player_marker = 1;
    // true, you won't see markers at all and you can't turn them on
    d_dont_show_player_markers_at_all = false;

    // choose false, if you don't want to use the backpack feature
    d_use_backpack =
    #ifndef __ACE__
        true;
    #else
        false;
    #endif

    // if set to false you will not see the names beside a player marker on the map
    d_show_player_marker_names = true;
    // if set to true player marker direction will be set to player direction
    d_p_marker_dirs = false; // if  d_p_marker == "Vehicle" it is useless to draw direction as marker is the circle
    // if set to true vehicle marker direction will be set to vehicle direction
    d_v_marker_dirs = true;
    // marker type used for players
    d_p_marker = "Vehicle";

    #ifdef __ACE__
    d_p_dead_marker = "Vehicle";
    #endif

    // choose false, if you don't want to use teamstatusdialog
    d_use_teamstatusdialog = true;

    // position of the player ammobox at base (created only on the players computer, re-filled every 20 minutes)
    d_player_ammobox_pos =
    #ifdef __SCHMALFELDEN__

        [[2504.62,120.872,0],145.764];

    #endif
    #ifdef __UHAO__

        [[2248.13,4572.81,0],272];

    #endif
    #ifdef __DEFAULT__
        #ifdef __TT__

        [
            [[2603.55,2858.77,0],260], // West
            [[18057.5,18193.8,0],80]  // Racs
        ];

        #else
        //[[9654.24,9993,0],270]; // [[9654.24,9993.49,0],270] box pos for orginal Xeno base building (Camp of Warfire)
        [[9672.535,9993.026, 0.25],180]; // box pos for the depot as base building (Depot of Warfire) 9672.535156,142.730530,9993.026367

        #endif
    #endif

    #ifdef __ACE__
    d_ace_boxes = [
        #ifdef __DEFAULT__
        ["ACE_RuckBox",[9670.771,9998.445,0.69],0], 	// [9659.13,9982.11,0],0]
        //["ACE_MedicBox",[9659.12,9980.25,0],0], // [9664.12,9979.25,0],0]
        ["ACE_HuntIRBox",[9667.064,9995.478,0.7],270] // [9659.16,9978.42,0],0]
        #endif
    ];
    #endif

    // this vehicle will be created if you use the "Create XXX" at a mobile respawn (old "Create Motorcycle") or a jump flag
    // IMPORTANT !!!! for ranked version !!!!
    // if there is more than one vehicle defined in the array the vehicle will be selected by player rank
    // one vehicle only, vehicle is only available when the player is at least lieutenant
    d_create_bike =
    #ifdef __OWN_SIDE_RACS__
    ["M1030"];
    #endif
    #ifdef __OWN_SIDE_WEST__
    if (__ACEVer) then {
        ["ACE_Bicycle", "M1030", "ACE_ATV_HondaR"]
    } else {
        ["M1030"]
    };
    #endif
    #ifdef __OWN_SIDE_EAST__
    if (__ACEVer) then {
        ["ACE_Bicycle", "TT650G", "ACE_ATV_HondaR"]
    } else {
        ["TT650G"]
    };
    #endif
    #ifdef __TT__
    ["M1030"];
    #endif

    // if the array is empty, anybody can fly,
    // just add the type of players that can fly if you want to restrict to certain types
    // for example: d_only_pilots_can_fly = ["SoldierWPilot","SoldierWMiner"];
    // this includes bonus aircrafts too
    d_only_pilots_can_fly = [];

    #ifdef __ACE__
    // some ACE client stuff, haven't tested if it is still valid, but I think it's not needed anymore
    ACE_RespawnFade = true;
    ACE_RespawnNoChat = true;
    ACE_Respawn = true;
    //ACE_Wind_Modifier_Vehicles = 0.5; // wind influence to helicopter flight
    #endif

    current_mission_resolved_text = "";

    #ifndef __TT__
    max_number_ammoboxes = 6;
    #endif
    #ifdef __TT__
    max_number_ammoboxes = 20;
    #endif

    tele_array = [];
    player_is_driver = false;
    client_target_counter = 0;
    current_mission_text = localize "STR_SYS_120"; // "Дополнительное задание ещё не получено..."
    vec2_id = -1000;
    vec3_id = -1000;
    vec_id = -1000;
    actionID1 = -1;
    actionID2 = -1;
    weapon_array = [];
    ass = -1;
    bike_created = false;
    // time player has to wait until he can drop the next ammobox (in seconds)
    d_drop_ammobox_time = 300;
    max_truck_cargo = 6;
    current_truck_cargo_array = 0;
    cargo_selected_index = -1;
    currently_loading = false;
    pbp_id = -9999;
    // d_check_ammo_load_vecs
    // the only vehicles that can load an ammo box are the transport choppers and MHQs__
    d_check_ammo_load_vecs = ["M113_MHQ","UH60mg"];
    #ifdef __OWN_SIDE_EAST__
    d_check_ammo_load_vecs = ["BMP2_MHQ","Mi17_MG"];
    #endif
    #ifdef __CSLA__
    d_check_ammo_load_vecs = ["CSLAWarfareEastMobileHQ","CSLA_Mi8T"];
    #endif
    #ifdef __ACE__
    d_check_ammo_load_vecs = (
        if (d_enemy_side == "EAST") then {
            ["M113_MHQ","ACE_UH60MG_M240C","ACE_UH60MG_M134","ACE_CH47D_CARGO","ACE_Mi17_MG"]
        } else {
            ["ACE_Mi17_MG","BMP2_MHQ","ACE_UH60MG_M240C","ACE_UH60MG_M134"]
        }
    );
    #endif

    #ifndef __REVIVE__
    d_respawn_delay = D_RESPAWN_DELAY;
    // if you set d_with_respawn_dialog_after_death = false then you will respawn at your base, if true you'll see the respawn dialog allways if you die
    d_with_respawn_dialog_after_death = true;
    // if set to false, players will respawn with BIS default weapons
    x_weapon_respawn = true;
    #endif

    #ifdef __REVIVE__
    x_weapon_respawn = false;
    #endif

    #ifdef __AI__
    max_ai = 11; // 8;
    #endif

    #ifdef __MANDO__
    vec_mando_id = -1000;
    #endif

    // gets subtracted from your current score if you die (must be a negative value, only valid in the ranked version)
    d_sub_kill_points = -1;


    // gets subtracted for killing others (not negative)
    d_sub_tk_points = 20;

    // points needed to get a specific rank
    // gets even used in the unranked versions, though it's just cosmetic there
    d_points_needed = [
    #ifdef __OLD_SCORES__
    //  score/ Name      /diff /r.num/r.cost
        40, // Ефрейтор   +40  1      0
        80, // Сержант    +40  2      5 (min, static)
        150, // Лейтенант +70  3      15
        300, // Капитан   +150 4      10
        500, // Майор     +200 5      10
        800 // Полковник  +300 6      30
    #else
        40, // Ефрейтор   / Corporal   +40
        80, // Сержант    / Sergeant   +80
        120, // Лейтенант / Lieutenant +40
        180, // Капитан   / Captain    +40
        300, // Майор     / Major      +120
        800 // Полковник  / Colonel    +500
    #endif
    ];

    d_rank_names = ["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"];
    // not official ranks for super-gamers only
    d_pseudo_ranks =
        [1300,1800,2300,3000,4000,5000]; // +500 6 40, +500 35, +500 8 30, +700 9 35, +1000 10 50, +1000 11 45
    d_pseudo_rank_names =
        //[localize "STR_SYS_1000",localize "STR_SYS_1001",localize "STR_SYS_1002",localize "STR_SYS_1003",localize "STR_SYS_1004",localize "STR_SYS_1005"];
        ["BRIGADIER-GENERAL","LIEUTENANT-GENERAL","COLONEL-GENERAL","GENERAL-OF-THE-ARMY","MARSHAL","GENERALISSIMO"];

    #ifdef __RANKED__
    // Array with all predefined score for many achievments
    d_ranked_a = [
        10, 		// 0 очков необходимо инженеру для ремонта
        [4,3,2,1], 	// 1 очков начисляется инженеру за ремонт авиа, танки, машины, другое. Now is deprected, score added for the number of repair steps, not vehicle type!!!
        2, 			// 2 очков вычитается за 1 залп
        5,          // 3 points in the AI version for recruiting one soldier at lowest rank, each next rank add the same score number to cost
        1, 			// 4 очков вычитается за AAHALO parajump
        2, 			// 5 очков вычитается за создание техники из MHQ
        (d_points_needed select 0), // 6 очков необходимо игроку иметь для создания техники из MHQ (ефрейтор?)
        2, 			// 7 очков начисляется медику за лечение игроков в его палатке
        ["Sergeant","Lieutenant","Captain","Major"], // 8  ранги необходимые для управления различной техникой: легкая броня, танки, боевые верты, самолеты
        40, 		// 9 очков начисляется за взятие города
        500, 		//10 дистанция на которой ещё начисляются очки за взятие города
        20, 		//11 очков за дополнительную миссию
        250, 		//12 дистанция за которую начисляются очки за допку
        5,  		//13 очков требуется для починки разрушенных сервисов на базе
        10, 		//14 очков необходимо для развертывания пулеметного гнезда
        5, 	        //15 points needed in AI Ranked to call in an airtaxi
        80,			//16 очков необходимо для вызова снабжения
        5, 			//17 очков начисляются медику за лечение других игроков
        5, 			//18 очки получаемые за перевозку других игроков
        20,			//19 очков необходимо для вызова артиллерийского удара
        10,			//20 очков вычитается за ремонт разрушенных сервисов на базе
        10,			//21 очков вычитается за развертывание пулеметного гнезда
        20,			//22 очков вычитается за вызов снабжения
        1,			//23 очков добавляется за посещение неизвестной до того палатки
        5,			//24 очка вычитают за провал задания ГРУ по доставке секретной карты...
        10,         //25 очков вычисляется за выполнение второстепенного задания в городе
        "Corporal", //26 rank to resurrect internal objects on server map (vegetation, fences etc) - not used
        9,          //27 scores added for observer kill +1 for ordinal frag
        "Sergeant", //28 lowest rank abled to call the recruit
        1			//29 score for vehicle respawn
    ];

    // distance a player has to transport others to get points
    d_transport_distance = 2000; // 1500;

    // rank needed to fly the wreck lift chopper
    d_wreck_lift_rank = "Private"; //+++Sygsky: was "Lieutenant", "Major" , "Colonel"
    #endif

    d_viewdistance = 1500; // default view distance diameter
    d_graslayer_index = 0; // default graas level (no grass at all)
    d_playermarker_index = 1; // default player marker: marker with name
    d_rebornmusic_index = 0; // default reborn music: play

    #ifdef __ACE__
    // set d_with_ace_map to true if you want to use ACE_Map
    d_with_ace_map = false;
    #endif

    // Set it to false if you have performance problems (short hickups) at mission start.
    // If false repair stations can not repair vehicles
    d_with_repstations = true;
#ifdef __SPPM__
    SYG_recentSPPMCmdUseTime = time;
#endif
};