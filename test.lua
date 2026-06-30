local player = game.Players.LocalPlayer
local remote = game:GetService("ReplicatedStorage").Remotes.Player:FindFirstChild("get")
if not remote then
    warn("Player data remote not found!")
    return
end

local data = remote:InvokeServer()
if not data then
    warn("No player data returned!")
    return
end

local function printHeader(title)
    warn("========================================")
    warn("  " .. title)
    warn("========================================")
end

local function printRewards(rewards)
    if not rewards or next(rewards) == nil then
        warn("    No rewards")
        return
    end
    for item, amount in pairs(rewards) do
        warn("    + " .. item .. " x" .. amount)
    end
end

-- BOUNTIES
if data.bounties and next(data.bounties) ~= nil then
    printHeader("BOUNTIES (" .. #data.bounties .. " total)")
    for i, b in ipairs(data.bounties) do
        if type(b) == "table" then
            warn("[" .. i .. "] " .. b.enemy .. " - " .. b.world)
            warn("    Difficulty: " .. b.difficulty)
            warn("    Progress: " .. (b.progress or 0) .. "/" .. b.required)
            warn("    Active: " .. tostring(b.active))
            warn("    Rewards:")
            printRewards(b.rewards)
        end
    end
else
    printHeader("BOUNTIES")
    warn("  No active bounties found.")
end

-- QUESTS (Daily & Weekly)
if data.quests and next(data.quests) ~= nil then
    printHeader("QUESTS (" .. #data.quests .. " total)")
    local dailyCount, weeklyCount = 0, 0
    for _, q in pairs(data.quests) do
        if q.type == "daily" then dailyCount = dailyCount + 1 end
        if q.type == "weekly" then weeklyCount = weeklyCount + 1 end
    end
    warn("  Daily: " .. dailyCount .. " | Weekly: " .. weeklyCount)
    warn("")
    for id, q in pairs(data.quests) do
        warn("[Quest] " .. q.name .. " (" .. q.type:upper() .. ")")
        warn("    Progress: " .. q.progress .. "/" .. q.required)
        warn("    Multiplier: x" .. q.multiplier)
        if q.progress >= q.required then
            warn("    >>> READY TO CLAIM! <<<")
        end
        warn("    Rewards:")
        printRewards(q.rewards)
    end
else
    printHeader("QUESTS")
    warn("  No quests found.")
end

-- SPECIAL QUESTS
if data.specials and next(data.specials) ~= nil then
    printHeader("SPECIAL QUESTS")
    for name, s in pairs(data.specials) do
        local total = 0
        local completed = 0
        for _, q in pairs(s.quests) do
            total = total + 1
            completed = completed + (q.claimed and 1 or 0)
        end
        warn("  " .. name .. " - " .. completed .. "/" .. total .. " completed")
        if s.claimed then
            warn("    >>> FULLY CLAIMED! <<<")
        end
        for id, q in pairs(s.quests) do
            warn("    Task #" .. id .. ": progress=" .. q.progress .. ", claimed=" .. tostring(q.claimed))
        end
    end
else
    printHeader("SPECIAL QUESTS")
    warn("  No special quests found.")
end

-- MISSIONS (Beginner missions etc.)
if data.missions and next(data.missions) ~= nil then
    printHeader("MISSIONS (" .. #data.missions .. " sets)")
    for i, missionSet in ipairs(data.missions) do
        if type(missionSet) == "table" then
            warn("  Mission Set #" .. i .. ":")
            for missionName, missionData in pairs(missionSet) do
                if type(missionData) == "table" then
                    warn("    " .. missionName .. ": progress=" .. missionData.p .. ", claimed=" .. tostring(missionData.c))
                end
            end
        end
    end
else
    printHeader("MISSIONS")
    warn("  No missions found.")
end

warn("========================================")
warn("  END OF REPORT")
warn("========================================")
