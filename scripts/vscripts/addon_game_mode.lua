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
   PrecacheUnitByNameSync("Troll_Headhunter", context)
   PrecacheUnitByNameSync("rock", context)
   PrecacheUnitByNameSync("Gnoll_Headhunter", context)
   PrecacheUnitByNameSync("Forest_Footman", context)
   PrecacheUnitByNameSync("Blight_Footman", context)
   PrecacheUnitByNameSync("Siege_Golem", context)
   PrecacheUnitByNameSync("Ghost_Assassin", context)
   PrecacheUnitByNameSync("Haunter", context)
   PrecacheUnitByNameSync("haunt_helper", context)
   PrecacheUnitByNameSync("Siege_Burner", context)
   PrecacheUnitByNameSync("npc_hero_archmage", context)
   PrecacheUnitByNameSync("npc_hero_death_knight", context)
   PrecacheUnitByNameSync("sentry_ward", context)

   PrecacheUnitByNameSync("Control_Point_Footman", context)
   PrecacheUnitByNameSync("Control_Point_Headhunter", context)
   PrecacheUnitByNameSync("Control_Point_Siege", context)
   PrecacheUnitByNameSync("Control_Point_Ghost", context)
   PrecacheUnitByNameSync("invisible_man", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
   GameRules.AddonTemplate:InitGameMode()

end


-- generic unit spawning. istep needed for different unit widths
function spawnUnits(player, unit_name, istep, ycoord, num, hero)
   local imax = istep * (num - 1)
   local unit_team = hero:GetTeam()

   for i = 0, imax, istep do
      local point = Vector(-(imax/2) + i, ycoord, 0) -- centered
      
      local unit = CreateUnitByName(unit_name, point, true, nil, hero, unit_team)
      unit:SetControllableByPlayer(player, true)
   end
end
function spawnUnitsForBoth(player1, player2, unit_name, istep, ycoord, num)
   spawnUnits(player1, unit_name, istep, ycoord, num)
   spawnUnits(player2, unit_name, istep, -ycoord, num)
end

function spawnFootmen(num, player, hero)
   local y = 4150
   if hero:GetTeam() == DOTA_TEAM_BADGUYS then y = -4150 end
   spawnUnits(player, hero.footman_name, 80, y, num, hero)
end
function spawnHeadhunters(num, player, hero)
   local y = 4250
   if hero:GetTeam() == DOTA_TEAM_BADGUYS then y = -4250 end
   spawnUnits(player, hero.headhunter_name, 80, y, num, hero)
end

function spawnSiege(num, player, hero)
   local y = 4450
   if hero:GetTeam() == DOTA_TEAM_BADGUYS then y = -4450 end
   spawnUnits(player, hero.siege_name, 200, y, num, hero)
end   

function spawnGhost(num, player, hero)
   local y = 4650
   if hero:GetTeam() == DOTA_TEAM_BADGUYS then y = -4650 end
   spawnUnits(player, hero.ghost_name, 270, y, num, hero)
end

function spawnPoint(name, x, y, z)
   CreateUnitByName(name, Vector(x,y,z), true, nil, nil, DOTA_TEAM_NEUTRALS)
   CreateUnitByName("invisible_man", Vector(x,y,z), true, nil, nil, DOTA_TEAM_GOODGUYS)
   CreateUnitByName("invisible_man", Vector(x,y,z), true, nil, nil, DOTA_TEAM_BADGUYS)
end

function spawnControlPoints()
   --gross code goes here. spawn the sightgivers here too
   spawnPoint("Control_Point_Footman", 2304, 4096, 0)
   spawnPoint("Control_Point_Footman", -2304, 4096, 0)
   spawnPoint("Control_Point_Footman", 2304, -4096, 0)
   spawnPoint("Control_Point_Footman", -2304, -4096, 0)


   spawnPoint("Control_Point_Headhunter", 5631, 4864, 0)
   spawnPoint("Control_Point_Headhunter", -5631, 4864, 0)
   spawnPoint("Control_Point_Headhunter", 5631, -4864, 0)
   spawnPoint("Control_Point_Headhunter", -5631, -4864, 0)

   spawnPoint("Control_Point_Siege", 2304, 1280, 0)
   spawnPoint("Control_Point_Siege", -2304, 1280, 0)
   spawnPoint("Control_Point_Siege", 2304, -1280, 0)
   spawnPoint("Control_Point_Siege", -2304, -1280, 0)


   spawnPoint("Control_Point_Ghost", 0, 3328, 0)
   spawnPoint("Control_Point_Ghost", 0, -3328, 0)
end

function spawnArmy(player, hero) 
   -- spawn player units
   print("in spawnArmy() for player " .. player)

   if hero:GetUnitName() == "npc_dota_hero_keeper_of_the_light"
   then
      hero.footman_name = "Forest_Footman"
      hero.headhunter_name = "Troll_Headhunter"
      hero.siege_name = "Siege_Golem"
      hero.ghost_name = "Ghost_Assassin"
   elseif hero:GetUnitName() == "npc_dota_hero_abaddon"
   then
      hero.footman_name = "Blight_Footman"
      hero.headhunter_name = "Gnoll_Headhunter"
      hero.siege_name = "Siege_Burner"
      hero.ghost_name = "Haunter"
   end

   spawnHeadhunters(6, player, hero)
   spawnFootmen(6, player, hero)
   spawnSiege(2, player, hero)
   spawnGhost(1, player, hero)


   -- dont run again
   return nil
end   

function CAddonTemplateGameMode:onHeroPick(event)
   print("onHeroPick()")
   
   --level up gallop
   local hero = EntIndexToHScript(event.heroindex)
   hero:SetAbilityPoints(2)
   hero:UpgradeAbility(hero:GetAbilityByIndex(4))

   spawnArmy(hero:GetPlayerID(), hero)
end

function onGameStart(event)
   print("onGameStart()")

   spawnControlPoints()
end


function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
   ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(CAddonTemplateGameMode, 'onHeroPick'), self)

   GameRules:SetSameHeroSelectionEnabled(true)

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "Template addon script is running." )
      onGameStart()
      return nil
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end
