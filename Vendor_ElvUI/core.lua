local R,G,B = GetItemQualityColor(0)
local Vendor_ElvUI = {}
Vendor_ElvUI.ElvUIHookTries = 0

local ElvUIBags = ElvUI[1]:GetModule("Bags")


local function UpdateContainerElvUI(bag)
	local frame = _G['ElvUI_ContainerFrameBag' .. bag]
	local name = frame:GetName()
	local size = frame.numSlots

	if not size then return end
	for i = 1, size do
		local slot = i
		local button = _G[name .. 'Slot' .. slot]

		local item = {}
		item.Properties = VendorAddonAPI:GetItemPropertiesFromBag(bagID, slotID)

		local isJunk = VendorAddonAPI:EvaluateItemForSelling(item)
		local glow = button.JunkItemGlow or self:NewGlow(button)
		local icon = button.JunkItemIcon or self:NewIcon(button)

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

	local item = {}
	item.Properties = VendorAddonAPI:GetItemPropertiesFromBag(bagID, slotID)


	local button = self.Bags[bagID][slotID]

	local isJunk = VendorAddonAPI:EvaluateItemForSelling(item.Properties)
	local icon = button.JunkItemIcon or Vendor_ElvUI:NewIcon(button)
	local glow = button.JunkItemGlow or Vendor_ElvUI:NewGlow(button)

	button.JunkItemGlow:SetShown(isJunk and glow)
	button.JunkItemIcon:SetShown(isJunk and icon)
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







-- Hooks
local function SetHooks()
	hooksecurefunc(ElvUIBags, "UpdateSlot", UpdateSlot)

	UpdateAll()
end
hooksecurefunc(ElvUIBags, "Initialize", SetHooks)