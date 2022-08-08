module(..., package.seeall)
require "utils"
require "pm"

sys.taskInit(function()
    while true do
        pm.wake("QUERY_SINGLE")
        if not _G.FLY_STATE then
            net.csqQueryPoll()
            net.cengQueryPoll()
            sys.wait(2000)
            while _G.SINGLE_QUERY ==0  and _G.LCD_STATE do
                _G.SINGLE_QUERY = net.getRssi()
                log.info("getting获取信号强度",_G.SINGLE_QUERY)
                sys.wait(2000)
            end
            _G.SINGLE_QUERY = net.getRssi()
            log.info("final获取信号强度",_G.SINGLE_QUERY)
            net.stopQueryAll()
        end
        pm.sleep("QUERY_SINGLE")
        sys.wait(600000)
    end
end)
