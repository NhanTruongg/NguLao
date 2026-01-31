-- ===== MANUAL KEY SAVE SYSTEM =====

local keyFile = "AkenaHub_SavedKey.txt"

local savedKey = nil

local keyValid = false



-- Check if key is already saved

if isfile(keyFile) then

    savedKey = readfile(keyFile)

    if savedKey == "concac" then

        keyValid = true

    end

end



-- If no valid saved key, show notification

if not keyValid then

    game:GetService("StarterGui"):SetCore("SendNotification", {

        Title = "Akeno Hub - Get Key";

        Text = "Link copied to clipboard!";

        Duration = 5;

    })

    setclipboard("https://link-hub.net/3050161/ymHiXgeMkYTv")

end



wait(1)



local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()



-- ===== KEY SYSTEM =====

local Window = Rayfield:CreateWindow({

   Name = "Akeno Hub",

   LoadingTitle = "Akeno Hub Key System",

   LoadingSubtitle = "by Akeno",

   KeySystem = not keyValid, -- Only show key system if key not valid

   KeySettings = {

      Title = "Akeno Hub",

      Subtitle = "Key link copied to clipboard!",

      Note = "Paste the link in your browser to get the key",

      FileName = "AkenaHub_Key",

      SaveKey = false, -- We handle saving manually

      GrabKeyFromSite = false,

      Key = {"concac"}

   },

   ConfigurationSaving = {

      Enabled = false,

      FolderName = nil,

      FileName = "AkenaHub"

   },

})



-- Save the key manually after window creation (key was entered correctly)

if not keyValid then

    writefile(keyFile, "concac")

end



-- ===== CUSTOM AUTO-LOAD CONFIGURATION =====

local savedConfig = nil

local configLoaded = false



local function LoadSavedConfig()

    local success, config = pcall(function()

        return game:GetService("HttpService"):JSONDecode(readfile("AkenaHub_Config.json"))

    end)

    

    if success and config then

        savedConfig = config

        configLoaded = true

        print("✓ Configuration loaded from file")

    else

        print("No saved configuration found, using defaults")

    end

end



-- Load config BEFORE creating tabs

LoadSavedConfig()



-- ===== UNIT MATCHING SYSTEM =====

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer



wait(2)



local UnitInventory = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("UnitInventory")

local UnitsListFrame = UnitInventory.Inventory.Content.Units.UnitsListFrame.List



local UnitIDToName = {}

local EffectToUnitMatches = {}

local UsedPositions = {}



local function GetUnitMappings()

    for _, child in pairs(UnitsListFrame:GetChildren()) do

        local success, nameLabel = pcall(function()

            return child.Frame.UnitFrame.Content.NameLabel

        end)

        

        if success and nameLabel and nameLabel.Text ~= "" then

            local unitID = child.Name

            local unitName = nameLabel.Text

            UnitIDToName[unitID] = unitName

        end

    end

end



GetUnitMappings()



local function ExtractCharacterName(effectName)

    local cleaned = effectName:gsub("_EVO_", "_"):gsub("_EVO", "")

    local underscorePos = cleaned:find("_")

    if underscorePos then

        return cleaned:sub(1, underscorePos - 1)

    end

    return cleaned

end



local function CleanUnitName(unitName)

    local cleaned = unitName:gsub("%s*%(.-%)", "")

    return cleaned:match("^%s*(.-)%s*$")

end



local function StringsMatch(str1, str2)

    if not str1 or not str2 or str1 == "" or str2 == "" then return false end

    str1 = str1:lower()

    str2 = str2:lower()

    if #str1 < 2 or #str2 < 2 then return false end

    return str1:sub(1, 2) == str2:sub(1, 2)

end



local function ScanEffects()

    local Effects = workspace:FindFirstChild("Effects")

    if not Effects then return end

    

    local newMatches = {}

    for _, child in pairs(Effects:GetChildren()) do

        local descendants = child:GetDescendants()

        if #descendants > 0 then

            local fullEffectName = child.Name

            local characterName = ExtractCharacterName(fullEffectName)

            

            for unitID, unitName in pairs(UnitIDToName) do

                local cleanedUnitName = CleanUnitName(unitName)

                if StringsMatch(characterName, cleanedUnitName) then

                    newMatches[fullEffectName] = {

                        EffectName = fullEffectName,

                        CharacterName = characterName,

                        UnitName = unitName,

                        UnitID = unitID

                    }

                    break

                end

            end

        end

    end

    EffectToUnitMatches = newMatches

end



task.spawn(function()

    while true do

        ScanEffects()

        task.wait(5)

    end

end)



ScanEffects()



-- ===== WAVE DETECTION FUNCTION (SHARED) =====

local currentWave = 0



local function GetCurrentWave()

    local success, waveText = pcall(function()

        return LocalPlayer.PlayerGui.GameHUD.WaveFrame.WaveInfo.Waves.CurrentWave.Text

    end)

    

    if success and waveText then

        local waveNumber = tonumber(waveText:match("%d+"))

        return waveNumber or 0

    end

    

    return 0

end



-- Update current wave every 5 seconds

task.spawn(function()

    while true do

        currentWave = GetCurrentWave()

        task.wait(5)

    end

end)



-- ===== SETTINGS TAB =====

local SettingsTab = Window:CreateTab("Settings", 4483362458)



local GetKeyLinkButton = SettingsTab:CreateButton({

   Name = "Copy Key Link",

   Callback = function()

      setclipboard("https://link-hub.net/3050161/ymHiXgeMkYTv")

      

      Rayfield:Notify({

         Title = "Key Link",

         Content = "Link copied to clipboard!",

         Duration = 3,

         Image = "copy",

      })

   end,

})



local SaveConfigButton = SettingsTab:CreateButton({

   Name = "Save Configuration",

   Callback = function()

      local config = {

         selectedMap = selectedMap,

         selectedMode = selectedMode,

         selectedAct = selectedAct,

         selectedDifficulty = selectedDifficulty,

         autoJoinEnabled = autoJoinEnabled,

         autoRetryEnabled = autoRetryEnabled,

         autoLobbyEnabled = autoLobbyEnabled,

         autoPlaceEnabled = autoPlaceEnabled,

         autoStartEnabled = autoStartEnabled,

         autoUpgradeEnabled = autoUpgradeEnabled,

         selectedUnitsToUpgrade = selectedUnitsToUpgrade,

         startWave = startWave

      }

      

      local success = pcall(function()

         writefile("AkenaHub_Config.json", game:GetService("HttpService"):JSONEncode(config))

      end)

      

      if success then

         Rayfield:Notify({

            Title = "Settings",

            Content = "Configuration saved successfully!",

            Duration = 3,

            Image = "check",

         })

      else

         Rayfield:Notify({

            Title = "Settings",

            Content = "Failed to save configuration",

            Duration = 3,

            Image = "x",

         })

      end

   end,

})



local LoadConfigButton = SettingsTab:CreateButton({

   Name = "Load Configuration",

   Callback = function()

      local success, config = pcall(function()

         return game:GetService("HttpService"):JSONDecode(readfile("AkenaHub_Config.json"))

      end)

      

      if success and config then

         if config.selectedMap then

            selectedMap = config.selectedMap

            MapDropdown:Set({config.selectedMap})

         end

         if config.selectedMode then

            selectedMode = config.selectedMode

            ModeDropdown:Set({config.selectedMode})

         end

         if config.selectedAct then

            selectedAct = config.selectedAct

            ActDropdown:Set({config.selectedAct})

         end

         if config.selectedDifficulty then

            selectedDifficulty = config.selectedDifficulty

            DifficultyDropdown:Set({config.selectedDifficulty})

         end

         

         if config.autoJoinEnabled then

            AutoJoinToggle:Set(true)

         end

         

         if config.autoRetryEnabled then

            AutoRetryToggle:Set(true)

         end

         if config.autoLobbyEnabled then

            AutoLobbyToggle:Set(true)

         end

         if config.autoPlaceEnabled then

            AutoPlaceToggle:Set(true)

         end

         if config.autoStartEnabled then

            AutoStartToggle:Set(true)

         end

         

         if config.startWave then

            startWave = config.startWave

            StartWaveInput:Set(tostring(config.startWave))

         end

         if config.selectedUnitsToUpgrade then

            selectedUnitsToUpgrade = config.selectedUnitsToUpgrade

            UnitsUpgradeDropdown:Set(config.selectedUnitsToUpgrade)

         end

         if config.autoUpgradeEnabled then

            AutoUpgradeToggle:Set(true)

         end

         

         Rayfield:Notify({

            Title = "Settings",

            Content = "Configuration loaded successfully!",

            Duration = 3,

            Image = "check",

         })

      else

         Rayfield:Notify({

            Title = "Settings",

            Content = "No saved configuration found",

            Duration = 3,

            Image = "x",

         })

      end

   end,

})



-- ===== AUTO JOIN TAB =====

local Tab = Window:CreateTab("Auto Join", 4483362458)



selectedMap = (savedConfig and savedConfig.selectedMap) or "Hueco_Mundo"

selectedMode = (savedConfig and savedConfig.selectedMode) or "Legend"

selectedAct = (savedConfig and savedConfig.selectedAct) or "3"

selectedDifficulty = (savedConfig and savedConfig.selectedDifficulty) or "Normal"

autoJoinEnabled = false



MapDropdown = Tab:CreateDropdown({

   Name = "Select Map",

   Options = {"Leaf_Village", "Namek", "Hueco_Mundo"},

   CurrentOption = {selectedMap},

   MultipleOptions = false,

   Flag = "MapDropdown",

   Callback = function(Option)

      selectedMap = Option[1]

   end,

})



ModeDropdown = Tab:CreateDropdown({

   Name = "Select Mode",

   Options = {"Legend", "Story"},

   CurrentOption = {selectedMode},

   MultipleOptions = false,

   Flag = "ModeDropdown",

   Callback = function(Option)

      selectedMode = Option[1]

   end,

})



ActDropdown = Tab:CreateDropdown({

   Name = "Select Act",

   Options = {"1", "2", "3", "4", "5", "6", "Infinite"},

   CurrentOption = {selectedAct},

   MultipleOptions = false,

   Flag = "ActDropdown",

   Callback = function(Option)

      selectedAct = Option[1]

   end,

})



DifficultyDropdown = Tab:CreateDropdown({

   Name = "Select Difficulty",

   Options = {"Normal", "Nightmare"},

   CurrentOption = {selectedDifficulty},

   MultipleOptions = false,

   Flag = "DifficultyDropdown",

   Callback = function(Option)

      selectedDifficulty = Option[1]

   end,

})



local AutoJoinToggle = Tab:CreateToggle({

   Name = "Auto Join",

   CurrentValue = false,

   Flag = "AutoJoinToggle1",

   Callback = function(Value)

      autoJoinEnabled = Value

      

      if Value then

         local args = {

            "Create",

            selectedMap,

            selectedMode,

            selectedAct,

            false,

            selectedDifficulty

         }

         game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Pod"):FireServer(unpack(args))

         

         Rayfield:Notify({

            Title = "Auto Join",

            Content = "Creating " .. selectedMap .. " - " .. selectedMode .. " Act " .. selectedAct .. " (" .. selectedDifficulty .. ")",

            Duration = 3,

            Image = "check",

         })

         

         task.wait(3)

         

         if autoJoinEnabled then

            local startArgs = {

               "Start"

            }

            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Pod"):FireServer(unpack(startArgs))

            

            Rayfield:Notify({

               Title = "Auto Join",

               Content = "Starting mission...",

               Duration = 2,

               Image = "play",

            })

         end

      end

   end,

})



-- ===== AUTO PLAY TAB =====

local Tab2 = Window:CreateTab("Auto Play", 4483362458)



autoRetryEnabled = false

autoLobbyEnabled = false

autoPlaceEnabled = false

autoStartEnabled = false

local placementIndex = 0

local isPlacing = false



AutoRetryToggle = Tab2:CreateToggle({

   Name = "Auto Retry",

   CurrentValue = false,

   Flag = "AutoRetryToggle1",

   Callback = function(Value)

      autoRetryEnabled = Value

      

      if Value then

         Rayfield:Notify({

            Title = "Auto Retry",

            Content = "Auto Retry enabled - Fires every 5 seconds",

            Duration = 2,

            Image = "repeat",

         })

         

         task.spawn(function()

            while autoRetryEnabled do

               local args = {

                  "Replay"

               }

               game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StageEnd"):FireServer(unpack(args))

               task.wait(5)

            end

         end)

      else

         Rayfield:Notify({

            Title = "Auto Retry",

            Content = "Auto Retry disabled",

            Duration = 2,

            Image = "x",

         })

      end

   end,

})



AutoLobbyToggle = Tab2:CreateToggle({

   Name = "Auto Return to Lobby",

   CurrentValue = false,

   Flag = "AutoLobbyToggle1",

   Callback = function(Value)

      autoLobbyEnabled = Value

      

      if Value then

         Rayfield:Notify({

            Title = "Auto Lobby",

            Content = "Auto Return to Lobby enabled - Fires every 5 seconds",

            Duration = 2,

            Image = "home",

         })

         

         task.spawn(function()

            while autoLobbyEnabled do

               local args = {

                  "Lobby"

               }

               game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StageEnd"):FireServer(unpack(args))

               task.wait(5)

            end

         end)

      else

         Rayfield:Notify({

            Title = "Auto Lobby",

            Content = "Auto Return to Lobby disabled",

            Duration = 2,

            Image = "x",

         })

      end

   end,

})



local function GetNexusPosition()

    local success, nexusObject = pcall(function()

        return workspace.Map.NexusObjects.NexusObject

    end)

    

    if success and nexusObject then

        return nexusObject.Position

    end

    

    return nil

end



local function IsPositionUsed(pos)

    for _, usedPos in pairs(UsedPositions) do

        local distance = (Vector3.new(pos.X, pos.Y, pos.Z) - Vector3.new(usedPos.X, usedPos.Y, usedPos.Z)).Magnitude

        if distance < 1.5 then

            return true

        end

    end

    return false

end



local function GeneratePlacementPosition(nexusPos, index)

    local angle = (index * 5) % 360

    local distance = 10 + math.floor(index / 72)

    

    local radians = math.rad(angle)

    local x = nexusPos.X + (distance * math.cos(radians))

    local z = nexusPos.Z + (distance * math.sin(radians))

    local y = nexusPos.Y

    

    local newPos = {X = x, Y = y, Z = z}

    

    if IsPositionUsed(newPos) then

        return GeneratePlacementPosition(nexusPos, index + 1)

    end

    

    table.insert(UsedPositions, newPos)

    return newPos

end



local function PlaceUnit(unitID, position, rotation)

    local args = {

        "Place",

        unitID,

        vector.create(position.X, position.Y, position.Z),

        rotation or 0

    }

    

    pcall(function()

        LocalPlayer.Character:WaitForChild("CharacterHandler"):WaitForChild("Remotes"):WaitForChild("UnitAction"):FireServer(unpack(args))

    end)

end



AutoPlaceToggle = Tab2:CreateToggle({

   Name = "Auto Place Units",

   CurrentValue = false,

   Flag = "AutoPlaceToggle1",

   Callback = function(Value)

      autoPlaceEnabled = Value

      

      if Value then

         Rayfield:Notify({

            Title = "Auto Place",

            Content = "Auto Place enabled (waves 1-4)",

            Duration = 2,

            Image = "check",

         })

         

         task.spawn(function()

            while autoPlaceEnabled do

               if currentWave >= 1 and currentWave <= 4 then

                  isPlacing = true

                  

                  while autoPlaceEnabled and isPlacing and currentWave >= 1 and currentWave <= 4 do

                     local nexusPos = GetNexusPosition()

                     

                     if nexusPos then

                        for unitID, unitName in pairs(UnitIDToName) do

                           if not autoPlaceEnabled or currentWave >= 5 then

                              break

                           end

                           

                           placementIndex = placementIndex + 1

                           local position = GeneratePlacementPosition(nexusPos, placementIndex)

                           PlaceUnit(unitID, position, 0)

                           task.wait(0.1)

                        end

                     end

                     

                     task.wait(5)

                  end

                  

                  if currentWave >= 5 then

                     isPlacing = false

                  end

               end

               

               task.wait(5)

            end

         end)

      else

         isPlacing = false

         Rayfield:Notify({

            Title = "Auto Place",

            Content = "Auto Place disabled",

            Duration = 2,

            Image = "x",

         })

      end

   end,

})



AutoStartToggle = Tab2:CreateToggle({

   Name = "Auto Start",

   CurrentValue = false,

   Flag = "AutoStartToggle1",

   Callback = function(Value)

      autoStartEnabled = Value

      

      if Value then

         Rayfield:Notify({

            Title = "Auto Start",

            Content = "Auto Start enabled",

            Duration = 2,

            Image = "check",

         })

         

         task.spawn(function()

            while autoStartEnabled do

               local success = pcall(function()

                  local voteSkipFrame = LocalPlayer.PlayerGui.GameHUD.VoteSkipFrame

                  

                  if voteSkipFrame.Visible then

                     local button = voteSkipFrame.BTNs.Yes

                     local absolutePosition = button.AbsolutePosition

                     local absoluteSize = button.AbsoluteSize

                     

                     local centerX = absolutePosition.X + (absoluteSize.X / 2)

                     local centerY = absolutePosition.Y + (absoluteSize.Y / 2) + 50

                     

                     local VirtualInputManager = game:GetService("VirtualInputManager")

                     VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)

                     wait(0.05)

                     VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)

                  end

               end)

               

               task.wait(1)

            end

         end)

      else

         Rayfield:Notify({

            Title = "Auto Start",

            Content = "Auto Start disabled",

            Duration = 2,

            Image = "x",

         })

      end

   end,

})



-- ===== AUTO UPGRADE TAB =====

local Tab3 = Window:CreateTab("Auto Upgrade", 4483362458)



autoUpgradeEnabled = false

selectedUnitsToUpgrade = (savedConfig and savedConfig.selectedUnitsToUpgrade) or {}

startWave = (savedConfig and savedConfig.startWave) or 1



local function GetMatchedUnitNames()

    local matchedUnits = {}

    local addedUnits = {}

    

    for effectName, data in pairs(EffectToUnitMatches) do

        if not addedUnits[data.UnitName] then

            table.insert(matchedUnits, data.UnitName)

            addedUnits[data.UnitName] = true

        end

    end

    

    return matchedUnits

end



StartWaveInput = Tab3:CreateInput({

   Name = "Auto Upgrade from Wave",

   CurrentValue = tostring(startWave),

   PlaceholderText = "Enter wave number",

   RemoveTextAfterFocusLost = false,

   Flag = "StartWaveInput1",

   Callback = function(Text)

      local waveNum = tonumber(Text)

      if waveNum then

         startWave = waveNum

      end

   end,

})



UnitsUpgradeDropdown = Tab3:CreateDropdown({

   Name = "Select Units to Auto Upgrade",

   Options = GetMatchedUnitNames(),

   CurrentOption = selectedUnitsToUpgrade,

   MultipleOptions = true,

   Flag = "UnitsUpgradeDropdown1",

   Callback = function(Options)

      selectedUnitsToUpgrade = Options

   end,

})



local UnselectAllButton = Tab3:CreateButton({

   Name = "Unselect All Units",

   Callback = function()

      selectedUnitsToUpgrade = {}

      UnitsUpgradeDropdown:Set({})

      

      Rayfield:Notify({

         Title = "Auto Upgrade",

         Content = "All units unselected",

         Duration = 2,

         Image = "x",

      })

   end,

})



task.spawn(function()

    while true do

        task.wait(10)

        local currentMatches = GetMatchedUnitNames()

        

        local allOptions = {}

        local addedOptions = {}

        

        for _, unitName in pairs(currentMatches) do

            if not addedOptions[unitName] then

                table.insert(allOptions, unitName)

                addedOptions[unitName] = true

            end

        end

        

        for _, selectedUnit in pairs(selectedUnitsToUpgrade) do

            if not addedOptions[selectedUnit] then

                table.insert(allOptions, selectedUnit)

                addedOptions[selectedUnit] = true

            end

        end

        

        UnitsUpgradeDropdown:Refresh(allOptions)

    end

end)



local function UpgradeUnit(effectName)

    local Entities = workspace:FindFirstChild("Entities")

    if not Entities then return false end

    

    local unitEntity = Entities:FindFirstChild(effectName)

    if not unitEntity then return false end

    

    local args = {

        "Upgrade",

        unitEntity

    }

    

    local success = pcall(function()

        LocalPlayer.Character:WaitForChild("CharacterHandler"):WaitForChild("Remotes"):WaitForChild("UnitAction"):FireServer(unpack(args))

    end)

    

    return success

end



AutoUpgradeToggle = Tab3:CreateToggle({

   Name = "Auto Upgrade Selected Units",

   CurrentValue = false,

   Flag = "AutoUpgradeToggle1",

   Callback = function(Value)

      autoUpgradeEnabled = Value

      

      if Value then

         Rayfield:Notify({

            Title = "Auto Upgrade",

            Content = "Auto Upgrade enabled (starts at wave " .. startWave .. ")",

            Duration = 2,

            Image = "arrow-up",

         })

         

         task.spawn(function()

            while autoUpgradeEnabled do

               if currentWave >= startWave then

                  for _, selectedUnitName in pairs(selectedUnitsToUpgrade) do

                     for effectName, data in pairs(EffectToUnitMatches) do

                        if data.UnitName == selectedUnitName then

                           UpgradeUnit(effectName)

                           break

                        end

                     end

                  end

               end

               

               task.wait(1)

            end

         end)

      else

         Rayfield:Notify({

            Title = "Auto Upgrade",

            Content = "Auto Upgrade disabled",

            Duration = 2,

            Image = "x",

         })

      end

   end,

})



-- Manually trigger all saved toggles after UI loads

task.spawn(function()

    wait(0.5)

    

    if savedConfig then

        if savedConfig.autoJoinEnabled then

            AutoJoinToggle:Set(true)

        end

        if savedConfig.autoRetryEnabled then

            AutoRetryToggle:Set(true)

        end

        if savedConfig.autoLobbyEnabled then

            AutoLobbyToggle:Set(true)

        end

        if savedConfig.autoPlaceEnabled then

            AutoPlaceToggle:Set(true)

        end

        if savedConfig.autoStartEnabled then

            AutoStartToggle:Set(true)

        end

        if savedConfig.autoUpgradeEnabled then

            AutoUpgradeToggle:Set(true)

        end

    end

end)



-- Show notification if config was loaded

if configLoaded then

    Rayfield:Notify({

        Title = "Configuration",

        Content = "Settings loaded from save file!",

        Duration = 3,

        Image = "check",

    })

end 
