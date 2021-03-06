require('util')

--Some planning and advice from Noya
local num_points = 14
local goodguy_points = 0
local badguy_points = 0

function GetSpawningUnitName(caster, hero)
   local unit_name = ""
   if hero:GetUnitName() == "npc_dota_hero_keeper_of_the_light"
   then
      if caster:GetUnitName() == "Control_Point_Footman"
      then
         unit_name = "Forest_Footman"
      elseif caster:GetUnitName() == "Control_Point_Headhunter"
      then
         unit_name = "Troll_Headhunter"
      elseif caster:GetUnitName() == "Control_Point_Siege"
      then
         unit_name = "Siege_Golem"
      elseif caster:GetUnitName() == "Control_Point_Ghost"
      then
         unit_name = "Ghost_Assassin"
      end
   elseif hero:GetUnitName() == "npc_dota_hero_abaddon"
   then
      if caster:GetUnitName() == "Control_Point_Footman"
      then
         unit_name = "Blight_Footman"
      elseif caster:GetUnitName() == "Control_Point_Headhunter"
      then
         unit_name = "Gnoll_Headhunter"
      elseif caster:GetUnitName() == "Control_Point_Siege"
      then
         unit_name = "Siege_Burner"
      elseif caster:GetUnitName() == "Control_Point_Ghost"
      then
         unit_name = "Haunter"
      end
   end

   return unit_name
end

--remove from the table units that arent allowed to cap
function FilterUnits(units)
   local table = {}
   for key, unit in pairs(units) do
      if unit:GetUnitName() ~= "sentry_ward"
      then
         table[key] = unit
      end
   end
   return table
end

--returns result of GetTeam() if only one team is on the point, else nil
function SinglePlayerOnPoint(units)
   local cappingTeam = nil
   for _,unit in pairs(units) do
      if cappingTeam == nil then cappingTeam = unit:GetTeam() end
      if cappingTeam ~= unit:GetTeam() then return nil end
   end
   return cappingTeam
end
function zero_mana(event)
   event.caster:SetMana(0)
end

function capture_check(event) 
   local caster = event.caster
   if caster.time == nil then caster.time = 0 else caster.time = caster.time + event.time_interval end

   --capturing code
   units_on_point = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, event.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)

   if caster.contested == 1 
   then
      caster.contestedClock = caster.contestedClock + event.time_interval 
   end

   if next(units_on_point) ~= nil
   then
      --remove units that arent allowed to cap
      units_on_point = FilterUnits(units_on_point)
      --check if a player is dominating point presence
      cappingTeam = SinglePlayerOnPoint(units_on_point)
      if cappingTeam ~= caster:GetTeam() and cappingTeam ~= nil-- actual contention
      then
         if caster.contested == 0 or caster.contested == nil -- beginning of contention
         then
            caster.contested = 1
            caster.contestedClock = 0
            print("new contention")
         elseif caster.contested == 1 
         then
            if math.abs(caster.contestedClock % 1) < 0.001
            then
               -- the point is being taken over! and its time to decrement "progress bar"
               caster:SetHealth(caster:GetHealth() - (caster:GetMaxHealth() / event.cap_time))
               --if casters health is about 1
               if caster:GetHealth() <= 2
               then
                  --teamchange
                  local prevTeam = caster:GetTeam()
                  caster:SetTeam(cappingTeam)
                  local hero = getHeroForTeam(cappingTeam)
                  caster:SetControllableByPlayer(hero:GetPlayerID(), true)
                  caster:SetOwner(hero)

                  --restore hp
                  caster:SetHealth(caster:GetMaxHealth())
                  --reset rally - no enemy rallies!
                  caster.rally = nil

                  if cappingTeam == DOTA_TEAM_GOODGUYS
                  then
                     goodguy_points = goodguy_points + 1

                     caster:EmitSound("Hero_Puck.Phase_Shift")
                     local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
                     ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
                     ParticleManager:SetParticleControl(particle, 1, Vector(400,0,0))

                     if prevTeam == DOTA_TEAM_BADGUYS 
                     then badguy_points = badguy_points - 1 end
                     if goodguy_points == num_points
                     then
                        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
                     end
                  elseif cappingTeam == DOTA_TEAM_BADGUYS
                  then

                     badguy_points = badguy_points + 1
                     caster:EmitSound("Hero_Bane.Enfeeble")
                     local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
                     ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())

                     if prevTeam == DOTA_TEAM_GOODGUYS
                     then goodguy_points = goodguy_points - 1 end
                     if badguy_points == num_points
                     then
                        GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
                     end
                  end 
               end --end of if caster:GetHealth() <= 2
            end --end of if(on second)
         end --end of if(contested==1)
      end --end of if(any units on point)
      elseif caster.contested == 1 --point not being captured by enemy, but contested flag is up. increment hp rather than decrement
      then
         if caster:GetHealth() < caster:GetMaxHealth() and math.abs(caster.contestedClock % 1) < 0.001
         then
            if caster:GetHealth() + (caster:GetMaxHealth() / event.cap_time) <= caster:GetMaxHealth() 
            then caster:SetHealth(caster:GetHealth() + (caster:GetMaxHealth() / event.cap_time))
            else caster:SetHealth(caster:GetMaxHealth())
            end
         end
         if caster:GetHealth() == caster:GetMaxHealth() 
         then
            print("contention reset")
            caster.contested = 0
            caster.contestedClock = 0
         end
      end --end of if contested==1

   --spawning code
   if caster.time % 1 <= 0.001 
   then
      caster:SetMana(caster:GetMana() + 1)
      if caster:GetMana() == caster:GetMaxMana() 
      then   
         caster:SetMana(0)
         if caster:GetTeam() ~= DOTA_TEAM_NEUTRALS 
         then
            local hero = getHeroForTeam(caster:GetTeam())
            local unit_name = GetSpawningUnitName(caster, hero)
            local unit = CreateUnitByName(unit_name, caster:GetAbsOrigin(), true, nil, caster:GetOwner(), caster:GetTeam())

            unit:SetControllableByPlayer(hero:GetPlayerID(), true)

            if caster.rally ~= nil
            then
               print("moving")
               GameRules:GetGameModeEntity():SetThink(function() unit:MoveToPosition(caster.rally) return nil end, DoUniqueString("rally_move"), 0.06)
            end
         end
      end
   end
end

