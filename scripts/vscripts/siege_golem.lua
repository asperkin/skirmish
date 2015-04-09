function remove_movement(event)
   event.caster.move_speed = event.caster:GetBaseMoveSpeed()
   event.caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
end
function restore_movement(event)
   event.caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
   event.caster:SetBaseMoveSpeed(event.caster.move_speed)
end

function already_on_check(event)
   if event.caster:HasModifier("mod_war_stance") or event.caster:HasModifier("mod_burner_war_stance")
      then
         event.caster:Interrupt()
      end
end
function is_off_check(event)
   if not event.caster:HasModifier("mod_war_stance") and not event.caster:HasModifier("mod_burner_war_stance")
      then
         event.caster:Interrupt()
      end
end
