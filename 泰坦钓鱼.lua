local repo = "https://raw.githubusercontent.com/JanseJYC/Script/refs/heads/UI/"

local function s(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or type(res) ~= "string" or res == "" then return nil end
    return res
end

local l = s(repo .. "Library.lua")
local t = s(repo .. "ThemeManager.lua")
local sv = s(repo .. "SaveManager.lua")
if not l or not t or not sv then return end

local L = loadstring(l)()
local TM = loadstring(t)()
local SM = loadstring(sv)()
if not L or not TM or not SM then return end

TM:SetLibrary(L)

L.ForceCheckbox = false
L.ShowToggleFrameInKeybinds = true

local W = L:CreateWindow({Title = "Xi Pro[联邦]", Footer = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, Icon = "https://raw.githubusercontent.com/JanseJYC/Script/refs/heads/UI/20260329_011708.jpg", NotifySide = "Right", ShowCustomCursor = true})

TM.BuiltInThemes["Default"][2] = {FontColor = "ffffff", MainColor = "191919", AccentColor = "ffffff", BackgroundColor = "000000", OutlineColor = "ffffff", FontFace = "RobotoMono"}
TM:ApplyTheme("Default")

L:SetWatermarkVisibility(true)
L:SetWatermark("Xi Pro | " .. os.date("%H:%M:%S"))
task.spawn(function() while task.wait(1) do if L.Unloaded then break end L:SetWatermark("Xi Pro | " .. os.date("%H:%M:%S")) end end)

local Tabs = {Main = W:AddTab("主要", "rbxassetid://98755624629571")}
local MG = Tabs.Main:AddLeftGroupbox("主要","rbxassetid://136372617578355")
local TG = Tabs.Main:AddRightGroupbox("传送","flower")

local ac = {}
local wp = nil
local wc = nil
local fr = false
local autoFishRunning = false
local autoFishThread = nil

local is = {
    ["新手村"] = Vector3.new(43.65, 61.36, -11.81),
    ["岛2码头"] = Vector3.new(1687.82, 109.88, -348.57),
    ["岛3码头"] = Vector3.new(1018.60, 137.38, 1577.11),
    ["岛4码头"] = Vector3.new(503.15, 33.05, -1124.02),
    ["岛5码头"] = Vector3.new(-415.08, 29.30, 1203.14),
    ["岛6码头"] = Vector3.new(-778.70, 27.14, -286.58),
    ["岛7码头"] = Vector3.new(-574.53, 65.74, -1464.41),
    ["比熊NPC"] = Vector3.new(144.49, 28.59, -115.33),
    ["温NPC"] = Vector3.new(-982.41, 23.66, 0.69),
    ["萨努NPC"] = Vector3.new(-728.93, 62.42, -1178.17),
    ["T GamingNPC"] = Vector3.new(584.31, 18.67, -915.90),
    ["雪老头NPC"] = Vector3.new(-312.55, 22.80, 816.54),
    ["岛1船夫"] = Vector3.new(1479.97, 22.61, -422.72),
    ["岛2船夫"] = Vector3.new(1076.38, 23.85, 1324.43),
    ["岛3船夫"] = Vector3.new(533.43, 28.88, -946.45),
    ["岛4船夫"] = Vector3.new(-292.14, 24.08, 819.49),
    ["岛5船夫"] = Vector3.new(-751.79, 24.80, -287.20),
    ["岛6船夫"] = Vector3.new(-594.60, 27.77, -1060.65),
    ["冰BOSS刷新点"] = Vector3.new(-751.79, 24.80, -287.20)
}

for n, p in pairs(is) do
    TG:AddButton({Text = "传送到 " .. n, Func = function()
        local pl = game.Players.LocalPlayer
        if pl and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            pl.Character.HumanoidRootPart.CFrame = CFrame.new(p)
            L:Notify({Title = "传送成功", Description = "已传送到 " .. n, Time = 2})
        end
    end})
end

MG:AddToggle("AntiCheatBypass", {Text = "绕过反作弊", Default = true, Callback = function(v)
    if v then
        task.spawn(function()
            local RS = game:GetService("ReplicatedStorage")
            local LP = game.Players.LocalPlayer
            local br = {}
            local df = {"BanMe", "KickMe"}
            for _, v in pairs(RS:GetDescendants()) do if v:IsA("RemoteEvent") and v.Name == "Remote" then br[v] = true end end
            local dc = RS.DescendantAdded:Connect(function(v) if v:IsA("RemoteEvent") and v.Name == "Remote" then br[v] = true end end)
            table.insert(ac, dc)
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            local hk = newcclosure(function(s, ...)
                local m = getnamecallmethod()
                if m == "FireServer" and br[s] then
                    local args = {...}
                    if typeof(args[1]) == "string" and table.find(df, args[1]) then return nil end
                end
                if m == "GetRankInGroup" and s == LP then return 254 end
                return old(s, ...)
            end)
            mt.__namecall = hk
            setreadonly(mt, true)
            table.insert(ac, {t="nc", o=old, h=hk})
            for _, v in pairs(getgc()) do
                if typeof(v) == "function" and getfenv(v).script == script then
                    local i = debug.getinfo(v)
                    if i.name == "v_u_9" or i.name == "v_u_11" then hookfunction(v, function() end) end
                end
            end
            for _, c in pairs(getconnections(game:GetService("RunService").RenderStepped)) do
                local f = c.Function
                if f then
                    local i = debug.getinfo(f)
                    if i.source and (i.source:find("WalkSpeed") or i.source:find("JumpPower") or i.source:find("tptool")) then
                        c:Disable()
                        table.insert(ac, c)
                    end
                end
            end
            local function sc(char)
                for _, v in pairs(char:GetDescendants()) do if v.Name == "CollisionPart" then table.insert(ac, v:GetPropertyChangedSignal("CanCollide"):Connect(function() end)) end end
                table.insert(ac, char.DescendantAdded:Connect(function(v) if v.Name == "CollisionPart" then table.insert(ac, v:GetPropertyChangedSignal("CanCollide"):Connect(function() end)) end end))
            end
            if LP.Character then sc(LP.Character) end
            table.insert(ac, LP.CharacterAdded:Connect(function(char) sc(char) end))
        end)
        task.spawn(function()
            setthreadidentity(2)
            local D = nil
            for _, v in ipairs(getgc(true)) do
                if typeof(v) == "table" then
                    local det = rawget(v, "Detected")
                    if typeof(det) == "function" and not D then
                        D = det
                        hookfunction(det, function() return true end)
                    end
                    local kil = rawget(v, "Kill")
                    if typeof(kil) == "function" then hookfunction(kil, function() end) end
                end
            end
            hookfunction(getrenv().debug.info or getinfo or debug.getinfo, newcclosure(function(...)
                local args = {...}
                if D and (args[1] == D or args[2] == "f") then return coroutine.yield(coroutine.running()) end
                return debug.getinfo(...)
            end))
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(s, ...)
                local m = getnamecallmethod()
                if (m == "Kick" or m == "kick") and s == game.Players.LocalPlayer then return end
                if m == "FireServer" then
                    local rn = tostring(s.Name):lower()
                    if rn:find("ban") or rn:find("kick") or rn:find("detect") then return end
                end
                return old(s, ...)
            end)
            setreadonly(mt, true)
            task.spawn(function() task.wait(1) for _, o in ipairs(game:GetDescendants()) do if o:IsA("ModuleScript") and o.Name:match("^\n+\nModuleScript$") then pcall(function() o.Archivable = true o.Name = "ModuleScript" end) end end end)
            pcall(function()
                for _, c in ipairs(getconnections(game:GetService("LogService").MessageOut)) do pcall(function() c:Disable() end) end
                for _, c in ipairs(getconnections(game:GetService("ScriptContext").Error)) do pcall(function() c:Disable() end) end
            end)
            local pl = game.Players.LocalPlayer
            task.spawn(function() while task.wait(5) do pcall(function() if pl.Character and pl.Character:FindFirstChild("Humanoid") then pl.Character.Humanoid.WalkSpeed = pl.Character.Humanoid.WalkSpeed end end) end end)
        end)
    end
end})

MG:AddToggle("PassBypass", {Text = "破解通行证(娱乐)", Default = false, Callback = function(v)
    if v then
        local pl = game.Players.LocalPlayer
        pl:SetAttribute("VIP", true)
        pl:SetAttribute("SellEverywhere", true)
        pl:SetAttribute("Mastery", true)
        pl:SetAttribute("FishInventory", true)
        pl:SetAttribute("EXP", true)
    end
end})

MG:AddToggle("AutoFish", {Text = "自动钓鱼", Default = false, Callback = function(v)
    autoFishRunning = v
    if v then
        if autoFishThread then return end
        autoFishThread = task.spawn(function()
            while autoFishRunning do
                local pl = game.Players.LocalPlayer
                local rg = pl:WaitForChild("PlayerGui"):WaitForChild("RodGUI")
                local fb = rg:FindFirstChild("FishingButton")
                if fb then
                    local ti = {UserInputType = Enum.UserInputType.Touch, Position = fb.AbsolutePosition + fb.AbsoluteSize/2, Delta = Vector2.zero}
                    for _, c in pairs(getconnections(fb.InputBegan)) do c.Function(ti, false) end
                    task.wait(0.01)
                    for _, c in pairs(getconnections(fb.InputEnded)) do c.Function(ti, false) end
                end
                task.wait(0.01)
            end
            autoFishThread = nil
        end)
    else
        if autoFishThread then
            task.cancel(autoFishThread)
            autoFishThread = nil
        end
    end
end})

MG:AddToggle("WaterWalk", {Text = "水上行走", Default = false, Callback = function(v)
    if v then
        if wc then wc:Disconnect() end
        if wp then wp:Destroy() end
        task.spawn(function()
            local om = workspace:FindFirstChild("Map")
            if om then om = om:FindFirstChild("ocean") end
            if om and om:FindFirstChild("First") then
                wp = Instance.new("Part")
                wp.Size = Vector3.new(5000, 0.5, 5000)
                wp.Position = Vector3.new(0, om.First.Position.Y, 0)
                wp.Anchored = true
                wp.CanCollide = true
                wp.Transparency = 1
                wp.Parent = om
                wc = game:GetService("RunService").Heartbeat:Connect(function()
                    if v and om and om:FindFirstChild("First") then
                        wp.Position = Vector3.new(0, om.First.Position.Y + 0.25, 0)
                    end
                end)
            end
        end)
    else
        if wc then wc:Disconnect() wc = nil end
        if wp then wp:Destroy() wp = nil end
    end
end})

local SkillMod = nil
for _, v in pairs(getgc(true)) do
    if type(v) == "table" and rawget(v, "CastSkill") then
        SkillMod = v
        break
    end
end

local AutoSkill = false
local SkillBusy = false
local autoSkillThread = nil

local function CastSkill(idx)
    if SkillBusy then return end
    SkillBusy = true
    pcall(function() SkillMod:CastSkill(idx) end)
    task.wait(0.5)
    SkillBusy = false
end

local function SkillLoop()
    while AutoSkill do
        local char = game.Players.LocalPlayer.Character
        if char and char:GetAttribute("InCombat") then
            local skills = SkillMod.GetSkillsArray and SkillMod.GetSkillsArray()
            if skills then
                for i = 1, 4 do
                    if skills[i] and skills[i].SkillName then
                        local lvl = game.Players.LocalPlayer:GetAttribute("RodLevel") or 1
                        if lvl >= (skills[i].UnlockLevel or 999) then
                            CastSkill(i)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
    autoSkillThread = nil
end

MG:AddToggle("AutoSkill", {Text = "自动释放技能", Default = false, Callback = function(v)
    AutoSkill = v
    if v and SkillMod then
        if autoSkillThread then
            task.cancel(autoSkillThread)
            autoSkillThread = nil
        end
        autoSkillThread = task.spawn(SkillLoop)
    else
        if autoSkillThread then
            task.cancel(autoSkillThread)
            autoSkillThread = nil
        end
    end
end})

local Net = nil
for _, v in pairs(getgc(true)) do
    if type(v) == "table" then
        if rawget(v, "InvokeServer") and type(rawget(v, "InvokeServer")) == "function" then
            Net = v
        end
        if rawget(v, "SellFishingEverything") then
            Net = v
        end
    end
end

local SellOn = false
local SellDelay = 30
local SellBusy = false
local StartPos = nil
local autoSellThread = nil

local function GetNPC()
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, v in pairs(npcs:GetChildren()) do
            if v.Name == "bluewaterrobux" then
                return v
            end
        end
    end
    return nil
end

local function GoTo(pos)
    local c = game.Players.LocalPlayer.Character
    if c and c.HumanoidRootPart then
        c.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function DoSell()
    local npc = GetNPC()
    if not npc then return end
    
    StartPos = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart and game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    
    GoTo(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
    task.wait(0.5)
    
    local prompt = npc.HumanoidRootPart:FindFirstChild("ProximityPrompt")
    if prompt then pcall(function() prompt:Fire() end) end
    task.wait(1)
    
    local sg = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SellGUI")
    if sg then
        sg.Enabled = true
        task.wait(0.5)
        
        pcall(function()
            if Net then
                local lockedFish = _G.LockedFish or {}
                local sellList = {}
                for fish, _ in pairs(lockedFish) do
                    table.insert(sellList, fish)
                end
                Net:InvokeServer("SellFishingEverything", sellList)
            end
        end)
        
        pcall(function()
            if Net then
                Net:InvokeServer("SellFishingEverything", {})
            end
        end)
        
        task.wait(0.3)
        
        pcall(function()
            if Net then
                Net:InvokeServer("SellBackpackFish")
            end
        end)
        
        task.wait(0.5)
        sg.Enabled = false
    end
    
    pcall(function()
        if Net then
            Net:FireServer("CloseSell")
        end
    end)
    
    task.wait(0.3)
    
    if StartPos then GoTo(StartPos.Position) end
end

local function SellLoop()
    while SellOn do
        if not SellBusy then
            SellBusy = true
            DoSell()
            SellBusy = false
        end
        task.wait(SellDelay)
    end
    autoSellThread = nil
end

MG:AddToggle("AutoSell", {Text = "自动售卖", Default = false, Callback = function(v)
    SellOn = v
    if v then
        if autoSellThread then
            task.cancel(autoSellThread)
            autoSellThread = nil
        end
        autoSellThread = task.spawn(SellLoop)
    else
        if autoSellThread then
            task.cancel(autoSellThread)
            autoSellThread = nil
        end
    end
end})

MG:AddSlider("SellInterval", {Text = "售卖间隔(秒)", Default = 30, Min = 10, Max = 120, Callback = function(v)
    SellDelay = v
end})

MG:AddButton({Text = "一键售卖", Func = function()
    if not SellBusy then
        task.spawn(function()
            SellBusy = true
            DoSell()
            SellBusy = false
        end)
    end
end})

local ShowBoss = false
local RS = game:GetService("ReplicatedStorage")
local bossTimerThread = nil

local function GetBoss()
    local active = RS:GetAttribute("BossActive") or false
    local time = RS:GetAttribute("BossSpawnTime") or 0
    local left = time - workspace:GetServerTimeNow()
    if active then
        return "冰BOSS存活中"
    elseif left > 0 then
        return "冰BOSS刷新 | " .. string.format("%02d:%02d", math.floor(left/60), math.floor(left%60))
    else
        return "冰BOSS即将刷新"
    end
end

local function UpWater()
    if ShowBoss then
        L:SetWatermark("Xi Pro | " .. os.date("%H:%M:%S") .. " | " .. GetBoss())
    else
        L:SetWatermark("Xi Pro | " .. os.date("%H:%M:%S"))
    end
end

MG:AddToggle("ShowBossTimer", {Text = "显示BOSS复活时间", Default = false, Callback = function(v)
    ShowBoss = v
    if v then
        if bossTimerThread then
            task.cancel(bossTimerThread)
            bossTimerThread = nil
        end
        bossTimerThread = task.spawn(function()
            while ShowBoss do
                UpWater()
                task.wait(1)
            end
            bossTimerThread = nil
        end)
    else
        if bossTimerThread then
            task.cancel(bossTimerThread)
            bossTimerThread = nil
        end
        UpWater()
    end
end})

task.spawn(function()
    while true do
        if ShowBoss then
            UpWater()
        end
        task.wait(1)
    end
end)