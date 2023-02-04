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
		self:SetModel( "models/blu/hsd_leg_1.mdl" )
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

	local Length3 = 20
	local Length4 = 20

	local LegData1 = {
		Leg1 = {MDL = "models/blu/hsd_leg_2.mdl", Ang = Angle(0,-90,-90), Pos = Vector(0,0,0)},
		Leg2 = {MDL = "models/blu/hsd_leg_4.mdl", Ang = Angle(180,90,4), Pos = Vector(20,0,-12)},
		Foot = {MDL = "models/blu/hsd_foot.mdl", Ang = Angle(0,0,0), Pos = Vector(0,-2,0)}
	}

	local LegData2 = {
		Leg1 = {MDL = "models/blu/hsd_leg_3.mdl", Ang = Angle(0,90,-90), Pos = Vector(0,0,0)},
	}

	function ENT:Think()
		--self:SetAngles( Angle(0,math.cos( CurTime() * 2) * 10,0) )

		local ID = self:LookupAttachment( "lower" )
		local Att = self:GetAttachment( ID )

		local ENDPOS = util.TraceLine( { start = Att.Pos, endpos = self:LocalToWorld( Vector(0,-270,-300) ), filter = self } ).HitPos + Vector(0,0,25)

		local Pos, Ang = WorldToLocal( ENDPOS, (ENDPOS - Att.Pos):Angle(), Att.Pos, self:LocalToWorldAngles( Angle(0,-90,0) ) )

		local STARTPOS = Att.Pos

		local JointAngle = self:LocalToWorldAngles( Angle(0,180,90) )

		self:GetLegEnts( 1, Length1, Length2, JointAngle, STARTPOS, ENDPOS, LegData1 )

		if not self.IK_Joints[ 1 ] or not IsValid( self.IK_Joints[ 1 ].Attachment2 ) then return end

		local shaft = self.IK_Joints[ 1 ].Attachment2

		local ID1 = self:LookupAttachment( "upper" )
		local Start = self:GetAttachment( ID1 )

		local ID2 = shaft:LookupAttachment( "upper_end" )
		local End = shaft:GetAttachment( ID2 )

		self:GetLegEnts( 2, Length3, Length4, JointAngle, Start.Pos, End.Pos, LegData2 )

		if not self.IK_Joints[ 2 ] or not IsValid( self.IK_Joints[ 2 ].Attachment1 ) then return end

		local strut = self.IK_Joints[ 2 ].Attachment1
		strut:SetPoseParameter( "extrude", (Start.Pos - End.Pos):Length() )
		strut:InvalidateBoneCache()
	end

	function ENT:OnRemove()
		self:OnRemoved()
	end
end