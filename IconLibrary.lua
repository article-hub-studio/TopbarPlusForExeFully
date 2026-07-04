local HttpService = game:GetService("HttpService")

local IconLibrary = {}

local CACHE_FOLDER = "TopbarPlus/IconCache"

local function ensureFolder(path)
	local parts = string.split(path, "/")
	local current = ""
	for _, part in ipairs(parts) do
		current = current == "" and part or (current .. "/" .. part)
		if not isfolder(current) then
			makefolder(current)
		end
	end
end

ensureFolder(CACHE_FOLDER)

local REMOTE_SOURCES = {
	Material = {
		url = "https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/MaterialIcons.luau",
		format = "luau",
	},
	Lucide = {
		url = "https://raw.githubusercontent.com/frappedevs/lucideblox/master/src/modules/util/icons.json",
		format = "json",
	},
}

local SVG_ONLY_PREFIXES = {
	Solar = "solar",
	Blade = "fa",
}

local loadedSets = {}

local function fetchAndCache(name, source)
	local ext = source.format == "json" and ".json" or ".luau"
	local path = CACHE_FOLDER .. "/" .. name .. ext

	if isfile(path) then
		return readfile(path)
	end

	local ok, result = pcall(function()
		return game:HttpGet(source.url)
	end)
	if not ok then
		warn("[IconLibrary] Không tải được bộ '" .. name .. "': " .. tostring(result))
		return nil
	end

	local writeOk = pcall(function()
		writefile(path, result)
	end)
	if not writeOk then
		warn("[IconLibrary] Không ghi được cache cho '" .. name .. "', vẫn dùng dữ liệu vừa tải")
	end

	return result
end

local function parseData(name, source, raw)
	if source.format == "json" then
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if not ok then
			warn("[IconLibrary] Lỗi giải mã JSON cho '" .. name .. "'")
			return {}
		end
		return decoded
	else
		local ok, fn = pcall(loadstring, raw)
		if not ok or not fn then
			warn("[IconLibrary] Lỗi loadstring cho '" .. name .. "'")
			return {}
		end
		local runOk, tbl = pcall(fn)
		if not runOk or typeof(tbl) ~= "table" then
			warn("[IconLibrary] Lỗi chạy dữ liệu cho '" .. name .. "'")
			return {}
		end
		return tbl
	end
end

local function loadSet(name)
	if loadedSets[name] then
		return loadedSets[name]
	end
	local source = REMOTE_SOURCES[name]
	if not source then
		warn("[IconLibrary] Bộ icon '" .. tostring(name) .. "' không tồn tại hoặc không hỗ trợ (SVG-only)")
		loadedSets[name] = {}
		return loadedSets[name]
	end
	local raw = fetchAndCache(name, source)
	if not raw then
		loadedSets[name] = {}
		return loadedSets[name]
	end
	loadedSets[name] = parseData(name, source, raw)
	return loadedSets[name]
end

function IconLibrary.get(setName, iconName)
	local set = loadSet(setName)
	local value = set[iconName]
	if value == nil then
		warn("[IconLibrary] Không tìm thấy icon '" .. tostring(iconName) .. "' trong bộ '" .. tostring(setName) .. "'")
		return nil
	end
	if typeof(value) == "number" then
		return "rbxassetid://" .. value
	end
	if typeof(value) == "string" then
		if value:match("^rbxassetid://") or value:match("^rbxthumb://") or value:match("^http") then
			return value
		end
		local numeric = value:match("%d+")
		if numeric then
			return "rbxassetid://" .. numeric
		end
	end
	warn("[IconLibrary] Định dạng icon không hợp lệ cho '" .. tostring(iconName) .. "'")
	return nil
end

function IconLibrary.getRawSVG(setName, iconName)
	local prefix = SVG_ONLY_PREFIXES[setName]
	if not prefix then
		warn("[IconLibrary] '" .. tostring(setName) .. "' không phải bộ SVG được hỗ trợ")
		return nil
	end
	local path = CACHE_FOLDER .. "/" .. setName .. "_" .. iconName .. ".svg"
	if isfile(path) then
		return readfile(path)
	end
	local url = "https://api.iconify.design/" .. prefix .. "/" .. iconName .. ".svg"
	local ok, svg = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok then
		warn("[IconLibrary] Không tải được SVG '" .. iconName .. "': " .. tostring(svg))
		return nil
	end
	pcall(function()
		writefile(path, svg)
	end)
	warn("[IconLibrary] Lưu ý: '" .. setName .. "' là SVG-only, Roblox không render được làm ảnh icon trực tiếp. Dữ liệu SVG chỉ được cache lại để dùng ngoài (vd tự convert sang PNG rồi upload asset).")
	return svg
end

function IconLibrary.clearCache()
	if isfolder(CACHE_FOLDER) then
		for _, fileName in ipairs(listfiles(CACHE_FOLDER)) do
			pcall(delfile, fileName)
		end
	end
end

return IconLibrary
