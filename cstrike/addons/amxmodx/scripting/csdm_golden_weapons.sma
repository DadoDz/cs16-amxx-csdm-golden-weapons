#include <amxmodx>
#include <reapi>

// Uncomment this if you have the money_ul plugin
// #define USE_MONEY_UL

#if defined USE_MONEY_UL
    #include <money_ul>
#else
    #include <cstrike>
#endif

// Uncomment this if you want AWP to be VIP-only
// #define ONLY_VIP_AWP

#if defined ONLY_VIP_AWP
    native bool:is_user_vip(index);
#endif

#define PLUGIN  "[CSDM] Golden Weapons"
#define VERSION "1.0"
#define AUTHOR  "DadoDz"

#if defined USE_MONEY_UL
    #define get_user_money(%1) cs_get_user_money_ul(%1)
    #define set_user_money(%1,%2) cs_set_user_money_ul(%1,%2)
#else
    #define set_user_money(%1,%2) cs_set_user_money(%1,%2)
    #define get_user_money(%1) cs_get_user_money(%1)
#endif

#define GOLDEN_AK47_COST 3000   // Cost of Golden AK-47
#define GOLDEN_M4A1_COST 3000   // Cost of Golden M4A1
#define GOLDEN_AWP_COST 4250    // Cost of Golden AWP

new bool:g_bGoldenAK47[33], bool:g_bGoldenM4A1[33], bool:g_bGoldenAWP[33];

new const szWeapons[][] =
{
    "models/weapons/v_ak47_gold.mdl",   // Golden AK-47
    "models/weapons/p_ak47_gold.mdl",   // Golden AK-47

    "models/weapons/v_m4a1_gold.mdl",   // Golden M4A1
    "models/weapons/p_m4a1_gold.mdl",   // Golden M4A1

    "models/weapons/v_awp_gold.mdl",   // Golden AWP
    "models/weapons/p_awp_gold.mdl"    // Golden AWP
};

public plugin_precache()
{
    for (new i = 0; i < sizeof(szWeapons); i++)
        precache_model(szWeapons[i]);
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    RegisterHookChain(RG_CBasePlayer_Killed, "OnPlayerKilled", true);
    RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "OnWeaponDeploy", true);
    RegisterHookChain(RG_CBasePlayer_TakeDamage, "OnPlayerTakeDamage", false);

    register_clcmd("say /goldenak", "clcmd_GoldenAK47");
    register_clcmd("say /goldenm4", "clcmd_GoldenM4A1");
    register_clcmd("say /goldenawp", "clcmd_GoldenAWP");
}

public client_putinserver(id)
{
    g_bGoldenAK47[id] = false;
    g_bGoldenM4A1[id] = false;
    g_bGoldenAWP[id] = false;
}

public client_disconnected(id)
{
    g_bGoldenAK47[id] = false;
    g_bGoldenM4A1[id] = false;
    g_bGoldenAWP[id] = false;
}

public OnPlayerKilled(victim, attacker, shouldgib)
{
    g_bGoldenAK47[victim] = false;
    g_bGoldenM4A1[victim] = false;
    g_bGoldenAWP[victim] = false;
}

public clcmd_GoldenAK47(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    if (get_user_money(id) < GOLDEN_AK47_COST)
    {
        client_print_color(id, 0, "^x04[^1CSDM^x04]^x01 Not enough money^x03 ($%d)^x01.", GOLDEN_AK47_COST);
        return PLUGIN_HANDLED;
    }

    g_bGoldenAK47[id] = true;
    rg_give_item(id, "weapon_ak47", GT_REPLACE);
    rg_set_user_bpammo(id, WEAPON_AK47, 90);
    set_user_money(id, get_user_money(id) - GOLDEN_AK47_COST);
    client_print_color(id, 0, "^x04[^1CSDM^x04]^x01 You received a^x03 Golden AK-47^x01!");

    return PLUGIN_HANDLED;
}

public clcmd_GoldenM4A1(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    if (get_user_money(id) < GOLDEN_M4A1_COST)
    {
        client_print_color(id, 0, "^x04[^1CSDM^x04]^x01 Not enough money^x03 ($%d)^x01.", GOLDEN_M4A1_COST);
        return PLUGIN_HANDLED;
    }

    g_bGoldenM4A1[id] = true;
    rg_give_item(id, "weapon_m4a1", GT_REPLACE);
    rg_set_user_bpammo(id, WEAPON_M4A1, 90);
    set_user_money(id, get_user_money(id) - GOLDEN_M4A1_COST);
    client_print_color(id, 0, "^x04[^1CSDM^x04]^x01 You received a^x03 Golden M4A1^x01!");

    return PLUGIN_HANDLED;
}

public clcmd_GoldenAWP(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    #if defined ONLY_VIP_AWP
    if (!is_user_vip(id))
    {
        client_print_color(id, 0, "^x04[^1CSDM^x04]^x01 You are not a^x03 VIP^x01.");
        return PLUGIN_HANDLED;
    }
    #endif

    if (get_user_money(id) < GOLDEN_AWP_COST)
    {
        client_print_color(id, 0, "^x04[^1CSDM^x04]^x01 Not enough money^x03 ($%d)^x01.", GOLDEN_AWP_COST);
        return PLUGIN_HANDLED;
    }

    g_bGoldenAWP[id] = true;
    rg_give_item(id, "weapon_awp", GT_REPLACE);
    rg_set_user_bpammo(id, WEAPON_AWP, 30);
    set_user_money(id, get_user_money(id) - GOLDEN_AWP_COST);
    client_print_color(id, 0, "^x04[^1CSDM^x04]^x01 You received a^x03 Golden AWP^x01!");

    return PLUGIN_HANDLED;
}

public OnWeaponDeploy(const weapon)
{
    new id = get_member(weapon, m_pPlayer);

    if (!is_user_alive(id))
        return;

    new weaponid = get_member(weapon, m_iId);

    switch (weaponid)
    {
        case CSW_AK47:
        {
            if (g_bGoldenAK47[id])
            {
                set_entvar(id, var_viewmodel, szWeapons[0]);
                set_entvar(id, var_weaponmodel, szWeapons[1]);
            }
        }
        case CSW_M4A1:
        {
            if (g_bGoldenM4A1[id])
            {
                set_entvar(id, var_viewmodel, szWeapons[2]);
                set_entvar(id, var_weaponmodel, szWeapons[3]);
            }
        }
        case CSW_AWP:
        {
            if (g_bGoldenAWP[id])
            {
                set_entvar(id, var_viewmodel, szWeapons[4]);
                set_entvar(id, var_weaponmodel, szWeapons[5]);
            }
        }
    }
}

public OnPlayerTakeDamage(victim, inflictor, attacker, Float:damage, bitsDamageType)
{
    if (!is_user_connected(attacker) || attacker == victim || !is_user_alive(attacker))
        return HC_CONTINUE;

    new weapon = get_user_weapon(attacker);

    if ((weapon == CSW_AK47 && g_bGoldenAK47[attacker]) || (weapon == CSW_M4A1 && g_bGoldenM4A1[attacker]))
        SetHookChainArg(4, ATYPE_FLOAT, damage * 1.25);     // 25% more damage
    else if (weapon == CSW_AWP && g_bGoldenAWP[attacker])
        SetHookChainArg(4, ATYPE_FLOAT, damage * 1.5);      // 50% more damage

    return HC_CONTINUE;
}