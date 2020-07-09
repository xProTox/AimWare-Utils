-- Author: xprtnwork https://aimware.net/forum/user/225577

-- Split-, File Exists-Function
local function a(b,c)c=c or'%s'local d={}for e,f in string.gmatch(b,"([^"..c.."]*)("..c.."?)")do table.insert(d,e)if f==""then return d end end end;local g={}file.Enumerate(function(h)g[h]=''end)

local pFiles = {
	hasVersionFile = false,
	version = {
		path = "xprtnwork/version.txt",
		url = "https://raw.githubusercontent.com/xProTox/AimWare-Utils/master/version.txt",
	},
	main = {
		path = "xprtnwork/xprtnwork.lua",
		url = "https://raw.githubusercontent.com/xProTox/AimWare-Utils/master/xprtnwork.lua",
	},
	utils = {
		path = "xprtnwork/xprtnwork_utils.lua",
		url = "https://raw.githubusercontent.com/xProTox/AimWare-Utils/master/xprtnwork_utils.lua",
	},
	menu = {
		path = "xprtnwork/xprtnwork_menu.xml",
		url = "https://raw.githubusercontent.com/xProTox/AimWare-Utils/master/xprtnwork_menu.xml",
	},
}

local versionFile = 0
local versionArray = {}
local currentVersionMain = 0
local currentVersionUtils = 0
local currentVersionMenu = 0

print("[xPrTnWork] Getting version numbers..")

if g[pFiles.version.path] then
	pFiles.hasVersionFile = true
	versionFile = file.Read(pFiles.version.path)
	versionArray = split(versionFile, "\n")
	currentVersionMain = versionArray[1]
	currentVersionUtils = versionArray[2]
	currentVersionMenu = versionArray[3]
else
	pFiles.hasVersionFile = false
	versionFile = file.Open(pFiles.version.path, "w")
	versionFile:Write("0" .. "\n")
	versionFile:Write("0" .. "\n")
	versionFile:Write("0" .. "\n")
	versionFile:Close()
	versionFile = file.Read(pFiles.version.path)
	versionArray = split(versionFile, "\n")
	currentVersionMain = versionArray[1]
	currentVersionUtils = versionArray[2]
	currentVersionMenu = versionArray[3]
end

print("[xPrTnWork] Current Version: " .. currentVersionMain .. " " .. currentVersionUtils .. " " .. currentVersionMenu)
print("[xPrTnWork] Checking for latest version..")

local latestVersion = http.Get(pFiles.version.url)
versionArray = {}
versionArray = split(latestVersion, "\n")
local latestVersionMain = versionArray[1]
local latestVersionUtils = versionArray[2]
local latestVersionMenu = versionArray[3]
local doneUpdate = false

if tonumber(latestVersionMenu) > tonumber(currentVersionMenu) or not pFiles.hasVersionFile then
	print("[xPrTnWork] Menu Style Script needs update!")
	
	local xmlMenuContent = http.Get(pFiles.menu.url)
	local xmlMenu = file.Open(pFiles.menu.path, "w")
	
	xmlMenu:Write(xmlMenuContent)
	xmlMenu:Close()
	
	print("[xPrTnWork] Updated Menu Style Script!")
	
	doneUpdate = true
else
	print("[xPrTnWork] Menu Style Script is up to date!")
end


if tonumber(latestVersionUtils) > tonumber(currentVersionUtils) or not pFiles.hasVersionFile then
	print("[xPrTnWork] Utils Script needs update!")
	
	local luaUtilsContent = http.Get(pFiles.utils.url)
	local luaUtils = file.Open(pFiles.utils.path, "w")
	
	luaUtils:Write(luaUtilsContent)
	luaUtils:Close()
	
	print("[xPrTnWork] Updated Utils Script")
	
	doneUpdate = true
else
	print("[xPrTnWork] Utils Script is up to date!")
end

if tonumber(latestVersionMain) > tonumber(currentVersionMain) or not pFiles.hasVersionFile then
	print("[xPrTnWork] Main Script needs update!")
	
	local luaMainContent = http.Get(pFiles.main.url)
	local luaMain = file.Open(pFiles.main.path, "w")
	
	luaMain:Write(luaMainContent)
	luaMain:Close()
	
	print("[xPrTnWork] Updated Main Script!")
	
	doneUpdate = true
else
	print("[xPrTnWork] Main Script is up to date!")
end

if doneUpdate then
	local versionWFile = file.Open(pFiles.version.path, "w")
	
	versionWFile:Write(latestVersionMain.. "\n")
	versionWFile:Write(latestVersionUtils.. "\n")
	versionWFile:Write(latestVersionMenu)
	versionWFile:Close()
end

print("[xPrTnWork] Starting Main Script!")
LoadScript("xprtnwork/xprtnwork.lua")
