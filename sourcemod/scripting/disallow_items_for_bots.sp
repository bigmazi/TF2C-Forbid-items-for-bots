// Look for comments

#pragma semicolon 1

#include <tf2c>
#include <sdktools>

#define PLUGIN_VERSION "1.1"

public Plugin myinfo = {
	name = "Disallow items for bots",
	author = "bigmazi",
	description = "Bots can't equip forbidden items",
	version = PLUGIN_VERSION,
	url = ""
};

bool HasForbiddenItem(c)
{
	#define BEGIN(%1) \
	{\
		int slot = GetPlayerWeaponSlot(c, %1);\
		if (IsValidEntity(slot))\
		{\
			int index = GetEntProp(slot, Prop_Send, "m_iItemDefinitionIndex");\
			if (
	#define END false) return true;}}
	#define BEGIN_WEARABLE \
	{\
		int slot = -1;\
		while ((slot = FindEntityByClassname(slot, "tf_wearable")) != -1)\
		{\
			if (GetEntPropEnt(slot, Prop_Send, "m_hOwnerEntity") == c)\
			{\
				int index = GetEntProp(slot, Prop_Send, "m_iItemDefinitionIndex");\
				if (
	#define END_WEARABLE false) return true;}}}
	#define FORBID(%1) index == (%1) ||	
	
	#define PRIMARY 0
	#define SECONDARY 1
	#define MELEE 2
	
// ----------------------------------------------------------
// MODIFY FROM HERE...
// ----------------------------------------------------------
	
	// Remove /*  */ comment symbols to enable checking for a specific slot
	
	/*
	BEGIN(PRIMARY)
		FORBID(40)		// rpg - item index definition from items_game.txt file
		FORBID(41)		// hunting revolver
	END
	*/
	
	/*
	BEGIN(SECONDARY)
		FORBID(45)		// coilgun
	END
	*/
	
	BEGIN(MELEE)
		FORBID(47)		// shock therapy
		FORBID(34)		// ubersaw
	END
	
	// tf_wearable items should be handled separately
	BEGIN_WEARABLE
		FORBID(38)		// gunboats
	END_WEARABLE
	
// ----------------------------------------------------------
// ...TO HERE
// ----------------------------------------------------------
	
	return false;
}

public OnPluginStart()
{	
	HookEvent("post_inventory_application", Hook_PlayerInventoryApplication);
}

Action Hook_PlayerInventoryApplication(Handle event, const char[] name, bool dontBroadcast)
{
	int id = GetEventInt(event, "userid");
	int c = GetClientOfUserId(id);
	
	if (IsFakeClient(c) && HasForbiddenItem(c))
	{
		CreateTimer(0.1, Timer_ReapplyInventory, id);
	}
		
	return Plugin_Continue;
}

Action Timer_ReapplyInventory(Handle t, id)
{
	int c = GetClientOfUserId(id);
	
	if (c > 0 && IsPlayerAlive(c))
	{
		TF2_RespawnPlayer(c);
	}
}