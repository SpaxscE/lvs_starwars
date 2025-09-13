
include("entities/lvs_tank_wheeldrive/modules/cl_tankview.lua")


function ENT:CalcViewDriver( ply, pos, angles, fov, pod )
	angles = ply:EyeAngles()

	if not pod:GetThirdPersonMode() then
		pos = pos + self:GetForward() * 60 - self:GetUp() * 30
	end

	return self:CalcTankView( ply, pos, angles, fov, pod )
end

function ENT:TankViewOverride( ply, pos, angles, fov, pod )
	if ply:GetVehicle() == self:GetGunnerSeat() then
		angles = ply:EyeAngles()

		if not pod:GetThirdPersonMode() then
			local vieworigin, found = self:GetTurretViewOrigin()

			if found then pos = vieworigin end
		end
	end

	return pos, angles, fov
end
