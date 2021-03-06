local lwm2m = require 'lwm2m'
local socket = require 'socket'
local dtls = require 'dtls'

local udp = socket.udp();
udp:setsockname('*', 5682)

-- change UDP socket in DTLS socket
dtls.wrap(udp, {security = "PSK", identity = arg[3], key = arg[4]})

local deviceObj = {
  id = 3,
  [0]  = "Open Mobile Alliance",                   -- manufacturer
  [1]  = "Lightweight M2M Client",                 -- model number
  [2]  = "345000123",                              -- serial number
  [3]  = "1.0",                                    -- firmware version
  [13] = {read = function() return os.time() end}, -- current time
}

print("endpoint: " .. arg[1] .. " - server host: " .. arg[2]);

local ll = lwm2m.init(arg[1], {deviceObj},
  function(data,host,port) udp:sendto(data,host,port) end)

ll:addserver(123, arg[2], 5684)
ll:register()

repeat
  ll:step()
  local data, ip, port, msg = udp:receivefrom()
  if data then
    ll:handle(data,ip,port)
  end
until false

