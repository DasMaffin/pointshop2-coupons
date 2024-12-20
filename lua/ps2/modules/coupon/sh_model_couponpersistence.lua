-- Define the class
Pointshop2.CouponPersistence = class( "Pointshop2.CouponPersistence" )
local CouponPersistence = Pointshop2.CouponPersistence 

-- Link to the Pointshop2 Database
CouponPersistence.static.DB = "Pointshop2"

-- Define model fields
CouponPersistence.static.model = {
    -- Name of the SQL Table
    tableName = "ps2_couponpersistence",

    -- Table columns:
    fields = {
        -- Foreign key, needed to link to the basic item info row
        itemPersistenceId = "int",

        multiplier = "luadata",
    },

    -- Link to the item persistence of base_pointshop_item
    belongsTo = {
        ItemPersistence = {
            class = "Pointshop2.ItemPersistence",
            foreignKey = "itemPersistenceId",
            onDelete = "CASCADE",
        }
    }
}

-- Include Database Logic (creating tables, adding accessor functions)
CouponPersistence:include( DatabaseModel )

-- Include EasyExport: Makes it possible to import/export the item
CouponPersistence:include( Pointshop2.EasyExport )

--[[
    Called by the Item Creator to update or create a persistence.
    Args:
    - saveTable: A table of custom fields created by the creator
    - doUpdate: A boolean, true if we are updating an item, false if 
                creating it.
]]--
function CouponPersistence.static.createOrUpdateFromSaveTable( saveTable, doUpdate )
    -- call the base item createOrUpdateFromSaveTable to save basic item info (description, name, price, etc.) 
    return Pointshop2.ItemPersistence.createOrUpdateFromSaveTable( saveTable, doUpdate )
    :Then( function( itemPersistence )
        if doUpdate then
            -- Find the database row to update
            return CouponPersistence.findByItemPersistenceId( itemPersistence.id )
        else
            -- Create a new database row
            local weaponPersistence = CouponPersistence:new( )
            -- link the basic item info
            weaponPersistence.itemPersistenceId = itemPersistence.id
            return weaponPersistence
        end
    end )
    :Then( function( couponPersistence )
        -- Set our custom properties
        couponPersistence.multiplier = saveTable.multiplier
        return couponPersistence:save( )
    end )
end