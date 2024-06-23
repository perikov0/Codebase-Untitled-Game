local ProfileController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Warp = require(ReplicatedStorage.Packages.Warp)
local WarpKeys = require(ReplicatedStorage.WarpKeys)

local LocalPlayer = Players.LocalPlayer

local function GetLatestData(player)
	return ProfileController.PlayerData[player]
end

local function RequestNewData(player)
	ProfileController.PlayerData[player] = Warp.Client("RequestData"):Invoke(2, player, {"Data"})
	return GetLatestData(player)
end

function ProfileController.PlayerInit()
	ProfileController.PlayerData = {}
end

function ProfileController.DataInit()
	RequestNewData(LocalPlayer)
end

WarpKeys.Client.GetLatestData = Warp.Signal("GetLatestData"):Connect(GetLatestData)
WarpKeys.Client.RequestNewData = Warp.Signal("RequestNewData"):Connect(RequestNewData)

return ProfileController
