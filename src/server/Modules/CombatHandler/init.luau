local CombatHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Warp = require(ReplicatedStorage.Packages.Warp)
local Trove = require(ReplicatedStorage.Packages.Trove)

function CombatHandler.CharacterInit(character: Model)
	character:SetAttribute("CombatIndex", 0)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	CombatHandler.PlayerCharacters[playerFromCharacter] = character

	local highlight = Instance.new("Highlight")
	highlight.Adornee = character
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.FillColor = Color3.fromRGB(208, 89, 89)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.Name = "DamageHighlight"
	highlight.Parent = character
end

function CombatHandler.PlayerInit(player: Player)
	CombatHandler.Troves[player] = Trove.new()
end

function CombatHandler.ServerInit()
	CombatHandler.PlayerCharacters = {}
	CombatHandler.Troves = {}

	CombatHandler.CombatModules = {}

	for _, combatModule: ModuleScript in script:GetDescendants() do
		if not combatModule:IsA("ModuleScript") then continue end
		local module = require(combatModule)
		CombatHandler.CombatModules[module.DataName] = module
	end
end

function CombatHandler.ExecuteCombatFunction(player, clientTime, functionName: string, state: Enum.UserInputState, ...)
	local character = CombatHandler.PlayerCharacters[player]
	if not character then return end
	local networkDelay = workspace:GetServerTimeNow()-clientTime

	local fn = CombatHandler.CombatModules[functionName][state.Name]
	if fn then
		fn(character, networkDelay, ...) --// Call Begin / End function.
	end

	Warp.Signal(functionName):Fire()
end

ReplicatedStorage.Network.ExecuteCombatFunction.OnServerEvent:Connect(CombatHandler.ExecuteCombatFunction)

return CombatHandler