local id = 0
local dev_addr = 0x68
local t = {"sec","min","hour","day","date","month","year"}

local function bcdToDec(val)
  return((((val/16) - ((val/16)%1)) *10) + (val%16))
end

local function decToBcd(val)
  if val == nil then return 0 end
  return((((val/10) - ((val/10)%1)) *16) + (val%10))
end

local function read(byte,len)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, byte)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c = i2c.read(0, len)
  i2c.stop(id)
  return c
end

local function setTime(data)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x00)
  for i, val in ipairs(t) do
   i2c.write(id, decToBcd(data[i]))
  end
  i2c.stop(id)
  return "true"
end

local function getTime()
  local c = read(0x00,7)
  local date = {}
  for i = 1, 7 do
   date[t[i]] = bcdToDec(tonumber(string.byte(c, i)))
  end
  return date
end

local function getTemp()
  local c = read(0x11,2)
  return string.byte(c,1)
end

local function init(t)
 _DS3231 = {}
 if not _I2C then i2c.setup(id,t.sda,t.scl,i2c.SLOW)end
 return true
end

return function (d)
  local r = false
  if d.init then r = init(d.init)end
  if _DS3231 then
    if d.get then r=getTime()end
    if d.getStr then
      t = getTime()
      r = string.format("20%02d-%02d-%02dT%02d:%02d", t["year"], t["month"], t["date"], t["hour"], t["min"])
    end
    if d.temp then r = getTemp()end
    if d.set then r = setTime(d.set)end
  end
  return r
end
