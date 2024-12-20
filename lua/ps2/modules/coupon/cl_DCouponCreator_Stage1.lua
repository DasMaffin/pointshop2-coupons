local PANEL = {}

function PANEL:Init( )    
    self.infoPanel = vgui.Create( "DInfoPanel", self )
    self.infoPanel:SetSmall( true )
    self.infoPanel:Dock( TOP )
    self.infoPanel:SetInfo( "Discount", 
    [[Discounts the next purchase of an item/category for the user.]] )
    self.infoPanel:DockMargin( 5, 5, 5, 5 )

    -- Add a title
    self:addSectionTitle( "Settings" )

    -- Add a Number Wang control
    self.discountWang = vgui.Create( "DNumberWang" )
    local pnl = self:addFormItem( "Discount", self.discountWang )
    -- Set Default Value
    self.discountWang:SetValue( 80 ) 
end

function PANEL:SaveItem( saveTable )
    saveTable.multiplier = self.discountWang:GetValue( )
end

function PANEL:Validate( saveTable )
    if self.discountWang:GetValue() < 0 then
        return false, "Multiplier must be greater or equal to zero."
    end

    return true
end

function PANEL:EditItem( persistence, itemClass )
end

-- Override background painting
function PANEL:Paint() end

vgui.Register( "DCouponCreator_Stage1", PANEL, "DItemCreator_Stage" )