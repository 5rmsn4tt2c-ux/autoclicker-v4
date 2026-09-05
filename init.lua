--!nocheck
local license = ... or {}
license.Key = script_key or license.Key

local cloneref = cloneref or function(ref) return ref end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local downloader = Instance.new('TextLabel')
downloader.Size = UDim2.new(1, 0, 0, 40)
downloader.BackgroundTransparency = 1
downloader.TextStrokeTransparency = 0
downloader.TextSize = 20
downloader.TextColor3 = Color3.new(1, 1, 1)
downloader.Font = Enum.Font.Arial
downloader.Text = ''
downloader.Parent = Instance.new('ScreenGui', gethui and gethui() or cloneref(game:GetService('CoreGui')))

local function downloadFile(path, func)
	if not isfile(path) then
		if not license.Closet then
			downloader.Text = 'Downloading '.. path
		end
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/5rmsn4tt2c-ux/autoclicker-v4/'..readfile('autoclicker-v4/profiles/commit.txt')..'/'..select(1, path:gsub('autoclicker-v4/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
		downloader.Text = ''
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('init') then continue end
		if file:find('profile') then continue end
		if isfile(file) then
			delfile(file)
		elseif isfolder(file) then
			wipeFolder(file)
		end
	end
end


for _, folder in {'catrewrite', 'autoclicker-v4/games', 'autoclicker-v4/profiles', 'autoclicker-v4/assets', 'autoclicker-v4/libraries', 'autoclicker-v4/guis', 'autoclicker-v4/texturepacks'} do
	if not isfolder(folder) then
		downloader.Text = 'Downloading '.. folder
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local commit = license.Commit or nil
	if not commit then
		local ok, subbed = pcall(function()
			return game:HttpGet('https://api.github.com/repos/5rmsn4tt2c-ux/autoclicker-v4/commits/main')
		end)
		if ok and type(subbed) == 'string' then
			commit = subbed:match('"sha"%s*:%s*"(%x+)"')
		end
		commit = commit and #commit == 40 and commit or 'main'
	end
	if commit == 'main' or (isfile('autoclicker-v4/profiles/commit.txt') and readfile('autoclicker-v4/profiles/commit.txt') or '') ~= commit then
		if commit ~= 'main' and isfile('autoclicker-v4/profiles/commit.txt') then
			shared.updated = readfile('autoclicker-v4/profiles/commit.txt')
		end
		wipeFolder('catrewrite')
		wipeFolder('autoclicker-v4/games')
		wipeFolder('autoclicker-v4/guis')
		wipeFolder('autoclicker-v4/libraries')
		wipeFolder('autoclicker-v4/texturepacks')
	end
	writefile('autoclicker-v4/profiles/commit.txt', commit)
end

downloader.Text = ''
return loadstring(downloadFile('autoclicker-v4/main.lua'), 'main')(license)