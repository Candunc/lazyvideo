##LazyVideo

This is a personal project to download videos behind the scenes and save them to my computer. It uses a json "database" to keep track of downloaded videos, [youtube-dl](https://github.com/rg3/youtube-dl) to scrape youtube videos, and [rt-downloader](https://github.com/Candunc/rt-downloader) to get the proper urls for downloading Rooster Teeth content. Requires [LuaJSON](https://luarocks.org/modules/harningt/luajson) to be installed, and performs best with ffmpeg also installed.

config.json.example is an example file, simply configure it by adding your desired path (IE: /home/), and to download Rooster Teeth sponsor-only content enter in a username and password. Eventually I'd like to have interactive support, but that is for another day.

###Use case

Generally you would want to run this script in a crontab entry, checking for videos maybe once or twice a day, then saving them to a network or a [synced](https://www.resilio.com/individuals/) directory. This is somewhat beyond the documentation of the project, however [message me](mailto:duncan_bristow@candunc.com) and I may be able to help you.

###Licencing

This project is licenced under the MIT licence, and uses a few other programs. All full licences and credit can be found in the LICENSE file.