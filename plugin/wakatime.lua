local wakatime_config_path = vim.fs.joinpath(os.getenv("HOME"), ".wakatime.cfg")

-- only enable wakatime if the config exists, otherwise it
-- periodically asks for the api key and is really annoying
if vim.fn.filereadable(wakatime_config_path) then
	vim.pack.add({ "https://github.com/wakatime/vim-wakatime" })
end
