local InputController = {}

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configs = ReplicatedStorage.Configs

local Warp = require(ReplicatedStorage.Packages.Warp)

local KeybindsMap = {
	[Enum.KeyCode.Q] = "Roll",
	[Enum.KeyCode.C] = "Crouch",
	[Enum.KeyCode.F] = "Block",
	[Enum.UserInputType.MouseButton1] = "M1",
}

local MovementKeys = {"W","A","S","D","C"}

function InputController.CharacterInit(character: Model)
	InputController.Character = character
end

function InputController.PlayerInit()
	InputController.LastInputs = {}

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		local associatedKey = KeybindsMap[input.KeyCode] or KeybindsMap[input.UserInputType]

		local inputState = input.UserInputState

		if input.KeyCode == Enum.KeyCode.W then
			if InputController.Character and InputController.LastInputs[input.KeyCode] then
				if os.clock() - InputController.LastInputs[input.KeyCode] <= Configs.MaxInputRunInterval.Value then
					Warp.Signal("StartRunning"):Fire()
				end
			end
		end

		if table.find(MovementKeys, input.KeyCode.Name) then
			Warp.Signal("OnMovementKey"):Fire(inputState, input.KeyCode.Name)
		end

		if associatedKey then
			Warp.Signal("ExecuteCombatFunction"):Fire(associatedKey, inputState.Name)
		end

		InputController.LastInputs[input.KeyCode] = os.clock()
	end)

	UserInputService.InputEnded:Connect(function(input, gpe)
		if gpe then return end
		local associatedKey = KeybindsMap[input.KeyCode] or KeybindsMap[input.UserInputType]

		local inputState = input.UserInputState

		if input.KeyCode == Enum.KeyCode.W then
			if InputController.Character:GetAttribute("Running") then
				Warp.Signal("StopRunning"):Fire()
			end

		end

		if table.find(MovementKeys, input.KeyCode.Name) then
			Warp.Signal("OnMovementKey"):Fire(inputState, input.KeyCode.Name)
		end

		if associatedKey then
			Warp.Signal("ExecuteCombatFunction"):Fire(associatedKey, inputState.Name)
		end
	end)
end

function InputController.DataInit()

end

return InputController