AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_camera.lua" )
include("shared.lua")
include("sv_contraption.lua")
include("sv_controls.lua")
include("sv_ragdoll.lua")
include("sv_ai.lua")

ENT.SpawnNormalOffset = 50
ENT.SpawnNormalOffsetSpawner = 50

function ENT:OnSpawn( PObj )
	PObj:SetMass( 5000 )

	local DriverSeat = self:AddDriverSeat( Vector(50,0,265), Angle(0,-90,0) )
	DriverSeat:SetCameraDistance( 0.75 )
	DriverSeat.HidePlayer = true

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

	-- armor points
	self:AddDSArmor( {
		pos = Vector(0,0,215),
		ang = Angle(0,0,0),
		mins = Vector(-75,-75,-85),
		maxs =  Vector(75,75,60),
		Callback = function( tbl, ent, dmginfo )
			if ent:GetHP() > 500 or self:GetIsRagdoll() then return end

			local effectdata = EffectData()
				effectdata:SetOrigin( ent:LocalToWorld( Vector(0,0,250) ) )
			util.Effect( "lvs_explosion_nodebris", effectdata )

			ent:BecomeRagdoll()
		end
	} )

	self:AddDSArmor( {
		pos = Vector(0,0,290),
		ang = Angle(0,0,0),
		mins = Vector(-30,-50,-20),
		maxs =  Vector(30,50,20),
	} )

	-- weak points
	self:AddDS( {
		pos = Vector(50,0,290),
		ang = Angle(0,0,0),
		mins = Vector(-15,-15,-15),
		maxs =  Vector(15,15,15),
		Callback = function( tbl, ent, dmginfo )
			if dmginfo:GetDamage() <= 0 then return end

			dmginfo:ScaleDamage( 2 )

			if ent:GetHP() > 1000 or self:GetIsRagdoll() then return end

			ent:BecomeRagdoll()

			local effectdata = EffectData()
				effectdata:SetOrigin( ent:LocalToWorld( Vector(0,0,250) ) )
			util.Effect( "lvs_explosion_nodebris", effectdata )
		end
	} )

	self:AddDS( {
		pos = Vector(0,115,220),
		ang = Angle(0,0,0),
		mins = Vector(-35,-35,-35),
		maxs =  Vector(35,35,35),
		Callback = function( tbl, ent, dmginfo )
			if dmginfo:GetDamage() <= 0 then return end

			dmginfo:ScaleDamage( 1.5 )

			if ent:GetHP() > 2500 or ent:GetIsRagdoll() then return end

			ent:BecomeRagdoll()

			local effectdata = EffectData()
				effectdata:SetOrigin( ent:LocalToWorld( Vector(0,0,250) ) )
			util.Effect( "lvs_explosion_nodebris", effectdata )
		end
	} )

	self:AddDS( {
		pos = Vector(0,-115,220),
		ang = Angle(0,0,0),
		mins = Vector(-35,-35,-35),
		maxs =  Vector(35,35,35),
		Callback = function( tbl, ent, dmginfo )
			if dmginfo:GetDamage() <= 0 then return end

			dmginfo:ScaleDamage( 1.5 )

			if ent:GetHP() > 2500 or ent:GetIsRagdoll() then return end

			ent:BecomeRagdoll()

			local effectdata = EffectData()
				effectdata:SetOrigin( ent:LocalToWorld( Vector(0,0,250) ) )
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
