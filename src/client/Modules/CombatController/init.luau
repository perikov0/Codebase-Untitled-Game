local CombatController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Warp = require(ReplicatedStorage.Packages.Warp)

local Trove = require(ReplicatedStorage.Packages.Trove)

function CombatController.CharacterInit(character: Model)
	CombatController.Character = character
	CombatController.Humanoid = character:WaitForChild("Humanoid")
end

function CombatController.PlayerInit()
	CombatController.Trove = Trove.new()

	CombatController.CombatModules = {}

	for _, combatModule: ModuleScript in script:GetDescendants() do
		if not combatModule:IsA("ModuleScript") then continue end
		local module = require(combatModule)
		CombatController.CombatModules[module.DataName] = module
	end
end

function CombatController.ExecuteCombatFunction(functionName: string, key: string, ...)
	local character = CombatController.Character
	if not character then return end

	local fn = CombatController.CombatModules[functionName][key]
	if fn then
		fn(character, ...) --// Call Begin / End function.
	end

	Warp.Signal(functionName):Fire()
end

local function ReplicateVFX(functionName, ...)
	CombatController.ExecuteCombatFunction(functionName, "ReplicateVFX", ...)
end

Warp.Signal("ExecuteCombatFunction"):Connect(CombatController.ExecuteCombatFunction)
ReplicatedStorage.Network.ReplicateVFX.OnClientEvent:Connect(ReplicateVFX)

return CombatController