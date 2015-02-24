--Some planning and advice from Noya

function set_rally(event)
   print("here")
   event.caster.rally = event.target_points[1]
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
   units_on_point = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, event.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)

   if caster.contested == 1 and next(units_on_point) ~= nil then caster.contestedClock = caster.contestedClock + event.time_interval end

   if next(units_on_point) ~= nil
   then
      --if only one players units are in circle
      cappingTeam = SinglePlayerOnPoint(units_on_point)
      if cappingTeam ~= caster:GetTeam() -- actual contention
      then
         if caster.contested == 0 or caster.contested == nil -- beginning of contention
         then
            caster.contested = 1
            caster.contestedClock = 0
            print("new contention")
         elseif caster.contested == 1 and math.abs(caster.contestedClock % 1) < 0.001
         then
            -- the point is being taken over! and its time to decrement "progress bar"
            caster:SetHealth(caster:GetHealth() - (caster:GetMaxHealth() / event.cap_time))
            --if casters health is about 1
            if caster:GetHealth() <= 2
            then
               --teamchange
               caster:SetTeam(cappingTeam)
               if cappingTeam == DOTA_TEAM_GOODGUYS
               then
                  caster:SetControllableByPlayer(0, true)
               elseif cappingTeam == DOTA_TEAM_BADGUYS
               then
                  caster:SetControllableByPlayer(5, true)
               end
               --restore hp
               caster:SetHealth(caster:GetMaxHealth())
               --reset rally - no enemy rallies!
               caster.rally = nil
            end
         end
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
      end

   end

   --spawning code
   if caster.time % 1 <= 0.001 
   then
      caster:SetMana(caster:GetMana() + 1)
      if caster:GetMana() == caster:GetMaxMana() 
      then   
         caster:SetMana(0)
         if caster:GetTeam() ~= DOTA_TEAM_NEUTRALS 
         then
            local unit = CreateUnitByName(event.unit_name, caster:GetAbsOrigin(), true, nil, nil, caster:GetTeam())
            if caster:GetTeam() == DOTA_TEAM_GOODGUYS
            then
               unit:SetControllableByPlayer(0, true)
            elseif  caster:GetTeam() == DOTA_TEAM_BADGUYS
            then
               unit:SetControllableByPlayer(5, true)
            end

            if caster.rally ~= nil
            then
               print("moving")
               Timers:CreateTimer(1, function() unit:MoveToPosition(caster.rally) end)
            end
         end
      end
   end
end

