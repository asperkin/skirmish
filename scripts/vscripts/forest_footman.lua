function already_on_check(event)
   print("checkin")
   if event.caster:HasModifier("modifier_prep") 
      then
         print("interruptin")
         event.caster:Interrupt()
      end
end
