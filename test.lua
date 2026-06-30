local remote = game:GetService("ReplicatedStorage").Remotes.Player:FindFirstChild("get")
if not remote then return end

local data = remote:InvokeServer()
if not data or not data.bounties then return end

local function fmtRewards(rewards)
    local parts = {}
    for item, amount in pairs(rewards or {}) do
        table.insert(parts, item .. " x" .. amount)
    end
    return table.concat(parts, ", ")
end

for i, b in ipairs(data.bounties) do
    if type(b) == "table" then
        warn(string.format("[%d] %s | %s | %s | Progress: %d/%d | Active: %s",
            i, b.enemy, b.world, b.difficulty, b.progress or 0, b.required, tostring(b.active)))
        warn("    Rewards: " .. fmtRewards(b.rewards))
    end
end
