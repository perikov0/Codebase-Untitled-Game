local MovementHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Warp = require(ReplicatedStorage.Packages.Warp)

function MovementHandler.CharacterInit(character: Model)
    MovementHandler.PlayerCharacters[Players:GetPlayerFromCharacter(character)] = character
end

function MovementHandler.ServerInit()
    MovementHandler.PlayerCharacters = {}
end

function MovementHandler.ToggleRun(player, status)
    if not MovementHandler.PlayerCharacters[player] then return end

    MovementHandler.PlayerCharacters[player]:SetAttribute("Running", status)
end

return MovementHandler
