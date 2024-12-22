Coupons.ActiveCoupons = {}

if SERVER then
    if not file.Exists("ps2-coupons", "DATA") then
        file.CreateDir("ps2-coupons")
        print("[ps2-coupons] Created folder: ps2-coupons")
    end

    Coupons.ActiveCoupons = util.JSONToTable(file.Read("ps2-coupons/activeCoupons.txt", "DATA"))

    function saveUsedCoupons()
        file.Write("ps2-coupons/activeCoupons.txt", util.TableToJSON(/*Value to save here*/))
    end
    
    function loadUsedCoupons( steamId)
        return Coupons.ActiveCoupons[steamId] or {}
    end
end

hook.add("PlayerInitialSpawn", "LoadUsedCoupons", function(ply)
    local coupon = loadUsedCoupons(ply:SteamID())
    coupon:OnUseCl(coupon.class)
    coupon:OnUseSv(ply)
end)