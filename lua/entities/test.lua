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

	function ENT:Think()

		local ID = self:LookupAttachment( "leg_front_right" )
		local Att = self:GetAttachment( ID )

		local L1 = 200
		local L2 = 300
		local JOINTANG = self:LocalToWorldAngles( Angle(0,180,90) )
		local STARTPOS = Att.Pos
		local ENDPOS =  self:LocalToWorld( Vector(25,-350,0) )
		local ATTACHMENTS = {
			Leg1 = {MDL = "models/error.mdl", Ang = Angle(0,0,0), Pos = Vector(0,0,0)},
			Leg2 = {MDL = "models/blu/hsd_leg_4.mdl", Ang = Angle(180,90,4), Pos = Vector(20,0,-12)},
			Foot = {MDL = "models/blu/hsd_foot.mdl", Ang = Angle(0,0,0), Pos = Vector(0,-2,0)}
		}
		self:GetLegEnts( 1, L1, L2, JOINTANG, STARTPOS, ENDPOS, ATTACHMENTS )
	end

	function ENT:OnRemove()
		self:OnRemoved()
	end
end