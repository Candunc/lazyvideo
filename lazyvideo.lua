require("util")
require("process")
json = require("json")

db = {}
util.loadDB("config")
util.loadDB("ignore")

if db["config"]["tempdir"] == nil or db["config"]["tempdir"] == "" then
	db["config"]["tempdir"] = "/tmp/lazyvideo"
end

os.execute("mkdir \""..db["config"]["tempdir"].."\" >/dev/null 2>&1")

if db["config"]["path"] == nil or db["config"]["path"] == "" then
	db["config"]["path"] = "."
	util.saveDB("config")
end

--Set variables so we cycle through _all_ arguments before 
for _,argument in ipairs(arg) do
	if argument == "--cron" then
		youtube = true
		rt = true
	end

	if argument == "--youtube" then
		youtube = true
	end

	if argument == "--rt" or argument == "--roosterteeth" then
		rt = true
	end

	if argument == "-v" then
		verbose = true
	end
end

if youtube == true then
	process.Youtube()
end
if rt == true then
	process.RT()
end


util.safeClose()
--[[
--Interactive prompt still needs to be implemented
if youtube ~= true and rt ~= true then
	print("Didn't find run argument, running interactively. Type ? for help.")
	while true do
		io.write("> ")
		value = io.read()
		if value == "" or value == "exit" or value == "quit" then
			os.exit()
		end
	end
end]]
