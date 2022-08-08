--- 模块功能：APP MAIN  
-- @author JWL
-- @license MIT
-- @copyright JWL
-- @release 2020.04.02
-- require"ril"
-- require "utils"
require "sys"
-- require "pm"
-- require "net"
-- require "record"
-- require "audio"
-- require "rtos"
-- require "misc"
-- require "common"
-- require "socket"
-- require "http"
require "pins"
-- require "nvm"
-- require "config"
-- require "gps"
-- require "agps"
-- require"wifiScan"
-- require "ntp"
-- require "mutils"
module(..., package.seeall)

_G.DeviceName = "al00014g0002"
_G.ProductId = "4LwKzUwOpX"
_G.token =
    "version=2018-10-31&res=products%2F4LwKzUwOpX%2Fdevices%2Fal00014g0002&et=4100731932&method=md5&sign=PiCcUlaoROhzndmn9jgY8A%3D%3D"
_G.LCD_STATE = true -- 屏幕亮暗状态
_G.REC_STATE = false -- 记录状态
_G.temp = 12.54 -- 默认温度
_G.humi = 45.12 -- 默认湿度
_G.period = 5 -- 采样周期
_G.tempU = 40 -- 温度上限
_G.tempL = -40 -- 温度下限
_G.tempUA = 0 -- 高温报警数
_G.tempLA = 0 -- 低温报警数
_G.REC_count = 0 -- 纪录个数
_G.SINGLE_QUERY = 0 -- 信号
_G.BATT_VAL = 3760 -- 电池电压
_G.BATT_LEV = 100 -- 电池百分比
_G.BATT_CHARGING = false -- 电池充电状态
_G.SCREEN_STATE = 0 -- 当前界面 0 主界面 1飞行模式 2.蓝牙模式 3.U盘模式 4.系统信息
_G.FLY_STATE = false -- 飞行模式状态
_G.FLY_SCREEN_STATE = false -- 飞行模式界面状态
_G.LOCK_STATE = false -- 开关箱状态
_G.LOCK_SCREEN_STATE = false -- 开关箱界面状态
_G.U_SCREEN_STATE = false -- U盘界面状态
_G.temp_alarm = false -- 是否超限报警
_G.TA_SCREEN_STATE = true -- 超限报警界面状态
_G.BLE_STATE = false -- 蓝牙状态
_G.BLE_SCREEN_STATE = false -- 蓝牙状态界面状态
_G.flyrec_count = 0 -- 飞行状态下的记录条目
_G.tempfail = 0
_G.temp_recstate = 31
-- _G.JIANXIE = 0 --------间歇统一上传
-- _G.JIANXIEDAO = true
function start_main()
    log.info("=======================Starting")
    sys.publish("SINGLE_QUERY_ON")
    sys.publish("LCD_STATE_ON")
    sys.publish("REC_STATE_OFF")
end

sys.subscribe("LCD_WELCOME_DONE", start_main)
