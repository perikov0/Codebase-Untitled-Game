local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileManager = {}

local Warp = require(ReplicatedStorage.Packages.Warp)
local WarpKeys = require(ReplicatedStorage.WarpKeys)

local ProfileTemplate = require(script.Template)
local ProfileService = require(script.ProfileService)

local ProfileStore = ProfileService.GetProfileStore(
	"Test_PlayerData_01",
	ProfileTemplate
)

local TypeTable = {
	["number"] = "IntValue",
	["bool"] = "BoolValue",
	["string"] = "StringValue",
}

local Profiles: {[Player]: {Data: typeof(ProfileTemplate)}} = {}

function ProfileManager.SetData(player, dataPath, valueName, value): ()
	if not Profiles[player] then
		task.wait()
	end

	local path = Profiles[player]
	if not path then return "Failed" end

	for _, pathString in dataPath do
		path = path[pathString]
	end

	path[valueName] = value
end

function ProfileManager.PlayerInit(player: Player)
	local DataLoaded = Instance.new("BoolValue")
	DataLoaded.Name = "DataLoaded"
	DataLoaded.Parent = player

	local profile: typeof(Profiles[player]) = ProfileStore:LoadProfileAsync("Key_"..player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick()
		end)

		if player:IsDescendantOf(Players) == true then
			Profiles[player] = profile

			profile.Data.Data.LogInTimes += 1
			DataLoaded.Value = true

			local leaderstats = profile.Data.Data.leaderstats
			if leaderstats then
				local leaderstatsFolder = Instance.new("Folder")
				leaderstatsFolder.Name = "leaderstats"

				for key, value in leaderstats do
					local Item = Instance.new(TypeTable[typeof(value)])
					Item.Name = key
					Item.Value = value
					Item.Parent = leaderstatsFolder
				end

				leaderstatsFolder.Parent = player
			end
		else
			profile:Release()
		end

	else
		player:Kick()
	end
end

function ProfileManager.GetData(player, dataPath, valueName)
	if not Profiles[player] then
		task.wait()
	end

	local path = Profiles[player]
	if not path then return "Failed" end

	for _, pathString in dataPath do
		path = path[pathString]
	end

	return valueName and path[valueName] or path
end

WarpKeys.Server.SetProfileData = Warp.Signal("SetProfileData"):Connect(ProfileManager.SetData)
WarpKeys.Server.GetProfileData = Warp.Signal("GetProfileData"):Connect(ProfileManager.GetData)

local Frequency = 60
local LastRequest = os.clock()

Warp.Server("RequestData"):Connect(function(_, ...: any)
	if os.clock()-LastRequest < 1/Frequency then return {} end
	return ProfileManager.GetData(...)
end)

return ProfileManager
