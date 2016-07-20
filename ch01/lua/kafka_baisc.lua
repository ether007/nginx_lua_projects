local cjson = require "cjson"
local client = require "resty.kafka.client"
local producer = require "resty.kafka.producer"

local broker_list = {
    { host = "127.0.0.1", port = 9092 }
}


local key = "key"
local message = "halo world"

-- usually we do not use this library directly
local cli = client:new(broker_list)

local brokers, partitions = cli:fetch_metadata("test")

if not brokers then
    ngx.say("fetch_metadata failed, err:", partitions)
end

ngx.say("brokers: ", cjson.encode(brokers), "; partitions: ", cjson.encode(partitions))


-- sync producer_type
local p = producer:new(broker_list)

local offset, err = p:send("test", key, message)

if not offset then
    ngx.say("send err:", err)
    return
end
ngx.say("send success, offset: ", tonumber(offset))

-- this is async producer_type and bp will be reused in the whole nginx worker
local bp = producer:new(broker_list, { producer_type = "async" })

local ok, err = bp:send("test", key, message)
if not ok then
    ngx.say("send err:", err)
    return
end

ngx.say("send success, ok:", ok)