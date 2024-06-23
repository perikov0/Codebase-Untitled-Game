local M1 = {}
M1.DataName = "M1"

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationInformation = require(ReplicatedStorage.Information.AnimationLength)
local Utility = require(ReplicatedStorage.Shared.Utility)

function M1.Begin(character, networkDelay)
    if character:GetAttribute("ServerCanM1") == false then return end

    local prevIndex = character:GetAttribute("CombatIndex")

    character:SetAttribute("ServerCanM1", false)
    print(prevIndex)
	character:SetAttribute("CombatIndex", if prevIndex < 5 then prevIndex%5+1 else 1)
    print("Server Sync:", character:GetAttribute("CombatIndex"))

    if character:GetAttribute("CombatIndex") == prevIndex then
        print("Didn't change")
    end

    local animationLength = AnimationInformation.M1[character:GetAttribute("CombatIndex")]

    task.delay(animationLength-0.25-networkDelay*2, function()
        local hrp: Part = character.HumanoidRootPart

        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = CollectionService:GetTagged("Entity")

        local hitboxCFrame = hrp.CFrame*CFrame.new(0,0,-4)
        local hitboxSize = Vector3.new(4,6,4)
        local hitRoots = Utility.Hitbox(hitboxCFrame, hitboxSize, params)

        ReplicatedStorage.Network.ReplicateVFX:FireAllClients("M1", character, hitRoots)

        task.wait(networkDelay)

        --TODO: Inflict Damage

        for _, entityRoot: Part in hitRoots do
            local entityModel = entityRoot.Parent

            local reactAnim = ReplicatedStorage.Animations.Reactions[math.random(1,4)]
            if entityModel:GetAttribute("Blocking") then
                entityModel:SetAttribute("BlockHealth", entityModel:GetAttribute("BlockHealth")-10)
                reactAnim = ReplicatedStorage.Animations.BlockReact
            end

            Utility.FireAllInRadius(ReplicatedStorage.Network.PlayAnimation, entityRoot.Position, 50, entityModel, reactAnim)
        end

        if hitRoots[1] then
            local entityModel = hitRoots[1].Parent
            local knockbackVelocity = 8

            if entityModel:GetAttribute("Blocking") then
                knockbackVelocity = 4
            end

            local entityRoot = hitRoots[1]
            Utility.Knockback(entityRoot.Parent, -(hrp.Position-entityRoot.Position).Unit*knockbackVelocity, Vector3.new(8e7, 8e3, 8e7), 0.2)
            Utility.Knockback(character, -(hrp.Position-entityRoot.Position).Unit*knockbackVelocity*0.8 , Vector3.new(8e7, 8e3, 8e7), 0.2)
        end

        --Utility.VisualizeMatrix(hitboxCFrame, hitboxSize, 1)
    end)

    task.delay(animationLength-0.15-networkDelay, function()
        if character:GetAttribute("CombatIndex") == 5 then
            task.delay(1, function()
                character:SetAttribute("ServerCanM1", true)
            end)
        else
            character:SetAttribute("ServerCanM1", true)
        end

        if M1.DelayThread then
            task.cancel(M1.DelayThread)
        end

        M1.DelayThread = task.delay(animationLength*2, function()
            character:SetAttribute("CombatIndex", 0)
        end)
	end)
end

return M1