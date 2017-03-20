local function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

local function get(user, repo, bran, path, save)
	if not user or not repo or not bran or not path then
		error("not enough arguments, expected 4 or 5", 2)
	end
    local url = "https://raw.github.com/"..user.."/"..repo.."/"..bran.."/"..path
	local remote = http.get(url)
	if not remote then
		return false
	end
	local text = remote.readAll()
	remote.close()
	if save then
		local file = fs.open(save, "w")
		file.write(text)
		file.close()
		return true
	end
	return text
end

local function yesno(text, title, start)
	local function clear()
		term.clear()
		term.setCursorPos(1, 1)
	end
	
	local function drawButton(buttonText, x, y, x2, y2, enabled)
		if enabled then
			term.setBackgroundColor(colors.white)
		else
			if term.isColor() then
				term.setBackgroundColor(colors.gray)
			end
		end
		term.setCursorPos(x, y)
		for _y = y, y2 do
			for _x = x, x2 do
				term.setCursorPos(_x, _y)
				write(" ")
			end
		end
		term.setCursorPos(x+math.floor((x2-x)/2)-math.floor(buttonText:len()/2), y+math.floor((y2-y+1)/2))
		term.setTextColor(colors.black)
		write(buttonText)
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
	end
	
	local function cprint(text)
		local x, y = term.getCursorPos()
		local w, h = term.getSize()
		term.setCursorPos(math.floor(w/2)-math.floor(text:len()/2), y)
		print(text)
	end
	
	local selected = true
	
	local function redraw()
		clear()
		cprint(title)
		term.setCursorPos(1, 3)
		print(text)
		local w, h = term.getSize()
		drawButton("Yes", 2, h-1, math.floor(w/2)-1, h-1, selected)
		drawButton("No", math.floor(w/2)+1, h-1, w-1, h-1, not selected)
	end
	
	if start ~= nil and type(start) == "boolean" then
		selected = start
	end
	while true do
		redraw()
		local eventData = {os.pullEventRaw()}
		if eventData[1] == "terminate" then
			clear()
			return
		elseif eventData[1] == "key" then
			if eventData[2] == keys.up or eventData[2] == keys.down or eventData[2] == keys.left or eventData[2] == keys.right then
				selected = not selected
			elseif eventData[2] == keys.enter then
				clear()
				return selected
			end
		end
		sleep(0)
	end
end

local function getFile(file, target)
	return get("jordyvl", "VLWARESERVER”, “master”, file, target)
end

shell.setDir("")

clear()
print("Is the server disk in the drive?")
print("Press any key to continue!")
os.pullEvent("key")
clear()
print("VLWARE OS Server Edition - update or install")
print("Getting files...")
local files = {
	["src/startup.lua"] = "vlware",
	["src/vlware/init.lua"] = ".vlware/init",
	["src/vlware/login.lua"] = ".vlware/login",
	["src/vlware/update.lua"] = ".vlware/update",
	["src/usrbin/bash.lua"] = "usr/bin/bash",
	["src/usrbin/calc.lua"] = "usr/bin/calc",
	["src/usrbin/cat.lua"] = "usr/bin/cat",
	["src/usrbin/cd.lua"] = "usr/bin/cd",
	["src/usrbin/copy.lua"] = "usr/bin/copy",
	["src/usrbin/delete.lua"] = "usr/bin/delete",
	["src/usrbin/dupe.lua"] = "usr/bin/dupe",
	["src/usrbin/echo.lua"] = "usr/bin/echo",
	["src/usrbin/fileman.lua"] = "usr/bin/fileman",
	["src/usrbin/git.lua"] = "usr/bin/git",
	["src/usrbin/list.lua"] = "usr/bin/list",
	["src/usrbin/lmlua.lua"] = "usr/bin/lmlua",
	["src/usrbin/loader.lua"] = "usr/bin/loader",
	["src/usrbin/mkdir.lua"] = "usr/bin/mkdir",
	["src/usrbin/move.lua"] = "usr/bin/move",
	["src/usrbin/netget.lua"] = "usr/bin/netget",
	["src/usrbin/netsend.lua"] = "usr/bin/netsend",
	["src/usrbin/peripherals.lua"] = "usr/bin/peripherals",
	["src/usrbin/pwd.lua"] = "usr/bin/pwd",
	["src/usrbin/rdnt.lua"] = "usr/bin/rdnt",
	["src/usrbin/rdnt-srv.lua"] = "usr/bin/rdnt-srv",
	["src/usrbin/remotecl.lua"] = "usr/bin/remotecl",
	["src/usrbin/scrshare.lua"] = "usr/bin/scrshare",
	["src/usrbin/startw.lua"] = "usr/bin/startw",
	["src/usrbin/switch.lua"] = "usr/bin/switch",
	["src/usrbin/updater.lua"] = "usr/bin/updater",
	["src/usrbin/userctl.lua"] = "usr/bin/userctl",
	["src/usrbin/changelog.lua"] = "usr/bin/changelog",
	["src/usrbin/add.lua"] = "usr/bin/add",
	["src/usrbin/format.lua"] = "usr/bin/format",
	["src/usrbin/2d.lua"] = "usr/bin/2d",
	["src/usrbin/gists.lua"] = "usr/bin/gists",
	["src/apis/config.lua"] = ".vlware/apis/config",
	["src/apis/git.lua"] = ".vlware/apis/git",
	["src/apis/packet.lua"] = ".vlware/apis/packet",
	["src/apis/ui.lua"] = ".vlware/apis/ui",
	["src/apis/json.lua"] = ".vlware/apis/json",
	["src/apis/comgr.lua"] = ".vlware/apis/comgr",
	["src/lang/en.lang"] = ".vlware/lang/en.lang",
	["src/lang/nl.lang"] = ".vlware/lang/nl.lang",
	["src/lang/de.lang"] = ".vlware/lang/de.lang",
	["src/lang/it.lang"] = ".vlware/lang/it.lang",
	["src/lang/es.lang"] = ".vlware/lang/es.lang",
	["src/lang/fr.lang"] = ".vlware/lang/fr.lang",
	["src/lang/pt.lang"] = ".vlware/lang/pt.lang",
	["src/vlware/connor.lua"] = ".vlware/connor.sys",
	["src/usrbin/print.lua"] = "usr/bin/print",
	["src/usrbin/shutdown.lua"] = "usr/bin/shutdown",
	["src/usrbin/reboot.lua"] = "usr/bin/reboot",
	["src/usrbin/exit.lua"] = "usr/bin/exit",
	["src/usrbin/smartPaste.lua"] = "usr/bin/smartpaste",
	["src/usrbin/s.lua"] = "usr/bin/s"
}
local fileCount = 0
for _ in pairs(files) do
	fileCount = fileCount + 1
end
local filesDownloaded = 0

local w, h = term.getSize()
local pb
if ui and term.isColor() and ui.progressBar then
	pb = ui.progressBar(1,h-2,w,colors.green,true)
end

for k, v in pairs(files) do
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
	clear()
	term.setCursorPos(2, 2)
	print("VLWARE OS Server Edition Updater")
	term.setCursorPos(2, 4)
	print("File: "..v)
	term.setCursorPos(2, h - 1)
	if pb then
		pb.percent = math.floor(filesDownloaded / fileCount * 100)
		pb:draw()
	else
		print(tostring(math.floor(filesDownloaded / fileCount * 100)).."% - "..tostring(filesDownloaded + 1).."/"..tostring(fileCount))
	end
	local ok = getFile(k, v)
	if not ok then
		if term.isColor() then
			term.setTextColor(colors.red)
		end
		term.setCursorPos(2, 6)
		print("Error.")
		sleep(1)
	end
	filesDownloaded = filesDownloaded + 1
end
clear()
term.setCursorPos(2, 2)
print("Creating missing directories...")
local dirs = {
	"disk/SU",
	"disk/users",
	".vlware/apis/http",
	".vlware/apis/turtle",
}
for _, v in pairs(dirs) do
	if not fs.exists(v) then
		fs.makeDir(v)
	end
end
if not fs.exists("startup") then
	fs.copy("vlware", "startup")
elseif fs.exists("startup") and not fs.isDir("startup") then
	local oldSu = fs.open("startup", "r")
	local oSu = oldSu.readAll()
	oldSu.close()
	local newSu = fs.open("vlware", "r")
	local nSu = newSu.readAll()
	newSu.close()
	if oSu ~= nSu then
		local overwrite = yesno("Replace old startup?\n\n(\"No\" to run VLWARE OS with \"vlware\")", "Old startup detected.", false)
		if overwrite then
			fs.delete("startup")
			fs.copy("vlware", "startup")
		end
	end
end
clear()
term.setCursorPos(2, 2)
print("Press any key to continue.")
local w, h = term.getSize()
term.setCursorPos(2, h-1)
print("100% - "..tostring(filesDownloaded).."/"..tostring(fileCount))
local timconf = fs.open("/.vlware/tim.conf","w")
timconf.writeLine("upd8=true")
timconf.close()
os.pullEvent("key")
os.reboot()
