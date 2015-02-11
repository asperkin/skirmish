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
   PrecacheUnitByNameSync("Gnoll_Headhunter", context)
   PrecacheUnitByNameSync("Forest_Footman", context)
   PrecacheUnitByNameSync("Siege_Golem", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	
   GameRules:GetGameModeEntity():SetThink(spawnArmy, 2)
end

-- generic unit spawning. istep needed for different unit widths
function spawnUnits(player, unit_name, istep, ycoord, num)
   local imax = istep * (num - 1)
   local unit_team
   if player == 0 then
      unit_team = DOTA_TEAM_GOODGUYS
   else
      unit_team = DOTA_TEAM_BADGUYS
   end

   for i = 0, imax, istep do
      local point = Vector(-(imax/2) + i, ycoord, 0) -- centered
      
      local unit = CreateUnitByName(unit_name, point, true, nil, nil, unit_team)
      unit:SetControllableByPlayer(player, true)
   end
end

function spawnFootmen(num)
    spawnUnits(0, "Forest_Footman", 80, 5500, num)
    -- spawn for other player as well
end
function spawnHeadhunters(num)
    spawnUnits(0, "Gnoll_Headhunter", 80, 5600, num)
end

function spawnSiege(num)
   spawnUnits(0, "Siege_Golem", 120, 5800, num)
end   

function spawnArmy() 
   -- spawn player units
   print("in spawnUnits().")

   spawnHeadhunters(10)
   spawnFootmen(10)
   spawnSiege(4)

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
