ITEM.baseClass = "base_single_use"
ITEM.multiplier = 80
ITEM.material = "pointshop2/coupon.png"

local Player = FindMetaTable( "Player" )
local pricePanel

function ITEM.static.getPersistence()
	return Pointshop2.CouponPersistence
end

function ITEM.static.generateFromPersistence( itemTable, persistence )
    -- Call the parent's generateFromPersistence to populate default  fields such as name, price, description.
    ITEM.super.generateFromPersistence( itemTable, persistence.ItemPersistence )
    -- Set the class properties from the persistence
    ITEM.multiplier = persistence.multiplier
end

function ITEM:CanBeUsed( )
	local canBeUsed, reason = ITEM.super.CanBeUsed( self )
	if not canBeUsed then
		return false, reason
	end

	return true
end

function ITEM:OnUseCl()
	local originalCanAffordCL = Player.PS2_CanAfford

	function Player:PS2_CanAfford(itemClass)
		if LocalPlayer():GetNWBool("Discounted") then
			Player.PS2_CanAfford = originalCanAffordCL
		end
		local price = itemClass:GetBuyPrice()
		if price.points then
			price.points = price.points * ((100 - ITEM.multiplier) / 100)
		end
		local wallet = self:PS2_GetWallet()
		if not wallet or not price then
			return false
		end
	
		if price.points and wallet.points >= price.points then
			return true
		end
	
		if price.premiumPoints and wallet.premiumPoints >= price.premiumPoints then
			return true
		end
	
		return false
	end

	hook.Add("PS2_ItemDescription_SetItemClass", "OverrideSetItemClass", function(panel, item)

		if LocalPlayer():GetNWBool("Discounted") then
			hook.Remove("PS2_ItemDescription_SetItemClass", "OverrideSetItemClass")
			return
		end
		
		panel.buttonsPanel:Reset( )
	
		price = item:GetBuyPrice( LocalPlayer( ))
		if price.points then
			price.points = price.points * ((100 - ITEM.multiplier) / 100)
		end
		panel.buttonsPanel:AddBuyButtons( price )
	end)
end

function ITEM:OnUseSv()
	-- Save the original method for fallback if needed
	local originalBuyItem = Pointshop2Controller.buyItem
	local originalCanAffordSV = Player.PS2_CanAfford
	self:GetOwner():SetNWBool("Discounted", false)
	function Pointshop2Controller:buyItem( ply, itemClassName, currencyType )
		return self:isValidPurchase( ply, itemClassName )
		:Then( function( )
			local itemClass = Pointshop2.GetItemClassByName( itemClassName )
	
			local price = itemClass:GetBuyPrice( ply )
			if not price then
				KLogf( 3, "Player %s tried to buy item %s which cannot be bought! Hacking Attempt?", ply:Nick(), itemClass )
				return Promise.Reject( "Item %s cannot be bought!" )
			end
			if price.points then
				price.points = price.points * ((100 - ITEM.multiplier) / 100)
			end
	
			if currencyType == "points" and price.points and ply.PS2_Wallet.points < price.points  or
			   currencyType == "premiumPoints" and price.premiumPoints and ply.PS2_Wallet.premiumPoints < price.premiumPoints
			then
				return Promise.Reject( "You cannot purchase this item (insufficient " .. currencyType .. ")" )
			end
	
			return self:internalBuyItem( ply, itemClass, currencyType, price[currencyType] )
		end )
		:Then( function( item )
			KLogf( 4, "Player %s purchased item %s", ply:Nick( ), itemClassName )
			hook.Run( "PS2_PurchasedItem", ply, itemClassName )
			Pointshop2Controller.buyItem = originalBuyItem
			Player.PS2_CanAfford = originalCanAffordSV
			ply:SetNWBool("Discounted", true)
			return item
		end, function( errid, err )
			KLogf( 2, "Error saving item purchase: %s", err or errid )
			return err
		end )
	end

	function Player:PS2_CanAfford(itemClass)
		local price = itemClass:GetBuyPrice()
		if price.points then
			price.points = price.points * ((100 - ITEM.multiplier) / 100)
		end
		local wallet = self:PS2_GetWallet()
		if not wallet or not price then
			return false
		end

		if price.points and wallet.points >= price.points then
			return true
		end

		if price.premiumPoints and wallet.premiumPoints >= price.premiumPoints then
			return true
		end

		return false
	end
	
end

local originalUseButtonClicked = ITEM.UseButtonClicked
function ITEM:UseButtonClicked()
	self:OnUseCl()

	return originalUseButtonClicked( self )
end

hook.Add("PlayerInitialSpawn", "SetDefaultDiscountedValue", function(ply)
    ply:SetNWBool("Discounted", false)
end)

function ITEM:OnUse()
	Coupons.ActiveCoupons[self:GetOwner():SteamID64()] = self
	Coupons.saveUsedCoupons()

	self:OnUseSv(ply)	

	print("[Pointshop Discount] Successfully applied " .. ITEM.multiplier .. "% discount to internalBuyItem!")
end