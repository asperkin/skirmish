function already_on_check(event)
   if event.caster:HasModifier("mod_war_stance") 
      then
         event.caster:Interrupt()
      end
end
