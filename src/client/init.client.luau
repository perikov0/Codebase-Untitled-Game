local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Warp = require(Packages.Warp)

local LocalPlayer = Players.LocalPlayer

local CompletedModules = {}

for _, module in script.Modules:GetChildren() do
	if module:IsA("ModuleScript") then
		CompletedModules[module.Name] = require(module)
	end
end

local function Iterate(functionName, ...)
	for _, module in CompletedModules do
		if module[functionName] and typeof(module[functionName]) == "function" then
			task.spawn(module[functionName], ...)
		end
	end
end

local function CharacterInit(character)
	Iterate("CharacterInit", character)
end

Iterate("PlayerInit")
if LocalPlayer.Character then
	CharacterInit(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(CharacterInit)

do
	local clock = os.clock()

	LocalPlayer:WaitForChild("DataLoaded", 120)
	local DataLoadedValue = LocalPlayer:FindFirstChild("DataLoaded")
	local timeOut = false

	task.delay(20, function()
		timeOut = true
	end)

	if not DataLoadedValue then
		LocalPlayer:Kick("Data took too long to load.")
	else
		repeat task.wait() until DataLoadedValue.Value or timeOut
	end

	if DataLoadedValue.Value == true then
		Iterate("DataInit", os.clock()-clock)
	else
		LocalPlayer:Kick("Data took too long to load.")
	end
end