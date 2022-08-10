module(..., package.seeall)
require "utils"
require "pm"
require "pins"

local rec_key = pio.P0_19
local rec_key_down_start = 0
local rec_key_down_end = 0

-------------------------------------------------------------------------
function rec_key_while_recon()
    log.info("收到: REC_STATE_ON, 更改 _G.REC_STATE = true")
    _G.REC_STATE = true
end

function rec_key_while_recoff()
    log.info("收到: REC_STATE_OFF, 更改 _G.REC_STATE = false")
    _G.REC_STATE = false
end

sys.subscribe("REC_STATE_ON", rec_key_while_recon)
sys.subscribe("REC_STATE_OFF", rec_key_while_recoff)
--------------------------按键1 记录键-------------------------------------
function rec_keyIntFnc(msg)
    if _G.LCD_STATE then
        log.info("testGpioSingle.rec_keyIntFnc", msg, getrec_keyFnc())
        -- 上升沿中断
        if _G.SCREEN_STATE == 0 then
            if msg == cpu.INT_GPIO_POSEDGE then
                rec_key_down_end = rtos.tick()
                if rec_key_down_end - rec_key_down_start > 400 then
                    _G.REC_STATE = not _G.REC_STATE
                    if _G.REC_STATE then
                        sys.publish("REC_STATE_ON")
                        log.info("...开启记录")
                    else
                        sys.publish("REC_STATE_OFF")
                        log.info("...关闭记录")
                    end
                end
                pm.sleep("REC_KEY")
            else  --按下
                pm.wake("REC_KEY")
                rec_key_down_start = rtos.tick()
                task_auto_screenoff.oled_on_start = rtos.tick()
            end
        elseif _G.SCREEN_STATE == 1 then
            if msg == cpu.INT_GPIO_POSEDGE then
                _G.FLY_SCREEN_STATE = not _G.FLY_SCREEN_STATE
                pm.sleep("REC_KEY")
            else
                pm.wake("REC_KEY")
                task_auto_screenoff.oled_on_start = rtos.tick()
            end
        elseif _G.SCREEN_STATE == 4 then
            if msg == cpu.INT_GPIO_POSEDGE then
                _G.LOCK_SCREEN_STATE = not _G.LOCK_SCREEN_STATE
                pm.sleep("REC_KEY")
            else
                pm.wake("REC_KEY")
                task_auto_screenoff.oled_on_start = rtos.tick()
            end
        elseif _G.SCREEN_STATE == 5 then
            if msg == cpu.INT_GPIO_POSEDGE then
                _G.U_SCREEN_STATE = not _G.U_SCREEN_STATE
                pm.sleep("REC_KEY")
            else
                pm.wake("REC_KEY")
                task_auto_screenoff.oled_on_start = rtos.tick()
            end
        elseif _G.SCREEN_STATE == 2 then
            if msg == cpu.INT_GPIO_POSEDGE then
                _G.TA_SCREEN_STATE = not _G.TA_SCREEN_STATE
                pm.sleep("REC_KEY")
            else
                pm.wake("REC_KEY")
                task_auto_screenoff.oled_on_start = rtos.tick()
            end
        elseif _G.SCREEN_STATE == 6 then
            if msg == cpu.INT_GPIO_POSEDGE then
                _G.BLE_SCREEN_STATE = not _G.BLE_SCREEN_STATE
                pm.sleep("REC_KEY")
            else
                pm.wake("REC_KEY")
                task_auto_screenoff.oled_on_start = rtos.tick()
            end
        end
    end
    pm.sleep("REC_KEY")
end

-- rec_key配置为中断，可通过getrec_keyFnc()获取输入电平，产生中断时，自动执行rec_keyIntFnc函数
getrec_keyFnc = pins.setup(rec_key, rec_keyIntFnc, pio.PULLUP)
