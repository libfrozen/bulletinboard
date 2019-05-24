--Set up requirements.
local cpm = require("component")
local term = require("term")
local event = require("event")
local wirelessModem = {}

--Find wireless modems,then add them to a table.
for address,d_type in cpm.list("modem") do
  local modem = cpm.proxy(address)
  local isornot = modem.isWireless()
  if isornot == true then
    table.insert(wirelessModem,address)
  end
  local modem = nil
end

function table_count(table_name)
  local leng = 0
  for k,v in pairs(table_name) do
     leng = leng + 1
  end
  return leng
end

--Are there any modems?
if table_count(wirelessModem) == 0 then
  print("No wireless modem installed.Please install one.")
  os.exit()
end

if component.isAvailable("modem") then
 if table_count(wirelessModem) == 1 then
  local i = 1
  modem = cpm.proxy(wirelessModem[i])
  csn = wirelessModem[i]
  print("Now using card " .. wirelessModem[i])
  end
 else if table_count(wirelessModem) > 1 then
  print("You have installed more than 1 wireless modems.Please choose one.")
  for k,v in pairs(wirelessModem) do
     print(k .. " " .. v)
  end
  print("Type a number.")
  local i = tonumber(io.read())
  if i < 1 or i > table_count(wirelessModem) or i == nil or not type(i) == "number" then
    print("Wrong input.")
    os.exit()
  else
    modem = cpm.proxy(wirelessModem[i])
    csn = wirelessModem[i]
    print("Now using card " .. wirelessModem[i])
  end
  end
else
  print
end

--Port selection.
print("Please specify a port.It will be used to listen the message.Number couldn't lower than 1 or more than 65535.")
port = tonumber(io.read())
if port == nil then
  print("Wrong input.")
  return
end
if port < 1 or port > 65535 then
  print("Wrong input.")
  return
end

if modem.isOpen(port) == nil then
  modem.close(port)
end

--Open port,clear screen,then start the server.
modem.open(port)
 
term.clear()

timerstart = os.time()
function timer()
  local t = tonumber(os.time()) - timerstart
  return t
end

print("[" .. timer() .. "]" .. "The bulletinboard server is started on port " .. port .. " now.")
print("[" .. timer() .. "]" .. "Server\'s address is " .. csn)
function receiver(event_name,localNetworkCard,remoteAddress,port,distance,payload)
  print("[" .. timer() .. "]" .. "Received data '" .. tostring(payload) .. "' from address " .. remoteAddress ..
        " on network card " .. localNetworkCard .. " on port " .. port .. ".")
  if distance > 0 then
    print("[" .. timer() .. "]" .. "Message was sent from " .. distance .. " blocks away.")
  end
end

function simplify(string)
  local simplified = string.sub(string,1,6)
  return simplified
end

function receiver2(event_name,localNetworkCard,remoteAddress,port,distance,payload)
  print("[" .. simplify(remoteAddress) .. "..." .. "]" .. tostring(payload))
end

while true do
  receiver2(event.pull("modem_message"))
end
