module(..., package.seeall)
require "utils"
require "pm"
---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥-------------------------------------

local tmp, hum -- 原始数据
local addr = 0x40
local id = 2

function sht_init()
    i2c.close(id)
    if i2c.setup(id, i2c.SLOW, addr) ~= i2c.SLOW then
        i2c.close(id)
        log.warn("SHT20", "open i2c error.")
        return
    end
end

function sht_getTH()
    -- log.info("=================测温度=========================")
    i2c.send(id, addr, string.char(0xe3))
    sys.wait(100)
    tmp = i2c.recv(id, addr, 2)
    -- log.info("SHT20", "read tem data", tmp:toHex())
    i2c.send(id, addr, string.char(0xe5))
    sys.wait(100)
    hum = i2c.recv(id, addr, 2)
    -- log.info("SHT20", "read hum data", hum:toHex())
    local _, tval = pack.unpack(tmp, '>H')
    local _, hval = pack.unpack(hum, '>H')
    if tval and hval then
        _G.temp = ((1750 * (tval) / 65535 - 450)) / 10
        _G.humi = ((1000 * (hval) / 65535)) / 10
        -- log.info("SHT20", "temp,humi", _G.temp, _G.humi)
    end
end

---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥-------------------------------------
function sht_while_lcdon()
    log.info("SHT收到: LCD_STATE_ON 开启频繁测量!")
    sys.taskInit(function()
        while _G.LCD_STATE do
            -- log.info("sht_while_lcdon 我在疯狂采集温度!")
            sht_init()
            sht_getTH()
            sys.wait(100)
            log.warn("SHT20", "temp,humi", _G.temp, _G.humi)
        end
    end)
end

function sht_while_lcdoff()
    log.info("SHT收到: LCD_STATE_OFF 关闭频繁测量!")
    _G.LCD_STATE = false
end

function sht_get_recing()
    sys.taskInit(function()
        if not _G.LCD_STATE then
            log.info("SHT收到: RECING, 采集一次温度!")
            sht_init()
            sht_getTH()
            sys.wait(200)
            log.info("SHT20 RECING", "temp,humi", _G.temp, _G.humi)
        end
    end)
end

sys.subscribe("LCD_STATE_ON", sht_while_lcdon)
sys.subscribe("LCD_STATE_OFF", sht_while_lcdoff)
-- sys.subscribe("RECING", sht_get_recing)

----------------------------------------------------------------
-- 启动个task, 定时查询SHT20的数据
sys.taskInit(function()
    sht_init()
end)
