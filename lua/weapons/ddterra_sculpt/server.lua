// print("Bunga")
local points = {}
SWEP.bStroking = false

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	if !self.bStroking then
		self.bStroking = true
	end

	local tr = ply:GetEyeTrace()
	local x,y = ddterra.PosToIndex(tr.HitPos)
	local brush = self.Brush
	if brush.SX == x && brush.SY == y then return end
	local rad = self:GetRadius()
	points = ddterra.GetPointsInRadius(x,y,rad,points)
	local center = ddterra.Points:Get(x,y)
	brush:StartStroke(center,rad,128)

	for i = 1,points._count do
		local point = points[i]
		if !point then continue end
		point:ApplyChanges(brush:Process(point,ply:KeyDown(IN_SPEED)))
	end
	// ApplyChanges
end