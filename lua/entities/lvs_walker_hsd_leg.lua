AddCSLuaFile()

ENT.Type            = "anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "Base" )
	self:NetworkVar( "String",0, "LocationIndex" )
end

if SERVER then
	function ENT:Initialize()	
		self:SetModel( "models/blu/hsd_leg_1.mdl" )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
	end

	function ENT:Think()
		return false
	end
else 
	include( "entities/lvs_walker_atte/cl_ikfunctions.lua" )

	ENT.Length1 = 140
	ENT.Length2 = 300

	ENT.Length3 = 20
	ENT.Length4 = 20

	ENT.LegData1 = {
		Leg1 = {MDL = "models/blu/hsd_leg_2.mdl", Ang = Angle(0,-90,-90), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/hsd_leg_4.mdl", Ang = Angle(180,90,4), Pos = Vector(20,0,-12)},
		Foot = {MDL = "models/blu/hsd_foot.mdl", Ang = Angle(0,0,0), Pos = Vector(0,-2,0)}
	}

	ENT.LegData2 = {
		Leg1 = {MDL = "models/blu/hsd_leg_3.mdl", Ang = Angle(0,90,-90), Pos = Vector(0,0,0)},
	}

	ENT.StartPositions = {
		["FL"] = Vector(150,270,0),
		["FR"] = Vector(150,-270,0),
		["RL"] = Vector(-150,270,0),
		["RR"] = Vector(-150,-270,0),
	}

	ENT.LocToID = {
		[1] = "RL",
		[2] = "FL",
		[3] = "RR",
		[4] = "FR",
	}

	function ENT:Think()
		local Base = self:GetBase()

		if not IsValid( Base ) then return end

		if Base:GetIsRagdoll() then 
			self:LegClearAll()

			return
		end

		local EntTable = self:GetTable()
		local LocIndex = self:GetLocationIndex()

		if not Base:HitGround() then
			local Pos = Base:LocalToWorld( EntTable.StartPositions[ LocIndex ] )

			self:RunIK( Pos, Base )
			EntTable._OldPos = Pos
			EntTable._smPos = Pos

			return
		end

		local Up = Base:GetUp()
		local Forward = Base:GetForward()
		local Vel = Base:GetVelocity()

		local Speed = Vel:Length()
		local VelForwardMul = math.min( Speed / 100, 1 )
		local VelForward = Vel:GetNormalized() * VelForwardMul + Forward * (1 - VelForwardMul)

		local TraceStart = Base:LocalToWorld( EntTable.StartPositions[ LocIndex ] ) + VelForward * math.Clamp( 400 - Speed * 2, 100, 200 ) * VelForwardMul

		local trace = util.TraceLine( { 
			start = TraceStart + Vector(0,0,200),
			endpos = TraceStart - Vector(0,0,100), 
			filter = function( ent ) 
				if ent == Base or Base.HoverCollisionFilter[ ent:GetCollisionGroup() ] then return false end 

				return true
			end,
		} )

		local UpdateLeg = EntTable.LocToID[ Base:GetUpdateLeg() ] == LocIndex

		EntTable._OldPos = EntTable._OldPos or trace.HitPos
		EntTable._smPos = EntTable._smPos or EntTable._OldPos

		if EntTable._OldUpdateLeg ~= UpdateLeg then
			EntTable._OldUpdateLeg = UpdateLeg

			if UpdateLeg then
				EntTable.UpdateNow = true
			end
		end

		if EntTable.UpdateNow and not EntTable.MoveLeg then
			sound.Play( Sound( "lvs/vehicles/hsd/hydraulic_stop0"..math.random(1,2)..".wav" ), self:GetPos(), SNDLVL_100dB )

			EntTable.UpdateNow = nil
			EntTable.MoveLeg = true
			EntTable.MoveDelta = 0
		end

		local ShaftOffset = 0
		local ENDPOS = EntTable._smPos + Up * 20

		if EntTable.MoveLeg then
			local traceWater = util.TraceLine( {
				start = TraceStart + Vector(0,0,200),
				endpos = ENDPOS,
				filter = Base:GetCrosshairFilterEnts(),
				mask = MASK_WATER,
			} )

			if traceWater.Hit then
				local T = CurTime()

				if (EntTable._NextFX or 0) < T then
					EntTable._NextFX = T + 0.05
	
					local effectdata = EffectData()
						effectdata:SetOrigin( traceWater.HitPos )
						effectdata:SetEntity( Base )
						effectdata:SetMagnitude( 50 )
					util.Effect( "lvs_hover_water", effectdata )
				end
			end

			if EntTable.MoveDelta >= 1 then
				EntTable.MoveLeg = false
				EntTable.MoveDelta = nil

				sound.Play( Sound( "lvs/vehicles/hsd/footstep0"..math.random(1,3)..".wav" ), ENDPOS, SNDLVL_100dB )

				local effectdata = EffectData()
					effectdata:SetOrigin( trace.HitPos )
				util.Effect( "lvs_walker_stomp", effectdata )

				sound.Play( Sound( "lvs/vehicles/hsd/hydraulic_start0"..math.random(1,2)..".wav" ), self:GetPos(), SNDLVL_100dB )
			else
				EntTable.MoveDelta = math.min( EntTable.MoveDelta + RealFrameTime() * 2, 1 )
	
				EntTable._smPos = LerpVector( EntTable.MoveDelta, EntTable._OldPos, trace.HitPos )

				local MulZ =  math.max( math.sin( EntTable.MoveDelta * math.pi ), 0 )

				ShaftOffset = MulZ ^ 2 * 30
				ENDPOS = ENDPOS + Up * MulZ * 50
			end
		else
			EntTable._OldPos = EntTable._smPos
		end

		self:RunIK( ENDPOS, Base, ShaftOffset )
	end

	function ENT:RunIK( ENDPOS, Base, shaftoffset )
		shaftoffset = shaftoffset or 0

		local EntTable = self:GetTable()

		local Ang = Base:WorldToLocalAngles( (ENDPOS - self:GetPos()):Angle() )

		self:SetAngles( Base:LocalToWorldAngles( Angle(0,Ang.y + 90,0) ) )

		local ID = self:LookupAttachment( "lower" )
		local Att = self:GetAttachment( ID )

		if not Att then return end

		local Pos, Ang = WorldToLocal( ENDPOS, (ENDPOS - Att.Pos):Angle(), Att.Pos, self:LocalToWorldAngles( Angle(0,-90,0) ) )

		local STARTPOS = Att.Pos

		self:GetLegEnts( 1, EntTable.Length1, EntTable.Length2, self:LocalToWorldAngles( Angle(0,180,135) ), STARTPOS, ENDPOS, EntTable.LegData1 )

		if not EntTable.IK_Joints[ 1 ] or not IsValid( EntTable.IK_Joints[ 1 ].Attachment2 ) then return end

		local shaft = EntTable.IK_Joints[ 1 ].Attachment2

		shaft:SetPoseParameter( "extrude", shaftoffset )
		shaft:InvalidateBoneCache()

		local ID1 = self:LookupAttachment( "upper" )
		local Start = self:GetAttachment( ID1 )

		if not Start then return end

		local ID2 = shaft:LookupAttachment( "upper_end" )
		local End = shaft:GetAttachment( ID2 )

		if not End then return end

		self:GetLegEnts( 2, EntTable.Length3, EntTable.Length4, self:LocalToWorldAngles( Angle(0,0,-45) ), Start.Pos, End.Pos, EntTable.LegData2 )

		if not EntTable.IK_Joints[ 2 ] or not IsValid( EntTable.IK_Joints[ 2 ].Attachment1 ) then return end

		local strut = EntTable.IK_Joints[ 2 ].Attachment1
		strut:SetPoseParameter( "extrude", (Start.Pos - End.Pos):Length() )
		strut:InvalidateBoneCache()
	end

	function ENT:OnRemove()
		self:OnRemoved()
	end

	function ENT:Draw()
		local Base = self:GetBase()

		if not IsValid( Base ) then return end

		if Base:GetIsRagdoll() then return end

		self:DrawModel()
	end
end