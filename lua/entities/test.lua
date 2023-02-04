AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName = "test"
ENT.Author = "Luna"
ENT.Category = "[LVS] - Other"

ENT.Spawnable		= true

if SERVER then
	function ENT:SpawnFunction( ply, tr, ClassName )
		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal * 1 )
		ent:Spawn()
		ent:Activate()

		return ent

	end

	function ENT:Initialize()	
		self:SetModel( "models/blu/hsd.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	end

	function ENT:Think()
		return true
	end
else 

	include( "entities/lvs_walker_atte/cl_ikfunctions.lua" )

	local Length1 = 140
	local Length2 = 300

	local LegData = {
		Leg1 = {MDL = "models/blu/hsd_leg_2.mdl", Ang = Angle(0,-90,-90), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/hsd_leg_4.mdl", Ang = Angle(180,90,4), Pos = Vector(20,0,-12)},
		Foot = {MDL = "models/blu/hsd_foot.mdl", Ang = Angle(0,0,0), Pos = Vector(0,-2,0)}
	}

	function ENT:Think()

		local ID = self:LookupAttachment( "leg_front_right" )
		local Att = self:GetAttachment( ID )

		local STARTPOS = Att.Pos
		local ENDPOS = util.TraceLine( { start = STARTPOS, endpos = self:LocalToWorld( Vector(80,-270,-100) ), filter = self } ).HitPos + Vector(0,0,25)

		local Pos, Ang = WorldToLocal( ENDPOS, (ENDPOS - Att.Pos):Angle(), Att.Pos, self:LocalToWorldAngles( Angle(0,-90,0) ) )

		local JointAngle = self:LocalToWorldAngles( Angle(0,180 + Ang.y,90) )

		self:GetLegEnts( 1, Length1, Length2, JointAngle, STARTPOS, ENDPOS, LegData )

		if self.IK_Joints[ 1 ] then
			if IsValid( self.IK_Joints[ 1 ].LegBaseRot ) then
				self.IK_Joints[ 1 ].LegBaseRot:SetAngles( JointAngle )
			end
			if IsValid( self.IK_Joints[ 1 ].Attachment3 ) then
				self.IK_Joints[ 1 ].Attachment3:SetAngles( self:LocalToWorldAngles( Angle(0,Ang.y,0) ) )
			end
		end
	end

	function ENT:OnRemove()
		self:OnRemoved()
	end
end