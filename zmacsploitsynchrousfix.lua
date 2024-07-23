local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local debris = game:GetService("Debris")
local statsService = game:GetService("Stats")
local httpService = game:GetService("HttpService")

local player = players.LocalPlayer
local categoryDragging = false

local Bleachhack = {}; Bleachhack.__index = Bleachhack
local objects = (runService:IsStudio() and game:GetService("ReplicatedStorage"):FindFirstChild("Bleachhack") or game:GetObjects("rbxassetid://17799632030")[1]):Clone()

local IS_STUDIO = runService:IsStudio()
local indent = " "

local clickId = "rbxassetid://535716488"
local ping = 0.15

local fps = 0

function playSound(id, vol)
	vol = vol or 1
	local sound = Instance.new("Sound")
	sound.Parent = workspace
	sound.SoundId = id
	sound.Volume = vol
	sound:Play()
	debris:AddItem(sound, 3)
end

function getRainbowColor()
	local epochTime = os.clock() * 100
	local hue = (epochTime % 360)

	local color = Color3.fromHSV(hue / 360, 1, 1)

	return color
end

function valueToColor(value, max_value)
	value = math.max(0, math.min(value, max_value))

	local red = math.floor((value / max_value) * 255)
	local green = math.floor((1 - (value / max_value)) * 255)

	local blue = 0

	return {red, green, blue}
end

function valueToColor2(value, max_value)
	value = math.max(0, math.min(value, max_value))

	local red = math.floor((1 - (value / max_value)) * 255)
	local green = math.floor((value / max_value) * 255)

	local blue = 0

	return {red, green, blue}
end


function getPing()
	return statsService.PerformanceStats.Ping:GetValue()
end

function getServerPing()
	return statsService.Network.ServerStatsItem['Data Ping']:GetValue()
end

task.spawn(function()
	while true do
		task.wait(0.1)
		ping = (getPing() + getServerPing()) / 1000
	end
end)

local Category = {}; Category.__index = Category; do
	local Module = {}; Module.__index = Module; do
		function Module.new(title, root, non, f)
			local self = setmetatable({}, Module)
			self.Title = title
			self.Root = root
			self.UI = objects.Module:Clone()
			self.UI.Module.Text = indent..title
			self.UI.Parent = root.UI.List
			self.Value = false
			self.Settings = {}
			
			local moduleTextLabel = objects.ModuleList:Clone()
			moduleTextLabel.Visible = false
			moduleTextLabel.Text = indent..title
			moduleTextLabel.Parent = self.Root.Root.UI.ModulesList.List
			moduleTextLabel.Size = UDim2.new(0, 12 * #title, 0, 25)
			
			self.Root.UI.Size += UDim2.new(0, 0, 0, 23)
			self.Root.UI.List.Size += UDim2.new(0, 0, 0, 23)
			self.TextLabel = moduleTextLabel
			
			self.UI.Module.Dropdown.Visible = false
			
			self.Update = function(a)
				self.Value = not self.Value
				if not non then
					self.UI.Module.TextColor3 = self.Value and Color3.fromHex("#6fecdd") or Color3.fromHex("#fff")
				end
				moduleTextLabel.Visible = self.Value
				self.Root.Root.UI.ModulesList.Size += UDim2.new(0, 0, 0, 25 * (self.Value and 1 or -1))
				if not a then
					playSound(clickId, .5)
				end
				
				if not a then
					(f or function() end)(a)
				end
			end
			
			local dropdowned = false
			
			local function toggleDropdown()
				if not self.UI.Module.Dropdown.Visible then return end
				
				dropdowned = not dropdowned
				self.UI.Dropdown.Visible = dropdowned
				self.UI.Size += UDim2.new(0, 0, 0, (#self.UI.Dropdown.Frame:GetChildren() - 1) * 23 * (dropdowned and 1 or -1))
				self.Root.UI.Size += UDim2.new(0, 0, 0, (#self.UI.Dropdown.Frame:GetChildren() - 1) * 23 * (dropdowned and 1 or -1))
				self.Root.UI.List.Size += UDim2.new(0, 0, 0, (#self.UI.Dropdown.Frame:GetChildren() - 1) * 23 * (dropdowned and 1 or -1))
				self.UI.Module.Dropdown.Image = dropdowned and "http://www.roblox.com/asset/?id=6034818379" or "http://www.roblox.com/asset/?id=6034818372"
				playSound(clickId, .5)
			end
			
			self.UI.Module.MouseButton1Click:Connect(function()
				self.Update()
			end)
			
			self.UI.Module.Dropdown.MouseButton1Click:Connect(toggleDropdown)
			
			return self
		end
		
		function Module:CreateToggle(data)
			local title = data.Title
			local callback = data.Callback or function() end
			local value = data.Value or false
			
			local ui = objects.Toggle:Clone()
			ui.Text = indent..title
			ui.Parent = self.UI.Dropdown.Frame
			
			self.UI.Dropdown.Size += UDim2.new(0, 0, 0, 23)
			self.UI.Module.Dropdown.Visible = true
			
			data.Update = function()
				ui.TextColor3 = data.Value and Color3.fromHex("#54fc54") or Color3.fromHex("#fc5454")
			end
			
			ui.MouseButton1Click:Connect(function()
				data.Value = not data.Value
				data.Update()
				playSound(clickId, .5)
				callback(data.Value)
			end)
			
			data.Update()
			
			self.Settings[data.Title] = data
			
			return data
		end
		
		function Module:CreateButton(data)
			local title = data.Title
			local callback = data.Callback or function() end

			local ui = objects.Toggle:Clone()
			ui.Text = indent..title
			ui.Parent = self.UI.Dropdown.Frame

			self.UI.Dropdown.Size += UDim2.new(0, 0, 0, 23)
			self.UI.Module.Dropdown.Visible = true

			ui.MouseButton1Click:Connect(function()
				playSound(clickId, .5)
				callback(data.Value)
			end)

			return data
		end
		
		function Module:CreateKeybind(data)
			local title = data.Title
			local callback = data.Callback or function() end
			local value = data.Value or {Name = "None"}
			
			local ui = objects.Bind:Clone()
			ui.Text = indent..title..":"
			ui.TextColor3 = Color3.fromRGB(255, 255, 255)
			ui.Parent = self.UI.Dropdown.Frame
			
			self.UI.Dropdown.Size += UDim2.new(0, 0, 0, 23)
			self.UI.Module.Dropdown.Visible = true
			
			data.Update = function()
				ui.Text = indent..title..": "..data.Value.Name
			end
			
			ui.MouseButton1Click:Connect(function()
				ui.Text = indent..title..": waiting.."
				local input = userInputService.InputBegan:Wait()
				data.Value = input.KeyCode
				data.Update()
				callback(data.Value)
			end)
			
			data.Update()
			
			self.Settings[data.Title] = data
			
			return data
		end
		
		function Module:CreateSwitch(data)
			local title = data.Title
			local range = data.Range
			local callback = data.Callback or function() end
			local value = data.Value or range[1]
			
			data.Value = value

			local ui = objects.Switch:Clone()
			ui.Text = indent..title
			ui.Parent = self.UI.Dropdown.Frame

			self.UI.Dropdown.Size += UDim2.new(0, 0, 0, 23)
			self.UI.Module.Dropdown.Visible = true

			data.Update = function()
				ui.Text = indent..title..": "..data.Value
			end

			ui.MouseButton1Click:Connect(function()
				local rangeIndex = table.find(range, data.Value)
				rangeIndex += 1
				if rangeIndex > #range then
					rangeIndex = 1
				end
				data.Value = range[rangeIndex]
				data.Update()
				playSound(clickId, .5)
				callback(data.Value)
			end)

			data.Update()
			
			self.Settings[data.Title] = data

			return data
		end
		
		function Module:CreateSlider(data)
			local title = data.Title
			local range = data.Range
			local callback = data.Callback or function() end
			local value = data.Value or (range[1])
			local rangeMin = range[1]
			local rangeMax = range[2]
			local nonDecimal = data.NonDecimal or false
			
			local dragging = false

			data.Value = value

			local ui = objects.Slider:Clone()
			ui.Text.Text = indent..title
			ui.Parent = self.UI.Dropdown.Frame

			self.UI.Dropdown.Size += UDim2.new(0, 0, 0, 23)
			self.UI.Module.Dropdown.Visible = true

			data.Update = function()
				local percentage = (data.Value - range[1]) / (range[2] - range[1])
				
				ui.Text.Text = indent..title..": "..(math.round(data.Value * 100) / 100)
				ui.Frame.Size = UDim2.new(percentage, 0, 1, 0)
				
				callback(data.Value)
			end

			data.Update()
			
			userInputService.InputChanged:Connect(function(input)
				if dragging then
					local mousePos = userInputService:GetMouseLocation()
					local mouseX, mouseY = mousePos.X, mousePos.Y
					local boundaries0 = ui.Text.AbsolutePosition.X 
					local boundaries1 = ui.Text.AbsolutePosition.X + ui.Text.AbsoluteSize.X
					local at = mouseX - boundaries0
					local goal = boundaries1 - boundaries0
					local percentage = math.clamp(at / goal, 0, 1)
					data.Value = (nonDecimal and math.round or function(v) return v end)(rangeMin + ((rangeMax - rangeMin) * percentage))
					data.Update()	
				end
			end)
			
			ui.Text.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					local mousePos = userInputService:GetMouseLocation()
					local mouseX, mouseY = mousePos.X, mousePos.Y
					local boundaries0 = ui.Text.AbsolutePosition.X 
					local boundaries1 = ui.Text.AbsolutePosition.X + ui.Text.AbsoluteSize.X
					local at = mouseX - boundaries0
					local goal = boundaries1 - boundaries0
					local percentage = math.clamp(at / goal, 0, 1)
					data.Value = (nonDecimal and math.round or function(v) return v end)(rangeMin + ((rangeMax - rangeMin) * percentage))
					data.Update()	
					local e; e = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							e:Disconnect()
						end
					end)
				end
			end)
			
			self.Settings[data.Title] = data

			return data
		end
	end
	
	function Category.new(title, icon, root)
		local self = setmetatable({}, Category)
		self.Title = title
		self.Icon = icon
		self.UI = objects.Category:Clone()
		self.UI.Title.Icon.Image = icon
		self.UI.Title.Title.Text = title
		self.UI.Position += UDim2.new(0, 180 * #root.UI.Modules:GetChildren(), 0, 0)
		self.UI.Parent = root.UI.Modules
		self.Root = root
		self.Modules = {}
		
		if root.UI.Modules.AbsoluteSize.X < 180 * (#root.UI.Modules:GetChildren() - 1) and not string.match(getexecutorname():lower(), "macsploit") then
			if not getfenv().A then
				getfenv().A = #root.UI.Modules:GetChildren() - 1
			end
			self.UI.Position = UDim2.new(0, (#root.UI.Modules:GetChildren() - 1 - (getfenv().A)) * 180, 0, 200)
		end
		
		do
			local gui = self.UI

			local dragging
			local dragInput
			local dragStart
			local startPos

			local function update(input)
				local delta = input.Position - dragStart
				gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end

			gui.Title.InputBegan:Connect(function(input)
				if categoryDragging and categoryDragging ~= gui then return end
				categoryDragging = gui
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = gui.Position

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							categoryDragging = nil
							dragging = false
						end
					end)
				end
			end)

			gui.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)

			userInputService.InputChanged:Connect(function(input)
				if input == dragInput and dragging then
					update(input)
				end
			end)
		end
		
		return self
	end
	
	function Category:CreateModule(title, n, f)
		local module = Module.new(title, self, n, f)
		self.Modules[title] = module
		return module
	end
end

function Bleachhack:Create()
	local self = setmetatable({}, Bleachhack)
	self.UI = objects.Bleachhack:Clone()
	self.UI.Parent = IS_STUDIO and player.PlayerGui or ((gethui and gethui()) or game:GetService("CoreGui"))
	self.Categories = {}
	
	local function toggleModules()
		self.UI.Modules.Visible = not self.UI.Modules.Visible
	end
	
	userInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftAlt then
			toggleModules()
		end
	end)
	
	self.UI.ModulesList.List.Title.MouseButton1Click:Connect(toggleModules)
	
	runService.RenderStepped:Connect(function()
		local chroma = getRainbowColor()
		local pingColor = valueToColor(ping * 500, 200)
		local fpsColor = valueToColor2(fps, 60)
		self.UI.ModulesList.Bar.BackgroundColor3 = chroma
		self.UI.Server.Ping.Text = '<stroke thickness="1"><font color="#dbd9d9">Ping: </font><font color="rgb('..pingColor[1]..","..pingColor[2]..","..pingColor[3]..')">'..math.round(ping * 500).."</font></stroke>"
		self.UI.Server.FPS.Text = '<stroke thickness="1"><font color="#dbd9d9">FPS: </font><font color="rgb('..fpsColor[1]..","..fpsColor[2]..","..fpsColor[3]..')">'..fps.."</font></stroke>"
		for index, element in pairs(self.UI.ModulesList.List:GetChildren()) do
			if not element:IsA("TextLabel") then continue end
			element.TextColor3 = chroma
		end
		fps += 1
		task.delay(1, function()
			fps -= 1
		end)
	end)
	
	return self
end

function Bleachhack:CreateCategory(title, icon)
	local category = Category.new(title, icon, self)
	self.Categories[title] = category
	return category
end

function Bleachhack:Export()
	local data = {}
	
	for index, category in pairs(self.Categories) do
		data[category.Title] = {}
		for index, module in pairs(category.Modules) do
			data[category.Title][module.Title] = {
				Value = module.Value,
				Settings = {}
			}
			for index, setting in pairs(module.Settings) do
				local serialized = setting.Value
				
				if typeof(serialized) == "EnumItem" then
					serialized = {
						Type = "EnumItem",
						Name = serialized.Name
					}
				end
				
				data[category.Title][module.Title].Settings[index] = serialized
			end
		end
	end
	
	return httpService:JSONEncode(data)
end

function Bleachhack:Import(data)
	data = httpService:JSONDecode(data)
	
	for categoryName, data in pairs(data) do
		if not self.Categories[categoryName] then continue end
		for moduleName, moduleData in pairs(data) do
			if not self.Categories[categoryName].Modules[moduleName] then continue end
			self.Categories[categoryName].Modules[moduleName].Value = not moduleData.Value
			self.Categories[categoryName].Modules[moduleName].Update(true)
			for index, value in pairs(moduleData.Settings) do
				self.Categories[categoryName].Modules[moduleName].Settings[index].Value = typeof(value) == "table" and value.Type == "EnumItem" and Enum.KeyCode[value.Name] or value
				self.Categories[categoryName].Modules[moduleName].Settings[index].Update()
			end
		end
	end
end

return Bleachhack
