--- 模块功能：LCD屏幕绘制
-- @author openLuat
-- @module lcdshow
-- @license MIT
-- @copyright 熊爸天下
-- @release 2021-10-28
module(..., package.seeall)
require "utils"
require "color_lcd_spi_st7735"
require "common"
require "sys"
require "pm"
require "ntp"
require "misc"

---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥----------------
function showInit()
    -- body
    sys.wait(2000)
    disp.clear()
    font_id = disp.loadfont("/lua/MSG25x50.bin")
    font_id2 = disp.loadfont("/lua/A5x10.bin")
    disp.setfont(font_id)
end
function showWelcome()
    disp.clear()
    disp.putimage("/lua/sc_welcome.png", 0, 0)
    disp.update()
end
function showTempHumi(temp, humi)
    if temp == nil or humi == 0 then
        temp, humi = 0, 0
    end
    th, tl = math.modf(temp)
    tempH = th
    tempL = math.modf(math.abs(tl) * 10)
    disp.setfontheight(58)
    disp.setcolor(0x2444) -- 0300深绿  0x07EF春天绿 2C4A海洋绿 2444森林绿
    local singlespan = 29
    if tempH <= 0 and tempH > -10 and temp < 0 then
        disp.puttext(common.utf8ToGb2312(tempH), singlespan, 18)
    elseif tempH <= -10 then
        disp.puttext(common.utf8ToGb2312(tempH), 0, 18)
    elseif tempH >= 0 and tempH < 10 then
        disp.puttext(common.utf8ToGb2312(tempH), singlespan * 2, 18)
    elseif tempH >= 10 then
        disp.puttext(common.utf8ToGb2312(tempH), singlespan, 18)
    end
    disp.puttext(common.utf8ToGb2312("."), 85, 18)
    disp.puttext(common.utf8ToGb2312(tempL), 105, 18)
    -- 湿度
    hh, hl = math.modf(humi)
    humiH = hh
    humiL = math.modf(hl * 10)
    disp.setfont(font_id)
    disp.setfontheight(18)
    local hsinglespan = 9
    disp.setcolor(0x001F)
    if humiH >= 10 then
        disp.puttext(common.utf8ToGb2312(humiH), 93, 70)
    else
        disp.puttext(common.utf8ToGb2312(humiH), 102, 70)
    end
    disp.puttext(common.utf8ToGb2312("."), 111, 70)
    disp.puttext(common.utf8ToGb2312(humiL), 120, 70)
end
function showMsg(rec_count, device_name)
    disp.setfontheight(14)
    disp.setcolor(0x0000)
    disp.setfont(font_id)
    if _G.REC_STATE then
        disp.puttext(common.utf8ToGb2312(rec_count), 85, 92)
    end
    disp.puttext(common.utf8ToGb2312(device_name), 55, 110)
end
function ui_show_clock()
    local tm = misc.getClock()
    disp.setfont(font_id2)
    disp.setcolor(0x001F)
    disp.setfontheight(12)
    disp.puttext(common.utf8ToGb2312(string.format("%02d/%02d", tm.month, tm.day)), 62, 4)
    disp.puttext(common.utf8ToGb2312(string.format("%02d:%02d", tm.hour, tm.min)), 94, 4)
end
function ui_show_batt()
    _G.BATT_CHARGING = misc.getVbus()
    if _G.BATT_CHARGING then
        _G.BATT_LEV = _G.BATT_LEV + 4
        if _G.BATT_LEV > 120 then
            _G.BATT_LEV = 21
        end
    else
        _G.BATT_VAL = misc.getVbatt()
        if _G.BATT_VAL > 4008 then
            _G.BATT_LEV = 100
        elseif _G.BATT_VAL > 4000 then
            _G.BATT_LEV = 80
        elseif _G.BATT_VAL > 3870 then
            _G.BATT_LEV = 60
        elseif _G.BATT_VAL > 3790 then
            _G.BATT_LEV = 40
        elseif _G.BATT_VAL > 3680 then
            _G.BATT_LEV = 10
        else
            _G.BATT_LEV = 0
        end

    end
    if _G.BATT_LEV >= 100 then
        disp.putimage("/lua/charge100.png", 130, 4)
    elseif _G.BATT_LEV >= 80 then
        disp.putimage("/lua/charge80.png", 130, 4)
    elseif _G.BATT_LEV >= 60 then
        disp.putimage("/lua/charge60.png", 130, 4)
    elseif _G.BATT_LEV >= 40 then
        disp.putimage("/lua/charge40.png", 130, 4)
    elseif _G.BATT_LEV >= 10 then
        disp.putimage("/lua/charge10.png", 130, 4)
    else
        disp.putimage("/lua/charge0.png", 130, 4)
    end
end
function ui_show_signal()
    -- log.info("LCD_final获取信号强度",_G.SINGLE_QUERY)
    if _G.SINGLE_QUERY > 32 then
        disp.putimage("/lua/singal0.png", 6, 4)
    elseif _G.SINGLE_QUERY > 23 then
        disp.putimage("/lua/singal100.png", 6, 4)
    elseif _G.SINGLE_QUERY > 16 then
        disp.putimage("/lua/singal75.png", 6, 4)
    elseif _G.SINGLE_QUERY > 9 then
        disp.putimage("/lua/singal50.png", 6, 4)
    elseif _G.SINGLE_QUERY > 0 then
        disp.putimage("/lua/singal25.png", 6, 4)
    else
        disp.putimage("/lua/singal0.png", 6, 4)
    end
end
function show_ui(rec_state)
    -- body
    disp.drawrect(0, 0, 160, 128, 0xB71C)
    if rec_state then
        disp.putimage("/lua/scMAINon.png", 0, 0)
    else
        disp.putimage("/lua/scMAINoff.png", 0, 0)
    end
    ui_show_signal()
    if _G.tempLA + _G.tempUA ~= 0 then
        log.info("===============_G.tempLA + _G.tempUA:", _G.tempLA + _G.tempUA)
        disp.putimage("/lua/warning.png", 20, 4)
    end
    if _G.BLE_STATE then
        disp.putimage("/lua/bluetooth.png", 34, 4)
    else
        --------调试专用!!!!!!!!!!!!!!!!!!!!
        if _G.tempfail == nil then
            _G.tempfail = 99
        end
        if _G.temp_recstate == nil then
            _G.temp_recstate = 31
        end
        disp.puttext(common.utf8ToGb2312(_G.tempfail), 34, 4)
        disp.puttext(common.utf8ToGb2312(_G.temp_recstate), 1, 20)

    end
    if _G.LOCK_STATE then
        disp.putimage("/lua/lock.png", 46, 4)
    end
    ui_show_clock()
    ui_show_batt()
end
function showLoop()
    disp.clear()
    show_ui(_G.REC_STATE)
    showMsg(_G.REC_count, _G.DeviceName:upper())
    showTempHumi(_G.temp, _G.humi)
    disp.update()
end
----------------------------------------------
function showflyscreen()
    disp.clear()
    if _G.FLY_SCREEN_STATE then
        disp.putimage("/lua/scFLYon.png", 0, 0)
    else
        disp.putimage("/lua/scFLYoff.png", 0, 0)
    end
    disp.update()
end
----------------------------------------------
function showKGXscreen()
    disp.clear()
    if _G.LOCK_SCREEN_STATE then
        disp.putimage("/lua/scKGXon.png", 0, 0)
    else
        disp.putimage("/lua/scKGXoff.png", 0, 0)
    end
    disp.update()
end
----------------------------------------------
function showUscreen()
    disp.clear()
    if _G.U_SCREEN_STATE then
        disp.putimage("/lua/scUon.png", 0, 0)
    else
        disp.putimage("/lua/scUoff.png", 0, 0)
    end
    disp.update()
end
----------------------------------------------
function showTAscreen()
    disp.clear()
    if _G.TA_SCREEN_STATE then
        disp.putimage("/lua/scTAon.png", 0, 0)
    else
        disp.putimage("/lua/scTAoff.png", 0, 0)
    end
    disp.update()
end
----------------------------------------------
function showBLEscreen()
    disp.clear()
    if _G.BLE_SCREEN_STATE then
        disp.putimage("/lua/scBLEon.png", 0, 0)
    else
        disp.putimage("/lua/scBLEoff.png", 0, 0)
    end
    disp.update()
end
----------------------------------------------
function showinformation()
    disp.clear()
    disp.putimage("/lua/scINFOon.png", 0, 0)
    disp.update()
end
----------------------------------------------------------------------------------
function lcd_while_lcdon()
    log.info("收到: LCD_STATE_ON")
    _G.lcdpin = pins.setup(13, 0)
    _G.lcdpin(1)
    pm.wake("LCD")
    disp.sleep(0)
    sys.taskInit(function()
        while _G.LCD_STATE do
            if _G.SCREEN_STATE == 0 then
                showLoop()
            elseif _G.SCREEN_STATE == 1 then
                showflyscreen()
            elseif _G.SCREEN_STATE == 2 then
                showKGXscreen()
            elseif _G.SCREEN_STATE == 3 then
                showUscreen()
            elseif _G.SCREEN_STATE == 4 then
                showTAscreen()
            elseif _G.SCREEN_STATE == 5 then
                showBLEscreen()
            elseif _G.SCREEN_STATE == 6 then
                showinformation()
            end
            sys.wait(100)
        end
    end)
end

function lcd_while_lcdoff()
    log.info("收到: LCD_STATE_OFF 熄灭屏幕!")
    _G.LCD_STATE = false
    _G.lcdpin = pins.setup(13, 0)
    _G.lcdpin(0)
    _G.SCREEN_STATE = 0
    disp.sleep(1)
    pm.sleep("SCREEN_KEY")
    pm.sleep("LCD")
end

sys.subscribe("LCD_STATE_ON", lcd_while_lcdon)
sys.subscribe("LCD_STATE_OFF", lcd_while_lcdoff)

sys.taskInit(function()
    showInit()
    showWelcome()
    sys.wait(3000)
    sys.publish("LCD_WELCOME_DONE")
    log.info("sys.publish(LCD_WELCOME_DONE)")
end)
