
-- 捕获反向代理  

local ctx = {}

res = ngx.location.capture("/temp", { ctx = ctx })

if res.status == 200 then
	ngx.say(res.body)
else 
	ngx.say("request.error")
end


  