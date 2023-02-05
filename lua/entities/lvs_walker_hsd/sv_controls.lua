
function ENT:TransformNormal( ent, Normal )
	Normal.x = math.Clamp( Normal.x, -0.25, 0.25 )
	Normal.y = math.Clamp( Normal.y, -0.25, 0.25 )
	Normal:Normalize()

	ent.smNormal = ent.smNormal and ent.smNormal + (Normal - ent.smNormal) * FrameTime() or Normal

	return ent.smNormal
end

function ENT:SetTargetSteer( num )
	self._TargetSteer = num
end

function ENT:SetTargetSpeed( num )
	self._TargetVel = num
end

function ENT:GetTargetSpeed()
	local TargetSpeed = (self._TargetVel or 0)

	return TargetSpeed
end

function ENT:GetTargetSteer()
	return (self._TargetSteer or 0)
end

function ENT:ApproachTargetSpeed( MoveX )
	local Cur = self:GetTargetSpeed()
	local New = Cur + (MoveX - Cur) * FrameTime() * 3.5
	self:SetTargetSpeed( New )
end

function ENT:CalcThrottle( ply, cmd )
	local MoveSpeed = cmd:KeyDown( IN_SPEED ) and 150 or 100
	local MoveX = (cmd:KeyDown( IN_FORWARD ) and MoveSpeed or 0) + (cmd:KeyDown( IN_BACK ) and -MoveSpeed or 0)

	self:ApproachTargetSpeed( MoveX )
end

function ENT:CalcSteer( ply, cmd )
	local KeyLeft = cmd:KeyDown( IN_MOVELEFT )
	local KeyRight = cmd:KeyDown( IN_MOVERIGHT )
	local Steer = ((KeyLeft and 1 or 0) - (KeyRight and 1 or 0)) * 0.2 * math.abs( self:GetTargetSpeed() )

	local Cur = self:GetTargetSteer()
	local New = Cur + (Steer - Cur) * FrameTime() * 3.5

	self:SetTargetSteer( New )
end

function ENT:StartCommand( ply, cmd )
	if self:GetDriver() ~= ply then return end

	self:CalcThrottle( ply, cmd )
	self:CalcSteer( ply, cmd )
end

local MoveX = {
	[1] = -1,
	[2] = 1,
	[3] = -1,
	[4] = 1,
}

local MoveY = {
	[1] = -1,
	[2] = -1,
	[3] = 1,
	[4] = 1,
}

function ENT:GetAlignment( ent, phys )
	local Rate = FrameTime() * 2

	local UpdateLeg = self:GetUpdateLeg()

	if self._oldUpdateLeg ~= UpdateLeg then
		self._oldUpdateLeg = UpdateLeg

		self._smBodyMoveX = MoveX[ UpdateLeg ]
		self._smBodyMoveY = MoveY[ UpdateLeg ]
	end

	self._smBodyMoveX = self._smBodyMoveX and (self._smBodyMoveX - math.Clamp( self._smBodyMoveX, -Rate, Rate )) or 0
	self._smBodyMoveY =  self._smBodyMoveY and (self._smBodyMoveY - math.Clamp( self._smBodyMoveY, -Rate, Rate )) or 0

	local Pitch = 2 * self._smBodyMoveX
	local Roll =  2 * self._smBodyMoveY

	local Ang = self:LocalToWorldAngles( Angle(Pitch,0,Roll) )

	return Ang:Forward(), Ang:Right()
end

function ENT:GetMoveXY( ent, phys, deltatime )
	local VelL = ent:WorldToLocal( ent:GetPos() + ent:GetVelocity() )

	local X = (self:GetTargetSpeed() - VelL.x)
	local Y = -VelL.y * 0.6

	return X, Y
end

function ENT:GetSteer( ent, phys )
	local Steer = -phys:GetAngleVelocity().z * 0.8

	if not IsValid( self:GetDriver() ) and not self:GetAI() then return Steer end

	return Steer + self:GetTargetSteer()
end
