module(..., package.seeall)
require "utils"
require "pm"

oled_on_start = 0
oled_on_last = 0

function autoscreenoff_while_lcdon()
    sys.taskInit(function()
        pm.wake("AUTO_OFF")
        log.info("AUTO_SCREENOFF 收到: LCD_STATE_ON ")
        oled_on_start = rtos.tick()
        oled_on_last = rtos.tick()
        while _G.LCD_STATE do
            oled_on_last = rtos.tick()
            -- log.info("oled_on_start:", oled_on_start)
            -- log.info("oled_on_last:", oled_on_last)
            if oled_on_last - oled_on_start > 3000 then
                log.info("屏幕时间到, 自动息屏")
                sys.publish("LCD_STATE_OFF")
                break
            end
            sys.wait(1000)
        end
        pm.sleep("AUTO_OFF")
    end)
end

sys.subscribe("LCD_STATE_ON", autoscreenoff_while_lcdon)
