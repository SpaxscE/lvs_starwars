
function ENT:TransformNormal( ent, Normal )
	ent.smNormal = ent.smNormal and ent.smNormal + (Normal - ent.smNormal) * FrameTime() * 2 or Normal

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

function ENT:GetAlignment( ent, phys )
	local Move = self:GetMove()

	local P = math.cos( math.rad(Move) )
	local R = -math.cos( math.rad(Move * 2) )

	local Pitch = math.abs( P ) ^ 10 * self:Sign( P ) * 2
	local Roll = math.abs( R ) ^ 10 * self:Sign( R ) * 2
	local Ang = self:LocalToWorldAngles( Angle(Pitch,0,Roll) )

	return Ang:Forward(), Ang:Right()
end

function ENT:CalcMove( speed )
	local PhysObj = self:GetPhysicsObject()

	self:SetMove( self:GetMove() + speed * (0.015 + math.abs( PhysObj:GetAngleVelocity().z * 0.000125 )) )

	local Move = self:GetMove()

	if Move > 360 then
		self:SetMove( Move - 360 )
	end

	if Move < -360 then
		self:SetMove( Move + 360 )
	end
end

function ENT:GetMoveXY( ent, phys, deltatime )
	local VelL = ent:WorldToLocal( ent:GetPos() + ent:GetVelocity() )

	local X = (self:GetTargetSpeed() - VelL.x)
	local Y = -VelL.y * 0.6

	self:CalcMove( VelL.x )

	return X, Y
end

function ENT:GetSteer( ent, phys )
	local Steer = -phys:GetAngleVelocity().z * 0.5

	if not IsValid( self:GetDriver() ) and not self:GetAI() then return Steer end

	return Steer + self:GetTargetSteer()
end
