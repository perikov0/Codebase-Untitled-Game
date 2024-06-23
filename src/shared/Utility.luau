local Utility = {}

local Players = game:GetService("Players")

local cachedAttachments = {}

local function Debris(part: Instance, debrisT: number?): ()
	task.delay(debrisT, part.Destroy, part)
end

function Utility.Emit(particle: BasePart): ()
	for _, particleEmitter in particle:GetDescendants() do
		if particleEmitter:IsA("ParticleEmitter") then
			local emitDelay = particleEmitter:GetAttribute("EmitDelay")
			if emitDelay then
				task.delay(emitDelay, particleEmitter.Emit, particleEmitter, (particleEmitter:GetAttribute("EmitCount") or 16))
			else
				particleEmitter:Emit(particleEmitter:GetAttribute("EmitCount") or 16)
			end
		end
	end
end

function Utility.SetParticleState(particle: BasePart, state): ()
	for _, particleEmitter in particle:GetDescendants() do
		if not particleEmitter:IsA("ParticleEmitter") then continue end
		particleEmitter.Enabled = state
	end
end

function Utility.VisualizeMatrix(matrixCF: CFrame, matrixSize: Vector3, debrisTime: number): Part
	local visualizePart = Instance.new("Part")
	visualizePart.CFrame = matrixCF
	visualizePart.Anchored = true
	visualizePart.CanCollide = false
	visualizePart.Transparency = 0.8
	visualizePart.Size = matrixSize
	visualizePart.Parent = workspace.Effects
	visualizePart.Color = Color3.new(1, 0, 0)

	Debris(visualizePart, debrisTime)

	return visualizePart
end

function Utility.QuadraticBezier(p0, p1, p2, t): Vector3 | number
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

function Utility.Ragdoll(character): ()
	cachedAttachments[character] = {}

	for _, v in character:GetDescendants() do
		if not v:IsA("Motor6D") then continue end
		local ballSocketConstraint = Instance.new("BallSocketConstraint")
		local attachment0 = Instance.new("Attachment")
		local attachment1 = Instance.new("Attachment")

		ballSocketConstraint.Attachment0 = attachment0
		ballSocketConstraint.Attachment1 = attachment1

		attachment0.CFrame = v.C0
		attachment1.CFrame = v.C1

		ballSocketConstraint.MaxFrictionTorque = 200
		ballSocketConstraint.LimitsEnabled = true
		ballSocketConstraint.TwistLimitsEnabled = true

		ballSocketConstraint.Parent = v.Parent
		attachment0.Parent = v.Part0
		attachment1.Parent = v.Part1
		v.Enabled = false

		table.insert(cachedAttachments, attachment0)
		table.insert(cachedAttachments, attachment1)
	end

	character.Humanoid.PlatformStand = true
	character.Humanoid.RequiresNeck = false
end

function Utility.Unragdoll(character: Model): ()
	for _, v in cachedAttachments[character] do
		v:Destroy()
	end

	for _,v in character:GetDescendants() do
		if v:IsA("BallSocketConstraint") then
			v:Destroy()
		elseif v:IsA("Motor6D") then
			v.Enabled = true
		end
	end

	task.wait()
	character.Humanoid.RequiresNeck = true
	task.wait()
	character:PivotTo(CFrame.new(character:GetPivot().Position+Vector3.new(0,2.8,0)))
	character.Humanoid.PlatformStand = false
end

function Utility.FireAllInRadius(remote: RemoteEvent, beginPosition, radius: number, ...): ()
	for _, player in Players:GetPlayers() do
		if not player.Character then return end
		if (beginPosition-player.Character.PrimaryPart.Position).Magnitude < radius then
			remote:FireClient(player, ...)
		end
	end
end

function Utility.Knockback(character: Model, direction: Vector3, maxForce: Vector3, debrisTime: number): BodyVelocity

	local knockbackVelocity = Instance.new("BodyVelocity")
	knockbackVelocity.MaxForce = maxForce
	knockbackVelocity.Velocity = direction
	knockbackVelocity.Parent = character.HumanoidRootPart
	Debris(knockbackVelocity, debrisTime)

	return knockbackVelocity
end

local function GetHitInBox(hitboxCFrame: CFrame, hitboxSize: Vector3, params: OverlapParams): {Part}
	return workspace:GetPartBoundsInBox(hitboxCFrame, hitboxSize, params)
end

local function GetHitInRadius(hitboxPosition: CFrame, radius: number, params: OverlapParams): {Part}
	return workspace:GetPartBoundsInRadius(hitboxPosition, radius, params)
end

function Utility.Hitbox(hitboxCFrame, hitboxSize, filter: {any})
	return GetHitInBox(hitboxCFrame, hitboxSize, filter)
end

function Utility.Hitsphere(hitboxPosition: CFrame, radius: number, filter: {any})
	return GetHitInRadius(hitboxPosition, radius, filter)
end

function Utility.CutOffImage(image: GuiBase, alpha: number, properties: {[string]: any}): UIGradient
	local cutOffGradient = image:FindFirstChild("CutOffGradient") or Instance.new("UIGradient")
	cutOffGradient.Name = "CutOffGradient"
	print("Alpha 1:", alpha-2/100)
	print("Alpha 1:", alpha-1/100)
	cutOffGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(alpha-2/100, 0),
		NumberSequenceKeypoint.new(alpha-1/100, 1),
		NumberSequenceKeypoint.new(1, 1)
	}
	cutOffGradient.Parent = image

	for property, value in properties do
		cutOffGradient[property] = value
	end
end

return Utility