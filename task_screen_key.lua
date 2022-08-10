module(..., package.seeall)
require "utils"
require "pm"
require "pins"

local screen_key = pio.P0_18

function screen_key_while_lcdon()
    log.info("收到: LCD_STATE_ON, 更改 _G.LCD_STATE = true")
    _G.LCD_STATE = true
end

function screen_key_while_lcdoff()
    log.info("收到: LCD_STATE_OFF, 更改 _G.LCD_STATE = false")
    _G.LCD_STATE = false
end

sys.subscribe("LCD_STATE_ON", screen_key_while_lcdon)
sys.subscribe("LCD_STATE_OFF", screen_key_while_lcdoff)

-------------------------- 息屏亮屏键-------------------------------------
function screen_keyIntFnc(msg)
    log.info("testGpioSingle.screen_keyIntFnc", msg, getscreen_keyFnc())
    -- 上升沿中断
    if _G.SCREEN_STATE == 0 then
        if msg == cpu.INT_GPIO_POSEDGE then
            pm.wake("SCREEN_KEY")
            _G.LCD_STATE = not _G.LCD_STATE
            if _G.LCD_STATE then
                sys.publish("LCD_STATE_ON")
                pm.sleep("SCREEN_KEY")
            else
                sys.publish("LCD_STATE_OFF")
                pm.sleep("SCREEN_KEY")
            end
        end
    elseif _G.SCREEN_STATE == 1 then
        if msg == cpu.INT_GPIO_POSEDGE then
            pm.wake("SCREEN_KEY")
            if _G.FLY_SCREEN_STATE then
                log.info("********************************进入飞行模式")
                _G.FLY_STATE = true
                net.switchFly(true)
                _G.SINGLE_QUERY = 0
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            else
                log.info("********************************退出飞行模式")
                _G.FLY_STATE = false
                net.switchFly(false)
                _G.SINGLE_QUERY = 26
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            end
        end
    elseif _G.SCREEN_STATE == 4 then
        if msg == cpu.INT_GPIO_POSEDGE then
            pm.wake("SCREEN_KEY")
            if _G.LOCK_SCREEN_STATE then
                log.info("********************************进入开关箱模式")
                _G.LOCK_STATE = true
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            else
                log.info("********************************退出开关箱模式")
                _G.LOCK_STATE = false
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            end
        else
        end
    elseif _G.SCREEN_STATE == 5 then
        if msg == cpu.INT_GPIO_POSEDGE then
            pm.wake("SCREEN_KEY")
            if _G.U_SCREEN_STATE then
                log.info("********************************进入U盘模式")
                _G.U_STATE = true
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            else
                log.info("********************************退出U盘模式")
                _G.U_STATE = false
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            end
        else
        end
    elseif _G.SCREEN_STATE == 2 then
        if msg == cpu.INT_GPIO_POSEDGE then
            pm.wake("SCREEN_KEY")
            if _G.TA_SCREEN_STATE then
                log.info("********************************进入温度超限模式")
                _G.temp_alarm = true
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            else
                log.info("********************************退出温度超限模式")
                _G.temp_alarm = false
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            end
        else
        end
    elseif _G.SCREEN_STATE == 6 then
        if msg == cpu.INT_GPIO_POSEDGE then
            pm.wake("SCREEN_KEY")
            if _G.BLE_SCREEN_STATE then
                log.info("********************************进入蓝牙模式")
                _G.BLE_STATE = true
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            else
                log.info("********************************退出蓝牙模式")
                _G.BLE_STATE = false
                _G.LCD_STATE = true
                _G.SCREEN_STATE = 0
            end
        else
        end
    end
    pm.sleep("SCREEN_KEY")
end

-- screen_key配置为中断，可通过getscreen_keyFnc()获取输入电平，产生中断时，自动执行screen_keyIntFnc函数
getscreen_keyFnc = pins.setup(screen_key, screen_keyIntFnc, pio.PULLUP)
