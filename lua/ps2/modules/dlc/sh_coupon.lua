local MODULE = {}

MODULE.Name = "PS2 Coupons"
MODULE.Author = "Maffin"

Pointshop2.RegisterModule( MODULE )

MODULE.Blueprints = {
    {
        label = "Coupon",
        base = "base_coupon",
        icon = "pointshop2/crime1.png",
        creator = "DCouponCreator",
        tooltip = "Create Coupons"
    }
}