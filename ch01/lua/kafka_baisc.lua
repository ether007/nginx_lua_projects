-- kafka 有一个坑config/server.properties 
-- advertised.host.name=192.168.99.100
-- advertised.port=9092

local cjson = require "cjson"
local client = require "resty.kafka.client"
local producer = require "resty.kafka.producer"

local broker_list = {
    { host = "192.168.99.100", port = 9092 }
}

local uri_args = ngx.req.get_uri_args()

local key = "key"
local message = uri_args[key]

ngx.say(message)

-- usually we do not use this library directly
local cli = client:new(broker_list)

local brokers, partitions = cli:fetch_metadata("test")

if not brokers then
    ngx.say("fetch_metadata failed, err:", partitions)
end

ngx.say("brokers: ", cjson.encode(brokers), "; partitions: ", cjson.encode(partitions))

ngx.say("----------------------")

-- 同步发送消息

local p = producer:new(broker_list,{flush_time = 10000 })

local offset, err = p:send("test", key, message)

if not offset then
   ngx.say("send err:", err)
   return
end
ngx.say("send success, offset: ", tonumber(offset))


-- 异步
local bp = producer:new(broker_list, { producer_type = "async" })

local ok, err = bp:send("test", key, message)
if not ok then
    ngx.say("send err:", err)
    return
end

ngx.say("send success, ok:", ok)