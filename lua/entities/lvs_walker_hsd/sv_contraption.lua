
function ENT:ContraptionThink()
	local OnMoveableFloor = self:CheckGround()

	if not IsValid( self:GetDriver() ) and not self:GetAI() then
		self:ApproachTargetSpeed( 0 )
		self:SetTargetSteer( 0 )
	end

	self:CheckUpRight()
	self:CheckActive()
	self:CheckMotion( OnMoveableFloor )
	self:UpdateLegs()
end

function ENT:UpdateLegs()
	local T = CurTime()

	local PhysObj = self:GetPhysicsObject()

	local Delay = math.max(1.5 - math.max( self:GetVelocity():Length() / 150, math.abs( PhysObj:GetAngleVelocity().z / 23) ) ,0.35)

	if ((self._NextLeg or 0) + Delay ) > T then return end

	if not self:GetIsMoving() then return end

	self._NextLeg = T

	local Next = self:GetUpdateLeg() + (self:GetTargetSpeed() >= 0 and 1 or -1)

	if Next > 4 then
		Next = 1
	end

	if Next < 1 then
		Next = 4
	end

	self:SetUpdateLeg( Next )
end

function ENT:CheckUpRight()
	if self:IsPlayerHolding() then return end

	if self:HitGround() and self:AngleBetweenNormal( self:GetUp(), Vector(0,0,1) ) < 45 then
		return
	end

	self:BecomeRagdoll()
end

function ENT:CheckActive()
	local ShouldBeActive = self:HitGround() and not self:GetIsRagdoll()

	if ShouldBeActive ~= self:GetEngineActive() then
		self:SetEngineActive( ShouldBeActive )
	end
end

function ENT:ToggleGravity( PhysObj, Enable )
	if PhysObj:IsGravityEnabled() ~= Enable then
		PhysObj:EnableGravity( Enable )
	end
end

function ENT:CheckMotion( OnMoveableFloor )
	if self:GetIsRagdoll() then
		return
	end

	local TargetSpeed = self:GetTargetSpeed()

	if not self:HitGround() then
		self:SetIsMoving( false )
	else
		self:SetIsMoving( math.abs( TargetSpeed ) > 1 )
	end

	local IsHeld = self:IsPlayerHolding()

	if IsHeld then
		self:SetTargetSpeed( 200 )
	end

	if self:HitGround() and not OnMoveableFloor then
		local enable = self:GetIsMoving() or IsHeld

		local phys = self:GetPhysicsObject()

		if not IsValid( phys ) then return end

		if phys:IsMotionEnabled() ~= enable then
			phys:EnableMotion( enable )
			phys:Wake()
		end
	else
		local enable = self:GetIsMoving() or IsHeld or OnMoveableFloor

		local phys = self:GetPhysicsObject()

		if not IsValid( phys ) then return end

		if not phys:IsMotionEnabled() then
			phys:EnableMotion( enable )
			phys:Wake()
		end
	end
end

local StartPositions = {
	[1] = Vector(0,0,0),
	[2] = Vector(150,270,0),
	[3] = Vector(150,-270,0),
	[4] = Vector(-150,270,0),
	[5] = Vector(-150,-270,0),
}

function ENT:CheckGround()
	local NumHits = 0
	local FirstTraceHasHit = false
	local HitMoveable

	local phys = self:GetPhysicsObject()

	if not IsValid( phys ) then return false end

	for id, pos in ipairs( StartPositions ) do
		local masscenter = phys:LocalToWorld( phys:GetMassCenter() + pos )

		local trace =  util.TraceHull( {
			start = masscenter, 
			endpos = masscenter - self:GetUp() * self.HoverTraceLength,
			mins = Vector( -self.HoverHullRadius, -self.HoverHullRadius, 0 ),
			maxs = Vector( self.HoverHullRadius, self.HoverHullRadius, 0 ),
			filter = function( entity ) 
				if self:GetCrosshairFilterLookup()[ entity:EntIndex() ] or entity:IsPlayer() or entity:IsNPC() or entity:IsVehicle() or self.HoverCollisionFilter[ entity:GetCollisionGroup() ] then
					return false
				end

				return true
			end,
		} )

		if id == 1 then
			FirstTraceHasHit = trace.Hit
		end

		if not HitMoveable then
			if IsValid( trace.Entity ) then
				HitMoveable = self.CanMoveOn[ trace.Entity:GetClass() ]
			end
		end

		if not trace.Hit or trace.HitSky then continue end

		NumHits = NumHits + 1
	end

	local HitGround = NumHits >= (FirstTraceHasHit and 3 or 1)

	if self:GetNWGround() ~= HitGround then
		self:SetNWGround( HitGround )
	end

	self.HoverHeight = 50 + (200 / 5) * NumHits

	if NumHits <= 3 then
		return true
	end

	return HitMoveable == true
end