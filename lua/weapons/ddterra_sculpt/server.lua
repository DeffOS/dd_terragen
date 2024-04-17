SWEP.b_Stroking = false

function SWEP:PrimaryAttack()
	if self.b_Stroking then return end
	self.b_Stroking = true
	local ply = self:GetOwner()
	self.Brush:StartStroke(ply:GetEyeTrace())
end

function SWEP:Think()
	local ply = self:GetOwner()

	if self.b_Stroking then
		local trc = ply:GetEyeTrace()

		if ply:KeyDown(IN_ATTACK) then
			self.Brush:UpdateStroke(trc)
		else
			self.Brush:EndStroke(trc)
			self.b_Stroking = false
		end
	end
end