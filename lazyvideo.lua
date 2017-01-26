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
	os.exit()
end

function exec(command)
	local handle = io.popen(command)
	local data = handle:read("*a")
	handle:close()

	return data
end

--If my motivation to socialize matched my motivation to automate
--my routine, I'd probably be a better person. 

function processYoutube()
	for _,channel in ipairs(db["config"]["youtube"]) do
		playlist = json.decode(exec("youtube-dl -J --playlist-items 1-4 https://www.youtube.com/user/"..channel.."/videos")) --Why the limit of 4? That's a good question.
		for _,video in pairs(playlist["entries"]) do
			if db["ignore"][video["id"]] == nil then
				db["ignore"][video["id"]] = true

				--Here we don't use exec because we don't need the output.
				os.execute("youtube-dl -o \""..config["path"].."/%(uploader)s - %(title)s.%(ext)s\" \""..video["webpage_url"].."\"")
				--Using path combined with youtube-dl autonaming https://github.com/rg3/youtube-dl/#output-template
			end
		end
	end
end

function processRT()
	--It would be more efficient to do this with ipairs, however PHP turns integers into strings when encoding json.
	for _,video in pairs(exec("curl -s \"https://rtdownloader.com/api/?action=GetLatest\"")) do
		if db["config"]["roosterteeth"][video["showName"]] ~= nil and db["ignore"][video["hash"]] == nil then
			db["ignore"][video["hash"]] = true
			filename = ("\""..db["config"]["path"].."/"..video["title"].." - "..video["caption"]..".mp4\"")
			url =  (" \"http://"..video["channelUrl"].."/"..video["slug"].."\" ")

			if db["config"]["username"] ~= nil and db["config"]["password"] ~= nil then	
				os.execute("youtube-dl -o "..filename.." -u "..db["config"]["username"].." -p "..db["config"]["password"]..url)
			else
				os.execute("youtube-dl -o "..filename..url)
			end
		end
	end
end

function sync()
	if db["config"]["youtube"] ~= nil then
		-- Catch error on newly initialized configs
		processYoutube()
	end

	if db["config"]["roosterteeth"] ~= nil then
		processRT()
	end

	safeClose()
end

db = {}
loadDB("config")
loadDB("ignore")

if db["config"]["path"] == "nil" then
	db["config"]["path"] = "."
	saveDB("config"])
end

sync()

--[[
--	TODO: Build an interactive console for adding/removing youtube channels, or other things
if arg[1] == "--cron" then
		sync()
		os.exit()
end

print("Didn't find --cron argument, running interactively. Type ? for help.")
while true do
	io.write("> ")
	value = io.read()
	if value == "" or value == "exit" or value == "quit" then
		os.exit()
	end
end]]