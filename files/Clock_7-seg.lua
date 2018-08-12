
local function init(t)
 _Clock_7seg=t
 pwm.setup(2, 500, 500)
 pwm.start(2)
 return true
end

function while_led(v)
local d
if adc.read(0) > _Clock_7seg.adc_trig then
pwm.setup(2, 500, tonumber(_Clock_7seg.pwm_day))
else
pwm.setup(2, 500, tonumber(_Clock_7seg.pwm_night))
end
pwm.start(2)

if v==1 then
d=dofile("Clock_7-seg_DS3231.lua")({get=true})
d=string.format("%02d-%02d-20%02dT%02d:%02d",d["date"],d["month"],d["year"],d["hour"],d["min"])
dofile("Clock_7-seg_lcd.lua")({step=d},function(t)
while_led(2)
end)
end

if v==2 then
d=dofile("Clock_7-seg_DS3231.lua")({temp=true})
dofile("Clock_7-seg_lcd.lua")({step="t1 "..d},function(x) while_led(3) end)

end

if v==3 then
local t2=temp and temp or "--"
dofile("Clock_7-seg_lcd.lua")({step="t2 "..t2},function(x)  while_led(4) end)
end

if v==4 then
d=dofile("Clock_7-seg_DS3231.lua")({get=1})
d=string.format("%02d:%02d", d["hour"], d["min"])
dofile("Clock_7-seg_lcd.lua")({set=d})
end

end

local function start()
timer = tmr.create()
timer:register(60000, tmr.ALARM_AUTO, function()
while_led(1)
print(tmr.time())
end)
timer:start()
end

local function bl(t)
 local r,x
 x=tonumber(t.data)
 if t.type~="adc_trig" and (x>0 and x<1024) then
  pwm.setup(2, 500, t.data)
  pwm.start(2)
  r=true
 end
 _Clock_7seg[t.type]=t.data
 return r
end

return function (t)
 local r
 if t.init then r=init(t.init)end
 if t.start then r=start()end
 if t.pwm then r=bl(t.pwm)end
 return r
end
