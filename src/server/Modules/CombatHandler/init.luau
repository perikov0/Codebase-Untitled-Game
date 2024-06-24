local CombatHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Warp = require(ReplicatedStorage.Packages.Warp)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Utility = require(ReplicatedStorage.Shared.Utility)

function CombatHandler.CharacterInit(character: Model)
	character:SetAttribute("CombatIndex", 0)
	character.HumanoidRootPart:AddTag("Entity")

	local humanoid: Humanoid = character.Humanoid
	local animator: Animator = humanoid.animator

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

	local guardBreakUI = ReplicatedStorage.Interface.GuardUI:Clone()
    guardBreakUI.Parent = character

    local blockBreakAnim = animator:LoadAnimation(ReplicatedStorage.Animations.BlockBreak)
    blockBreakAnim.Priority = Enum.AnimationPriority.Action2

    local blockHealthCapacity = character:GetAttribute("BlockHealthCapacity")

    character:GetAttributeChangedSignal("BlockHealth"):Connect(function()
        if character:GetAttribute("BlockHealth") <= 0 then
            character:SetAttribute("Blocking", false)

            Utility.FireAllInRadius(ReplicatedStorage.Network.ExecuteCombatFunction, character.HumanoidRootPart.Position, 80, "GuardBreakVFX")
            task.wait(blockBreakAnim.Length)

            character:SetAttribute("Blocking", true)
            character:SetAttribute("BlockHealth", blockHealthCapacity)
        end

        local blockPercentage = character:GetAttribute("BlockHealth")/character:GetAttribute("BlockHealthCapacity")
        Utility.CutOffImage(guardBreakUI.Fill, blockPercentage, {Rotation = 270})
    end)

    guardBreakUI.Enabled = character:GetAttribute("Blocking")

    character:GetAttributeChangedSignal("Blocking"):Connect(function()
        guardBreakUI.Enabled = character:GetAttribute("Blocking")
    end)
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