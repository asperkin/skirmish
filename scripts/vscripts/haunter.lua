require('util')

function onHauntCast(event)
   --clear previous helper and vfx
   if (event.caster.haunt_vfx) 
   then 
      ParticleManager:DestroyParticle(event.caster.haunt_vfx, false)
      event.caster.haunt_vfx = nil
   end


   event.caster.haunt_center = event.target_points[1]
   event.caster.invis = false
   local hero = getHeroForTeam(event.caster:GetTeam())
   event.caster.haunt_vfx = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail_circle.vpcf", PATTACH_WORLDORIGIN, event.caster, PlayerResource:GetPlayer(hero:GetPlayerID()))

   ParticleManager:SetParticleControl(event.caster.haunt_vfx, 0, event.target_points[1])
   ParticleManager:SetParticleControl(event.caster.haunt_vfx, 1, Vector(126,0,0))
end

function hauntAreaThink(event)
   local caster = event.caster

   local distance = (caster:GetAbsOrigin() - caster.haunt_center):Length()
   if distance < event.radius
   then
      event.ability:ApplyDataDrivenModifier(caster,caster,"modifier_haunt_invis", {duration = 0.22})
      if caster.invis == false 
      then
         caster:EmitSound("Hero_TemplarAssassin.Meld")
      end
      caster.invis = true
   else
      caster.invis = false
   end
end

function disappear(event)
   event.caster.disappear_point = event.target_points[1]
   local diff = event.caster.disappear_point - event.caster:GetAbsOrigin()
   if diff:Length2D() > event.range 
   then
      event.caster.disappear_point = event.caster:GetAbsOrigin() + (event.caster.disappear_point - event.caster:GetAbsOrigin()):Normalized() * event.range
   end

   --hide caster for delay
   --there is no model scale getter currently. hardcoded to reset to 1.2
   event.caster:SetModelScale(0)
end

--guaranteed that disapear was called first
function reappear(event)
   FindClearSpaceForUnit(event.caster, event.caster.disappear_point, false)
   event.caster:SetModelScale(1.2)
end
