SWEP.b_Stroking = false

function SWEP:PrimaryAttack()
	if self.b_Stroking then return end
	self.b_Stroking = true
	local ply = self:GetOwner()
	self.Brush:StartStroke(ply:GetEyeTrace())
end


SWEP.i_SecondaryLastFrame = 0

function SWEP:SecondaryAttack()
	if FrameNumber() > self.i_SecondaryLastFrame + 4 then
		self.Brush:Cancel()
	end
	self.i_SecondaryLastFrame = FrameNumber()
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