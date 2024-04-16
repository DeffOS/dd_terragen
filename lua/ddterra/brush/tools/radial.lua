local distsqr = math.DistanceSqr
local BRUSH = {}
BRUSH.Type = "point"

function BRUSH:Setup(rad,frc)
	self.Distance = rad ^ 2
	self.Force = frc
end
function BRUSH:StartStroke(point)
	self.SX = point.X
	self.SY = point.Y
end
function BRUSH:EndStroke(point)
	self.EX = point.X
	self.EY = point.Y
end
function BRUSH:Process(point,invert)
	local add = 1 - distsqr(self.SX,self.SY,point.X,point.Y) / self.Distance
	add = (add > 0) and add or 0
	return point:GetHeight() + add * (invert and -self.Force or self.Force),point:GetAlpha()
end
return BRUSH