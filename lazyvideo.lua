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

--If my motivation to socialize matched my motivation to automate
--my routine, I'd probably be a better person. 

function processYoutube()
	for _,channel in ipairs(db["config"]["youtube"]) do
		playlist = json.decode(exec("youtube-dl -J --playlist-items 1-4 https://www.youtube.com/user/"..channel.."/videos")) --Why the limit of 4? That's a good question.
		for _,video in pairs(playlist["entries"]) do
			if db["ignore"][video["id"]] == nil then
				db["ignore"][video["id"]] = true

				--Here we don't use exec because we don't need the output.
				os.execute("youtube-dl -o \"/tmp/lazyvideo/%(uploader)s - %(title)s.%(ext)s\" \""..video["webpage_url"].."\"")
				-- Workaround for letting rt-downloader decide the name, and not this program.
				os.execute("mv \"/tmp/lazyvideo/"..video["uploader"].."*\" \""..db["config"]["path"].."/\"")
				--Using path combined with youtube-dl autonaming https://github.com/rg3/youtube-dl/#output-template
			end
		end
	end
end

function processRT()
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
			filename = (video["title"]..".mp4")
			url =  (" \"http://"..video["channelUrl"].."/episode/"..video["slug"].."\" ")

			if username_set == true then
				os.execute("youtube-dl -o \"/tmp/lazyvideo/"..filename.."\" -u "..db["config"]["username"].." -p "..db["config"]["password"]..url)
			else
				os.execute("youtube-dl -o \"/tmp/lazyvideo/"..filename.."\" "..url)
			end
			os.execute("mv \"/tmp/lazyvideo/"..filename.."\" \""..config["path"].."/\"")
		end
	end
end

function sync()
	os.execute("mkdir /tmp/lazyvideo")
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
	saveDB("config")
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