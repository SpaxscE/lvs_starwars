
function ENT:PredictPoseParamaters()
	local pod = self:GetDriverSeat()

	if not IsValid( pod ) then return end

	local plyL = LocalPlayer()
	local ply = pod:GetDriver()

	if ply ~= plyL then return end

	self:AimTurretPrimary()
	self:AimTurretSecondary()
end