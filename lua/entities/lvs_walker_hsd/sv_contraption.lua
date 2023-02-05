
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

	local Delay = math.max(1.5 - math.max( self:GetVelocity():Length() / 150, math.abs( PhysObj:GetAngleVelocity().z / 30) ) ,0.35)

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

	if self:HitGround() then
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

function ENT:CheckGround()

	local phys = self:GetPhysicsObject()

	if not IsValid( phys ) then return false end

	local masscenter = phys:LocalToWorld( phys:GetMassCenter() )

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

	if self:GetNWGround() ~= trace.Hit then
		self:SetNWGround( trace.Hit )
	end

	if IsValid( trace.Entity ) then
		return self.CanMoveOn[ trace.Entity:GetClass() ] == true
	else
		return false
	end
end