sm = require('preload.sounds')
te = require('lib.tesound')

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

    mod.config.customsounds.music.halfTime = helpers.InputBool("Use BPM Half Time", mod.config.customsounds.music.halfTime)
    helpers.imguiHelpMarker("Uses the BPM's half time (vanilla default: true)")

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

    imgui.SetNextItemWidth(120)
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

                    mod.config.customsounds.music.halfTime = helpers.InputBool("Use BPM Half Time", mod.config.customsounds.music.halfTime)
                    helpers.imguiHelpMarker("Uses the BPM's half time (vanilla default: true)")

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

if imgui.TreeNode_Str("Hit Score Visualizer") then
    imgui.SetWindowFontScale(2)
    imgui.Text("Hit Score Visualizer")
    imgui.SetWindowFontScale(1)
    imgui.Text("Shows visuals when you hit, get a barely, or miss a note\nin the expanded HUD")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    mod.config.hsv.misses = helpers.InputBool("Show Misses", mod.config.hsv.misses)
    mod.config.hsv.barelies = helpers.InputBool("Show Barelies", mod.config.hsv.barelies)
    mod.config.hsv.hits = helpers.InputBool("Show Hits", mod.config.hsv.hits)
    mod.config.hsv.taps = helpers.InputBool("Show Tap Accuracy", mod.config.hsv.taps)
    helpers.imguiHelpMarker("Shows more detailed text for hits, such as \"early\" and \"late\"")

    imgui.NewLine()

    imgui.SetNextItemWidth(120)
    mod.config.hsv.missText = helpers.InputText("Miss Text", mod.config.hsv.missText)
    imgui.SetNextItemWidth(120)
    mod.config.hsv.barelyText = helpers.InputText("Barely Text", mod.config.hsv.barelyText)
    imgui.SetNextItemWidth(120)
    mod.config.hsv.hitText = helpers.InputText("Hit Text", mod.config.hsv.hitText)

    imgui.NewLine()

    local fontTypes = { "digitalDisco", "digitalDiscoBold", "main", "jfdot", "jfdot2", "ancient", "terminal", "terminalTall", "terminalTallFixedWidth", "terabyte", "small", "rsUI", "undocrash" }

    imgui.SetNextItemWidth(120)
	if imgui.BeginCombo("Font", mod.config.hsv.font) then
        for i, v in ipairs(fontTypes) do
            local isSelected = (v == mod.config.hsv.font)
            if imgui.Selectable_Bool(v, isSelected) then
                mod.config.hsv.font = v
            end
        end
        imgui.EndCombo()
    end

    helpers.imguiHelpMarker("The font the visualizer uses")

    local positionTypes = { "Above Cranky", "Under Combo", "At Object", "Above Cursor" }

    imgui.SetNextItemWidth(120)
	if imgui.BeginCombo("Position", mod.config.hsv.position) then
        for i, v in ipairs(positionTypes) do
            local isSelected = (v == mod.config.hsv.position)
            if imgui.Selectable_Bool(v, isSelected) then
                mod.config.hsv.position = v
            end
        end
        imgui.EndCombo()
    end

    helpers.imguiHelpMarker("Where the visualizer is displayed")

    imgui.NewLine()

    imgui.SetNextItemWidth(120)
    mod.config.hsv.size = helpers.InputFloat("Size", mod.config.hsv.size)
    helpers.imguiHelpMarker("The size of the visualizer text")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.SetNextItemWidth(120)
    mod.config.hsv.duration = helpers.InputInt("Animation Duration (ms)", mod.config.hsv.duration)
    helpers.imguiHelpMarker("How long the text shows in milliseconds")
    imgui.SetNextItemWidth(120)
    mod.config.hsv.animation.rotation = helpers.InputInt("Random Rotation", mod.config.hsv.animation.rotation)
    helpers.imguiHelpMarker("How much the text should rotate when falling")
    imgui.SetNextItemWidth(120)
    mod.config.hsv.animation.position = helpers.InputInt("Random X Position", mod.config.hsv.animation.position)
    helpers.imguiHelpMarker("How much the text should move when falling")
    imgui.SetNextItemWidth(120)
    mod.config.hsv.animation.gravity = helpers.InputInt("Gravity", mod.config.hsv.animation.gravity)
    helpers.imguiHelpMarker("Controlls the gravity of the falling text (can be negative lol)")
    imgui.SetNextItemWidth(120)
    mod.config.hsv.animation.initVel = helpers.InputInt("Initial Y Velocity", mod.config.hsv.animation.initVel)
    helpers.imguiHelpMarker("Allows for adding a \"jump\" effect or have it fly straight down")

    local easings = { "linear", "inSine", "outSine", "inOutSine", "inQuad", "outQuad", "inOutQuad", "inCubic", "outCubic", "inOutCubic", "inQuart", "outQuart", "inOutQuart", "inQuint", "outQuint", "inOutQuint", "inExpo", "outExpo", "inOutExpo", "inCirc", "outCirc", "inOutCirc", "inSquaredCirc", "outSquaredCirc", "inOutSquaredCirc", "inBack", "outBack", "inOutBack", "inElastic", "outElastic", "inOutElastic", "inBounce", "outBounce", "inOutBounce" }

    imgui.SetNextItemWidth(120)
	if imgui.BeginCombo("Easing", mod.config.hsv.animation.ease) then
        for i, v in ipairs(easings) do
            local isSelected = (v == mod.config.hsv.animation.ease)
            if imgui.Selectable_Bool(v, isSelected) then
                mod.config.hsv.animation.ease = v
            end
        end
        imgui.EndCombo()
    end

    imgui.NewLine()

    mod.config.hsv.taps = helpers.InputBool("Don't Fade", mod.config.hsv.taps)
    helpers.imguiHelpMarker("Removes the dithering effect from the animation")

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
    imgui.Text("Some random freatures without enough options for its own\ncategory")

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    if imgui.BeginTabBar("miscconfig") then
        if imgui.BeginTabItem("Editor##miscconfig") then
            mod.config.misc.editor.musicOnEditorScroll = helpers.InputBool("Music On Scroll", mod.config.misc.editor.musicOnEditorScroll)
            helpers.imguiHelpMarker("Plays .1 seconds of the song while scrolling in the editor, at the current beat")

            imgui.EndTabItem()
        end

        if imgui.BeginTabItem("Game Mechanics##miscconfig") then
            mod.config.misc.gameMechanics.eventExit = helpers.InputBool("Event Exit", mod.config.misc.gameMechanics.eventExit)
            helpers.imguiHelpMarker("Want to stop playing in event mode? Press ESC to exit!")


            mod.config.misc.gameMechanics.forceUI = helpers.InputBool("Force UI", mod.config.misc.gameMechanics.forceUI)
            helpers.imguiHelpMarker("Always force UI in a level to show")

            mod.config.misc.gameMechanics.staticUI = helpers.InputBool("Static UI", mod.config.misc.gameMechanics.staticUI)
            helpers.imguiHelpMarker("Keep UI elements in game fixed in one place")

            mod.config.misc.gameMechanics.noGlitchUI = helpers.InputBool("Don't glitch UI", mod.config.misc.gameMechanics.noGlitchUI)
            helpers.imguiHelpMarker("UI ignores glitch and sensor effects")

            imgui.EndTabItem()
        end

        if imgui.BeginTabItem("Menus##miscconfig") then

            mod.config.misc.menus.customwiplevels = helpers.InputBool("Custom WIP Levels Tab", mod.config.misc.menus.customwiplevels)
            
            mod.config.misc.menus.nodiscord = helpers.InputBool("Remove Discord Tab", mod.config.misc.menus.nodiscord)

            mod.config.misc.menus.forceOffSteamEdit = helpers.InputBool("Force Off Steam Editing", mod.config.misc.menus.forceOffSteamEdit)
            helpers.imguiHelpMarker("Removes the \"Edit\" option under Steam Workshop charts (does nothing without notnotrelease)")

            imgui.EndTabItem()
        end

        imgui.EndTabBar()
    end

    imgui.NewLine()
    imgui.Separator()
    imgui.NewLine()

    imgui.TreePop()
end