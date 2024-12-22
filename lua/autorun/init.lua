Coupons = {}
Coupons.ActiveCoupons = {}

if SERVER then
    AddCSLuaFile()

    util.AddNetworkString("SendCouponData")

    if not file.Exists("ps2-coupons", "DATA") then
        file.CreateDir("ps2-coupons")
        print("[ps2-coupons] Created folder: ps2-coupons")
    end

    if file.Exists("ps2-coupons/activeCoupons.txt", "DATA") then
        Coupons.ActiveCoupons = util.JSONToTable(file.Read("ps2-coupons/activeCoupons.txt", "DATA"))
    else
        print("[ps2-coupons] No Used coupons file found.")
    end

    function Coupons:saveUsedCoupons()
        PrintTable(Coupons.ActiveCoupons)
        -- file.Write("ps2-coupons/activeCoupons.txt", util.TableToJSON(Coupons.ActiveCoupons))
    end
    
    function loadUsedCoupons( steamId )
        return Coupons.ActiveCoupons[steamId] or nil
    end

    hook.Add("PlayerInitialSpawn", "LoadUsedCoupons", function(ply)
        local coupon = loadUsedCoupons(ply:SteamID64())
        if coupon then
            coupon:OnUseSv()
            net.Start("SendCouponData")
            net.WriteTable(coupon)
            net.Send(ply)
        end
    end)
else
    net.Receive("SendCouponData", function()
        print("**************************************************************")
        local coupon = net.ReadTable()
        PrintTable(coupon)
        if coupon then
            coupon:OnUseCl()
        end
    end)
end