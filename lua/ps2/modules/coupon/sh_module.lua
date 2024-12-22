local MODULE = {}

MODULE.Name = "PS2 Coupons"
MODULE.Author = "Maffin"

MODULE.Blueprints = {
    {
        label = "Coupon",
        base = "base_coupon",
        icon = "pointshop2/coupon.png",
        creator = "DCouponCreator",
        tooltip = "Create coupons."
    }
}

Pointshop2.RegisterModule( MODULE )