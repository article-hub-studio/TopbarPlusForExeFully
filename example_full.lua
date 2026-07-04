local Icon = loadstring(game:HttpGet("https://raw.githubusercontent.com/article-hub-studio/TopbarPlusForExeFully/refs/heads/main/TopbarPlus_Executor.lua"))()
local IconLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/article-hub-studio/TopbarPlusForExeFully/refs/heads/main/IconLibrary.lua"))()

Icon.setDisplayOrder(50)

Icon.modifyBaseTheme({
	{"IconLabel", "TextColor3", "selected", Color3.fromRGB(255, 255, 255)},
	{"IconLabel", "TextColor3", "deselected", Color3.fromRGB(220, 220, 220)},
})

local mainMenu = Icon.new()
mainMenu:setName("MainMenu")
mainMenu:setImage(IconLibrary.get("Lucide", "layout-grid") or "rbxassetid://4483362748")
mainMenu:setLabel("Hub")
mainMenu:setCaption("Mở menu chính")
mainMenu:setOrder(1)
mainMenu:setWidth(40)
mainMenu:setCornerRadius(UDim.new(0, 8))
mainMenu:align("left")

mainMenu:bindEvent("selected", function(icon)
	icon:setLabel("Hub (Mở)")
end)
mainMenu:bindEvent("deselected", function(icon)
	icon:setLabel("Hub")
end)

local farmToggle = Icon.new()
farmToggle:setLabel("Auto Farm")
farmToggle:joinDropdown(mainMenu)
local farmEnabled = false
farmToggle:bindEvent("selected", function(icon)
	farmEnabled = true
	icon:setLabel("Auto Farm: ON")
end)
farmToggle:bindEvent("deselected", function(icon)
	farmEnabled = false
	icon:setLabel("Auto Farm: OFF")
end)

local collectToggle = Icon.new()
collectToggle:setLabel("Auto Collect")
collectToggle:joinDropdown(mainMenu)
collectToggle:oneClick(true)
collectToggle:bindEvent("selected", function(icon)
	print("Đã bấm Auto Collect")
	task.wait(0.3)
	icon:deselect()
end)

local settingsSub = Icon.new()
settingsSub:setLabel("Cài đặt")
settingsSub:joinMenu(mainMenu)
settingsSub:bindEvent("selected", function(icon)
	icon:setLabel("Cài đặt (đang mở)")
end)
settingsSub:bindEvent("deselected", function(icon)
	icon:setLabel("Cài đặt")
end)

local espIcon = Icon.new()
espIcon:setName("ESPToggle")
espIcon:setImage(IconLibrary.get("Lucide", "eye") or "rbxassetid://4483362748")
espIcon:setLabel("ESP: OFF")
espIcon:setCaption("Bật/tắt ESP")
espIcon:setCaptionHint(Enum.KeyCode.RightShift)
espIcon:bindToggleKey(Enum.KeyCode.RightShift)
espIcon:autoDeselect(false)

local espEnabled = false
espIcon:bindEvent("selected", function(icon)
	espEnabled = true
	icon:setLabel("ESP: ON")
	icon:modifyTheme({"IconImage", "ImageColor3", Color3.fromRGB(0, 255, 127), "Selected"})
end)
espIcon:bindEvent("deselected", function(icon)
	espEnabled = false
	icon:setLabel("ESP: OFF")
	icon:modifyTheme({"IconImage", "ImageColor3", Color3.fromRGB(255, 255, 255), "Deselected"})
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if espEnabled then
			espIcon:deselect()
		else
			espIcon:select()
		end
	end
end)

local indicatorIcon = Icon.new()
indicatorIcon:setLabel("Gamepad")
indicatorIcon:setIndicator(Enum.KeyCode.ButtonY)
indicatorIcon:bindEvent("selected", function(icon)
	icon:notify()
end)

local lockedIcon = Icon.new()
lockedIcon:setLabel("Đang tải...")
lockedIcon:lock()
task.delay(3, function()
	lockedIcon:unlock()
	lockedIcon:setLabel("Sẵn sàng")
	lockedIcon:notify()
end)

local dynamicIcon = Icon.new()
dynamicIcon:setLabel("Giờ: --:--")
task.spawn(function()
	while dynamicIcon do
		local t = os.date("*t")
		dynamicIcon:setLabel(string.format("Giờ: %02d:%02d", t.hour, t.min))
		task.wait(30)
	end
end)

local themeIcon = Icon.new()
themeIcon:setLabel("Đổi màu")
local usingAlt = false
themeIcon:bindEvent("selected", function(icon)
	usingAlt = not usingAlt
	if usingAlt then
		icon:modifyTheme({"IconButton", "BackgroundColor3", Color3.fromRGB(80, 60, 200)})
	else
		icon:removeModificationWith("IconButton", "BackgroundColor3")
	end
	task.wait(0.2)
	icon:deselect()
end)

local infoDropdown = Icon.new()
infoDropdown:setLabel("Thông tin")
infoDropdown:joinDropdown(mainMenu)
infoDropdown:bindEvent("selected", function(icon)
	local player = game:GetService("Players").LocalPlayer
	icon:setLabel("Chào " .. player.Name)
	task.wait(1)
	icon:setLabel("Thông tin")
	icon:deselect()
end)

local closeAllIcon = Icon.new()
closeAllIcon:setLabel("Đóng tất cả")
closeAllIcon:joinDropdown(mainMenu)
closeAllIcon:bindEvent("selected", function(icon)
	if espEnabled then
		espIcon:deselect()
	end
	icon:deselect()
	mainMenu:deselect()
end)

local highlightIcon = Icon.new()
highlightIcon:setLabel("Nhiệm vụ mới")
highlightIcon:setImage(IconLibrary.get("Material", "campaign") or "rbxassetid://4483362748")

local highlightOn = true
local highlightColorA = Color3.fromRGB(255, 230, 80)
local highlightColorB = Color3.fromRGB(255, 255, 255)
task.spawn(function()
	while highlightOn do
		highlightIcon:modifyTheme({"IconButton", "BackgroundColor3", highlightColorA}, "HighlightPulse")
		task.wait(0.5)
		highlightIcon:modifyTheme({"IconButton", "BackgroundColor3", highlightColorB}, "HighlightPulse")
		task.wait(0.5)
	end
end)

highlightIcon:bindEvent("selected", function(icon)
	highlightOn = false
	icon:removeModificationWith("IconButton", "BackgroundColor3", "HighlightPulse")
	icon:setLabel("Đã xem")
	task.wait(0.3)
	icon:deselect()
end)

mainMenu:notify()

print("TopbarPlus fully example đã load xong.")
print("Tổng số icon hiện tại: " .. tostring(#Icon.getIcons()))
