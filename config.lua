sm = require('preload.sounds')
te = require('lib.tesound')

local function copyTable(t)
    if type(t) ~= "table" then return t end
    local new = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            new[k] = copyTable(v)
        else
            new[k] = v
        end
    end
    return new
end

local function compareTable(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end

    for k, v in pairs(a) do
        local bv = b[k]
        if type(v) == "table" and type(bv) == "table" then
            if not compareTable(v, bv) then
                return false
            end
        elseif v ~= bv then
            return false
        end
    end

    for k in pairs(b) do
        if a[k] == nil then return false end
    end

    return true
end

if not mod.sConfigState then
    mod.sConfigState = copyTable(mod.config.customsounds.music)
end

if imgui.TreeNode_Str("Custom Player") then
    imgui.SetWindowFontScale(2)
    imgui.Text("Custom Player")
    imgui.SetWindowFontScale(1)
    imgui.Text("A list of levels played in the custom player")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

	local useCustomPlayer = helpers.InputBool("Use Custom Player", mod.config.customsounds.music.useCustomPlayer)
	if mod.config.customsounds.music.useCustomPlayer ~= useCustomPlayer then
		mod.config.customsounds.music.useCustomPlayer = useCustomPlayer
		cs.menuMusicManager:stop()
		cs.menuMusicManager:play()
	end
	helpers.imguiHelpMarker("Randomly shuffles songs from installed maps, no need to pick your favorite")

    mod.config.customsounds.music.repeatSameSong = helpers.InputBool("Repeat Single Song", mod.config.customsounds.music.repeatSameSong)
	helpers.imguiHelpMarker("Prevents the player from automatically advancing the song")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

	if lemontweaks and lemontweaks.levellist then

		imgui.Text("Level count: " .. #lemontweaks.levellist)

		imgui.NewLine()

		for i, data in ipairs(lemontweaks.levellist) do
			local current = lemontweaks.fetchedLevels[lemontweaks.current]
			if i ~= 1 then imgui.Separator() end
			if imgui.Selectable_Bool((data.artist or "unknown"):gsub("%b[]", "") .. " - " .. (data.name or "unknown"):gsub("%b[]", ""), data == current) then
				lemontweaks.current = data.index or 1
				lemontweaks.tempDontAdvance = true
				current = lemontweaks.fetchedLevels[lemontweaks.current]
				-- print("[lemontweaks] Set index to " .. lemontweaks.current .. " " .. (current.artist or "unknown"):gsub("%b[]", "") .. " - " .. (current.name or "unknown"):gsub("%b[]", ""))

				if cs and cs.menuMusicManager and mod.config.customsounds.music.useCustomPlayer then
					cs.menuMusicManager:stop()
					cs.menuMusicManager:play()
				else
					print("[lemontweaks] no MenuMusicManager")
				end
			end
		end
	else
		imgui.Text("No Levels")
	end

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.TreePop()
end

if imgui.TreeNode_Str("Chart Progress") then
    imgui.SetWindowFontScale(2)
    imgui.Text("Chart Progress")
    imgui.SetWindowFontScale(1)
    imgui.Text("Adds bars to the extended UI showing level progress")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.SetWindowFontScale(2)
    imgui.Text("Bar Positions")
    imgui.SetWindowFontScale(1)

    mod.config.chartprog.topBar = helpers.InputBool("Enable top bar", mod.config.chartprog.topBar)
    mod.config.chartprog.bottomBar = helpers.InputBool("Enable bottom bar", mod.config.chartprog.bottomBar)

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.SetWindowFontScale(2)
    imgui.Text("Progress Visuals")
    imgui.SetWindowFontScale(1)

    mod.config.chartprog.useVFXcolor = helpers.InputBool("Use UI color", mod.config.chartprog.useVFXcolor)
    helpers.imguiHelpMarker("Use the UI color rather than the player colors")

    mod.config.chartprog.centerBar = helpers.InputBool("Center bars", mod.config.chartprog.centerBar)
    helpers.imguiHelpMarker("Centers the bars horizontally")

    mod.config.chartprog.reverseDirection = helpers.InputBool("Reverse bar direction", mod.config.chartprog.reverseDirection)
    helpers.imguiHelpMarker("Makes the bars shrink instead of grow")

    imgui.NewLine()

    mod.config.chartprog.showProgressText = helpers.InputBool("Show Progress Text", mod.config.chartprog.showProgressText)

    local types = { "Percentage", "Beats", "Time" }
    local alternate = {
        Percentage = "Show Decimal",
        Beats = "Total Beats",
        Time = "Time Left"
    }
    
    if not mod.config.chartprog.showProgressText then
        imgui.BeginDisabled()
    end

	if imgui.BeginCombo("Progress Type", mod.config.chartprog.progressType) then
        for i, v in ipairs(types) do
            local isSelected = (v == mod.config.chartprog.progressType)
            if imgui.Selectable_Bool(v, isSelected) then
                mod.config.chartprog.progressType = v
            end
        end
        imgui.EndCombo()
    end

    mod.config.chartprog.alternate = helpers.InputBool("Show " .. alternate[mod.config.chartprog.progressType], mod.config.chartprog.alternate)

    if not mod.config.chartprog.showProgressText then
        imgui.EndDisabled()
    end

    imgui.NewLine()

    imgui.SetNextItemWidth(120)
    mod.config.chartprog.barHeight = helpers.InputInt("Bar thickness", mod.config.chartprog.barHeight)
    helpers.imguiHelpMarker("How tall the bars are")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.TreePop()
end

if imgui.TreeNode_Str("Custom Sounds") then
    imgui.SetWindowFontScale(2)
    imgui.Text("Custom Sounds")
    imgui.SetWindowFontScale(1)
    imgui.Text("Allows for replacing sound effects and music in game")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    if imgui.Button("Open CS Folder") then
        local path = os.getenv("APPDATA") .. "\\beatblock\\Mods\\lemontweaks\\customsounds"
        os.execute('start "" "' .. path .. '"')
    end

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    local customsounds = {
        sfx = {
            { label = "Barely", value = "barely", fallback = "assets/sfx/barely.ogg" },
            { label = "Block", value = "block", fallback = "assets/sfx/click.ogg" },
            { label = "Click", value = "click", fallback = "assets/sfx/click.ogg" },
            { label = "Hold", value = "hold", fallback = "assets/sfx/hold.ogg" },
            { label = "Hover", value = "hover", fallback = "assets/sfx/click.ogg" },
            { label = "Mine", value = "mine", fallback = "assets/sfx/mine.ogg" },
            { label = "Pause", value = "pause", fallback = "assets/sfx/pause.ogg" },
            { label = "Side", value = "side", fallback = "assets/sfx/click.ogg" },
            { label = "Tap", value = "tap", fallback = "assets/sfx/tap.ogg" },
            { label = "Miss", value = "miss", fallback = "assets/sfx/mine.ogg" }
        },
        music = {
            { label = "Menu Loop", value = "menuloop", fallback = "assets/music/menuloop.ogg" },
            { label = "Caution", value = "caution", fallback = "assets/music/caution.ogg" }
        }
    }

    -- local audioFiles = {sfx = {}, music = {}}

    local audioFileExtensions = {"mp3", "ogg", "wav", "aac", "flac", "m4a", "wma", "opus"} -- no idea if all of these work, but whatevs

    local function isAudio(fileName)
        local ext = fileName:match("^.+%.(.+)$") -- get text after last "."
        if not ext then return false end
        ext = ext:lower()
        for _, validExt in ipairs(audioFileExtensions) do
            if ext == validExt then
                return true
            end
        end
        return false
    end

    if imgui.BeginTabBar("sfxconfig") then
        for i = 1, #customsounds.sfx, 1 do
            if imgui.BeginTabItem(customsounds.sfx[i].label .. "##sfxconfig") then

                local sounds = love.filesystem.getDirectoryItems("Mods/lemontweaks/customsounds/sfx/" .. customsounds.sfx[i].value)

                imgui.Text("Selected: " .. mod.config.customsounds.sfx[customsounds.sfx[i].value]);

                if imgui.Button("Default##" .. customsounds.sfx[i].value) then
                    print("[lemontweaks] Reset " .. customsounds.sfx[i].value .. " to default")

                    mod.config.customsounds.sfx[customsounds.sfx[i].value] = "default"

                    sm:replaceSound(customsounds.sfx[i].value, customsounds.sfx[i].fallback)
                end

                imgui.NewLine()

                for _, sound in ipairs(sounds) do
                    if isAudio(sound) then
                        if imgui.Button(sound .. "##" .. customsounds.sfx[i].value) then
                            print("[lemontweaks] Set " .. customsounds.sfx[i].value .. " to " .. sound)

                            mod.config.customsounds.sfx[customsounds.sfx[i].value] = sound

                            sm:replaceSound(customsounds.sfx[i].value, "Mods/lemontweaks/customsounds/sfx/" .. customsounds.sfx[i].value .. "/" .. sound)

                            -- SFX previews!!!!!!!!
                            print("[lemontweaks] playing " .. sound)
                            te.playOne("Mods/lemontweaks/customsounds/sfx/" .. customsounds.sfx[i].value .. "/" .. sound, "static", "sfx")
                        end
                    end
                end

                imgui.EndTabItem()
            end
        end

        imgui.EndTabBar()
    end

    imgui.NewLine()
    imgui.NewLine()
    imgui.NewLine()

    imgui.SetWindowFontScale(2)
    imgui.Text("Music Replacements")
    imgui.SetWindowFontScale(1)

    if imgui.BeginTabBar("mconfig") then
        for i = 1, #customsounds.music, 1 do
            if imgui.BeginTabItem(customsounds.music[i].label .. "##mconfig") then

                local sounds = love.filesystem.getDirectoryItems("Mods/lemontweaks/customsounds/music/" .. customsounds.music[i].value)

                imgui.Text("Selected: " .. mod.config.customsounds.music[customsounds.music[i].value]);

                if imgui.Button("Default##" .. customsounds.music[i].value) then
                    print("[lemontweaks] Reset " .. customsounds.music[i].value .. " to default")

                    mod.config.customsounds.music[customsounds.music[i].value] = "default"
                end

                imgui.NewLine()

                for _, sound in ipairs(sounds) do
                    if isAudio(sound) then
                        if imgui.Button(sound .. "##" .. customsounds.music[i].value) then
                            print("[lemontweaks] Set " .. customsounds.music[i].value .. " to " .. sound)

                            mod.config.customsounds.music[customsounds.music[i].value] = sound

							if customsounds.music[i].value == "menuloop" and not mod.config.customsounds.music.useCustomPlayer then
								cs.menuMusicManager:stop()
								cs.menuMusicManager:play()
							end

                            --sounds:replaceSound(customsounds.music[i].value, "Mods/lemontweaks/customsounds/music/" .. customsounds.music[i].value .. "/" .. sound)
                        end
                    end
                end

                if customsounds.music[i].value == "menuloop" then
                    imgui.NewLine()

					local useCustomPlayer = helpers.InputBool("Use Custom Player", mod.config.customsounds.music.useCustomPlayer)
					if mod.config.customsounds.music.useCustomPlayer ~= useCustomPlayer then
						mod.config.customsounds.music.useCustomPlayer = useCustomPlayer
						cs.menuMusicManager:stop()
						cs.menuMusicManager:play()
					end
                    helpers.imguiHelpMarker("Randomly shuffles songs from installed maps, no need to pick your favorite")

                    imgui.NewLine()

                    if (mod.config.customsounds.music.useCustomPlayer) then
                        imgui.BeginDisabled();
                    end

                    imgui.SetNextItemWidth(120)
                    mod.config.customsounds.music.menuloopBPM = helpers.InputInt("BPM (default: 108)", mod.config.customsounds.music.menuloopBPM)

                    imgui.SetNextItemWidth(120)
                    mod.config.customsounds.music.menuloopOffset = helpers.InputInt("Offset (ms)(default: 0)", mod.config.customsounds.music.menuloopOffset)

                    if (mod.config.customsounds.music.useCustomPlayer) then
                        imgui.EndDisabled();
                    end
                end

                imgui.EndTabItem()
            end
        end
        imgui.EndTabBar()
    end

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.TreePop()
end

if imgui.TreeNode_Str("Section Skip") then
    imgui.SetWindowFontScale(2)
    imgui.Text("Section Skip")
    imgui.SetWindowFontScale(1)
    imgui.Text("Allows for skipping empty sections within a level")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    mod.config.sectionskip.enabled = helpers.InputBool("Enabled", mod.config.sectionskip.enabled)

    imgui.NewLine()

    imgui.SetNextItemWidth(120)
    mod.config.sectionskip.skipthreashold = helpers.InputInt("Skip Threashold (ms)", mod.config.sectionskip.skipthreashold)
    helpers.imguiHelpMarker("Determines how long the empty section should be to be skippable")

    imgui.SetNextItemWidth(120)
    mod.config.sectionskip.skipholdlength = helpers.InputInt("Skip Hold Length (ms)", mod.config.sectionskip.skipholdlength)
    helpers.imguiHelpMarker("How long a tab button should be held to skip the section")

    imgui.SetNextItemWidth(120)
    mod.config.sectionskip.skipjumpdist = helpers.InputInt("Skip Jump Distance (ms)", mod.config.sectionskip.skipjumpdist)
    helpers.imguiHelpMarker("Distance in milliseconds before the next note after an empty section it jumps to")

    if mod.config.sectionskip.skipholdlength > mod.config.sectionskip.skipthreashold then
        mod.config.sectionskip.skipholdlength = mod.config.sectionskip.skipthreashold
    end

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.TreePop()
end

if imgui.TreeNode_Str("Miscellaneous") then
    imgui.SetWindowFontScale(2)
    imgui.Text("Miscellaneous")
    imgui.SetWindowFontScale(1)
    imgui.Text("Some random freatures without enough options for its own category")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    if imgui.BeginTabBar("miscconfig") then
        if imgui.BeginTabItem("Menus##miscconfig") then

            mod.config.misc.menus.customwiplevels = helpers.InputBool("Custom WIP Levels Tab", mod.config.misc.menus.customwiplevels)
            mod.config.misc.menus.nodiscord = helpers.InputBool("Remove Discord Tab", mod.config.misc.menus.nodiscord)

            imgui.EndTabItem()
        end

        if imgui.BeginTabItem("Game Mechanics##miscconfig") then
            imgui.EndTabItem()
        end

        imgui.EndTabBar()
    end

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.TreePop()
end