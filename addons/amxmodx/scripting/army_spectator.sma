#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>
#include <fakemeta>
#include <army_bonus_system>

#define PLUGIN "ABS Spectator Info Addon"
#define VERSION "2.7-stable"
#define AUTHOR "harmony"

#define UPDATEINTERVAL 1.0

new g_hudSync;
new g_ar_spec_mode;

// Caching
new g_cachedName[33][32];
new g_cachedExp[33];
new g_cachedExpTo[33];
new g_cachedLevel[33];
new g_cachedBonus[33];
new bool:g_dataUpdated[33];

// Getting ranks from the main lang file
new const g_rankNames[][] = {
    "I_0","I_1","I_2","I_3","I_4","I_5","I_6","I_7","I_8","I_9","I_10","I_11","I_12","I_13","I_14",		
    "I_15","I_16","I_17","I_18","I_19","I_20","I_21","I_22","I_23","I_24","I_25","I_26","I_27","I_28","I_29"
};

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_dictionary("army_bonus_system.txt");
    
    g_ar_spec_mode = register_cvar("ar_spec_mode", "2");  // 1 - HUD, 2 - DHUD
    
    g_hudSync = CreateHudSyncObj();
    
    // Update cache on death
    register_event("DeathMsg", "event_death", "a");
    
    set_task(UPDATEINTERVAL, "task_show_spectator_info", .flags = "b");
}

public plugin_cfg() {
    static szCfgDir[64], szFile[192];
    
    get_configsdir(szCfgDir, charsmax(szCfgDir));
    formatex(szFile, charsmax(szFile), "%s/abs/army_bonus_system.cfg", szCfgDir);
    
    if (file_exists(szFile)) {
        server_cmd("exec %s", szFile);
    }
}

public client_putinserver(id) {
    if (is_user_connected(id) && !is_user_bot(id)) {
        // Init cache
        update_player_cache(id);
        g_dataUpdated[id] = true;
    }
}

public client_disconnect(id) {
    // Unset cache
    arrayset(g_cachedName[id], 0, 32);
    g_cachedExp[id] = 0;
    g_cachedExpTo[id] = 0;
    g_cachedLevel[id] = 0;
    g_cachedBonus[id] = 0;
    g_dataUpdated[id] = false;
}

public event_death() {
    // Update cache
    static victim;
    victim = read_data(2);
    
    if (is_user_connected(victim)) {
        update_player_cache(victim);
    }
}

update_player_cache(id) {
    if (!is_user_connected(id)) {
        return;
    }
    
    get_user_name(id, g_cachedName[id], charsmax(g_cachedName[]));
    g_cachedExp[id] = get_user_exp(id);
    g_cachedExpTo[id] = get_user_expto(id);
    g_cachedLevel[id] = get_user_lvl(id);
    g_cachedBonus[id] = get_user_bonus(id);
    g_dataUpdated[id] = true;
}

public task_show_spectator_info() {
    static players[32], num, i, spectator, target;
    get_players(players, num, "bh"); 
    
    for (i = 0; i < num; i++) {
        spectator = players[i];
        target = pev(spectator, pev_iuser2);
        
        if (!is_user_connected(target) || !is_user_alive(target)) {
            continue;
        }
        
        if (!g_dataUpdated[target]) {
            update_player_cache(target);
        }
        
        static szHud[256];
        format(szHud, charsmax(szHud), "%L", LANG_PLAYER, "SPECTATING_INF", 
               g_cachedName[target], 
               LANG_PLAYER, g_rankNames[g_cachedLevel[target]], 
               g_cachedExp[target], 
               g_cachedExpTo[target], 
               g_cachedBonus[target]);
        
        switch (get_pcvar_num(g_ar_spec_mode)) {
            case 1: { // HUD
                set_hudmessage(100, 100, 100, 0.01, 0.16, 0, 0.0, UPDATEINTERVAL + 0.1, 0.0, 0.0, -1);
                ShowSyncHudMsg(spectator, g_hudSync, szHud);
            }
            case 2: { // DHUD
                set_dhudmessage(100, 100, 100, 0.01, 0.16, 0, 0.0, UPDATEINTERVAL + 0.1, 0.0, 0.0);
                show_dhudmessage(spectator, szHud);
            }
        }
    }
}