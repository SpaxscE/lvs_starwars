
include("entities/lvs_tank_wheeldrive/modules/sh_turret.lua")
include("entities/lvs_tank_wheeldrive/modules/sh_turret_ballistics.lua")

ENT.TurretPodIndex = 2

ENT.TurretBallisticsPredicted = false

ENT.TurretBallisticsProjectileVelocity = 6000
ENT.TurretBallisticsMuzzleAttachment = "muzzle"
ENT.TurretBallisticsViewAttachment = "turret_view"

ENT.TurretAimRate = 80

ENT.TurretRotationSound = "vehicles/tank_turret_loop1.wav"

ENT.TurretPitchPoseParameterName = "turret_pitch"
ENT.TurretPitchMin = -10
ENT.TurretPitchMax = 10
ENT.TurretPitchMul = 1
ENT.TurretPitchOffset = 0

ENT.TurretYawPoseParameterName = "turret_yaw"
ENT.TurretYawMul = 1
ENT.TurretYawOffset = 0

function ENT:GetTurretViewOrigin()
	local ID = self:LookupAttachment( self.TurretBallisticsViewAttachment )

	local Att = self:GetAttachment( ID )

	if not Att then return self:GetPos(), false end

	local Pos = Att.Pos + Att.Ang:Forward() * 20 - Att.Ang:Right() * 5 - Att.Ang:Up() * 15

	return Pos, true
end
