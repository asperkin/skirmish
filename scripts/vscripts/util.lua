--helper functions that work well with this map
function getHeroForTeam(team)
   local heroes = HeroList:GetAllHeroes()
   for _, h in pairs(heroes) do
      if h:GetTeam() == team 
      then
         return h
      end
   end
   -- called before a hero was spawned/chosen for this team. return nil
   return nil
end

function Interrupt(event)
   event.caster:Interrupt()
end

function Stop(event)
   event.caster:Stop()
end

function CannotCastOnUnits(event)
   local units = FindUnitsInRadius(event.caster:GetTeam(), event.target_points[1], nil, event.hull_size, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)

   if next(units) ~= nil
   then
      event.caster:Interrupt()
      print("playerownerid= " .. event.caster:GetPlayerOwnerID())
      FireGameEvent('custom_error', {playerID = event.caster:GetPlayerOwnerID(), _text = "Cannot cast on top of units"} )
   end
end
function SetTargetHullSize(event)
   event.target:SetHullRadius(event.hull_size)
end
