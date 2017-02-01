-- Essential bits go here
json = require("json")

--All these functions: http://i.imgur.com/joSbnpl.jpg
function loadDB(name)
	local file = io.open(name..".json","r")
	if file == nil then
		db[name] = {}
	else
		db[name] = json.decode(file:read("*a"))
		file:close()
	end
end

function saveDB(name)
	local file = io.open(name..".json","w")
	file:write(json.encode(db[name]))
	file:close()
end

function safeClose()
	-- Flush database to file at end, rather than after every call.
	saveDB("ignore")
	os.execute("rmdir /tmp/lazyvideo")
	os.exit()
end

function exec(command)
	local handle = io.popen(command)
	local data = handle:read("*a")
	handle:close()

	return data
end

-- "Verbose" execute, if enabled display to stdout, otherwise throw away.
function vexec(command)
	if verbose == true then
		os.execute(command)
	else
		os.execute(command.." >/dev/null 2>&1")
	end
end 

function log(input)
	if verbose == true then
		print(os.date("%F %T - ")..input)
	end
end

--If my motivation to socialize matched my motivation to automate
--my routine, I'd probably be a better person. 

function processYoutube()
	if db["config"]["youtube"] == nil then
		--Config not initialized, close function
		return nil
	end

	local toProcess = {}
	local count = 0
	local time = 0

	for _,channel in ipairs(db["config"]["youtube"]) do
		time = os.clock()
		playlist = json.decode(exec("youtube-dl -J --playlist-items 1-4 https://www.youtube.com/user/"..channel.."/videos")) --Why the limit of 4? That's a good question.
		for _,entry in pairs(playlist["entries"]) do
			if db["ignore"][entry["id"]] == nil then
				
				--Remove unnecessary data, and set other important data.
				entry["formats"] = nil
				entry["requested_formats"] = nil
				entry["filename"] = (entry["uploader"].." - "..entry["title"])

				count = (count+1)
				toProcess[count] = entry				
			end
		end
		log("Processed "..channel.." in "..(os.clock()-time).." seconds.")
	end

	--Download all youtube videos sequentially _after_ getting all the metadata.
	for _,video in ipairs(toProcess) do
		db["ignore"][video["id"]] = true
		vexec("youtube-dl -o \"/tmp/lazyvideo/"..video["filename"].."\" \""..video["webpage_url"].."\"")
				
		-- Having the wildcard _outside_ the quotes and letting youtube-dl decide the filename should make things work.
		os.execute("mv \"/tmp/lazyvideo/"..video["filename"].."\"* \""..db["config"]["path"].."/\"")
	end
end

function processRT()
	if db["config"]["roosterteeth"] == nil then
		--Config not initialized, close function
		return nil
	end

	if db["config"]["username"] ~= nil and db["config"]["password"] ~= nil and db["config"]["username"] ~= "" and db["config"]["password"] then
		--Move this _really_ long if statement to the start so that it only gets called once
		--I'm assuming that the username and password do not have reserved characters.
		username_set = true
	end

	--I realized after the fact that I have an ipairs sorted table for RT Shows, and then call them directly.
	-- This is a workaround so that the config stays "simpler"
	local showEnabled = {}
	for _,title in ipairs(db["config"]["roosterteeth"]) do
		showEnabled[title] = true
	end


	--It would be more efficient to do this with ipairs, however PHP turns integers into strings when encoding json.
	for _,video in pairs(json.decode(exec("curl -s \"https://rtdownloader.com/api/?action=getLatest\""))) do
		if showEnabled[video["showName"]] ~= nil and db["ignore"][video["hash"]] == nil then
			db["ignore"][video["hash"]] = true
			filename = (video["showName"].." - "..video["title"]..".mp4")
			url =  (" \"http://"..video["channelUrl"].."/episode/"..video["slug"].."\" ")

			if username_set == true then
				os.execute("youtube-dl -o \"/tmp/lazyvideo/"..filename.."\" -u "..db["config"]["username"].." -p "..db["config"]["password"]..url)
			else
				os.execute("youtube-dl -o \"/tmp/lazyvideo/"..filename.."\" "..url)
			end
			os.execute("mv \"/tmp/lazyvideo/"..filename.."\" \""..db["config"]["path"].."/\"")
		end
	end
end

db = {}
loadDB("config")
loadDB("ignore")
os.execute("mkdir /tmp/lazyvideo")

if db["config"]["path"] == nil or db["config"]["path"] == "" then
	db["config"]["path"] = "."
	saveDB("config")
end

for _,argument in ipairs(arg) do
	if argument == "--cron" then
		processYoutube()
		processRT()
	end

	if argument == "--youtube" then
		processYoutube()
	end

	if argument == "--rt" or argument == "--roosterteeth" then
		processRT()
	end

	if argument == "-v" then
		verbose = true
	end
end


safeClose()
--[[
--Interactive prompt still needs to be implemented
print("Didn't find --cron argument, running interactively. Type ? for help.")
while true do
	io.write("> ")
	value = io.read()
	if value == "" or value == "exit" or value == "quit" then
		os.exit()
	end
end]]