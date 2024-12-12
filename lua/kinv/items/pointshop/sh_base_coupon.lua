ITEM.baseClass = "base_single_use"
ITEM.PrintName = "Coupon"
ITEM.Description = "Use this to get a Discount!"
ITEM.material = "pointshop2/small65.png"
ITEM.static.Price = {
    points = 100
}

function ITEM:CanBeUsed( )
	local canBeUsed, reason = ITEM.super.CanBeUsed( self )
	if not canBeUsed then
		return false, reason
	end

	local ply = self:GetOwner( )
	if not ply:Alive( ) or ( ply.IsSpec and ply:IsSpec( ) ) then
		return false, "You need to be alive to use this item"
	end
	return true
end

function ITEM:OnUse( ply )
    print(ply)
end

-- Tell the shop which persistence class to use to generate item classes for this base
function ITEM.static.getPersistence( )
    return Pointshop2.LowGravityPersistence
end

function ITEM.static.generateFromPersistence( itemTable, persistence )
    -- Call the parent's generateFromPersistence to populate default fields such as name, price, description.
    ITEM.super.generateFromPersistence( itemTable, persistence.ItemPersistence )

    -- Set the class properties from the persistence
    itemTable.multiplier = persistence.multiplier
end