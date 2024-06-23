local DummyHandler = {}

function DummyHandler.ServerInit()
    DummyHandler.Dummies = {}

    local dummiesFolder: Folder = workspace.Dummies

    local function IterateThruDummy(dummy)
		dummy.HumanoidRootPart:AddTag("Entity")

        local highlight = Instance.new("Highlight")
        highlight.Adornee = dummy
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 1
        highlight.FillColor = Color3.fromRGB(208, 89, 89)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = dummy
        highlight.Name = "DamageHighlight"
    end

    for _, dummyModel in dummiesFolder:GetChildren() do
        IterateThruDummy(dummyModel)
    end

    dummiesFolder.ChildAdded:Connect(IterateThruDummy)
end

return DummyHandler