--Major credits to Noya!
function far_sight(event) 

   local particle = "particles/items_fx/dust_of_appearance.vpcf"

   local radius = event.ability:GetLevelSpecialValueFor("radius", event.ability:GetLevel()- 1)
   local duration = event.ability:GetLevelSpecialValueFor("duration", event.ability:GetLevel()- 1)


   local allHeroes = HeroList:GetAllHeroes()

   for _, v in pairs( allHeroes ) do
         local fxIndex = ParticleManager:CreateParticleForPlayer( particle, PATTACH_WORLDORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
         ParticleManager:SetParticleControl( fxIndex, 0, event.target_points[1] )
         ParticleManager:SetParticleControl( fxIndex, 1, Vector(radius, 0, radius) )
   end

   event.ability:CreateVisibilityNode(event.target_points[1], radius, duration)

end

function kill_seer(event)
   print("killin")
   event.caster:Kill()
end

