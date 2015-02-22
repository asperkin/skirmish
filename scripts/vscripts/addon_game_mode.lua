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
   PrecacheUnitByNameSync("Ghost_Assassin", context)
   PrecacheUnitByNameSync("npc_hero_tactician", context)

   PrecacheUnitByNameSync("Control_Point_Footman", context)
   PrecacheUnitByNameSync("Control_Point_Headhunter", context)
   PrecacheUnitByNameSync("Control_Point_Golem", context)
   PrecacheUnitByNameSync("Control_Point_Assassin", context)
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
    spawnUnits(5, "Forest_Footman", 80, -5500, num)
end
function spawnHeadhunters(num)
    spawnUnits(0, "Gnoll_Headhunter", 80, 5600, num)
    spawnUnits(5, "Gnoll_Headhunter", 80, -5600, num)
end

function spawnSiege(num)
   spawnUnits(0, "Siege_Golem", 200, 5800, num)
   spawnUnits(5, "Siege_Golem", 200, -5800, num)
end   

function spawnAssassin(num)
   spawnUnits(0, "Ghost_Assassin", 270, 6000, num)
   spawnUnits(5, "Ghost_Assassin", 270, -6000, num)
end

function spawnControlPoints()
   --gross code goes here
    CreateUnitByName("Control_Point_Footman", Vector(2304,4096,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Footman", Vector(-2304,4096,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Footman", Vector(2304,-4096,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Footman", Vector(-2304,-4096,0), true, nil, nil, DOTA_TEAM_NEUTRALS)


    CreateUnitByName("Control_Point_Headhunter", Vector(5631,4864,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Headhunter", Vector(-5631,4864,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Headhunter", Vector(5631,-4864,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Headhunter", Vector(-5631,-4864,0), true, nil, nil, DOTA_TEAM_NEUTRALS)

    CreateUnitByName("Control_Point_Golem", Vector(2304,1280,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Golem", Vector(-2304,1280,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Golem", Vector(2304,-1280,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Golem", Vector(-2304,-1280,0), true, nil, nil, DOTA_TEAM_NEUTRALS)


    CreateUnitByName("Control_Point_Assassin", Vector(0,3328,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    CreateUnitByName("Control_Point_Assassin", Vector(0,-3328,0), true, nil, nil, DOTA_TEAM_NEUTRALS)


end

--hacky
function levelUpGallop()
   heroes = HeroList:GetAllHeroes()
   for _, h in pairs(heroes) do
      h:SetAbilityPoints(2)
      h:UpgradeAbility(h:GetAbilityByIndex(3)) -- ability 5
   end
      
end

function spawnArmy() 
   -- spawn player units
   print("in spawnArmy().")

   spawnHeadhunters(10)
   spawnFootmen(10)
   spawnSiege(4)
   spawnAssassin(2)
   spawnControlPoints()

   levelUpGallop()

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
