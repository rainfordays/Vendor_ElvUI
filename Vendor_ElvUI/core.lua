local R,G,B = GetItemQualityColor(0)
local Vendor_ElvUI = {}
Vendor_ElvUI.ElvUIHookTries = 0

local ElvUIBags = ElvUI[1]:GetModule("Bags")


local function UpdateContainerElvUI(bagID)
	local frame = _G['ElvUI_ContainerFrameBag' .. bagID]
	local name = frame:GetName()
	local size = frame.numSlots

	if not size then return end
	for slotID = 1, size do
		
		local button = _G[name .. 'Slot' .. slotID]
		local item = VendorAddonAPI:GetBagItemFromCache(bagID, slotID)

		local isJunk = item and item.Sell or false
		local icon = button.JunkItemIcon or Vendor_ElvUI:NewIcon(button)
		local glow = button.JunkItemGlow or Vendor_ElvUI:NewGlow(button)

		glow:SetShown(isJunk)
		icon:SetShown(isJunk)
	end
end

-- Update bags
local function UpdateAll()
  for i = 0, NUM_BAG_SLOTS do
		UpdateContainerElvUI(i)
  end
end




local function UpdateSlot(_, self, bagID, slotID)
	if not self.Bags[bagID] or not self.Bags[bagID][slotID] then
		return
	end

	local button = self.Bags[bagID][slotID]
	local item = VendorAddonAPI:GetBagItemFromCache(bagID, slotID)


	local isJunk = item and item.Sell or false
	local icon = button.JunkItemIcon or Vendor_ElvUI:NewIcon(button)
	local glow = button.JunkItemGlow or Vendor_ElvUI:NewGlow(button)

	button.JunkItemGlow:SetShown(isJunk and glow and Vendor_ElvUIDB.glow)
	button.JunkItemIcon:SetShown(isJunk and icon and Vendor_ElvUIDB.icon)
end






function Vendor_ElvUI:NewGlow(button)
	button.JunkItemGlow = button:CreateTexture(button:GetName().."JunkItemGlow", 'OVERLAY', nil, 3)
	button.JunkItemGlow:SetTexture('Interface/Buttons/UI-ActionButton-Border')
	button.JunkItemGlow:SetVertexColor(R,G,B, .7)
	button.JunkItemGlow:SetBlendMode('ADD')
	button.JunkItemGlow:SetAllPoints(button.ExtendedSlot)

	return button.JunkItemGlow
end

function Vendor_ElvUI:NewIcon(button)
	button.JunkItemIcon = button:CreateTexture(button:GetName().."JunkItemIcon", 'OVERLAY', nil, 3)
	button.JunkItemIcon:SetTexture('Interface/Buttons/UI-GroupLoot-Coin-Up')
	button.JunkItemIcon:SetPoint('TOPLEFT', 2, -2)
	button.JunkItemIcon:SetSize(15, 15)

	return button.JunkItemIcon
end



function Vendor_ElvUI:SlashCommand(msg)
	msg = string.lower(msg)

	if msg == "glow" then
		Vendor_ElvUIDB.glow = not Vendor_ElvUIDB.glow
	end

	if msg == "icon" then
		Vendor_ElvUIDB.icon = not Vendor_ElvUIDB.icon
	end

	UpdateAll()
end



-- Hooks
local function SetHooks()
	hooksecurefunc(ElvUIBags, "UpdateSlot", UpdateSlot)
	hooksecurefunc(VendorAddonAPI.Config, "NotifyChanges", UpdateAll)


	SLASH_AUTOMAILER1= "/vendorelvui"
  SlashCmdList.AUTOMAILER = function(msg)
    Vendor_ElvUI:SlashCommand(msg)
	end
	
	Vendor_ElvUIDB = Vendor_ElvUIDB or {}
	if Vendor_ElvUIDB.glow == nil then Vendor_ElvUIDB.glow = true end
	if Vendor_ElvUIDB.icon == nil then Vendor_ElvUIDB.icon = true end

	UpdateAll()
end
hooksecurefunc(ElvUIBags, "Initialize", SetHooks)
