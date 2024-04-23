local distsqr = math.DistanceSqr
local BRUSH = {}
BRUSH.Base = "base_point"

function BRUSH:Process(center,point,invert)
	local add = 1 - distsqr(center.X,center.Y,point.X,point.Y) / (self.Radius ^ 2)
	add = (add > 0) && add || 0

	return point:GetHeight() + add * (invert && -self.Force || self.Force),point:GetAlpha()
end

return BRUSH