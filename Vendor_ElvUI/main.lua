local R,G,B = GetItemQualityColor(0)
local Vendor_ElvUI = {}

local ElvUIBags = ElvUI[1]:GetModule("Bags")
--local Vendor = VendorAddonAPI
local NUM_BAG_SLOTS = NUM_BAG_SLOTS


local function UpdateBag(bagID)
	local frame = _G['ElvUI_ContainerFrameBag' .. bagID]
	local name = frame:GetName()
	local size = tonumber(frame.numSlots)

	if not size then return end

	for i = 1, size do
		local slotID = i
		local button = _G[name .. 'Slot' .. slotID]

		local result = Vendor.EvaluateItem(bagID, slotID)

		local isJunk = result == 1
		local icon = button.JunkItemIcon or Vendor_ElvUI:NewIcon(button)
		local glow = button.JunkItemGlow or Vendor_ElvUI:NewGlow(button)

		glow:SetShown(isJunk and glow and Vendor_ElvUIDB.glow)
		icon:SetShown(isJunk and icon and Vendor_ElvUIDB.icon)
	end
end

-- Update bags
local function UpdateAll()
	--Vendor:ClearItemCache()
	for i = 0, NUM_BAG_SLOTS do
		UpdateBag(i)
	end
end

--[[

	local function CacheBagItem(_, bagID, slotID)
		if (not bagID or not slotID) or (bagID < 0 or slotID < 0) then return end
		local button = _G['ElvUI_ContainerFrameBag' .. bagID .. 'Slot' .. slotID]
		local item, _ = Vendor:GetItemPropertiesFromBag(bagID, slotID)
		local result = Vendor.EvaluateItem(item)
	
	
		local isJunk = result == 1
		local icon = button.JunkItemIcon or Vendor_ElvUI:NewIcon(button)
		local glow = button.JunkItemGlow or Vendor_ElvUI:NewGlow(button)
	
		button.JunkItemGlow:SetShown(isJunk and glow and Vendor_ElvUIDB.glow)
		button.JunkItemIcon:SetShown(isJunk and icon and Vendor_ElvUIDB.icon)
	end
]]


local function SetInside(obj, anchor, xOffset, yOffset, anchor2, noScale)
	if not anchor then anchor = obj:GetParent() end

	if not xOffset then xOffset = E.Border end
	if not yOffset then yOffset = E.Border end
	local x = (noScale and xOffset) or E:Scale(xOffset)
	local y = (noScale and yOffset) or E:Scale(yOffset)

	if E:SetPointsRestricted(obj) or obj:GetPoint() then
		obj:ClearAllPoints()
	end

	DisablePixelSnap(obj)
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', x, -y)
	obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -x, y)
end



local function UpdateSlot(_, self, bagID, slotID)
	if not self.Bags[bagID] or not self.Bags[bagID][slotID] then
		return
	end

	local button = self.Bags[bagID][slotID]
	local result = Vendor.EvaluateItem(bagID, slotID)


	local isJunk = result == 1
	local icon = button.JunkItemIcon or Vendor_ElvUI:NewIcon(button)
	local glow = button.JunkItemGlow or Vendor_ElvUI:NewGlow(button)

	button.JunkItemGlow:SetShown(isJunk and glow and Vendor_ElvUIDB.glow)
	button.JunkItemIcon:SetShown(isJunk and icon and Vendor_ElvUIDB.icon)
end






function Vendor_ElvUI:NewGlow(button)
	button.JunkItemGlow = button:CreateTexture(button:GetName().."JunkItemGlow", 'OVERLAY', nil, 5)
	button.JunkItemGlow:SetInside()
	button.JunkItemGlow:SetBlendMode('ADD')
	button.JunkItemGlow:SetColorTexture(1,0,0, 0.4)


	return button.JunkItemGlow
end

function Vendor_ElvUI:NewIcon(button)
	button.JunkItemIcon = button:CreateTexture(button:GetName().."JunkItemIcon", 'OVERLAY', nil, 7)
	button.JunkItemIcon:SetTexture('Interface/Buttons/UI-GroupLoot-Coin-Up')
	button.JunkItemIcon:SetPoint('BOTTOMLEFT', 2, -2)
	button.JunkItemIcon:SetSize(20, 20)

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

	Vendor_ElvUI:UpdateAll()
end



-- Hooks
local function SetHooks()
	hooksecurefunc(ElvUIBags, "UpdateSlot", UpdateSlot)

	SLASH_VENDORELVUI1= "/vendorelvui"
  SlashCmdList.VENDORELVUI = function(msg)
    Vendor_ElvUI:SlashCommand(msg)
	end
	
	Vendor_ElvUIDB = Vendor_ElvUIDB or {}
	if Vendor_ElvUIDB.glow == nil then Vendor_ElvUIDB.glow = true end
	if Vendor_ElvUIDB.icon == nil then Vendor_ElvUIDB.icon = true end

	UpdateAll()
end
hooksecurefunc(ElvUIBags, "Initialize", SetHooks)