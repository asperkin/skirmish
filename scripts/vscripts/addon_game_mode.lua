-- Generated from template

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
   PrecacheUnitByNameSync("pc_gnoll", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	
   GameRules:GetGameModeEntity():SetThink(spawnUnits, 2)
end

function spawnUnits() 
   -- spawn player units
   print("in onGameStart().")
   local unit_team = DOTA_TEAM_GOODGUYS
   local unit_name = "pc_gnoll"
   local player = PlayerResource:GetPlayer(0)
   local point = Vector(0,0,0)
   local unit = CreateUnitByName(unit_name, point, true, nil, nil, unit_team)
   unit:SetControllableByPlayer(player:GetPlayerID(), true)

   -- dont run again
   return nil
end   

function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end
