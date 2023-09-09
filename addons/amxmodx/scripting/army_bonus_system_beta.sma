#include < amxmodx >
#include < amxmisc >
#include < fun >
#include < cstrike >
#include < nvault >
#include < colorchat2 >
#include < dhudmessage >
#include < csx >
#include < fakemeta_util >
#include < hamsandwich >
#include < army_bonus_system >

#pragma tabsize 0;
#define ver "build-11.1-stable"

new block = 0;      // For blocking poeple from opening anew menu
new round;          // Count rounds for anew menu restrictions
new players_online;
new players_need;
new need_kills[33];
new need_hs[33];
new players[33];
new first_blood;
new gRestrictMaps, gFlash, gSmoke,gHe, gHpbylevel, gApbylevel, gTk, gLostXpTk, gLevelUpmsg
new ar_bonus_knife, ar_bonus_newlvl, ar_kill_exp, ar_kill_head, ar_kill_knife,
ar_round_acc, ar_bonus_on, ar_bonus_streak, ar_bonus_streak_head, ar_bombplant_exp, ar_def_exp, anew_dmg_deagle, anew_dmg_he;
new mode_lvlup;
new bomb_mode;
new g_iMsgIdBarTime;
new first_exp;
new g_vault;

enum _:{
	NONE,
	MEGA_DEAGLE,
	MEGA_GRENADE
};

enum _:PlData{
	gId, gExp, gLevel, gTempKey, g_Bonus, Streak, HeadStr
};

enum _:Cvars{
	price1,
	price2,
	price3,
	price4,
	price5,
	price6,
	price7,
	price8,
	price9,
	menu_str1,
	menu_str2,
	menu_str3
};

new price_cvar[Cvars];
new UserData[50][PlData];
new MaxPlayers, levelUp[33];
new bool:restr_blocked;

new const restrict_bonus[][] =
{
	"fy_pool_day",
	"fy_snow"
};

new const gRankNames[][] = 
{
	"I_0","I_1","I_2","I_3","I_4","I_5","I_6","I_7","I_8","I_9","I_10","I_11","I_12","I_13","I_14",		
	"I_15","I_16","I_17","I_18","I_19","I_20","I_21","I_22","I_23","I_24","I_25","I_26","I_27","I_28","I_29"
};

new const gLevels[] = 
{
	0,20,40,60,120,200,370,770,1020,1520,2220,2820,3220,3920,4520,5020,5520,6020,7020,9000,12000,15000,20000,25000,30000,38000,45000,50000,80000
};

new const gNades[][] =
{
	{0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1}
};

public plugin_init()
{
	register_plugin("Army Bonus System", ver, "harmony")
	register_clcmd("say /anew","anew_menu");
    set_cvar_string("abs", ver);
	
	/// Register prices
	anew_dmg_deagle 	    = register_cvar("anew_dmg_deagle","1.3");
	anew_dmg_he	            = register_cvar("anew_dmg_he","2.0");
	price_cvar[price1]		= register_cvar("price_anew_menu1","15");	// AWP price
	price_cvar[price2]		= register_cvar("price_anew_menu2","15");	// AK47 price
	price_cvar[price3]		= register_cvar("price_anew_menu3","15");	// M4A1 price
	price_cvar[price4]		= register_cvar("price_anew_menu4","15");	// %d Money
	price_cvar[price5]		= register_cvar("price_anew_menu5","5");	// %d Health
	price_cvar[price6]		= register_cvar("price_anew_menu6","10");	// %d EXP
	price_cvar[price7]		= register_cvar("price_anew_menu7","10");	// Invisibility
	price_cvar[price8]		= register_cvar("price_anew_menu8","15");	// MEGA GRENADE
	price_cvar[price9]		= register_cvar("price_anew_menu9","15");	// MEGA DEAGLE
	price_cvar[menu_str1]	= register_cvar("anew_menu1","10000");		// How much dollars you get from menu
	price_cvar[menu_str2]	= register_cvar("anew_menu2","50");			// How much health you get from menu
	price_cvar[menu_str3]	= register_cvar("anew_menu3","50");			// How much exp you get from menu

    // Register other plugin CVars
	first_exp				= register_cvar("ar_firstblood_exp","3");
	ar_def_exp 				= register_cvar("ar_def_exp","3");
	ar_bombplant_exp 		= register_cvar("ar_bombplant_exp","3");
	players_need 			= register_cvar("ar_players_need","5");
	ar_bonus_on 			= register_cvar("ar_bonus_on","1");
	ar_bonus_streak_head 	= register_cvar("ar_bonus_streak_head","2");
	ar_round_acc 			= register_cvar("ar_round_acc","1");
	ar_bonus_streak 		= register_cvar("ar_bonus_streak","2");
	ar_kill_exp 			= register_cvar("ar_kill_exp","1");
	ar_kill_head 			= register_cvar("ar_kill_head","2");
	ar_kill_knife			= register_cvar("ar_kill_exp_knife","3");
	ar_bonus_knife 			= register_cvar("ar_kill_bonus_knife","3");
	ar_bonus_newlvl			= register_cvar("ar_bonus_newlvl","8");
	gRestrictMaps 			= register_cvar("ar_restrict_maps","1");
	gFlash					= register_cvar("ar_flash_nades","0");
	gSmoke					= register_cvar("ar_smoke_nades","1");
	gHe						= register_cvar("ar_henades","1");
	gHpbylevel				= register_cvar("ar_hp_by_level","3");
	gApbylevel				= register_cvar("ar_ap_by_level","5");
	gTk 					= register_cvar("ar_tk_lose_xp","1");
	gLostXpTk 				= register_cvar("ar_tk_lose_val","1");
	gLevelUpmsg				= register_cvar("ar_level_up_msg","1");
	mode_lvlup				= register_cvar("ar_lvlup_mode","1");
	bomb_mode				= register_cvar("ar_bomb_mode","1");

	register_dictionary("army_bonus_system.txt");
	register_logevent( "EventRoundStart", 2, "1=Round_Start" );
	register_event( "DeathMsg","EventDeath","a");
	register_event("HLTV", "on_new_round", "a", "1=0", "2=0");
	register_message(get_user_msgid("SayText"), "msg_SayText");
	RegisterHam(Ham_TakeDamage,"player","TakeDamage");
	set_task(1.0, "Info", _, _, _, "b");

	MaxPlayers = get_maxplayers();
	g_vault = nvault_open("army_bonus_system");	
	g_iMsgIdBarTime = get_user_msgid("BarTime");

    if(get_pcvar_num(gRestrictMaps)){
        new szMapName[64];
        get_mapname(szMapName, 63);

        for(new a = 0; a < sizeof restrict_bonus; a++){
            if(equal(szMapName, restrict_bonus[a])){
                restr_blocked = true;
                block = 1;
                log_amx("[ABS] Bonus menu is blocked on map [%s].", restrict_bonus[a]);
                break;
            }else{
                restr_blocked = false;
                block = 0;
            }	
        }
    }
}


public plugin_cfg(){
	new szCfgDir[64], szFile[192];
	get_configsdir(szCfgDir, charsmax(szCfgDir));
	formatex(szFile, charsmax(szFile), "%s/abs/army_bonus_system.cfg", szCfgDir);
	if(file_exists(szFile)){
		server_cmd("exec %s", szFile);
	}
}

public bomb_planting(planter){
	if(players_online <= get_pcvar_num(players_need) && get_pcvar_num(bomb_mode) == 1){
		client_print(planter, print_center, "%L", LANG_PLAYER, "NO_BOMB_PLANT", get_pcvar_num(players_need));

		// Fix for planting status being played whe you're not planting a bomb
		engclient_cmd(planter,"weapon_knife");
		message_begin(MSG_ONE, g_iMsgIdBarTime, _, planter);
		write_short(0);
		message_end();								
	}
}

public bomb_planted(planter){
	if(players_online <= get_pcvar_num(players_need) && get_pcvar_num(bomb_mode) == 2) {
		ColorChat(planter, RED, "%L", LANG_PLAYER, "NOT_ENOUGH_PLAYERS", get_pcvar_num(players_need));	
		return;					
	} else {
		ColorChat(planter, GREEN, "%L", LANG_PLAYER, "SUCC_BOMB_PLANT", get_pcvar_num(ar_bombplant_exp));
		UserData[planter][gExp] += get_pcvar_num(ar_bombplant_exp);
	}
}

public bomb_defused(defuser){
	if(players_online <= get_pcvar_num(players_need))
	{
		ColorChat(defuser, RED, "%L", LANG_PLAYER,"NOT_ENOUGH_PLAYERS", get_pcvar_num(players_need));
	}else{
		ColorChat(defuser, GREEN, "%L", LANG_PLAYER, "SUCC_BOMB_DEF", get_pcvar_num(ar_def_exp));
		UserData[defuser][gExp] += get_pcvar_num(ar_def_exp);
	}
}

public TakeDamage(victim,idinflictor,idattacker,Float:damage,damagebits){
	if(!idattacker || idattacker > get_maxplayers())
		return HAM_IGNORED;
	
	if(!players[idattacker])
		return HAM_IGNORED;
	
	if(0 < idinflictor <= get_maxplayers()){
		new wp = get_user_weapon(idattacker);
		
		if(wp == CSW_DEAGLE && (players[idattacker] & (1 << MEGA_DEAGLE)))
			SetHamParamFloat(4, damage * get_pcvar_float(anew_dmg_deagle));
		}else{
		new classname[32];
		pev(idinflictor, pev_classname, classname,31);
		
		if(!strcmp(classname,"grenade") && (players[idattacker] & (1 << MEGA_GRENADE))){
			set_task(0.5, "deSetNade", idattacker);
			
			SetHamParamFloat(4, damage * get_pcvar_float(anew_dmg_he));
		}
	}
	
	return HAM_IGNORED
}

public deSetNade(id){
	players[id] &= ~(1<<MEGA_GRENADE);
}

public plugin_end(){
	nvault_close(g_vault);
}

public client_putinserver(id){
	players_online++
	UserData[id] = UserData[0];
	UserData[id][Streak] = 0;
	UserData[id][HeadStr] = 0;
	load_data(id);
	need_kills[id] = 5;
	need_hs[id] = 4;
}

public client_disconnect(id){
	players_online--;
	UserData[id][Streak] = 0;
	UserData[id][HeadStr] = 0;
	// This was a possible fix for data being erased. Unused
	// UserData[id] = UserData[0];
	players[id] = NONE;
	save_usr(id);
}

public on_new_round(id){
	round++
	first_blood = 1
}

public check_level(id){
	if(UserData[id][gLevel] <= 0)
		UserData[id][gLevel] = 1;
		
	if(UserData[id][gExp] < 0)
		UserData[id][gExp] = 0;

	while(UserData[id][gExp] >= gLevels[UserData[id][gLevel]]) 
	{
		UserData[id][gLevel]++;
		levelUp[id] = 1;
		
		switch(get_pcvar_num(mode_lvlup)){
            case 1:
            {
                UserData[id][g_Bonus] += get_pcvar_num(ar_bonus_newlvl);
                new szName[33], HudSyncObj
                HudSyncObj = CreateHudSyncObj();
                get_user_name(id, szName, 32);
                set_hudmessage(255, 100, 40, -1.0, 0.8, 0, 6.0, 5.0,0.7,0.7);
                ShowSyncHudMsg(0, HudSyncObj, "%L", LANG_PLAYER, "NEW_LVL_HUD", szName,LANG_PLAYER, gRankNames[UserData[id][gLevel]]);
                client_cmd(id, "spk abs/lvl_up");
            }
            case 2:
            {
                UserData[id][g_Bonus] += get_pcvar_num(ar_bonus_newlvl);
                new szName[33];
                get_user_name(id, szName, 32);
                static buffer[192], len;
                len = format(buffer, charsmax(buffer), "^4[^3%L^4]^1 %L ^4%s^1", LANG_PLAYER, "PRIFIX", LANG_PLAYER, "PLAYER", szName);
                len += format(buffer[len], charsmax(buffer) - len, " %L", LANG_PLAYER, "NEW_LEVEL"); 
                len += format(buffer[len], charsmax(buffer) - len, " ^4%L^1. ", LANG_PLAYER, gRankNames[UserData[id][gLevel]]);
                len += format(buffer[len], charsmax(buffer) - len, "%L", LANG_PLAYER, "CONTR");

                if(get_pcvar_num(gLevelUpmsg) == 1){
                    ColorChat(0, NORMAL, buffer);
                } else {
                    ColorChat(id, NORMAL, buffer);
                }
            }
		}
	}
}

public EventDeath(){
	static iKiller, iVictim, head, wpn[32];
	iKiller = read_data(1);

	if(!is_user_connected(iKiller))	// [Player out of range (0)]
		return PLUGIN_HANDLED
	
	iVictim = read_data(2);
	head = read_data(3);
	read_data(4, wpn, 31);
	
	if(iKiller != iVictim && is_user_connected(iKiller) && is_user_connected(iVictim) && UserData[iKiller][gLevel] <= 29)	
	{
		// First Blood
		if(first_blood == 1 && get_pcvar_num(first_exp) != 0){
			new name[33];
			get_user_name(iKiller, name, 32);
			UserData[iKiller][gExp] += get_pcvar_num(first_exp);
			client_print(0, print_center, "%L", LANG_PLAYER,"FIRST_BLOOD", name, get_pcvar_num(first_exp));
			first_blood = 0;
			return PLUGIN_HANDLED;
		}
		
		// Teamkill
		if(get_pcvar_num(gTk) && get_user_team(iKiller) == get_user_team(iVictim))
			UserData[iKiller][gExp] -= get_pcvar_num(gLostXpTk);

		// Headshot
		if(head){
			UserData[iKiller][HeadStr]++
			UserData[iKiller][gExp] += get_pcvar_num(ar_kill_head);
		}

		// Remove invisibility if player has it
		set_user_rendering(iVictim,kRenderFxNone, 255, 255, 255, kRenderNormal, 16);

		UserData[iKiller][Streak]++
		UserData[iKiller][gExp] += get_pcvar_num(ar_kill_exp);

		// Remove from victim any streaks and perks
		players[iVictim] = NONE;
		UserData[iVictim][Streak] = 0;
		UserData[iVictim][HeadStr] = 0;
		need_kills[iVictim] = 5;
		need_hs[iVictim] = 3;
	
		// KILLSTERAK
		if(UserData[iKiller][Streak] >= need_kills[iKiller]){
			UserData[iKiller][g_Bonus] += get_pcvar_num(ar_bonus_streak);
			ColorChat(iKiller, GREEN, "%L", LANG_PLAYER, "STREAK", need_kills[iKiller], get_pcvar_num(ar_bonus_streak));
			need_kills[iKiller] += 5;
		}
		
		// HEADSTREAK
		if(UserData[iKiller][HeadStr] >= need_hs[iKiller]){
			UserData[iKiller][g_Bonus] += get_pcvar_num(ar_bonus_streak_head);
			ColorChat(iKiller, GREEN, "%L", LANG_PLAYER,"STREAK_HS", need_hs[iKiller], get_pcvar_num(ar_bonus_streak_head));
			need_hs[iKiller] += 4;
		}
		
		// KNIFE KILL
		if(contain(wpn, "knife") != -1){
			UserData[iKiller][gExp] += get_pcvar_num(ar_kill_knife);
			UserData[iKiller][g_Bonus] += get_pcvar_num(ar_bonus_knife);
			ColorChat(iKiller, GREEN, "%L", LANG_PLAYER, "KNIFE_KILL", get_pcvar_num(ar_bonus_knife));
		}

		check_level(iKiller);

        save_usr(iKiller);
        save_usr(iVictim);
	}
	return PLUGIN_CONTINUE;
}

public EventRoundStart(){
	for(new id = 1; id <= MaxPlayers; id++)
	{
		save_usr(id);
			if(is_user_alive(id) && is_user_connected(id)){
				if(restr_blocked)
					return PLUGIN_CONTINUE;
			
				if(get_pcvar_num(gFlash) && gNades[0][UserData[id][gLevel]])
					give_item(id,"weapon_flashbang");
			
				if(get_pcvar_num(gSmoke) && gNades[1][UserData[id][gLevel]])
					give_item(id,"weapon_smokegrenade");
				
				if(get_pcvar_num(gHe) && gNades[2][UserData[id][gLevel]])
					give_item(id,"weapon_hegrenade");
			
				if(get_pcvar_num(gHpbylevel) != 0)
					set_user_health(id,get_user_health(id) + get_pcvar_num(gHpbylevel) * UserData[id][gLevel]);
				
				if(get_pcvar_num(gApbylevel) != 0)
					set_user_armor(id,get_user_armor(id) + get_pcvar_num(gApbylevel) * UserData[id][gLevel]);	
				
				if(levelUp[id] == 1)
					levelUp[id] = 0;
			}
	}
	return PLUGIN_CONTINUE;
}

///
///		Nvault Handling
///

public load_data(id){
	new szName[33];
	
    get_user_name(id,szName,32);

	static data[256], timestamp;
		if(nvault_lookup(g_vault, szName, data, sizeof(data) - 1, timestamp) ){
			next_load_data(id, data, sizeof(data) - 1);
			return;
		} else {
			register_player(id,"");
	}
}

public next_load_data(id,data[],len){
	new szName[33];
    new exp[10], level[10], bonus[10], rank[10];

	get_user_name(id,szName,32);
	replace_all(data,len,"|"," ");
	parse(data, exp, 9, level, 9, bonus, 9, rank, 9);

	UserData[id][gExp]= str_to_num(exp);
	UserData[id][gLevel]= str_to_num(level);
	UserData[id][g_Bonus]= str_to_num(bonus);
		
	if(UserData[id][gLevel] <= 0)
		UserData[id][gLevel] = 1;

	while(UserData[id][gExp] >= gLevels[UserData[id][gLevel]]) 
		UserData[id][gLevel]++;
}

public register_player(id,data[]){
	new szName[33];
	get_user_name(id, szName, 32);
	
	UserData[id][gExp] = 0
	UserData[id][gLevel] = 1;
	UserData[id][g_Bonus] = 0
	UserData[id][Streak] = 0	
	UserData[id][HeadStr] = 0
}

public save_usr(id){
	new szName[33];
	get_user_name(id, szName, 32);

	static data[256];
	formatex(data, 255, "|%i|%i|%i|", UserData[id][gExp], UserData[id][gLevel], UserData[id][g_Bonus]);
	nvault_set(g_vault, szName, data);
}

public client_infochanged(id){
	new newname[32], oldname[32];

	get_user_info(id, "name", newname,31);
	get_user_name(id, oldname, 31);

	if(!is_user_connected(id) || is_user_bot(id)) 
		return PLUGIN_CONTINUE;
		
	if(!equali(newname, oldname))
	{
		set_user_info(id, "name", oldname);
		log_amx("[ABS] Name change blocked.");

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public msg_SayText(){
	new arg[32];
	get_msg_arg_string(2, arg, 31);
	if(containi(arg,"name") != -1)
		return PLUGIN_HANDLED

	return PLUGIN_CONTINUE;
}

public Info(){
	for(new id = 1; id <= MaxPlayers; id++)
	{
		if(!is_user_bot(id) && is_user_connected(id) && is_user_alive(id))
		{
			static buffer[256], len; new name[33]; get_user_name(id, name, 32);
			len = format(buffer, charsmax(buffer), "%L", LANG_PLAYER,"FULL_INFO", name, LANG_PLAYER, gRankNames[UserData[id][gLevel]]);

				if(UserData[id][gLevel] <= 19){
					len += format(buffer[len], charsmax(buffer) - len, "^n%L", LANG_PLAYER, "PL_XP", UserData[id][gExp],gLevels[UserData[id][gLevel]]);
				}else{
					len += format(buffer[len], charsmax(buffer) - len, "^n%L", LANG_PLAYER, "PL_MAX");
				}

			set_dhudmessage(100, 100, 100, 0.01, 0.16, 0, 1.0, 1.0, _, _, _);
			show_dhudmessage(id, "%s", buffer);

			set_dhudmessage(100, 100, 100,-1.0,0.90, 0, 1.0, 1.0);
			show_dhudmessage(id, "%L", LANG_PLAYER, "ANEW_INFO", UserData[id][g_Bonus]);
		}
	}
	return PLUGIN_CONTINUE;
}

// Anew Menu
public anew_menu(id){

if(get_pcvar_num(ar_bonus_on) == 0){
	ColorChat(id,RED,"%L",LANG_PLAYER,"BONUS_OFF");
	return PLUGIN_HANDLED;
}

if(restr_blocked == true){
	ColorChat(id,RED,"%L",LANG_PLAYER,"BONUS_BLOCKED_MAP");
	return PLUGIN_HANDLED;
}

if(!is_user_alive(id)){
	ColorChat(id,RED,"%L",LANG_PLAYER,"ONLY_ALIVE");
	return PLUGIN_HANDLED;
}
	
if(round <= get_pcvar_num(ar_round_acc)){
	ColorChat(id,RED,"%L",LANG_PLAYER,"NOT_ENOUGH_ROUNDS",get_pcvar_num(ar_round_acc));
	return PLUGIN_HANDLED;
}

	static s_menu_it[700];
	new Text[1024];
	format(s_menu_it, charsmax(s_menu_it), "%L", LANG_PLAYER, "MENU_TITLE", UserData[id][g_Bonus]);
	new menu = menu_create(s_menu_it, "func_anew_menu");

	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price1])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_ONE", get_pcvar_num(price_cvar[price1]));
		menu_additem(menu, Text,"1");
	}else{
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text,"1");
	}

	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price2])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_TWO", get_pcvar_num(price_cvar[price2]));
		menu_additem(menu, Text,"2");
	}else{
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text,"2");
	}

	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price3])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_THREE", get_pcvar_num(price_cvar[price3]));
		menu_additem(menu, Text, "3");
	}else{
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text, "3");
	}

	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price4])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_FOUR", get_pcvar_num(price_cvar[menu_str1]), get_pcvar_num(price_cvar[price4]));
		menu_additem(menu, Text, "4");
	}else{
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text, "4");
	}

	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price5])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_FIVE", get_pcvar_num(price_cvar[menu_str2]), get_pcvar_num(price_cvar[5]));
		menu_additem(menu, Text, "5");
	}else{
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text, "5");
	}
		
	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price6])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_SIX", get_pcvar_num(price_cvar[menu_str3]), get_pcvar_num(price_cvar[price6]));
		menu_additem(menu, Text, "6");
	}else{
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text, "6");
	}
		
	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price7])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_SEVEN", get_pcvar_num(price_cvar[price7]));
		menu_additem(menu, Text, "7");
	}else{
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text, "7");
	}
		
	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price8])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_EIGHT", get_pcvar_num(price_cvar[price8]));
		menu_additem(menu, Text, "8");
	}else{
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text, "8");
	}
		
	if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price9])){
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_NINE", get_pcvar_num(price_cvar[price9]));
		menu_additem(menu, Text, "9");
	} else {
		formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
		menu_additem(menu, Text, "9");
	}
	
    menu_setprop(menu, MPROP_BACKNAME, "%L", LANG_PLAYER, "MENU_PREV");
	menu_setprop(menu, MPROP_NEXTNAME, "%L", LANG_PLAYER, "MENU_NEXT");
	menu_setprop(menu, MPROP_EXITNAME, "%L", LANG_PLAYER, "MENU_EXIT");
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public func_anew_menu(id, menu, item)
{
	if(item == MENU_EXIT){
	    menu_destroy(menu);
	    return PLUGIN_HANDLED;
	}

	new data[6], iName[64];
	new access, callback;
	 
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	new key = str_to_num(data);
    new username[32];
    get_user_name(id, username, 31);

	switch(key){
		case 1:{
			if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price1])){
				give_item(id, "weapon_awp");
				give_item(id, "weapon_hegrenade");
				give_item(id, "weapon_flashbang");
				cs_set_user_bpammo( id, CSW_AWP, 40);
				set_user_armor(id, 100);
				ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET1");
				UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price1]);
			}
		}
		case 2:{
			if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price2])){
				give_item(id, "weapon_ak47");
				give_item(id, "weapon_hegrenade");
				give_item(id, "weapon_flashbang");
				give_item(id, "weapon_flashbang");
				cs_set_user_bpammo(id, CSW_AK47, 200);
				ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET2");
				UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price2]);
			}
		}
		case 3:{
			if(UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price3])){
				give_item(id, "weapon_m4a1");
				give_item(id, "weapon_hegrenade");
				give_item(id, "weapon_flashbang");
				give_item(id, "weapon_flashbang");
				cs_set_user_bpammo(id, CSW_M4A1, 200);
				ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET3");
				UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price3]);
			}
		}
		case 4:{
			if (UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price4])){
				cs_set_user_money(id, cs_get_user_money(id) + get_pcvar_num(price_cvar[menu_str1]), 1);
				ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET4", get_pcvar_num(price_cvar[menu_str1]));
				UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price4]);
			}
		}
		case 5:{
			if (UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price5])){
				set_user_health(id, get_user_health(id) + get_pcvar_num(price_cvar[menu_str2]));
				ColorChat(id,TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET5", get_pcvar_num(price_cvar[menu_str2]));
				UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price5]);
			}
		}
		
		case 6:{
			if (UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price6])){
				UserData[id][gExp] += get_pcvar_num(price_cvar[menu_str3]);
				check_level(id);
				ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET6", get_pcvar_num(price_cvar[menu_str3]));
				UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price6]);
			}
		}
		
		case 7:{
			if (UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price7])){
				set_user_rendering(id,kRenderFxNone,0,0,0, kRenderTransTexture, 60);
                ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET7");
				UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price7]);
			}
		}
		
		case 8:{
			if (UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price8]) || !user_has_weapon(id, CSW_HEGRENADE)){
                if(!user_has_weapon(id, CSW_HEGRENADE))
                    fm_give_item(id, "weapon_hegrenade");
                    players[id] |= (1<<MEGA_GRENADE);
                    ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET8");
                    UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price8]);
                } else {
                    players[id] |= (1<<MEGA_GRENADE);
                    ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET8");
                    UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price8]);
                }
		}
		
		case 9:{
			if (UserData[id][g_Bonus] >= get_pcvar_num(price_cvar[price9])){
				DropWeaponSlot(id, 2);
				fm_give_item(id, "weapon_deagle");
				cs_set_user_bpammo(id, CSW_DEAGLE, 35);
				players[id] |= (1 << MEGA_DEAGLE);
				ColorChat(id, TEAM_COLOR, "%L", LANG_PLAYER, "ANEW_MENU_GET8")
				UserData[id][g_Bonus] -= get_pcvar_num(price_cvar[price9]);
			}
		}

		}
		return PLUGIN_HANDLED;
}

DropWeaponSlot(iPlayer, iSlot){
	static const m_rpgPlayerItems = 367;
	static const m_pNext = 42; 
	static const m_iId = 43; 
	
	if(!(1 <= iSlot <= 2)){
		return 0;
	}
	
	new iCount;
	
	new iEntity = get_pdata_cbase(iPlayer, (m_rpgPlayerItems + iSlot), 5);
	if(iEntity > 0)	{
		new iNext;
		new szWeaponName[32];
		
		do{
			iNext = get_pdata_cbase(iEntity, m_pNext, 4);
			
			if( get_weaponname(get_pdata_int(iEntity, m_iId, 4), szWeaponName, charsmax(szWeaponName )))
			{
				engclient_cmd(iPlayer, "drop", szWeaponName);
				
				iCount++;
			}
		}	while((iEntity = iNext) > 0);
	}
	return iCount;
}

public plugin_precache(){
	precache_sound("abs/lvl_up.wav");
}

public plugin_natives(){
	register_native("get_user_exp", "native_get_user_exp", 1);
	register_native("get_user_lvl", "native_get_user_lvl", 1);
	register_native("get_user_rankname", "native_get_user_rankname", 1);
	register_native("get_user_bonus", "native_get_user_bonus", 1);
	register_native("get_user_expto", "native_get_user_expto", 1);		// Returns the amount of exp left until new rank
	register_native("get_map_block","map_block",1);
    register_native("set_user_exp", "native_set_user_exp", 1);
	register_native("set_user_lvl", "native_set_user_lvl", 1);
    register_native("set_user_bonus", "native_set_user_bonus", 1);
}

public map_block(id){
	return block;
}

public native_set_user_bonus(id,num){
	UserData[id][g_Bonus] = num;
}

public native_set_user_exp(id,num){
	UserData[id][gExp] = num;
}

public native_set_user_lvl(id,num){
	UserData[id][gLevel] = num;
}

public native_get_user_exp(id){
	return UserData[id][gExp];
}

public native_get_user_lvl(id){
	return UserData[id][gLevel];
}

public native_get_user_expto(id){
	return gLevels[UserData[id][gLevel]];	
}

public native_get_user_bonus(id){
	return UserData[id][g_Bonus];
}

public native_get_user_rankname(id){
	static szRankName[64];
	format(szRankName, charsmax(szRankName), "%L", LANG_PLAYER, gRankNames[UserData[id][gLevel]]);
	return szRankName;
}
