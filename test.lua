repeat task.wait() until game:IsLoaded()
wait(5)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local utility = game.Players.LocalPlayer.PlayerScripts.Client.Utility
local util = require(utility)
local data = util.data
local playerItems = data.items or {}
local playerStats = data.stats or {}

local inHub = pcall(function() return ReplicatedStorage.Remotes.Play ~= nil end)
local create_room, start_remote
if inHub then
    create_room = ReplicatedStorage.Remotes.Play:WaitForChild("create_room")
    start_remote = ReplicatedStorage.Remotes.Play:WaitForChild("start")
end

local MATERIAL_DROPS = {
	["Zenkai Ore"] = { world = "GT City", mode = "Story", acts = {1,2} },
	["Ki Resonant Crystal"] = { world = "GT City", mode = "Story", acts = {3,4} },
	["Stellar Ki Quartz"] = { world = "GT City", mode = "Story", acts = {5,6} },
	["Limitbreak Obsidian"] = { world = "GT City", mode = "Story", acts = {7,8} },
	["Eclipse Godstone"] = { world = "GT City", mode = "Story", acts = {9,10} },
	["Zeni"] = { world = "GT City", mode = "Squadron", act = 1 },
	["Scouter"] = { world = "GT City", mode = "Squadron", act = 2 },
	["Power Pole"] = { world = "GT City", mode = "Squadron", act = 3 },
	["Omega Coins"] = { world = "GT City", mode = "Raid", acts = {1,2,3,4} },
	["Omega Chest"] = { world = "GT City", mode = "Raid", act = 1 },
	["Omega Legs"] = { world = "GT City", mode = "Raid", act = 2 },
	["Omega Horns"] = { world = "GT City", mode = "Raid", act = 3 },
	["Shanron"] = { world = "GT City", mode = "Raid", act = 4 },
	["Dragonballs"] = { world = "GT City", mode = "Raid", act = 4 },
	["Currentbinder Rope"] = { world = "Marine Lobby", mode = "Story", acts = {1,2} },
	["Depthglass Bottle"] = { world = "Marine Lobby", mode = "Story", acts = {3,4} },
	["Stormwake Sailcloth"] = { world = "Marine Lobby", mode = "Story", acts = {5,6} },
	["Beastblood Catalyst"] = { world = "Marine Lobby", mode = "Story", acts = {7,8} },
	["King's Haki Residue"] = { world = "Marine Lobby", mode = "Story", acts = {9,10} },
	["Pelli"] = { world = "Marine Lobby", mode = "Squadron", act = 1 },
	["Bisento"] = { world = "Marine Lobby", mode = "Squadron", act = 2 },
	["Gryphon"] = { world = "Marine Lobby", mode = "Squadron", act = 3 },
	["Shinobi Bone"] = { world = "Ninja Village", mode = "Story", acts = {1,2} },
	["Binding Cloth"] = { world = "Ninja Village", mode = "Story", acts = {3,4} },
	["Genjutsu Fog Vial"] = { world = "Ninja Village", mode = "Story", acts = {5,6} },
	["Fuin Script Paper"] = { world = "Ninja Village", mode = "Story", acts = {7,8} },
	["Chakra Fragment"] = { world = "Ninja Village", mode = "Story", acts = {9,10} },
	["Headband"] = { world = "Ninja Village", mode = "Squadron", act = 1 },
	["Karashi's Book"] = { world = "Ninja Village", mode = "Squadron", act = 2 },
	["Shuriken"] = { world = "Ninja Village", mode = "Squadron", act = 3 },
	["Gunbai"] = { world = "Ninja Village", mode = "Squadron", act = 4 },
	["Madora"] = { world = "Ninja Village", mode = "Squadron", act = 4 },
	["Apostle Iron"] = { world = "Eclipse (Before)", mode = "Story", acts = {1,2} },
	["Eclipse Stone"] = { world = "Eclipse (Before)", mode = "Story", acts = {3,4} },
	["Brand Ash"] = { world = "Eclipse (Before)", mode = "Story", acts = {5,6} },
	["Moonlit Silver"] = { world = "Eclipse (Before)", mode = "Story", acts = {7,8} },
	["Black Sun Amber"] = { world = "Eclipse (Before)", mode = "Story", acts = {9,10} },
	["Behelit"] = { world = "Eclipse (Before)", mode = "Squadron", act = 1 },
	["Caskas Sword"] = { world = "Eclipse (Before)", mode = "Squadron", act = 2 },
	["Cavalry Saber"] = { world = "Eclipse (Before)", mode = "Squadron", act = 3 },
	["Dragon Slayer (Evo)"] = { world = "Eclipse (Before)", mode = "Squadron", act = 4 },
	["Berserker"] = { world = "Eclipse (Before)", mode = "Squadron", act = 4 },
	["White Behelit"] = { world = "Eclipse (Before)", mode = "Raid", acts = {1,2,3,4} },
	["Falcon Chest"] = { world = "Eclipse (Before)", mode = "Raid", act = 1 },
	["Falcon Legs"] = { world = "Eclipse (Before)", mode = "Raid", act = 2 },
	["Falcon Head"] = { world = "Eclipse (Before)", mode = "Raid", act = 3 },
	["Skeleton Knight"] = { world = "Eclipse (Before)", mode = "Raid", act = 4 },
	["Sword Of Resonance"] = { world = "Eclipse (Before)", mode = "Raid", act = 4 },
	["Hogyoku Orb"] = { world = "Katakara Bridge", mode = "Challenge", act = 1 },
	["Puppeteer"] = { world = "Katakara Bridge", mode = "Challenge", act = 1 },
	["Hunters Cloth"] = { world = "The Hero Hunter", mode = "Challenge", act = 1 },
	["Garu"] = { world = "The Hero Hunter", mode = "Challenge", act = 1 },
	["Trait Shards"] = { world = "GT City", mode = "Raid", act = 4 },
	["Gold"] = { world = "GT City", mode = "Squadron", acts = {1} },
    ["Baras"] = { world = "Cosmic Throne Hall", mode = "Event", act = 1 }
}

local MAP_LIST = { "GT City", "Marine Lobby", "Ninja Village", "Eclipse (Before)", "Katakara Bridge", "The Hero Hunter", "Katakara Wasteland", "Cosmic Throne Hall" }

local DIFFICULTY_ORDER = { ["Impossible"] = 4, ["Nightmare"] = 3, ["Intermediate"] = 2, ["Easy"] = 1 }

local Window = Fluent:CreateWindow({
    Title = "Evo & Stage Automation",
    SubTitle = "Anime Squadron" .. (inHub and " [HUB]" or " [IN-GAME]"),
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = { 
    Main = Window:AddTab({ Title = "Evo Farm", Icon = "sword" }),
    Kaitun = Window:AddTab({ Title = "Kaitun", Icon = "gantt-chart" }),
    AutoJoin = Window:AddTab({ Title = "Auto Join", Icon = "door-open" }),
    Bounty = Window:AddTab({ Title = "Bounty", Icon = "clipboard-check" })
}

local Options = Fluent.Options
local selectedUnit = nil
local units = {}
local unitIds = {}

local farming = false
local autoJoinEnabled = false
local kaitunEnabled = false
local autoEventEnabled = false
local bountyEnabled = false
local currentBountyIndex = nil

local autoFarmToggle = nil
local autoJoinToggle = nil
local autoEventToggle = nil
local kaitunToggle = nil
local bountyToggle = nil

-- Bounty remotes
local bountyAccept, bountyClaim, bountyUseTicket
pcall(function()
    local b = ReplicatedStorage.Remotes.Bounties
    bountyAccept = b:WaitForChild("accept")
    bountyClaim = b:WaitForChild("claim")
    bountyUseTicket = b:WaitForChild("use_ticket")
end)

local function getBountyData()
    local remote = ReplicatedStorage.Remotes.Player:FindFirstChild("get")
    if not remote then return nil, 0 end
    local ok, result = pcall(function() return remote:InvokeServer() end)
    if ok and result and result.bounties then
        return result.bounties, (result.stats and result.stats["Bounty Tickets"]) or 0
    end
    return nil, 0
end

local function claimBounty(index)
    if not bountyClaim then return false end
    local ok = pcall(function() return bountyClaim:InvokeServer(index) end)
    return ok
end

local function acceptBounty(index)
    if not bountyAccept then return false end
    local ok = pcall(function() return bountyAccept:InvokeServer(index) end)
    return ok
end

local function getEvoData(template)
    if not template then return nil end
    local d = template:FindFirstChild("data")
    if not d then return nil end
    local ok, mod = pcall(require, d)
    if not ok then return nil end
    return mod.awakening or mod.evolution or mod.evolve or mod.evo
end

local function findTemplate(name)
    if not name then return nil end
    local t = ReplicatedStorage.Characters:FindFirstChild(name)
    if t then return t end
    for _, child in ipairs(ReplicatedStorage.Characters:GetChildren()) do
        if child.Name:lower() == name:lower() then return child end
        if child.Name:find(name, 1, true) or name:find(child.Name, 1, true) then return child end
    end
    return nil
end

for id, char in pairs(data.characters or {}) do
    if not char or not char.name then continue end
    if unitIds[char.name] then continue end
    unitIds[char.name] = true

    local template = findTemplate(char.name)
    if not template then continue end

    local evo = getEvoData(template)
    if not evo then continue end
    if not evo.cost or not evo.object then continue end

    local missingMats = {}
    for mat, needed in pairs(evo.cost) do
        local have = playerItems[mat] or playerStats[mat] or 0
        if have < needed then
            missingMats[#missingMats+1] = { mat = mat, have = have, need = needed, short = needed - have }
        end
    end
    local traitStr = ""
    if char.trait then
        traitStr = char.trait
        if char.trait_2 then traitStr = traitStr .. "+" .. char.trait_2 end
    end
    units[#units+1] = {
        id = id, name = char.name, target = evo.object.Name,
        level = char.level, shiny = char.shiny, traitStr = traitStr,
        missing = missingMats, numMissing = #missingMats,
        fullCost = evo.cost
    }
end

table.sort(units, function(a,b) return a.numMissing > b.numMissing end)

local hasWrite = pcall(function() writefile("EFarmTest.txt", "1"); delfile("EFarmTest.txt") end)

local function saveCurrentFarmedMat(matName)
    if not hasWrite then return end
    pcall(function() writefile("EFarmCurrentMat.txt", matName) end)
end

local function loadCurrentFarmedMat()
    if not hasWrite then return "" end
    local ok, res = pcall(function() return readfile("EFarmCurrentMat.txt") end)
    if ok and res then return res:match("^%s*(.-)%s*$") or "" end
    return ""
end

local function saveAutoJoinConfig()
    if not hasWrite then return end
    local mode = Options.StageMode and Options.StageMode.Value or "Story"
    local world = Options.StageMap and Options.StageMap.Value or "GT City"
    local difficulty = Options.StageDiff and Options.StageDiff.Value or "Normal"
    local act = Options.StageAct and tonumber(Options.StageAct.Value) or 1
    local enabled = autoJoinEnabled
    local evEnabled = autoEventEnabled
    local config = { mode = mode, world = world, difficulty = difficulty, act = act, enabled = enabled, evEnabled = evEnabled }
    pcall(function() writefile("EFarmAutoJoin.txt", HttpService:JSONEncode(config)) end)
end

local function loadAutoJoinConfig()
    if not hasWrite then return nil end
    local ok, res = pcall(function() return HttpService:JSONDecode(readfile("EFarmAutoJoin.txt")) end)
    return ok and res or nil
end

local function saveSelectedUnitName(name)
    if not hasWrite then return end
    pcall(function() writefile("EFarmUnit.txt", HttpService:JSONEncode(name)) end)
end

local function loadSelectedUnitName()
    if not hasWrite then return "" end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile("EFarmUnit.txt")) end)
    return (ok and type(data) == "string" and data) or ""
end

local function saveUnitsList()
    if not hasWrite then return end
    local dataOut = {}
    for _, u in ipairs(units) do
        dataOut[u.name] = { level = u.level, shiny = u.shiny, traitStr = u.traitStr, target = u.target, fullCost = u.fullCost }
    end
    pcall(function() writefile("EFarmUnits.txt", HttpService:JSONEncode(dataOut)) end)
end

local function loadUnitsList()
    if not hasWrite then return {} end
    local ok, dataIn = pcall(function() return HttpService:JSONDecode(readfile("EFarmUnits.txt")) end)
    if ok and type(dataIn) == "table" then return dataIn end
    return {}
end

if inHub then
    saveUnitsList()
    task.spawn(function()
        while true do
            task.wait(30)
            pcall(function()
                local m = require(utility)
                data = m.data
                playerItems = data.items or {}
                playerStats = data.stats or {}
            end)
            for _, u in ipairs(units) do
                local missing = {}
                for mat, needed in pairs(u.fullCost) do
                    local have = playerItems[mat] or playerStats[mat] or 0
                    if have < needed then missing[#missing+1] = { mat = mat, have = have, need = needed, short = needed - have } end
                end
                u.missing = missing; u.numMissing = #missing
            end
            saveUnitsList()
        end
    end)
else
    local savedData = loadUnitsList()
    if next(savedData) then
        units = {}
        for name, info in pairs(savedData) do
            local fullCost = info.fullCost or {}
            local missing = {}
            for mat, needed in pairs(fullCost) do
                local have = playerItems[mat] or playerStats[mat] or 0
                if have < needed then missing[#missing+1] = { mat = mat, have = have, need = needed, short = needed - have } end
            end
            local level, shiny, traitStr = info.level or 1, info.shiny or false, info.traitStr or ""
            for _, char in pairs(data.characters or {}) do
                if char.name == name then
                    level = char.level; shiny = char.shiny
                    traitStr = char.trait or ""
                    if char.trait_2 then traitStr = traitStr .. "+" .. char.trait_2 end
                    break
                end
            end
            units[#units+1] = { name = name, level = level, shiny = shiny, traitStr = traitStr, target = info.target or "?", missing = missing, numMissing = #missing, fullCost = fullCost }
        end
        table.sort(units, function(a,b) return a.numMissing > b.numMissing end)
    end
end

local unitNames = { "Select a unit..." }
local unitMap = { ["Select a unit..."] = nil }
local unitByName = {}
for _, u in ipairs(units) do
    local shiny = u.shiny and " [SHINY]" or ""
    local trait = u.traitStr ~= "" and " [" .. u.traitStr .. "]" or ""
    local key = "Lv" .. tostring(u.level) .. " " .. u.name .. shiny .. trait .. " need" .. tostring(u.numMissing)
    unitNames[#unitNames+1] = key
    unitMap[key] = u
    unitByName[u.name] = u
end

-- ===================================================================
-- TAB 1: EVO FARM
-- ===================================================================
Tabs.Main:AddParagraph({ Title = "Evo Material Farmer", Content = inHub and ("HUB Mode - " .. #units .. " unit") or "GAME Mode" })

local function refreshData(u)
    pcall(function()
        local m = require(utility)
        data = m.data
        playerItems = data.items or {}
        playerStats = data.stats or {}
    end)
    if not u then return end
    local cost = u.fullCost
    local template = ReplicatedStorage.Characters:FindFirstChild(u.name)
    if template and template:FindFirstChild("data") then
        local ok, mod = pcall(require, template.data)
        if ok then cost = (mod.awakening or mod.evolution or mod.evolve or mod.evo or {}).cost end
    end
    cost = cost or u.fullCost
    local newMissing = {}
    for mat, needed in pairs(cost) do
        local have = playerItems[mat] or playerStats[mat] or 0
        if have < needed then newMissing[#newMissing+1] = { mat = mat, have = have, need = needed, short = needed - have } end
    end
    u.missing = newMissing; u.numMissing = #newMissing
end

local function logMaterialStatus(unit)
    if not unit then return end
    print("===== Evo Material [" .. unit.name .. "] =====")
    for mat, needed in pairs(unit.fullCost) do
        local have = playerItems[mat] or playerStats[mat] or 0
        print("  " .. (have >= needed and "READY" or "NEED") .. " " .. mat .. ": " .. tostring(have) .. "/" .. tostring(needed))
    end
end

local function showUnitInfo(unit)
    if not unit then return end
    local lines = {}
    local s = unit.shiny and " [SHINY]" or ""
    local t = unit.traitStr ~= "" and " Trait: " .. unit.traitStr or ""
    lines[#lines+1] = unit.name .. s .. " Lv" .. unit.level .. t
    lines[#lines+1] = "-> Target: " .. unit.target
    lines[#lines+1] = "Yêu cầu:"
    for mat, needed in pairs(unit.fullCost) do
        local have = playerItems[mat] or playerStats[mat] or 0
        local icon = have >= needed and "✓" or "✗"
        local drop = MATERIAL_DROPS[mat]
        local d = ""
        if drop then local a = drop.acts and drop.acts[#drop.acts] or drop.act or 1; d = " [" .. drop.world .. " A" .. a .. " " .. drop.mode .. "]" end
        lines[#lines+1] = icon .. " " .. mat .. ": " .. tostring(have) .. "/" .. tostring(needed) .. d
    end
    lines[#lines+1] = unit.numMissing > 0 and "Thiếu " .. unit.numMissing .. " loại" or "ĐÃ ĐỦ NGUYÊN LIỆU!"
    Fluent:Notify({ Title = unit.name, Content = table.concat(lines, "\n"), Duration = 10 })
end

Tabs.Main:AddButton({ Title = "Cập nhật số liệu Material", Description = "Làm tươi số lượng vật phẩm", Callback = function()
    pcall(function() refreshData(selectedUnit); if selectedUnit then pcall(showUnitInfo, selectedUnit); pcall(logMaterialStatus, selectedUnit) end end)
    Fluent:Notify({ Title = "Cập nhật", Content = "Đã làm mới số liệu!", Duration = 3 })
end })

local unitDropdown = Tabs.Main:AddDropdown("UnitSelect", { Title = "Chọn mục tiêu Unit", Values = unitNames, Multi = false, Default = 1 })
local diffDropdown = Tabs.Main:AddDropdown("Difficulty", { Title = "Độ khó phòng tạo", Values = {"Normal", "Hard"}, Multi = false, Default = 1 })

autoFarmToggle = Tabs.Main:AddToggle("AutoFarm", { Title = "Kích hoạt Auto Farm Theo Unit", Description = "Tự động tìm map, nhảy map khi đủ nguyên liệu.", Default = false })

-- ===================================================================
-- TAB 2: KAITUN
-- ===================================================================
Tabs.Kaitun:AddParagraph({ Title = "Hệ thống Kaitun thông minh", Content = "Tự động quét túi đồ xem đã sở hữu Unit chưa." })

local kaitunDropdown = Tabs.Kaitun:AddDropdown("KaitunTarget", { Title = "Mục tiêu", Values = {"Puppeteer", "Garu", "Baras"}, Multi = false, Default = 1 })

local function checkHasUnit(unitName)
    pcall(function()
        local m = require(utility)
        data = m.data
        playerItems = data.items or {}
        playerStats = data.stats or {}
    end)
    if playerItems[unitName] and playerItems[unitName] > 0 then return true end
    if playerStats[unitName] and playerStats[unitName] > 0 then return true end
    for _, char in pairs(data.characters or {}) do
        if char.name and char.name:lower() == unitName:lower() then return true end
    end
    return false
end

local function getFirstDrop(u)
    if not u then return nil end
    for _, m in ipairs(u.missing or {}) do
        local d = MATERIAL_DROPS[m.mat]
        if d then return d, m.mat end
    end
    return nil
end

local function enterGame(u, forceDiff)
    local drop, matName = getFirstDrop(u)
    if not drop then return false end
    saveCurrentFarmedMat(matName or "")
    local act = drop.acts and drop.acts[#drop.acts] or drop.act or 1
    local diff = forceDiff or diffDropdown.Value
    local ok = pcall(function() return create_room:InvokeServer({ boosted = true, act = act, difficulty = diff, mode = drop.mode, only_friends = false, world = drop.world }) end)
    if not ok then return false end
    print("Farming: " .. matName .. " at " .. drop.world .. " A" .. act .. " " .. drop.mode)
    task.wait(1.5); pcall(function() start_remote:InvokeServer() end)
    return true
end

local function enterKaitunChallenge(unitName, worldName, modeName)
    saveCurrentFarmedMat("KAITUN_CHALLENGE")
    local ok = pcall(function() return create_room:InvokeServer({ boosted = true, act = 1, difficulty = "Normal", mode = modeName or "Challenge", only_friends = false, world = worldName }) end)
    if not ok then return false end
    print("Kaitun: " .. worldName); task.wait(0.5)
    if modeName == "Event" then
        pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Matchmaking"):WaitForChild("find_match"):InvokeServer({ difficulty = "Normal", mode = "Event", world = worldName, act = 1 }) end)
    else
        task.wait(1.0); pcall(function() start_remote:InvokeServer() end)
    end
    return true
end

local function doKaitunLoop()
    if not kaitunEnabled then return end
    local targetUnit = kaitunDropdown.Value
    local challengeWorld, modeName = "", "Challenge"
    if targetUnit == "Puppeteer" then challengeWorld = "Katakara Bridge"
    elseif targetUnit == "Garu" then challengeWorld = "The Hero Hunter"
    elseif targetUnit == "Baras" then challengeWorld = "Cosmic Throne Hall"; modeName = "Event"
    else return end

    local hasUnit = checkHasUnit(targetUnit)
    if not hasUnit then
        if inHub and create_room then if not enterKaitunChallenge(targetUnit, challengeWorld, modeName) then if kaitunToggle then kaitunToggle:SetValue(false) end; return end end
    else
        local u = nil
        for _, unit in ipairs(units) do if unit.name == targetUnit then u = unit; break end end
        if not u then
            pcall(function()
                local m = require(utility)
                if m and m.data and m.data.characters then
                    for id, char in pairs(m.data.characters) do
                        if char.name == targetUnit then
                            local template = findTemplate(targetUnit)
                            local evo = template and getEvoData(template)
                            if evo then u = { name = targetUnit, fullCost = evo.cost, missing = {}, numMissing = 1 }; break end
                        end
                    end
                end
            end)
        end
        if not u then Fluent:Notify({ Title = "Kaitun", Content = "Không tìm thấy công thức Evo!", Duration = 5 }); if kaitunToggle then kaitunToggle:SetValue(false) end; return end
        refreshData(u)
        if u.numMissing == 0 then Fluent:Notify({ Title = "Kaitun", Content = "Đã đủ nguyên liệu!", Duration = 5 }); if kaitunToggle then kaitunToggle:SetValue(false) end; return end
        if inHub and create_room and start_remote then if not enterGame(u, "Hard") then if kaitunToggle then kaitunToggle:SetValue(false) end; return end end
    end
    while kaitunEnabled do task.wait(5) end
end

kaitunToggle = Tabs.Kaitun:AddToggle("KaitunToggle", { Title = "Kích hoạt Kaitun", Description = "Check & Farm tự động", Default = false })
kaitunToggle:OnChanged(function(val)
    kaitunEnabled = val
    if val then
        if farming and autoFarmToggle then autoFarmToggle:SetValue(false) end
        if autoJoinEnabled and autoJoinToggle then autoJoinToggle:SetValue(false) end
        if autoEventEnabled and autoEventToggle then autoEventToggle:SetValue(false) end
        if bountyEnabled and bountyToggle then bountyToggle:SetValue(false) end
        if inHub then task.spawn(doKaitunLoop) end
    end
end)

-- ===================================================================
-- TAB 3: AUTO JOIN
-- ===================================================================
Tabs.AutoJoin:AddParagraph({ Title = "Thiết lập phòng chơi", Content = "Cấu hình tự chọn độc lập." })

local stageModeDropdown = Tabs.AutoJoin:AddDropdown("StageMode", { Title = "Chế độ", Values = {"Story", "Squadron", "Raid", "Challenge", "Event"}, Multi = false, Default = 1 })
stageModeDropdown:OnChanged(function() saveAutoJoinConfig() end)
local stageMapDropdown = Tabs.AutoJoin:AddDropdown("StageMap", { Title = "Bản đồ", Values = MAP_LIST, Multi = false, Default = 1 })
stageMapDropdown:OnChanged(function() saveAutoJoinConfig() end)
local stageDiffDropdown = Tabs.AutoJoin:AddDropdown("StageDiff", { Title = "Độ khó", Values = {"Normal", "Hard"}, Multi = false, Default = 1 })
stageDiffDropdown:OnChanged(function() saveAutoJoinConfig() end)
local stageActDropdown = Tabs.AutoJoin:AddDropdown("StageAct", { Title = "Hồi", Values = {"1","2","3","4","5","6","7","8","9","10"}, Multi = false, Default = 1 })
stageActDropdown:OnChanged(function() saveAutoJoinConfig() end)

autoJoinToggle = Tabs.AutoJoin:AddToggle("AutoJoinStage", { Title = "Auto Join Stage", Description = inHub and "Tự động tạo phòng" or "Auto Replay", Default = false })

Tabs.AutoJoin:AddParagraph({ Title = "Auto Cosmic Throne Hall Event", Content = "Tự động tạo phòng Event, out ra Hub ngay khi xong." })
autoEventToggle = Tabs.AutoJoin:AddToggle("AutoEventStage", { Title = "Auto Event (Cosmic Throne Hall)", Description = "Tự động đi Event và Out ra Hub", Default = false })

-- ===================================================================
-- TAB 4: BOUNTY
-- ===================================================================
Tabs.Bounty:AddParagraph({ Title = "Auto Bounty", Content = "Tự động làm bounty. Chỉ nhận 1 nhiệm vụ mỗi lần. Ưu tiên độ khó cao nhất." })

local bountyInfoLabel = Tabs.Bounty:AddParagraph({ Title = "Trạng thái:", Content = "Đang chờ..." })

local bountyToggle = Tabs.Bounty:AddToggle("BountyToggle", { Title = "Kích hoạt Auto Bounty", Description = "Tự động làm bounty, claim khi xong, chuyển nhiệm vụ mới", Default = false })

local function selectHardestBounty(bounties)
    -- Only 1 bounty active at a time.
    -- If no active bounty, pick the inactive one with highest difficulty.
    local hardest = nil
    local hardestScore = -1

    for idx, b in ipairs(bounties) do
        if type(b) ~= "table" then continue end
        if b.active then
            -- Already an active bounty, must finish it first
            currentBountyIndex = idx
            return b
        end
        local score = DIFFICULTY_ORDER[b.difficulty] or 0
        if score > hardestScore then
            hardestScore = score
            hardest = b
            hardest.idx = idx
        end
    end

    if hardest then
        currentBountyIndex = hardest.idx
        hardest.active = true
    end
    return hardest
end

local function doBountyLoop()
    if not bountyEnabled then return end

    local bounties, tickets = getBountyData()
    if not bounties or #bounties == 0 then
        Fluent:Notify({ Title = "Bounty", Content = "Không có bounty!", Duration = 4 })
        if bountyToggle then bountyToggle:SetValue(false) end
        return
    end

    -- 1. Claim completed active bounty (progress >= required)
    for idx, b in ipairs(bounties) do
        if type(b) == "table" and b.active and b.progress >= b.required then
            local ok = claimBounty(idx)
            if ok then
                Fluent:Notify({ Title = "Bounty", Content = "Claim thành công: " .. b.enemy, Duration = 4 })
                bounties, tickets = getBountyData()
                break
            end
        end
    end

    -- 2. Select the best bounty to work on (hardest first)
    local target = selectHardestBounty(bounties)
    if not target then
        Fluent:Notify({ Title = "Bounty", Content = "Hết bounty để làm!", Duration = 4 })
        if bountyToggle then bountyToggle:SetValue(false) end
        return
    end

    -- 3. If not active, accept it
    if not target.active then
        local ok = acceptBounty(currentBountyIndex)
        if not ok then
            -- Try use ticket then accept
            local ticketOk = pcall(function() return bountyUseTicket:InvokeServer() end)
            if ticketOk then
                ok = acceptBounty(currentBountyIndex)
            end
        end
        if not ok then
            Fluent:Notify({ Title = "Bounty", Content = "Không thể accept bounty!", Duration = 4 })
            if bountyToggle then bountyToggle:SetValue(false) end
            return
        end
        Fluent:Notify({ Title = "Bounty", Content = "Đã accept: " .. target.enemy .. " (" .. target.difficulty .. ")", Duration = 4 })
        target.active = true
    end

    -- 4. Farm: join target world, Act 10 Hard
    local world = target.world or "Marine Lobby"
    saveCurrentFarmedMat("BOUNTY_" .. world)

    bountyInfoLabel:SetContent("Đang farm: " .. target.enemy .. "\n" .. world .. " A10 Hard\nTiến độ: " .. (target.progress or 0) .. "/" .. target.required)

    if inHub and create_room then
        local ok = pcall(function() return create_room:InvokeServer({ boosted = true, act = 10, difficulty = "Hard", mode = "Story", only_friends = false, world = world }) end)
        if not ok then
            Fluent:Notify({ Title = "Bounty", Content = "Không vào được " .. world .. ", thử lại!", Duration = 4 })
        end
        task.wait(1.5)
        pcall(function() start_remote:InvokeServer() end)
    end

    while bountyEnabled do task.wait(5) end
end

bountyToggle:OnChanged(function(val)
    if val and (farming or kaitunEnabled or autoJoinEnabled or autoEventEnabled) then
        Fluent:Notify({ Title = "Xung đột", Content = "Tắt các Auto khác trước!", Duration = 4 })
        if bountyToggle then bountyToggle:SetValue(false) end
        return
    end
    bountyEnabled = val
    if val and inHub then
        task.spawn(doBountyLoop)
    end
end)

-- ===================================================================
-- HANDLERS
-- ===================================================================
local function setFarmOff()
    farming = false
    if autoFarmToggle then autoFarmToggle:SetValue(false) end
end

local function setAutoJoinOff()
    autoJoinEnabled = false
    if autoJoinToggle then autoJoinToggle:SetValue(false) end
end

local function setAutoEventOff()
    autoEventEnabled = false
    if autoEventToggle then autoEventToggle:SetValue(false) end
end

local function enterGameManual()
    local mode = stageModeDropdown.Value
    local world = stageMapDropdown.Value
    local diff = stageDiffDropdown.Value
    local act = tonumber(stageActDropdown.Value) or 1
    saveCurrentFarmedMat("MANUAL_STAGE")
    saveAutoJoinConfig()
    local ok = pcall(function() return create_room:InvokeServer({ boosted = true, act = act, difficulty = diff, mode = mode, only_friends = false, world = world }) end)
    if not ok then return false end
    print("Auto Join: " .. world .. " A" .. act .. " " .. mode .. " [" .. diff .. "]")
    if mode == "Event" then
        pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Matchmaking"):WaitForChild("find_match"):InvokeServer({ difficulty = diff, mode = mode, world = world, act = act }) end)
    else
        task.wait(1.5); pcall(function() start_remote:InvokeServer() end)
    end
    return true
end

local function enterGameEventManual()
    saveCurrentFarmedMat("MANUAL_EVENT_STAGE")
    saveAutoJoinConfig()
    local ok = pcall(function() return ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Play"):WaitForChild("create_room"):InvokeServer({ difficulty = "Normal", mode = "Event", world = "Cosmic Throne Hall", act = 1 }) end)
    if not ok then return false end
    print("Auto Event: Cosmic Throne Hall"); task.wait(0.5)
    pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Matchmaking"):WaitForChild("find_match"):InvokeServer({ difficulty = "Normal", mode = "Event", world = "Cosmic Throne Hall", act = 1 }) end)
    return true
end

local function scanRewards(endScreen)
    if not endScreen then return false end
    local rewardsFrame = endScreen:FindFirstChild("Rewards")
    local scroll = rewardsFrame and rewardsFrame:FindFirstChild("ScrollingFrame")
    if not scroll then return false end
    local added = false
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("ImageButton") then
            local qty = child:FindFirstChild("Quantity")
            local qtyVal = qty and tonumber(qty.Text) or 0
            if qtyVal and qtyVal > 0 then
                local name = child.Name
                if playerItems[name] ~= nil then playerItems[name] = (playerItems[name] or 0) + qtyVal; added = true
                elseif playerStats[name] ~= nil then playerStats[name] = (playerStats[name] or 0) + qtyVal; added = true end
            end
        end
    end
    return added
end

local gameReplay, gameEnding, gameTeleport
pcall(function() gameReplay = ReplicatedStorage.Remotes.Game:WaitForChild("replay") end)
pcall(function() gameEnding = ReplicatedStorage.Remotes.Game:WaitForChild("ending") end)
pcall(function() gameTeleport = ReplicatedStorage.Remotes.Players:WaitForChild("teleport") end)

if gameEnding then
    gameEnding.OnClientEvent:Connect(function()
        if not autoJoinEnabled and not farming and not kaitunEnabled and not autoEventEnabled and not bountyEnabled then
            print("Auto: TẮT."); return
        end

        local endScreen = nil
        local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        for i = 1, 10 do
            local menus = playerGui:FindFirstChild("Menus")
            if menus then endScreen = menus:FindFirstChild("EndScreen"); if endScreen and endScreen.Visible then break end end
            task.wait(0.5)
        end
        if not endScreen then
            if gameReplay then
                if kaitunEnabled and kaitunDropdown.Value == "Baras" and loadCurrentFarmedMat() == "KAITUN_CHALLENGE" then
                    if gameTeleport then pcall(function() gameTeleport:FireServer() end) end
                elseif autoEventEnabled and loadCurrentFarmedMat() == "MANUAL_EVENT_STAGE" then
                    if gameTeleport then pcall(function() gameTeleport:FireServer() end) end
                elseif bountyEnabled then
                    if gameTeleport then pcall(function() gameTeleport:FireServer() end) end
                elseif autoJoinEnabled or farming or kaitunEnabled then
                    pcall(function() gameReplay:FireServer() end)
                end
            end
            return
        end

        pcall(scanRewards, endScreen)

        -- Priority: Auto Event
        if autoEventEnabled or loadCurrentFarmedMat() == "MANUAL_EVENT_STAGE" then
            print("Auto Event: Out ra Hub.")
            if gameTeleport then pcall(function() gameTeleport:FireServer() end) end
            return
        end

        -- Priority: Auto Join
        if autoJoinEnabled then
            if gameReplay then pcall(function() gameReplay:FireServer() end) end
            return
        end

        -- Priority: Kaitun
        if kaitunEnabled then
            local targetUnit = kaitunDropdown.Value
            local hasUnit = checkHasUnit(targetUnit)
            local trackedMat = loadCurrentFarmedMat()
            if trackedMat == "KAITUN_CHALLENGE" then
                if targetUnit == "Baras" then
                    if gameTeleport then pcall(function() gameTeleport:FireServer() end) end
                else
                    if hasUnit then if gameTeleport then pcall(function() gameTeleport:FireServer() end) end else if gameReplay then pcall(function() gameReplay:FireServer() end) end end
                end
                return
            end
            local u = nil
            for _, unit in ipairs(units) do if unit.name == targetUnit then u = unit; break end end
            if u then pcall(refreshData, u); pcall(logMaterialStatus, u) end
            if not u or u.numMissing == 0 then if kaitunToggle then kaitunToggle:SetValue(false) end; if gameTeleport then pcall(function() gameTeleport:FireServer() end) end; return end
            local curMatDone = true
            if trackedMat and trackedMat ~= "" and trackedMat ~= "MANUAL_STAGE" and trackedMat ~= "KAITUN_CHALLENGE" then
                local need = u.fullCost[trackedMat] or 0; local have = playerItems[trackedMat] or playerStats[trackedMat] or 0
                if have < need then curMatDone = false end
            else
                local _, fb = getFirstDrop(u); if fb then trackedMat = fb; saveCurrentFarmedMat(fb); curMatDone = false end
            end
            if curMatDone then if gameTeleport then pcall(function() gameTeleport:FireServer() end) end else if gameReplay then pcall(function() gameReplay:FireServer() end) end end
            return
        end

        -- Priority: Bounty
        if bountyEnabled then
            print("Bounty: Kết thúc màn, out ra Hub xử lý tiếp.")
            if gameTeleport then pcall(function() gameTeleport:FireServer() end) end
            return
        end

        -- Priority: Evo Farm
        if not farming then return end
        local u = selectedUnit
        if u then pcall(refreshData, u); pcall(logMaterialStatus, u) end
        if not u or u.numMissing == 0 then setFarmOff(); if gameTeleport then pcall(function() gameTeleport:FireServer() end) end; return end
        local trackedMat = loadCurrentFarmedMat()
        local curMatDone = true
        if trackedMat and trackedMat ~= "" and trackedMat ~= "MANUAL_STAGE" then
            local need = u.fullCost[trackedMat] or 0; local have = playerItems[trackedMat] or playerStats[trackedMat] or 0
            if have < need then curMatDone = false end
        else
            local _, fb = getFirstDrop(u); if fb then trackedMat = fb; saveCurrentFarmedMat(fb); curMatDone = false end
        end
        if curMatDone then if gameTeleport then pcall(function() gameTeleport:FireServer() end) end else if gameReplay and farming then pcall(function() gameReplay:FireServer() end) end end
    end)
end

local function doFarmLoop()
    local u = selectedUnit
    if not u then setFarmOff(); return end
    refreshData(u); logMaterialStatus(u)
    if u.numMissing == 0 then setFarmOff(); return end
    if not getFirstDrop(u) then setFarmOff(); return end
    if inHub and create_room and start_remote then if not enterGame(u) then setFarmOff(); return end end
    while farming do task.wait(5) end
end

local function doAutoJoinLoop()
    if inHub and create_room then if not enterGameManual() then setAutoJoinOff(); return end end
    while autoJoinEnabled do task.wait(5) end
end

local function doAutoEventLoop()
    if inHub and create_room then if not enterGameEventManual() then setAutoEventOff(); return end end
    while autoEventEnabled do task.wait(5) end
end

unitDropdown:OnChanged(function(val)
    local u = unitMap[val]
    selectedUnit = u
    if u then
        saveSelectedUnitName(u.name)
        pcall(refreshData, u); pcall(showUnitInfo, u); pcall(logMaterialStatus, u)
        if farming and inHub and u.numMissing > 0 then task.spawn(doFarmLoop) end
    end
end)

autoFarmToggle:OnChanged(function(value)
    if value and (autoJoinEnabled or kaitunEnabled or autoEventEnabled or bountyEnabled) then
        Fluent:Notify({ Title = "Xung đột", Content = "Tắt các Auto khác trước!", Duration = 4 })
        autoFarmToggle:SetValue(false); return
    end
    farming = value
    if value then if inHub then if not selectedUnit then return end; if selectedUnit.numMissing == 0 then setFarmOff(); return end; task.spawn(doFarmLoop) end
    else Fluent:Notify({ Title = "Hệ thống", Content = "Đã hủy Auto Farm.", Duration = 3 }) end
end)

autoJoinToggle:OnChanged(function(value)
    if value and (farming or kaitunEnabled or autoEventEnabled or bountyEnabled) then
        Fluent:Notify({ Title = "Xung đột", Content = "Tắt các Auto khác trước!", Duration = 4 })
        autoJoinToggle:SetValue(false); return
    end
    autoJoinEnabled = value; saveAutoJoinConfig()
    if value then if inHub then task.spawn(doAutoJoinLoop) else Fluent:Notify({ Title = "Auto Join", Content = "Trong game - Auto Replay.", Duration = 4 }) end
    else Fluent:Notify({ Title = "Hệ thống", Content = "Đã hủy Auto Join.", Duration = 3 }) end
end)

autoEventToggle:OnChanged(function(value)
    if value and (farming or kaitunEnabled or autoJoinEnabled or bountyEnabled) then
        Fluent:Notify({ Title = "Xung đột", Content = "Tắt các Auto khác trước!", Duration = 4 })
        if autoEventToggle then autoEventToggle:SetValue(false) end; return
    end
    autoEventEnabled = value; saveAutoJoinConfig()
    if value then if inHub then task.spawn(doAutoEventLoop) else Fluent:Notify({ Title = "Auto Event", Content = "Trong game - Out ra Hub khi xong.", Duration = 4 }) end
    else Fluent:Notify({ Title = "Hệ thống", Content = "Đã hủy Auto Event.", Duration = 3 }) end
end)

-- SETTINGS TAB
local TabsS = Window:AddTab({ Title = "Settings", Icon = "settings" })
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("EvoFarmer2")
SaveManager:SetFolder("EvoFarmer2/configs")
InterfaceManager:BuildInterfaceSection(TabsS)
SaveManager:BuildConfigSection(TabsS)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

task.spawn(function()
    task.wait(0.5)
    local savedJoin = loadAutoJoinConfig()
    if savedJoin then
        pcall(function() stageModeDropdown:SetValue(savedJoin.mode) end)
        pcall(function() stageMapDropdown:SetValue(savedJoin.world) end)
        pcall(function() stageDiffDropdown:SetValue(savedJoin.difficulty) end)
        pcall(function() stageActDropdown:SetValue(tostring(savedJoin.act)) end)
        task.wait(0.2)
        if savedJoin.enabled and not farming and autoJoinToggle then autoJoinToggle:SetValue(true)
        elseif savedJoin.evEnabled and not farming and not autoJoinEnabled and autoEventToggle then autoEventToggle:SetValue(true) end
    end
    if not selectedUnit then
        local savedName = loadSelectedUnitName()
        if savedName ~= "" and unitByName[savedName] then
            selectedUnit = unitByName[savedName]
            for key, u in pairs(unitMap) do if u == selectedUnit then unitDropdown:SetValue(key); break end end
        end
    end
    if selectedUnit then refreshData(selectedUnit) end
    if farming and inHub and selectedUnit and selectedUnit.numMissing > 0 then task.spawn(doFarmLoop)
    elseif kaitunEnabled and inHub then task.spawn(doKaitunLoop)
    elseif autoJoinEnabled and inHub then task.spawn(doAutoJoinLoop)
    elseif autoEventEnabled and inHub then task.spawn(doAutoEventLoop)
    elseif bountyEnabled and inHub then task.spawn(doBountyLoop) end
end)

Fluent:Notify({ Title = "Hệ thống", Content = "Đã tích hợp Auto Bounty thành công!", Duration = 5 })
