local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
})

local playersService = cloneref(game:GetService('Players'))
local inputService = cloneref(game:GetService('UserInputService'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local collectionService = cloneref(game:GetService('CollectionService'))
local tweenService = cloneref(game:GetService('TweenService'))
local runService = cloneref(game:GetService('RunService'))

local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vape = shared.vape
local entitylib = vape.Libraries.entity
local whitelist = vape.Libraries.whitelist
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local getfontsize = vape.Libraries.getfontsize

local store, md = {
    murderer = nil,
    sheriff = nil
}, nil

run(function()
    md = {}

    local function ToolAdded(player, v)
        if v:IsA('Tool') then
            local Index = v:FindFirstChild('KnifeClient') and 'murderer' or v:FindFirstChild('GunClient') and 'sheriff' or nil
            if Index then
                store[Index] = player
                vape:Clean(v.Destroying:Once(function()
                    if store[Index] == player then
                        store[Index] = nil
                    end
                end))
            end
        end
    end
    local function Added(plr): ...any
        if plr:IsA('Player') then
            vape:Clean(plr.CharacterAdded:Connect(Added))
            vape:Clean(plr:WaitForChild('Backpack', 9e9).ChildAdded:Connect(function(v)
                task.delay(0.2, ToolAdded, plr, v)
            end))
            vape:Clean(plr.ChildAdded:Connect(function(v)
                if v:IsA('Backpack') then
                    vape:Clean(v.ChildAdded:Connect(function(v)
                        task.delay(0.2, ToolAdded, plr, v)
                    end))
                end
            end))
            for _, v in plr.Backpack:GetChildren() do
                ToolAdded(plr, v)
            end
            if plr.Character then
                Added(plr.Character)
            end
        else
            local player = playersService:GetPlayerFromCharacter(plr)
            vape:Clean(plr.ChildAdded:Connect(function(v)
                task.delay(0.1, ToolAdded, player, v)
            end))
            for _, v in plr:QueryDescendants('Tool') do
                ToolAdded(player, v)
            end
        end
    end
    for _, v in playersService:GetPlayers() do
        Added(v)
    end
    playersService.PlayerAdded:Connect(Added)
end)

for _, v in {'Reach', 'Trigger Bot', 'Anti Fall', 'Anti Ragdoll', 'Disabler'} do
    vape:Remove(v)
end

--[[
    Combat
]]

