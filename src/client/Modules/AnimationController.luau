local AnimationController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Warp = require(ReplicatedStorage.Packages.Warp)
local WarpKeys = require(ReplicatedStorage.WarpKeys)

function AnimationController.CharacterInit(character: Model)

    if AnimationController.CachedAnimations then
        for _, animation: Animation in AnimationController.CachedAnimations do
            animation:Stop()
        end
    end

    local humanoid: Humanoid = character:WaitForChild("Humanoid")
    local animator: Animator = humanoid:WaitForChild("Animator")

    AnimationController.CachedAnimations = {}

    for _, child in ReplicatedStorage.Animations:GetDescendants() do
        if not child:IsA("Animation") then continue end
        AnimationController.CachedAnimations[child] = animator:LoadAnimation(child)
    end

    AnimationController.CachedExternalAnimations = {}

    AnimationController.Groups = {}
end

local function PlayAnimation(animationInstance, playSettings)
    local fadetime = if playSettings and playSettings.FadeTime then playSettings.FadeTime else 0
    local weight = if playSettings and playSettings.Weight then playSettings.Weight else 1

    if playSettings and playSettings.StopGroup then
        if AnimationController.Groups[playSettings.StopGroup] then
            for _, animation: Animation in AnimationController.Groups[playSettings.StopGroup] do
                animation:Stop(fadetime)
            end
        end
    end

    local animation = AnimationController.CachedAnimations[animationInstance]

    if playSettings and playSettings.AnimationPriority then
        animation.Priority = playSettings.AnimationPriority
    end

    if playSettings and playSettings.Group then
        if not AnimationController.Groups[playSettings.Group] then
            AnimationController.Groups[playSettings.Group] = {}
        end

        if not table.find(AnimationController.Groups[playSettings.Group], animation) then
            table.insert(AnimationController.Groups[playSettings.Group], animation)
        end
    end

    animation:Play(fadetime, weight)

    return animation
end

Warp.Signal("PlayAnimation"):Connect(PlayAnimation)
Warp.Signal("StopAnimation"):Connect(function(animationInstance, stopSettings)
    if stopSettings and stopSettings.StopGroup then
        if AnimationController.Groups[stopSettings.StopGroup] then
            for _, animation: Animation in AnimationController.Groups[stopSettings.StopGroup] do
                animation:Stop()
            end
        end
    end

    if animationInstance then
        local animation = AnimationController.CachedAnimations[animationInstance]
        animation:Stop()
    end
end)

WarpKeys.Client.GetAnimation = Warp.Signal("GetAnimation"):Connect(function(animationInstance)
    return AnimationController.CachedAnimations[animationInstance]
end)

ReplicatedStorage.Network.PlayAnimation.OnClientEvent:Connect(function(character, animation)
    AnimationController.CachedExternalAnimations[character] = AnimationController.CachedExternalAnimations[character] or {}
    local animator: Animator = character.Humanoid:WaitForChild("Animator")

    if not AnimationController.CachedExternalAnimations[character][animation] then
        AnimationController.CachedExternalAnimations[character][animation] = animator:LoadAnimation(animation)
    end

    AnimationController.CachedExternalAnimations[character][animation]:Play()
end)

return AnimationController
