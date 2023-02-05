AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")
include("sv_contraption.lua")
include("sv_controls.lua")
include("sv_ragdoll.lua")
include("sv_ai.lua")

ENT.SpawnNormalOffset = 50
ENT.SpawnNormalOffsetSpawner = 50

function ENT:OnSpawn( PObj )
	PObj:SetMass( 5000 )

	local DriverSeat = self:AddDriverSeat( Vector(0,0,190), Angle(0,-90,0) )
	DriverSeat:SetCameraDistance( 0.75 )

	local Legs = {
		[1] = {
			id = "FL",
			name = "leg_front_left",
			ang = 180,
		},
		[2] = {
			id = "FR",
			name = "leg_front_right",
			ang = 0,
		},
		[3] = {
			id = "RL",
			name = "leg_rear_left",
			ang = 180,
		},
		[4] = {
			id = "RR",
			name = "leg_rear_right",
			ang = 0,
		},
	}

	for _, data in pairs( Legs ) do
		local ID = self:LookupAttachment( data.name )
		local Att = self:GetAttachment( ID )

		if not Att then self:Remove() return end

		local Leg = ents.Create( "lvs_walker_hsd_leg" )
		Leg:SetPos( Att.Pos )
		Leg:SetAngles( self:LocalToWorldAngles( Angle(0,data.ang,0) ) )
		Leg:Spawn()
		Leg:Activate()
		Leg:SetParent( self, ID )
		Leg:SetBase( self )
		Leg:SetLocationIndex( data.id )
	end

	self:AddDS( {
		pos = Vector(0,0,200),
		ang = Angle(0,0,0),
		mins = Vector(-100,-100,-100),
		maxs =  Vector(100,100,100),
		Callback = function( tbl, ent, dmginfo )
			if dmginfo:GetDamage() <= 0 then return end

			if ent:GetHP() > 1000 or self:GetIsRagdoll() then return end

			ent:BecomeRagdoll()

			local effectdata = EffectData()
				effectdata:SetOrigin( self:LocalToWorld( Vector(0,0,80) ) )
			util.Effect( "lvs_explosion_nodebris", effectdata )
		end
	} )
end

function ENT:OnTick()
	self:ContraptionThink()
end

function ENT:OnMaintenance()
	self:UnRagdoll()
end

function ENT:AlignView( ply, SetZero )
	if not IsValid( ply ) then return end

	timer.Simple( 0, function()
		if not IsValid( ply ) or not IsValid( self ) then return end

		ply:SetEyeAngles( Angle(0,90,0) )
	end)
end
