function DealDamage(event)
   local damage = {}
   if event.target:IsHero()
   then
      damage = {victim = event.target, attacker = event.caster, damage = event.dmg_heroes, damage_type = DAMAGE_TYPE_PHYSICAL, }
   else
      damage = {victim = event.target, attacker = event.caster, damage = event.dmg_units, damage_type = DAMAGE_TYPE_PHYSICAL, }
   end
   ApplyDamage(damage)
end
