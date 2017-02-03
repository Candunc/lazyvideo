util = {}

function util.loadDB(name)
	local file = io.open(name..".json","r")
	if file == nil then
		db[name] = {}
	else
		db[name] = json.decode(file:read("*a"))
		file:close()
	end
end

function util.saveDB(name)
	local file = io.open(name..".json","w")
	file:write(json.encode(db[name]))
	file:close()
end

function util.safeClose()
	-- Flush database to file at end, rather than after every call.
	util.saveDB("ignore")
	os.execute("rmdir \""..db["config"]["tempdir"].."\" >/dev/null 2>&1")
	os.exit()
end

function util.exec(command)
	local handle = io.popen(command)
	local data = handle:read("*a")
	handle:close()

	return data
end

-- "Verbose" execute, if enabled display to stdout, otherwise throw away.
function util.vexec(command)
	if verbose == true then
		os.execute(command)
	else
		os.execute(command.." >/dev/null 2>&1")
	end
end 

function util.log(input)
	if verbose == true then
		print(os.date("%F %T - ")..input)
	end
end

