process = {}

function process.Youtube()
	if db["config"]["youtube"] == nil then
		--Config not initialized, close function
		return nil
	end

	local toProcess = {}
	local count = 0
	local time = 0

	for _,channel in ipairs(db["config"]["youtube"]) do
		time = os.time() --os.clock benchmarks _lua_ code, it does not include calls to outside resources like popen.
		playlist = json.decode(util.exec("youtube-dl -J --playlist-items 1-4 https://www.youtube.com/user/"..channel.."/videos")) --Why the limit of 4? That's a good question.
		for _,entry in pairs(playlist["entries"]) do
			if db["ignore"][entry["id"]] == nil then
				
				--Remove unnecessary data, and set other important data.
				entry["formats"] = nil
				entry["requested_formats"] = nil
				entry["filename"] = string.gsub((entry["uploader"].." - "..entry["title"]),"/","_")
				-- Replace incompatible slash (Bug #3) with Windows Compatible underscore

				count = (count+1)
				toProcess[count] = entry				
			end
		end
		util.log("Processed "..channel.." in "..(os.time()-time).." seconds.")
	end

	--Download all youtube videos sequentially _after_ getting all the metadata.
	for _,video in ipairs(toProcess) do
		util.log("Downloading '"..video["filename"].."'")
		db["ignore"][video["id"]] = true
		util.vexec("youtube-dl -o \""..db["config"]["tempdir"].."/"..video["filename"].."\" \""..video["webpage_url"].."\"")
				
		-- Having the wildcard _outside_ the quotes and letting youtube-dl decide the filename should make things work.
		util.vexec("mv \""..db["config"]["tempdir"].."/"..video["filename"].."\"* \""..db["config"]["path"].."/\"")
	end
end


function process.RT()
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
	for _,video in pairs(json.decode(util.exec("curl -s \"https://rtdownloader.com/api/?action=getLatest\""))) do
		if showEnabled[video["showName"]] ~= nil and db["ignore"][video["hash"]] == nil then
			db["ignore"][video["hash"]] = true
			filename = (video["showName"].." - "..video["title"]..".mp4")
			url =  (" \"http://"..video["channelUrl"].."/episode/"..video["slug"].."\" ")

			if username_set == true then
				util.vexec("youtube-dl -o \""..db["config"]["tempdir"].."/"..filename.."\" -u "..db["config"]["username"].." -p "..db["config"]["password"]..url)
			else
				util.vexec("youtube-dl -o \""..db["config"]["tempdir"].."/"..filename.."\" "..url)
			end
			util.vexec("mv \""..db["config"]["tempdir"].."/"..filename.."\" \""..db["config"]["path"].."/\"")
		end
	end
end