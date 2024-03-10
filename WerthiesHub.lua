--[[
// Werthies Hub - Alpha v0.1

Some sorta script hub type thingy
]] 

local coreGui = game:GetService("CoreGui")
local playerService = game:GetService("Players")
local teams = game:GetService("Teams")
local contextActionService = game:GetService("ContextActionService")

local player = playerService.LocalPlayer

local interface = game:GetObjects("rbxassetid://16691413878")[1]
interface.Parent = coreGui

local storage, sounds = interface.Storage, interface.Sounds
local front = interface.Front
local apps = front.Apps.ScrollingFrame
local home, storageHome = front.Home, storage.Home
local click = sounds.Click

local rgb, insert = Color3.fromRGB, table.insert

local enabled, disabled = rgb(89, 255, 95), rgb(255, 41, 41)
local commands = {}
local zeppelinWars = {}

commands.__index = commands

function zeppelinWars.getDispensers()
	local zeppelins = workspace.GameTime.Zeppelins
	local collection = {}

	for _, zeppelin in pairs(zeppelins:GetChildren()) do
		local dispensers = zeppelin:FindFirstChild("Dispensers")
		if not dispensers then continue end

		for _, dispenser in pairs(dispensers:GetChildren()) do
			insert(collection, dispenser)
		end
	end

	return collection
end

function commands.nukeDispensers(enemyOnly)
	if getgenv().nukeDispensers then
		getgenv().nukeDispensers = false

		return warn("Nuke disabled.")
	end

	local teamColors = {
		["Pirates"] = "Bright red",
		["Patrol"] = "Bright blue"
	}

	getgenv().nukeDispensers = true
	warn("Nuke enabled")

	while getgenv().nukeDispensers do
		local dispensers, team = zeppelinWars.getDispensers(), teamColors[player.Team.Name]

		for _, dispenser in pairs(dispensers) do
			local ext, dispenserTeam = dispenser:FindFirstChild("Ext"), dispenser.TEAM

			if enemyOnly and dispenserTeam.Value.Name == team then continue end
			if not ext then continue end

			fireclickdetector(ext.ClickDetector)
		end

		task.wait(1)
	end
end

function commands.nukeEnemyDispensers()
	commands.nukeDispensers(true)
end

local function clearApps()
	for _, button in pairs(apps:GetChildren()) do
		if not button:IsA("TextButton") then continue end
		
		button.Visible = false
		button.Parent = storage[button:GetAttribute("Category")]
	end
end

local function setupCategory(name)
	local category = if name then storage:FindFirstChild(name) else storage["Home"]
	if not category then return end
	
	clearApps()
	
	for _, button in pairs(category:GetChildren()) do
		button.Parent = apps
		button.Visible = true
	end
end

local function toggleInterface(_, state)
    if state ~= Enum.UserInputState.Begin then return end

    interface.Enabled = not interface.Enabled
end

for _, directory in pairs(storage:GetChildren()) do
	if directory == storageHome then continue end

	for _, button in pairs(directory:GetChildren()) do
        local name = button.Name
		local command = commands[name]

		button.MouseButton1Click:Connect(function()
			if button.TextColor3 == enabled then
				button.TextColor3 = disabled
			else
				button.TextColor3 = enabled
			end
			
			click:Play()
			
            local success, errorMessage = pcall(command)
            if errorMessage then warn("There was an error while executing ["..name.."], this may be due to being used in the wrong game: ", errorMessage) end
		end)
	end
end

for _, navigator in pairs(storageHome:GetChildren()) do
	navigator.MouseButton1Click:Connect(function()
		click:Play()
		
		setupCategory(navigator.Name)
	end)
end

home.MouseButton1Click:Connect(setupCategory)
contextActionService:BindAction("toggle", toggleInterface, false, Enum.KeyCode.KeypadFive)

setupCategory()
