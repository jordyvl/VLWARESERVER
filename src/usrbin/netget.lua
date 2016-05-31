local modemsFound = false
for _, v in pairs(rs.getSides()) do
	if peripheral.getType(v) == "modem" then
		rednet.open(v)
		modemsFound = true
	end
end

if not modemsFound then
	printError("No modems attached")
	return
end

local oldPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local function printLog(text)
	local time = textutils.formatTime(os.time(), true)
	print("["..string.rep(" ", 5-time:len())..time.."] "..text)
end

local running = true
printLog("Receiving files...")
while running do
	local ok, err = pcall(function()
		local e = {os.pullEvent()}
		if e[1] == "terminate" then
			printLog("Exiting.")
			running = false
		elseif e[1] == "rednet_message" and type(e[3]) == "string" then
			local data = textutils.unserialize(e[3])
			if data then
				if data["mode"] == "netfile" then
					printLog("File received by "..e[2])
					local file = fs.open(data["name"], "w")
					file.write(data["content"])
					file.close()
					printLog("Saved as "..data["name"])
				elseif data['mode'] == "netfileDIR" then
					local allNames = textutils.unserialize(data['name'])
					local allCode = textutils.unserialize(data['content'])
					if #allNames ~= #allCode then
						printError("Unknown error.")
						return
					end
					for i=1,#allNames do
						local file = fs.open(allNames[i],"w")
						file.write(allCode[i])
						file.close()
						printLog('File '..i..' saved as '..allNames[i])
					end
				end
			end
		end
	end)
	if not ok then
		printLog("Exiting.")
		printLog("("..err..")")
		running = false
	end
end

os.pullEvent = oldPullEvent
