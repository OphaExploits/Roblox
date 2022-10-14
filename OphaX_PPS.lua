--// PLAYER INFOS
local __player = game.Players.LocalPlayer;
local __actualInventorySize = __player.Leaderstats.NumberOfPets.Value;
local __maxInventorySize = __player.Leaderstats.MaxInventory.Value;
local __normalCoins = __player.Leaderstats.Coins.Value;
local __seaCoins = __player.Leaderstats["Sea Coins"].Value;
local __foodCoins = __player.Leaderstats["Food Coins"].Value;
local __eventCoins = __player.Leaderstats["Event Coins"].Value;
local __megaCoins = __player.Leaderstats.MegaCoin.Value;
local __actualLevel = __player.Leaderstats.Level.Value;
local __maxLevel = __player.Leaderstats.MaxLevel.Value;
local __currentWorld = __player.Leaderstats.currentWorld.Value;

--// HELPERS
function activateButton(button)
    local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
    for i,v in pairs(events) do
        for i,v in pairs(getconnections(button[v])) do
            v:Fire();
        end
    end
end

function updatePlayerInfos(__coins, __inventorySize, __level)
    if (__inventorySize) then
        __actualInventorySize = __player.Leaderstats.NumberOfPets.Value;
        __maxInventorySize = __player.Leaderstats.MaxInventory.Value;
    end
    if (__coins) then
        __normalCoins = __player.Leaderstats.Coins.Value;
        __seaCoins = __player.Leaderstats["Sea Coins"].Value;
        __foodCoins = __player.Leaderstats["Food Coins"].Value;
        __eventCoins = __player.Leaderstats["Event Coins"].Value;
    end
    if (__level) then
        __actualLevel = __player.Leaderstats.Level.Value;
        __maxLevel = __player.Leaderstats.MaxLevel.Value;
    end
end

function teleportPlayerTo(placeCFrame)
	if __player.Character then
		__player.Character.HumanoidRootPart.CFrame = placeCFrame;
	end
end

--// AUTO HATCH
local __autoHatchEnabled = false;
local __tripleEgg = false;
local __actualEgg = "Starter Camp Egg";
local __hatchSellList = {};

function hatchSell()
	if (__autoHatchEnabled) then
		for actualIndex = 1, #__hatchSellList do
			__player.PlayerGui.Merchant.Frame.Top.Search.Query.Text = __hatchSellList[actualIndex];

			local button = __player.PlayerGui.Merchant.Frame.Top.SelectSearched;
            activateButton(button);
		end
		local args = {
			[1] = game:GetService("Players").LocalPlayer.PlayerGui
		}
		workspace.__THINGS.__REMOTES.confirmSellPetToMerchant:InvokeServer(unpack(args));
		task.spawn(hatchOpen);
	end
end

function hatchOpen()
	if (__autoHatchEnabled) then
		local args;
		if (__tripleEgg) then
			args = {
				[1] = __actualEgg,
				[2] = "tripleEgg"
			}
		else 
			args = {
				[1] = __actualEgg
			}
		end
		workspace.__THINGS.__REMOTES.buyEgg:InvokeServer(unpack(args));
        updatePlayerInfos(false, true, false);
		if (__maxInventorySize - __actualInventorySize > 2) then
			wait(.5);
			hatchOpen();
		else
			hatchSell();
		end
	end
end

--// AUTO SELLER
local __sellerList = {};

function sellPets()
	game.Players.LocalPlayer.PlayerGui.Merchant.Enabled = true;

	for actualIndex = 1, #__sellerList do
		game.Players.LocalPlayer.PlayerGui.Merchant.Frame.Top.Search.Query.Text = __sellerList[actualIndex];

		local button = game.Players.LocalPlayer.PlayerGui.Merchant.Frame.Top.SelectSearched;
		local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
		for i,v in pairs(events) do
			for i,v in pairs(getconnections(button[v])) do
				v:Fire();
			end
		end
	end

	local args = {
		[1] = game:GetService("Players").LocalPlayer.PlayerGui
	}
	workspace.__THINGS.__REMOTES.confirmSellPetToMerchant:InvokeServer(unpack(args));

	game.Players.LocalPlayer.PlayerGui.Merchant.Enabled = false;
end

--// AUTO COLLECTOR
local __autoCollectorEnabled = false;

function collectDrops()
	for i, v in pairs(game:GetService("Workspace").__THINGS.MysteryBlocks:GetChildren()) do
		if (__autoCollectorEnabled) then
			teleportPlayerTo(v.CFrame)
			wait(.15);
		end
	end
end



--// GUI ----------------------------------------------------------------------------------------

--// INFO
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))();
local Window = OrionLib:MakeWindow({Name = "OphaX - PPS Script", HidePremium = true, IntroEnabled = true, IntroText = "Welcome to OphaX - PPS!", SaveConfig = true, ConfigFolder = "OphaXConfig"})

--// TABS
local __farmTab = Window:MakeTab({
	Name = "Auto Farmer",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local __hatchTab = Window:MakeTab({
	Name = "Egg Hatcher",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local __sellingTab = Window:MakeTab({
	Name = "Auto Seller",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local __collectorTab = Window:MakeTab({
	Name = "Auto Collector",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local __miscellaneousTab = Window:MakeTab({
	Name = "Miscellaneous",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

--// AUTO HATCHER TAB
local __hatcherSwitchSection = __hatchTab:AddSection({
	Name = "Switcher"
})
__hatcherSwitchSection:AddToggle({
	Name = "Auto Hatch Eggs",
	Default = false,
	Callback = function(Value)
        __autoHatchEnabled = Value;
		if Value then
            hatchOpen();
		end
	end
})

local __hatcherListSection = __hatchTab:AddSection({
	Name = "Pets to Sell"
})
local __sellDropdown1 = __hatcherListSection:AddDropdown({
	Name = "Pet 1:",
	Default = "--",
	Options = {"--"},
	Callback = function(Value)
        if (Value ~= "--" or Value ~= nil or Value ~= "") then
            __hatchSellList[1] = Value;

        else
            __hatchSellList[1] = "";
        end
	end    
})
local __sellDropdown2 = __hatcherListSection:AddDropdown({
	Name = "Pet 2:",
	Default = "--",
	Options = {"--"},
	Callback = function(Value)
        if (Value ~= "--" or Value ~= nil or Value ~= "") then
            __hatchSellList[2] = Value;

        else
            __hatchSellList[2] = "";
        end
	end    
})
local __sellDropdown3 = __hatcherListSection:AddDropdown({
	Name = "Pet 3:",
	Default = "--",
	Options = {"--"},
	Callback = function(Value)
        if (Value ~= "--" or Value ~= nil or Value ~= "") then
            __hatchSellList[3] = Value;

        else
            __hatchSellList[3] = "";
        end
	end    
})
local __sellDropdown4 = __hatcherListSection:AddDropdown({
	Name = "Pet 4:",
	Default = "--",
	Options = {"--"},
	Callback = function(Value)
        if (Value ~= "--" or Value ~= nil or Value ~= "") then
            __hatchSellList[4] = Value;

        else
            __hatchSellList[4] = "";
        end
	end    
})
local __sellDropdown5 = __hatcherListSection:AddDropdown({
	Name = "Pet 5:",
	Default = "--",
	Options = {"--"},
	Callback = function(Value)
        if (Value ~= "--" or Value ~= nil or Value ~= "") then
            __hatchSellList[5] = Value;

        else
            __hatchSellList[5] = "";
        end
	end    
})
local __sellDropdown6 = __hatcherListSection:AddDropdown({
	Name = "Pet 6:",
	Default = "--",
	Options = {"--"},
	Callback = function(Value)
        if (Value ~= "--" or Value ~= nil or Value ~= "") then
            __hatchSellList[6] = Value;

        else
            __hatchSellList[6] = "";
        end
	end    
})
function adjustSellDropdowns()
    if (__actualEgg == "Starter Camp Egg") then
        __sellDropdown1:Refresh({"--", "Cat"},true);
        __sellDropdown2:Refresh({"--", "Dog"},true);
        __sellDropdown3:Refresh({"--", "Cow"},true);
        __sellDropdown4:Refresh({"--", "Pig"},true);
        __sellDropdown5:Refresh({"--", "Chicken"},true);
        __sellDropdown6:Refresh({"--", "Friendly Spirit"},true);
        __sellDropdown1:Set("Cat");
        __sellDropdown2:Set("Dog");
        __sellDropdown3:Set("Cow");
        __sellDropdown4:Set("Pig");
        __sellDropdown5:Set("Chicken");
        __sellDropdown6:Set("Friendly Spirit");
    elseif (__actualEgg == "Meadow Egg") then
        __sellDropdown1:Refresh({"--", "Rat"},true);
        __sellDropdown2:Refresh({"--", "Bunny"},true);
        __sellDropdown3:Refresh({"--", "Goat"},true);
        __sellDropdown4:Refresh({"--", "Lamb"},true);
        __sellDropdown5:Refresh({"--", "Owl"},true);
        __sellDropdown6:Refresh({"--", "Meadow Spirit"},true);
        __sellDropdown1:Set("Rat");
        __sellDropdown2:Set("Bunny");
        __sellDropdown3:Set("Goat");
        __sellDropdown4:Set("Lamb");
        __sellDropdown5:Set("Owl");
        __sellDropdown6:Set("Meadow Spirit");
    elseif (__actualEgg == "Mountain Falls Egg") then
        __sellDropdown1:Refresh({"--", "Komodo Dragon"},true);
        __sellDropdown2:Refresh({"--", "Rhinoceros"},true);
        __sellDropdown3:Refresh({"--", "Tiger"},true);
        __sellDropdown4:Refresh({"--", "Koala"},true);
        __sellDropdown5:Refresh({"--", "Orangutangus"},true);
        __sellDropdown6:Refresh({"--", "Mist Spirit"},true);
        __sellDropdown1:Set("Komodo Dragon");
        __sellDropdown2:Set("Rhinoceros");
        __sellDropdown3:Set("Tiger");
        __sellDropdown4:Set("Koala");
        __sellDropdown5:Set("Orangutan");
        __sellDropdown6:Set("Mist Spirit");
    elseif (__actualEgg == "Snow Town Egg") then
        __sellDropdown1:Refresh({"--", "Arctic Hare"},true);
        __sellDropdown2:Refresh({"--", "Polar Bear"},true);
        __sellDropdown3:Refresh({"--", "Penguin"},true);
        __sellDropdown4:Refresh({"--", "Seal"},true);
        __sellDropdown5:Refresh({"--", "Musk Ox"},true);
        __sellDropdown6:Refresh({"--", "??? Spirit"},true);
        __sellDropdown1:Set("Arctic Hare");
        __sellDropdown2:Set("Polar Bear");
        __sellDropdown3:Set("Penguin");
        __sellDropdown4:Set("Seal");
        __sellDropdown5:Set("Musk Ox");
        __sellDropdown6:Set("??? Spirit");
    elseif (__actualEgg == "Bone Desert Egg") then
        __sellDropdown1:Refresh({"--", "Desert Fox"},true);
        __sellDropdown2:Refresh({"--", "Lizard"},true);
        __sellDropdown3:Refresh({"--", "Snake"},true);
        __sellDropdown4:Refresh({"--", "Winter Snake"},true);
        __sellDropdown5:Refresh({"--", "Summer Snake"},true);
        __sellDropdown6:Refresh({"--", "??? Spirit"},true);
        __sellDropdown1:Set("Desert Fox");
        __sellDropdown2:Set("Lizard");
        __sellDropdown3:Set("Snake");
        __sellDropdown4:Set("Winter Snake");
        __sellDropdown5:Set("Summer Snake");
        __sellDropdown6:Set("??? Spirit");
    elseif (__actualEgg == "Lava Land Egg") then
        __sellDropdown1:Refresh({"--", "Night Dragon"},true);
        __sellDropdown2:Refresh({"--", "Fire Cat"},true);
        __sellDropdown3:Refresh({"--", "Dragon"},true);
        __sellDropdown4:Refresh({"--", "Fire Dog"},true);
        __sellDropdown5:Refresh({"--", "Firecorn"},true);
        __sellDropdown6:Refresh({"--", "??? Spirit"},true);
        __sellDropdown1:Set("Night Dragon");
        __sellDropdown2:Set("Fire Cat");
        __sellDropdown3:Set("Dragon");
        __sellDropdown4:Set("Fire Dog");
        __sellDropdown5:Set("Firecorn");
        __sellDropdown6:Set("??? Spirit");
    elseif (__actualEgg == "Mystical Valley Egg") then
        __sellDropdown1:Refresh({"--", "Crystal Dog"},true);
        __sellDropdown2:Refresh({"--", "Crystal Cat"},true);
        __sellDropdown3:Refresh({"--", "Crystal Dragon"},true);
        __sellDropdown4:Refresh({"--", "Crystalcorn"},true);
        __sellDropdown5:Refresh({"--", "Cerberus"},true);
        __sellDropdown6:Refresh({"--", "??? Spirit"},true);
        __sellDropdown1:Set("Crystal Dog");
        __sellDropdown2:Set("Crystal Cat");
        __sellDropdown3:Set("Crystal Dragon");
        __sellDropdown4:Set("Crystalcorn");
        __sellDropdown5:Set("Cerberus");
        __sellDropdown6:Set("??? Spirit");
    elseif (__actualEgg == "Golden Castle Egg") then
        __sellDropdown1:Refresh({"--", "Golden Dog"},true);
        __sellDropdown2:Refresh({"--", "Golden Cat"},true);
        __sellDropdown3:Refresh({"--", "Golden Monkey"},true);
        __sellDropdown4:Refresh({"--", "Golden Koala"},true);
        __sellDropdown5:Refresh({"--", "Golden Tiger"},true);
        __sellDropdown6:Refresh({"--", "Golden Owl"},true);
        __sellDropdown1:Set("Golden Dog");
        __sellDropdown2:Set("Golden Cat");
        __sellDropdown3:Set("Golden Monkey");
        __sellDropdown4:Set("Golden Koala");
        __sellDropdown5:Set("Golden Tiger");
        __sellDropdown6:Set("Golden Owl");
    elseif (__actualEgg == "Sea Town Egg") then
        __sellDropdown1:Refresh({"--", "Sea Urchin"},true);
        __sellDropdown2:Refresh({"--", "Goldfish"},true);
        __sellDropdown3:Refresh({"--", "Redfish"},true);
        __sellDropdown4:Refresh({"--", "Silver Swordfish"},true);
        __sellDropdown5:Refresh({"--", "Swordfish"},true);
        __sellDropdown6:Refresh({"--", "??? Spirit"},true);
        __sellDropdown1:Set("Sea Urchin");
        __sellDropdown2:Set("Goldfish");
        __sellDropdown3:Set("Redfish");
        __sellDropdown4:Set("Silver Swordfish");
        __sellDropdown5:Set("Swordfish");
        __sellDropdown6:Set("??? Spirit");
    elseif (__actualEgg == "Tiki Land Egg") then
        __sellDropdown1:Refresh({"--", "Tiki Cat"},true);
        __sellDropdown2:Refresh({"--", "Tiki Dog"},true);
        __sellDropdown3:Refresh({"--", "Tiki Monkey"},true);
        __sellDropdown4:Refresh({"--", "Tikicorn"},true);
        __sellDropdown5:Refresh({"--", "Tiki Dragon"},true);
        __sellDropdown6:Refresh({"--", "??? Spirit"},true);
        __sellDropdown1:Set("Tiki Cat");
        __sellDropdown2:Set("Tiki Dog");
        __sellDropdown3:Set("Tiki Monkey");
        __sellDropdown4:Set("Tikicorn");
        __sellDropdown5:Set("Tiki Dragon");
        __sellDropdown6:Set("??? Spirit");
    elseif (__actualEgg == "Tropical Island Egg") then
        __sellDropdown1:Refresh({"--", "Toucan"},true);
        __sellDropdown2:Refresh({"--", "Turtle"},true);
        __sellDropdown3:Refresh({"--", "Jellyfish"},true);
        __sellDropdown4:Refresh({"--", "Hammerhead"},true);
        __sellDropdown5:Refresh({"--", "Shark"},true);
        __sellDropdown6:Refresh({"--", "??? Spirit"},true);
        __sellDropdown1:Set("Toucan");
        __sellDropdown2:Set("Turtle");
        __sellDropdown3:Set("Jellyfish");
        __sellDropdown4:Set("Hammerhead");
        __sellDropdown5:Set("Shark");
        __sellDropdown6:Set("Huge Tropical Spirit");
    elseif (__actualEgg == "Splash Zone Egg") then
        __sellDropdown1:Refresh({"--", "Splash Cat"},true);
        __sellDropdown2:Refresh({"--", "Lifeguard Shark"},true);
        __sellDropdown3:Refresh({"--", "Gull"},true);
        __sellDropdown4:Refresh({"--", "Otter"},true);
        __sellDropdown5:Refresh({"--", "Splash Penguin"},true);
        __sellDropdown6:Refresh({"--", "Huge Otter"},true);
        __sellDropdown1:Set("Splash Cat");
        __sellDropdown2:Set("Lifeguard Shark");
        __sellDropdown3:Set("Gull");
        __sellDropdown4:Set("Otter");
        __sellDropdown5:Set("Splash Penguin");
        __sellDropdown6:Set("Huge Otter");
    elseif (__actualEgg == "Ocean Egg") then
        __sellDropdown1:Refresh({"--", "Narwhal"},true);
        __sellDropdown2:Refresh({"--", "Walrus"},true);
        __sellDropdown3:Refresh({"--", "Beluga"},true);
        __sellDropdown4:Refresh({"--", "Pilot Whale"},true);
        __sellDropdown5:Refresh({"--", "Huge Orca"},true);
        __sellDropdown6:Refresh({"--"},true);
        __sellDropdown1:Set("Narwhal");
        __sellDropdown2:Set("Walrus");
        __sellDropdown3:Set("Beluga");
        __sellDropdown4:Set("Pilot Whale");
        __sellDropdown5:Set("Huge Orca");
        __sellDropdown6:Set("--");
    elseif (__actualEgg == "Deep Sea Egg") then
        __sellDropdown1:Refresh({"--", "Octopus"},true);
        __sellDropdown2:Refresh({"--", "Giant Squid"},true);
        __sellDropdown3:Refresh({"--", "Giant Isopod"},true);
        __sellDropdown4:Refresh({"--", "Fangtooth"},true);
        __sellDropdown5:Refresh({"--", "Huge Anglerfish"},true);
        __sellDropdown6:Refresh({"--"},true);
        __sellDropdown1:Set("Octopus");
        __sellDropdown2:Set("Giant Squid");
        __sellDropdown3:Set("Giant Isopod");
        __sellDropdown4:Set("Fangtooth");
        __sellDropdown5:Set("Huge Anglerfish");
        __sellDropdown6:Set("--");
    end
end

local __hatcherGeneralSection = __hatchTab:AddSection({
	Name = "General Configurations"
})
__hatcherGeneralSection:AddDropdown({
	Name = "Opening Mode",
	Default = "Single Egg",
	Save = true,
	Options = {"Single Egg", "Triple Egg"},
	Callback = function(Value)
        __tripleEgg = Value;
	end 
})
__hatcherGeneralSection:AddDropdown({
	Name = "Egg",
	Default = "Starter Camp Egg",
	Save = true,
	Options = {
		"Starter Camp Egg",
		"Meadow Egg",
		"Mountain Falls Egg",
		"Snow Town Egg",
		"Bone Desert Egg",
		"Lava Land Egg",
		"Mystical Valley Egg",
		"Golden Castle Egg",
		"Sea Town Egg",
		"Tiki Land Egg",
		"Tropical Island Egg", 
		"Splash Zone Egg",
		"Ocean Egg",
		"Deep Sea Egg",
		"Supermarket Egg",
		"Fruit Egg",
		"Land Of Chocolates Egg",
		"Candy Land Egg",
		"Dessert Valley Egg",
		"Spooky Treats Egg",
		"Sinister Sweets Egg"
		},
	Callback = function(Value)
		__actualEgg = Value;
        adjustSellDropdowns();
	end    
})

--// AUTO SELLER TAB

__sellingTab:AddToggle({
	Name = "Sell Pets",
	Default = false,
	Callback = function(Value)
		if Value then
			sellPets();
		end
	end
})

__sellingTab:AddTextbox({
	Name = "Pet List:",
	Default = "",
	Save = true,
	TextDisappear = false,
	Callback = function(Value)
		__sellerList = {}
		for w in Value:gmatch("([^,]+)") do
			table.insert(__sellerList, w);
		end
	end	  
})

--// AUTO COLLECTOR TAB

__collectorTab:AddToggle({
	Name = "Auto Collect Drops",
	Default = false,
	Callback = function(Value)
		canCollect = Value;
		if Value then
			collectDrops();
		end
	end
})
