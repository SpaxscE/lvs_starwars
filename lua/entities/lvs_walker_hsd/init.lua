AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_camera.lua" )
AddCSLuaFile( "cl_prediction.lua" )
AddCSLuaFile( "sh_weapons.lua" )
include("shared.lua")
include("sv_contraption.lua")
include("sv_controls.lua")
include("sv_ragdoll.lua")
include("sv_ai.lua")
include("sh_weapons.lua")

ENT.SpawnNormalOffset = 50
ENT.SpawnNormalOffsetSpawner = 50

function ENT:OnSpawn( PObj )
	PObj:SetMass( 5000 )

	local DriverSeat = self:AddDriverSeat( Vector(50,0,265), Angle(0,-90,0) )
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
	self:AddArmor( Vector(0,0,215), Angle(0,0,0), Vector(-75,-75,-85),Vector(75,75,60), 800, 5000 )
	self:AddArmor( Vector(0,0,290), Angle(0,0,0), Vector(-30,-50,-20),Vector(30,50,20), 400, 5000 )

	-- weak points
	self:AddDS( {
		pos = Vector(50,0,290),
		ang = Angle(0,0,0),
		mins = Vector(-15,-15,-15),
		maxs =  Vector(15,15,15),
		Callback = function( tbl, ent, dmginfo )
			if dmginfo:GetDamage() <= 0 then return end

			dmginfo:ScaleDamage( 2 )

			if ent:GetHP() > 1500 or self:GetIsRagdoll() then return end

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

	local ID = self:LookupAttachment( "muzzle_primary" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDProjector = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/hsd/fire_projector.mp3", "lvs/vehicles/hsd/fire_projector.mp3" )
	self.SNDProjector:SetSoundLevel( 95 )
	self.SNDProjector:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle_secondary" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/hsd/fire.mp3", "lvs/vehicles/hsd/fire.mp3" )
	self.SNDTurret:SetSoundLevel( 110 )
	self.SNDTurret:SetParent( self, ID )
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

function ENT:ProjectorBeamDamage( target, attacker, HitPos, HitDir )
	if not IsValid( target ) then return end

	if not IsValid( attacker ) then
		attacker = self
	end

	if target ~= self then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( 250 * FrameTime() )
		dmginfo:SetAttacker( attacker )
		dmginfo:SetDamageType( DMG_SHOCK + DMG_ENERGYBEAM + DMG_AIRBOAT )
		dmginfo:SetInflictor( self ) 
		dmginfo:SetDamagePosition( HitPos ) 
		dmginfo:SetDamageForce( HitDir * 20000 ) 
		target:TakeDamageInfo( dmginfo )
	end
end
