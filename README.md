##LazyVideo

This is a personal project to download videos behind the scenes and save them to my computer. It uses a json "database" to keep track of downloaded videos, [youtube-dl](https://github.com/rg3/youtube-dl) to scrape youtube videos, and [rt-downloader](https://github.com/Candunc/rt-downloader) to get the proper urls for downloading Rooster Teeth content. Requires [LuaJSON](https://luarocks.org/modules/harningt/luajson) to be installed.

###Use case

Generally you would want to run this script in a crontab entry, checking for videos maybe once or twice a day, then saving them to a network directory or to a [synced directory](https://www.resilio.com/individuals/). This is somewhat beyond the documentation of the project.

###Forking or Improvements

This is licensed under the MIT License, meaning you can do whatever you want with it as long as you give credit. Feel free to [file and issue](https://github.com/Candunc/lazyvideo/issues) if you actually use the program and find something missing.