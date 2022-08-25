#include < amxmodx >
#include < amxmisc >
#include < dhudmessage >
#include < fakemeta >
#include < army_bonus >

#define PLUGIN "ABS Spectator List"
#define VERSION "2.6"
#define AUTHOR "harmony"

#define UPDATEINTERVAL 1.0

new sy1

// Getting ranks from the main lang file
new const CLS[][] = {
"I_0", 
"I_1", 
"I_2",
"I_3", 
"I_4", 
"I_5", 
"I_6", 
"I_7", 
"I_8", 
"I_9", 
"I_10", 
"I_11", 
"I_12", 
"I_13", 
"I_14", 
"I_15",
"I_16",
"I_17", 
"I_18", 
"I_19",
"I_20"
};

new ar_spec_mode

public plugin_init()
{
   register_plugin(PLUGIN, VERSION, AUTHOR);
   register_dictionary("army_bonus_system.txt");
   register_cvar(PLUGIN, VERSION);

   ar_spec_mode = register_cvar("ar_spec_mode","2");  //      1 - HUD      2 - DHUD
   sy1 = CreateHudSyncObj();   
   set_task(UPDATEINTERVAL, "tskShowSpec", 123094, "", 500, "b", 0);
}

public plugin_cfg()
{
   new szCfgDir[64], szFile[192];
   get_configsdir(szCfgDir, charsmax(szCfgDir));
   formatex(szFile,charsmax(szFile),"%s/ar/army_bonus_sys.cfg",szCfgDir);
   if(file_exists(szFile))
      server_cmd("exec %s", szFile);
}

public tskShowSpec()
{
   static szHud[256], szName[32], iExp, iExpTo, iRnk, pl[32], cnt, i, player;
   get_players(pl, cnt, "bch");
   
   for(i = 0; i < cnt; i++){
      player = pev(pl[i], pev_iuser2);
      if(!is_user_alive(player))
       continue;
    
      iExp = get_user_exp(player);
      iExpTo = get_user_expto(player);
      iRnk = get_user_lvl(player);
      get_user_name(player, szName, charsmax(szName));
      format(szHud, charsmax(szHud), "%L", LANG_PLAYER, "SPECTATING_INF", szName, LANG_PLAYER, CLS[iRnk], iExp, iExpTo, get_user_bonus(player));
      
      if(get_pcvar_num(ar_spec_mode)==1){
         set_hudmessage(100, 100, 100,0.01, 0.16, 0, 0.0, UPDATEINTERVAL + 0.1, 0.0, 0.0, -1);
         ShowSyncHudMsg(pl[i], sy1, szHud);
      }else{
         set_dhudmessage(100, 100, 100,0.01, 0.16, 0, 0.0, UPDATEINTERVAL + 0.1, 0.0, 0.0);
         show_dhudmessage(pl[i], szHud);
      }
   }
   
   return PLUGIN_CONTINUE;
}