//Model Moving, foked from boomix (Models in map - https://forums.alliedmods.net/showthread.php?p=2389415), I've just adjusted it a little bit.
int iPlayerSelectedBlock[MAXPLAYERS + 1];
int iPlayerNewEntity[MAXPLAYERS + 1];
int iPlayerPrevButtons[MAXPLAYERS + 1];
float fPlayerSelectedBlockDistance[MAXPLAYERS + 1];
bool bOnceStopped[MAXPLAYERS + 1];

public Action Moving_OnPlayerRunCmd(int client, int &iButtons)
{
	if(IsClientInGame(client) && CheckCommandAccess(client, "sm_props", ADMFLAG_GENERIC))
	{
		if(bMoveProp[client])
		{
			// ** 	FIRST CLICK (RUNS ONCE) 	**//
			if(!(iPlayerPrevButtons[client] & IN_USE) && iButtons & IN_USE)
				FirstTimePress(client);
			
			//** 	SECOND CLICK (RUNS ALL TIME) 	**//
			else if (iButtons & IN_USE)
				StillPressingButton(client, iButtons);
			
			//** 	LAST CLICK (RUNS ONCE) 	**//
			else if(bOnceStopped[client])
				StoppedMovingBlock(client);
			
			//** 	BLOCK ROTATE 	**//
			if(iButtons & IN_RELOAD && !(iPlayerPrevButtons[client] & IN_RELOAD))
			{
				RotateBlock(EntRefToEntIndex(iPlayerNewEntity[client]), 10.0);
			}
			
			iPlayerPrevButtons[client] = iButtons;
		}
		
	}
}

public void FirstTimePress(int client)
{
	iPlayerSelectedBlock[client] = GetAimEnt(client);
	
	if(iPlayerSelectedBlock[client] != -1 && FindInArray(iPlayerSelectedBlock[client]) != -1)
	{
		
		bOnceStopped[client] = true;
		
		iPlayerNewEntity[client] = CreateEntityByName("prop_dynamic");
		
		float TeleportNewEntityOrg[3];
		GetAimOrigin(client, TeleportNewEntityOrg);
		TeleportEntity(iPlayerNewEntity[client], TeleportNewEntityOrg, NULL_VECTOR, NULL_VECTOR);
		
		SetVariantString("!activator");
		AcceptEntityInput(iPlayerSelectedBlock[client], "SetParent", iPlayerNewEntity[client], iPlayerSelectedBlock[client], 0);
		
		float posent[3];
		float playerpos[3];
		GetClientEyePosition(client, playerpos);
		GetEntityOrigin(iPlayerNewEntity[client], posent);
		fPlayerSelectedBlockDistance[client] =  GetVectorDistance(playerpos, posent);
	
		iPlayerSelectedBlock[client] = EntIndexToEntRef(iPlayerSelectedBlock[client]);
		iPlayerNewEntity[client] = EntIndexToEntRef(iPlayerNewEntity[client]);
	}
}

void StillPressingButton(int client, int &iButtons)
{
	if (iButtons & IN_ATTACK)
		fPlayerSelectedBlockDistance[client] += 1.0;
	
	else if (iButtons & IN_ATTACK2)
		fPlayerSelectedBlockDistance[client] -= 1.0;
	
	MoveBlock(client);
}


void MoveBlock(int client)
{
	iPlayerSelectedBlock[client] = EntRefToEntIndex(iPlayerSelectedBlock[client]);
	iPlayerNewEntity[client] = EntRefToEntIndex(iPlayerNewEntity[client]);
	
	if ((iPlayerSelectedBlock[client] != INVALID_ENT_REFERENCE) && (iPlayerNewEntity[client] != INVALID_ENT_REFERENCE)) 
	{
		
		float posent[3];
		GetEntityOrigin(iPlayerNewEntity[client], posent);
		
		float playerpos[3];
		GetClientEyePosition(client, playerpos);
		
		float playerangle[3];
		GetClientEyeAngles(client, playerangle);
		
		float final[3];
		AddInFrontOf(playerpos, playerangle, fPlayerSelectedBlockDistance[client], final);
		
		TeleportEntity(iPlayerNewEntity[client], final, NULL_VECTOR, NULL_VECTOR);
		
		iPlayerSelectedBlock[client] = EntIndexToEntRef(iPlayerSelectedBlock[client]);
		iPlayerNewEntity[client] = EntIndexToEntRef(iPlayerNewEntity[client]);
	}
}


public void StoppedMovingBlock(int client)
{
	
	if(IsValidEntity(iPlayerSelectedBlock[client])) 
	{
		SetVariantString("!activator");
		AcceptEntityInput(iPlayerSelectedBlock[client], "SetParent", iPlayerSelectedBlock[client], iPlayerSelectedBlock[client], 0);
	}
	
	bOnceStopped[client] = false;
	
}

stock int GetAimOrigin(int client, float hOrigin[3])
{
	float vAngles[3];
	float fOrigin[3];
	GetClientEyePosition(client,fOrigin);
	GetClientEyeAngles(client, vAngles);
	
	TR_TraceRayFilterEx(fOrigin, vAngles, MASK_ALL, RayType_Infinite, TraceRayDontHitPlayer);
	
	if(TR_DidHit())
	{
		TR_GetEndPosition(hOrigin);
		return 1;
	}
	
	return 0;
}

stock void AddInFrontOf(float vecOrigin[3], float vecAngle[3], float units, float output[3])
{
	float vecAngVectors[3];
	vecAngVectors = vecAngle; //Don't change input
	GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
	for (int i; i < 3; i++)
		output[i] = vecOrigin[i] + (vecAngVectors[i] * units);
}


void RotateBlock(int entity, float rotatesize)
{
	if (entity != INVALID_ENT_REFERENCE)
	{
		float angles[3];
		GetEntityAngles(entity, angles);
		angles[0] += 0.0;
		angles[1] += rotatesize;
		angles[2] += 0.0;
		TeleportEntity(entity, NULL_VECTOR, angles, NULL_VECTOR);
	}
}