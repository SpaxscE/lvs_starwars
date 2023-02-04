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

		local ID = self:LookupAttachment( "leg_front_right" ) 
		local att = self:GetAttachment( ID )

		local leg = ents.Create( "prop_dynamic" )
		leg:SetModel("models/blu/hsd_leg.mdl")
		leg:SetPos( att.Pos )
		leg:SetAngles( self:LocalToWorldAngles( Angle(0,0,0) ) )
		leg:Spawn()
		leg:Activate()
		leg:SetParent( self, ID )

		self.leg = leg
	end

	function ENT:Test()
	
		local up = self:GetUp()
		local ID = self.leg:LookupAttachment( "trace_start" ) 
		local att = self.leg:GetAttachment( ID )

		local trace = util.TraceLine( {
			start = att.Pos,
			endpos = att.Pos - up * 1000,
			filter = self,
		} )

		local Z = self.leg:WorldToLocal( trace.HitPos + up * 216 ).z

		self.leg:SetPoseParameter( "leg_z", Z  )

		debugoverlay.Cross( att.Pos, 50, 0.1, Color( 0, 255, 255 ) )
	end

	function ENT:Think()
		self:NextThink( CurTime() )

		if IsValid( self.leg ) then
			self:Test()
		end

		return true
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end