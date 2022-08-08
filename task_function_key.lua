module(..., package.seeall)
require "utils"
require "pm"
require "pins"

local function_key = pio.P0_12
local function_key_down_start = 0
local function_key_down_end = 0
-------------------------- 息屏亮屏键-------------------------------------
function function_keyIntFnc(msg)
    if _G.LCD_STATE then
        log.info("testGpioSingle.function_key", msg, getfunction_keyFnc())
        -- 上升沿中断
        if msg == cpu.INT_GPIO_POSEDGE then
            function_key_down_end = rtos.tick()
            if function_key_down_end - function_key_down_start > 400 then
                _G.FLY_STATE = not _G.FLY_STATE
                if _G.FLY_STATE then
                    log.info("********************************进入飞行模式")
                    net.switchFly(true)
                    _G.SINGLE_QUERY = 0
                else
                    log.info("********************************退出飞行模式")
                    net.switchFly(flase)
                    _G.SINGLE_QUERY = 26
                end
            end
            _G.SCREEN_STATE = _G.SCREEN_STATE + 1
            if _G.SCREEN_STATE >= 7 then
                _G.SCREEN_STATE = 0
            end
            pm.sleep("FUNC_KEY")
        else
            pm.wake("FUNC_KEY")
            function_key_down_start = rtos.tick()
            task_auto_screenoff.oled_on_start = rtos.tick()
        end
    end
    pm.sleep("FUNC_KEY")
end


-- screen_key配置为中断，可通过getfunction_keyFnc()获取输入电平，产生中断时，自动执行screen_keyIntFnc函数
getfunction_keyFnc = pins.setup(function_key, function_keyIntFnc, pio.PULLUP)
