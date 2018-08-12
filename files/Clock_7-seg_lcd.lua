local num={["0"]=192,["1"]=249,["2"]=164,["3"]=176,["4"]=153,["5"]=146,["6"]=130,
["7"]=248,["8"]=128,["9"]=144,["-"]=191,["_"]=247,["t"]=135,["d"]=151
}

local function str_to_tab(str)
local r={}
for S in str:gmatch("(.)") do
if _LCD_7SEG.type=="anode" then r[#r+1]=num[S]and num[S]or 255 else r[#r+1]=num[S]and 255-num[S]or 0
end
end
return r
end

local function init(t)
_LCD_7SEG={}
_LCD_7SEG.latch=t.latch
_LCD_7SEG.qty=t.qty
_LCD_7SEG.type=t.type
_LCD_7SEG.speed=type(t.speed)=="number"and t.speed or 500
spi.setup(1,spi.MASTER,spi.CPOL_LOW,spi.CPHA_LOW,8,8)
gpio.mode(_LCD_7SEG.latch,gpio.OUTPUT)
return true
end

local function set_to_spi(d)
_,_,x=spi.send(1,0,d)
gpio.write(_LCD_7SEG.latch,gpio.HIGH)
gpio.write(_LCD_7SEG.latch,gpio.LOW)
return true
end

return function (t,cb)
local r,str=false
if t.init then r=init(t.init)end
 if _LCD_7SEG then
  if t.set then
  str=t.set
  str=#str<_LCD_7SEG.qty and string.rep(" ",_LCD_7SEG.qty-#str)..str or str
  r=set_to_spi(str_to_tab(str))
  end
  if t.step then
   if _LCD_7SEG.st then return false end
   _LCD_7SEG.st=true
   local rep=string.rep(" ",_LCD_7SEG.qty)
   str=rep..t.step..rep
   _LCD_7SEG.tmr = tmr.create()
   _LCD_7SEG.tmr:register(t.speed or _LCD_7SEG.speed,tmr.ALARM_AUTO,function(t)
   set_to_spi(str_to_tab(str:sub(1,_LCD_7SEG.qty)))
   str=str:sub(2,#str)
   if #str<_LCD_7SEG.qty then _LCD_7SEG.st=nil t:unregister()if cb then cb(true)end end
   end)
   _LCD_7SEG.tmr:start()
   r=true
  end
 end
return r
end

