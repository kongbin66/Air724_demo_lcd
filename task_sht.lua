module(..., package.seeall)
require "utils"
require "pm"
require "bit"
---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥-------------------------------------

local tmp, hum -- 原始数据
local i2cid = 2 -- i2cid
local SHT20_ADDRESS = 0x40

---SHT20所用地址
local POLYNOMIAL = 0x131
CMD_READ_TEMPERATURE_hold = 0xE3
CMD_READ_HUMIDITY_hold = 0xE5
CMD_READ_TEMPERATURE = 0xF3
CMD_READ_HUMIDITY = 0xF5
CMD_READ_REGISTER = 0xE7
CMD_WRITE_REGISTER = 0xE6
CMD_RESET = 0xFE

local function i2c_send(data)
    return i2c.send(i2cid, SHT20_ADDRESS, data)
end
local function i2c_recv(num)
    return i2c.recv(i2cid, SHT20_ADDRESS, num)
end

function SHT20_init()
    i2c.close(i2cid)
    if i2c.setup(i2cid, i2c.SLOW) ~= i2c.SLOW then
        log.error("SHT20", "i2c.setup fail")
        return false
    end
    log.info("SHT20", "i2c init_ok")
end

local function CheckCRC(buf)
    crc = 0
    for i = 0, 1 do
        crc = bit.bxor(crc, buf:byte(1))
        for j = 0, 7 do
            if bit.band(crc, 0x80) then
                crc = bit.bxor(bit.lshift(crc, 1), POLYNOMIAL)
            else
                crc = bit.lshift(crc, 1)
            end
        end
    end
    a, b = string.toHex(pack.pack('b', crc))
    return a
end

-- 发送命令
local function SHT20_run_command(command, bytesToRead)
    retryCounter = 0
    if bytesToRead > 0 then
        i2c_send(command)
        while retryCounter < 10 do
            recv = i2c_recv(bytesToRead)
            if recv and #recv >= 3 then
                break
            end
            retryCounter = retryCounter + 1
            sys.wait(10)
        end
        a, b = string.toHex(pack.pack('b', recv:byte(3)))
        if CheckCRC(recv) ~= a then
            return false
        end
        return recv
    end
    return false
end

-- 将原始数据转换成温度
local function SHT20_to_temperature(buf)
    if buf == false then
        log.error("SHT20", "CRC Error...\r\n")
        return false
    end
    return -46.85 + 175.72 * (bit.lshift(recv:byte(1), 8) + buf:byte(2)) / 2 ^ 16
end
-- 将原始数据转换成湿度
local function SHT20_to_humidity(buf)
    if buf == false then
        log.error("SHT20", "CRC Error...\r\n")
        return false
    end
    return -6 + 125.0 * (bit.lshift(recv:byte(1), 8) + buf:byte(2)) / 2 ^ 16
end

local function SHT20_get_temperature()
    return SHT20_to_temperature(SHT20_run_command(CMD_READ_TEMPERATURE, 3))
end

local function SHT20_get_humidity()
    return SHT20_to_humidity(SHT20_run_command(CMD_READ_HUMIDITY, 3))
end

function sht_getTH()
    -- log.info("=================测温度=========================")
    _G.temp = SHT20_get_temperature()
    _G.humi = SHT20_get_humidity()
    log.info("SHT20", "temp,humi", _G.temp, _G.humi)
    -- end
end

---------------------------------------------------------♥♥♥♥♥♥♥♥♥♥-------------------------------------
function sht_while_lcdon()
    log.info("SHT收到: LCD_STATE_ON 开启频繁测量!")
    sys.taskInit(function()
        while _G.LCD_STATE do
            -- log.info("sht_while_lcdon 我在疯狂采集温度!")
            SHT20_init()
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
            SHT20_init()
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
    SHT20_init()
end)
