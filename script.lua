repeat wait() until game:IsLoaded()
local role = ""

if game.Players.LocalPlayer.Name ~= getgenv().main then
    role = "follower"
else
    role = "host"
end




local runService = game:GetService("RunService")

local eventLogs = {}



local function createDrawing(type, prop)
   local obj = Drawing.new(type)
   if prop then
       for i,v in next, prop do
           obj[i] = v
       end
   end
   return obj
end


function createEventLog(text)
   local eventLog = {
       text = text,
       startTick = tick(),
       lifeTime = 5,
       shadowText = createDrawing("Text", {
           Center = false,
           Outline = false,
           Color = Color3.new(),
           Transparency = 200/255,
           Text = text,
           Size = 13,
           Font = 2,
           Visible = false
       }),
       mainText = createDrawing("Text", {
           Center = false,
           Outline = false,
           Color = Color3.new(1, 1, 1),
           Transparency = 1,
           Text = text,
           Size = 13,
           Font = 2,
           Visible = false
       })
   }

   function eventLog:Destroy()
       local shadowTextOrigin = self.shadowText.Position
       local mainTextOrigin = self.mainText.Position
       local shadowTextTrans = self.shadowText.Transparency
       local mainTextTrans = self.mainText.Transparency
       for i = 0, 1, 1/60 do
           self.shadowText.Position = shadowTextOrigin:Lerp(Vector2.new(), i)
           self.mainText.Position = mainTextOrigin:Lerp(Vector2.new(), i)
           self.shadowText.Transparency = shadowTextTrans * (1 - i)
           self.mainText.Transparency = mainTextTrans * (1 - i)
           runService.RenderStepped:Wait()
       end
       self.mainText:Remove()
       self.shadowText:Remove()
       self.mainText = nil
       self.shadowText = nil
       table.clear(self)
       self = nil
   end


   table.insert(eventLogs, eventLog)
   return eventLog
end




runService.RenderStepped:Connect(function(deltaTime)
   local count = #eventLogs
   local removedFirst = false
   for i = 1, count do
       local curTick = tick()
       local eventLog = eventLogs[i]
       if eventLog then
           if curTick - eventLog.startTick > eventLog.lifeTime then
               task.spawn(eventLog.Destroy, eventLog)
               table.remove(eventLogs, i)
           elseif count > 10 and not removedFirst then
               removedFirst = true
               local first = table.remove(eventLogs, 1)
               task.spawn(first.Destroy, first)
           else
               local previousEventLog = eventLogs[i - 1]
               local basePosition
               if previousEventLog then
                   basePosition = Vector2.new(4, previousEventLog.mainText.Position.y + previousEventLog.mainText.TextBounds.y + 1)
               else
                   basePosition = Vector2.new(4, 320)
               end
               eventLog.shadowText.Position = basePosition + Vector2.new(1, 1)
               eventLog.mainText.Position = basePosition
               eventLog.shadowText.Visible = true
               eventLog.mainText.Visible = true
           end
       end
   end
end)

getgenv().createEventLog = createEventLog




printconsole("bot server executed")

local onhost = "in|"..game.Players.LocalPlayer.Name.."|"..game.PlaceId.."|"..game.JobId



printconsole(role)

local eventCodes = {
    ["1"]  = "on-route",
    ["2"]  = "couldn't join",
    ["3"]  = "server full",
    ["in"] = "in server"
}





local websocket = syn.websocket.connect("ws://localhost:3000")
websocket:Send("newcon")
createEventLog("successfully connected to websocket!")
createEventLog("current role: "..role)

-- host stuff

if role == "host" then
    websocket:Send("in|"..game.Players.LocalPlayer.Name.."|"..game.PlaceId.."|"..game.JobId)
    createEventLog("sent server id to websocket...")
end

if role == "host" then
    websocket.OnMessage:Connect(function(msg)
        local params = string.split(msg, "|")
        if params[1] == "1" and not game.Players:FindFirstChild(params[2]) then
            createEventLog(params[2].." on route to "..game:GetService("MarketplaceService"):GetProductInfo(tonumber(params[3])).Name.." ("..params[4]..")")
        end
    end)
    websocket.OnMessage:Connect(function(msg)
        if msg == "newcon" then
            createEventLog("new connection to websocket...")
            wait(3)
            websocket:Send(onhost)
            createEventLog("sent server id to websocket!")
        end
    end)
    
    websocket.OnMessage:Connect(function(msg)
        local params = string.split(msg, "|")
        if params[1] == "main is in server, not switching servers" then
            createEventLog(params[2].." is now in your game!")
            websocket:Send("exec|"..readfile("goopysbotserver/script.lua"))
        end
    end)
    
    websocket.OnMessage:Connect(function(msg)
        local params = string.split(msg, "|")
        if params[1] == "executed" then
            createEventLog(params[2].." injected and executed!")
        end
    end)
end

-- host end

-----------------------------------------------------------------------------------

-- follower stuff

if role == "follower" then
    websocket.OnMessage:Connect(function(msg)
        local params = string.split(msg, "|")
        if params[1] == "in" then
            websocket:Send("1|"..game.Players.LocalPlayer.Name.."|"..params[3].."|"..params[4])
            printconsole("game:GetService('TeleportService'):Teleport("..tonumber(params[3])..", "..params[4]..", game.Players.LocalPlayer)")
            if game.Players:FindFirstChild(getgenv().main) then
                websocket:Send("main is in server, not switching servers|"..game.Players.LocalPlayer.Name)
            else
                game:GetService('TeleportService'):TeleportToPlaceInstance(tonumber(params[3]), params[4], game.Players.LocalPlayer)
            end
        end
    end)
end

spawn(function()
    if role == "follower" then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/thekura312/effective-doodle/main/control.lua"))
    end
end)


-- follower end
















