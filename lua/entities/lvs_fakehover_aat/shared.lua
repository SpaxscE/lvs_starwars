
ENT.Base = "lvs_base_fakehover"

ENT.PrintName = "AAT"
ENT.Author = "Luna"
ENT.Information = "Trade Federation Hover Tank. Later used in the Droid army of the Separatists"
ENT.Category = "[LVS] - Star Wars"

ENT.VehicleCategory = "Star Wars"
ENT.VehicleSubCategory = "Hover Tanks"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/blu/aat_fixed.mdl"
ENT.GibModels = {
	"models/gibs/helicopter_brokenpiece_01.mdl",
	"models/gibs/helicopter_brokenpiece_02.mdl",
	"models/gibs/helicopter_brokenpiece_03.mdl",
	"models/combine_apc_destroyed_gib02.mdl",
	"models/combine_apc_destroyed_gib04.mdl",
	"models/combine_apc_destroyed_gib05.mdl",
	"models/props_c17/trappropeller_engine.mdl",
	"models/gibs/airboat_broken_engine.mdl",
}

ENT.AITEAM = 1

ENT.MaxHealth = 2000

ENT.ForceAngleMultiplier = 2
ENT.ForceAngleDampingMultiplier = 1

ENT.ForceLinearMultiplier = 1
ENT.ForceLinearRate = 0.25

ENT.MaxVelocityX = 180
ENT.MaxVelocityY = 180

ENT.MaxTurnRate = 0.5

ENT.BoostAddVelocityX = 120
ENT.BoostAddVelocityY = 120

ENT.GroundTraceHitWater = true
ENT.GroundTraceLength = 50
ENT.GroundTraceHull = 100

ENT.TurretTurnRate = 100

ENT.LAATC_PICKUPABLE = true
ENT.LAATC_DROP_IN_AIR = true
ENT.LAATC_PICKUP_POS = Vector(-260,0,0)
ENT.LAATC_PICKUP_Angle = Angle(0,0,0)

function ENT:OnSetupDataTables()
	self:AddDT( "Bool", "IsCarried" )
	self:AddDT( "Entity", "GunnerSeat" )

	if SERVER then
		self:NetworkVarNotify( "IsCarried", self.OnIsCarried )
	end
end

function ENT:GetAimAngles()
	local trace = self:GetEyeTrace()

	local AimAnglesR = self:WorldToLocalAngles( (trace.HitPos - self:LocalToWorld( Vector(10,-60,81) ) ):GetNormalized():Angle() )
	local AimAnglesL = self:WorldToLocalAngles( (trace.HitPos - self:LocalToWorld( Vector(10,60,81) ) ):GetNormalized():Angle() )

	return AimAnglesR, AimAnglesL
end

function ENT:WeaponsInRange()
	if self:GetIsCarried() then return false end

	local AimAnglesR, AimAnglesL = self:GetAimAngles()

	return not ((AimAnglesR.p >= 20 and AimAnglesL.p >= 20) or (AimAnglesR.p <= -30 and AimAnglesL.p <= -30) or (math.abs(AimAnglesL.y) + math.abs(AimAnglesL.y)) >= 60)
end

local COLOR_RED = Color(255,0,0,255)
local COLOR_WHITE = Color(255,255,255,255)
function ENT:InitWeapons()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = 600
	weapon.Delay = 0.2
	weapon.HeatRateUp = 0.25
	weapon.HeatRateDown = 0.25
	weapon.Attack = function( ent )
		if not ent:WeaponsInRange() then return true end

		local ID_L = ent:LookupAttachment( "muzzle_left" )
		local ID_R = ent:LookupAttachment( "muzzle_right" )
		local MuzzleL = ent:GetAttachment( ID_L )
		local MuzzleR = ent:GetAttachment( ID_R )

		if not MuzzleL or not MuzzleR then return end

		ent.MirrorPrimary = not ent.MirrorPrimary

		local Pos = ent.MirrorPrimary and MuzzleL.Pos or MuzzleR.Pos
		local Dir =  (ent.MirrorPrimary and MuzzleL.Ang or MuzzleR.Ang):Forward()

		local bullet = {}
		bullet.Src 	= Pos
		bullet.Dir 	= Dir
		bullet.Spread 	= Vector( 0.01,  0.01, 0 )
		bullet.TracerName = "lvs_laser_red_short"
		bullet.Force	= 11000
		bullet.HullSize 	= 1
		bullet.Damage	= 25
		bullet.Velocity = 12000
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
			local effectdata = EffectData()
				effectdata:SetStart( Vector(255,50,50) ) 
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetNormal( tr.HitNormal )
			util.Effect( "lvs_laser_impact", effectdata )
		end
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetStart( Vector(255,50,50) )
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( Dir )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle_colorable", effectdata )

		ent:TakeAmmo()

		if ent.MirrorPrimary then
			if not IsValid( ent.SNDLeft ) then return end
	
			ent.SNDLeft:PlayOnce()

			return
		end

		if not IsValid( ent.SNDRight ) then return end

		ent.SNDRight:PlayOnce()
	end
	weapon.OnSelect = function( ent )
		ent:EmitSound("physics/metal/weapon_impact_soft3.wav")
	end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	weapon.OnThink = function( ent, active )
		if ent:GetIsCarried() then
			self:SetPoseParameter("cannon_right_pitch", 0 )
			self:SetPoseParameter("cannon_right_yaw", 0 )

			self:SetPoseParameter("cannon_left_pitch", 0 )
			self:SetPoseParameter("cannon_left_yaw", 0 )

			return
		end

		local AimAnglesR, AimAnglesL = ent:GetAimAngles()

		ent:SetPoseParameter("cannon_right_pitch", AimAnglesR.p )
		ent:SetPoseParameter("cannon_right_yaw", AimAnglesR.y )

		ent:SetPoseParameter("cannon_left_pitch", AimAnglesL.p )
		ent:SetPoseParameter("cannon_left_yaw", AimAnglesL.y )
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		if base:GetIsCarried() then return false end


		local Col = base:WeaponsInRange() and COLOR_WHITE or COLOR_RED

		local Pos2D = base:GetEyeTrace().HitPos:ToScreen() 

		ent:PaintCrosshairCenter( Pos2D, Col )
		ent:PaintCrosshairOuter( Pos2D, Col )
		ent:LVSPaintHitMarker( Pos2D )
	end
	self:AddWeapon( weapon )


	local weapon = {}
	weapon.Icon = Material("lvs/weapons/missile.png")
	weapon.Ammo = 60
	weapon.Delay = 1
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0.2
	weapon.Attack = function( ent )
		if not ent:WeaponsInRange() then return true end

		local Driver = ent:GetDriver()

		local MissileAttach = {
			[1] = {
				left = "missile_1l",
				right = "missile_1r"
			},
			[2] = {
				left = "missile_2l",
				right = "missile_2r"
			},
			[3] = {
				left = "missile_3l",
				right = "missile_3r"
			},
		}

		for i = 1, 3 do
			timer.Simple( (i / 5) * 0.75, function()
				if not IsValid( ent ) then return end

				if ent:GetAmmo() <= 0 then ent:SetHeat( 1 ) return end

				local ID_L = ent:LookupAttachment( MissileAttach[i].left )
				local ID_R = ent:LookupAttachment( MissileAttach[i].right )
				local MuzzleL = ent:GetAttachment( ID_L )
				local MuzzleR = ent:GetAttachment( ID_R )

				if not MuzzleL or not MuzzleR then return end

				local swap = false

				for i = 1, 2 do
					local Pos = swap and MuzzleL.Pos or MuzzleR.Pos
					local Start = Pos + ent:GetForward() * 50
					local Dir = (ent:GetEyeTrace().HitPos - Start):GetNormalized()
					if not ent:WeaponsInRange() then
						Dir = swap and MuzzleL.Ang:Forward() or MuzzleR.Ang:Forward()
					end

					local projectile = ents.Create( "lvs_missile" )
					projectile:SetPos( Start )
					projectile:SetAngles( Dir:Angle() )
					projectile:SetParent( ent )
					projectile:Spawn()
					projectile:Activate()
					projectile.GetTarget = function( missile ) return missile end
					projectile.GetTargetPos = function( missile )
						return missile:LocalToWorld( Vector(150,0,0) + VectorRand() * math.random(-10,10) )
					end
					projectile:SetAttacker( IsValid( Driver ) and Driver or self )
					projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )
					projectile:SetDamage( 300 )
					projectile:SetRadius( 150 )
					projectile:Enable()
					projectile:EmitSound( "LVS.AAT.FIRE_MISSILE" )

					ent:TakeAmmo( 1 )

					swap = true
				end
			end)
		end

		ent:SetHeat( 1 )
		ent:SetOverheated( true )
	end
	weapon.OnSelect = function( ent )
		ent:EmitSound("weapons/shotgun/shotgun_cock.wav")
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		if ent:GetIsCarried() then return false end


		local Col = base:WeaponsInRange() and COLOR_WHITE or COLOR_RED

		local Pos2D = base:GetEyeTrace().HitPos:ToScreen() 

		ent:PaintCrosshairSquare( Pos2D, Col )
		ent:LVSPaintHitMarker( Pos2D )
	end
	self:AddWeapon( weapon )

	self:InitTurret()
end

function ENT:InitTurret()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = -1
	weapon.Delay = 0.3
	weapon.HeatRateUp = 1.25
	weapon.HeatRateDown = 0.2
	weapon.OnOverheat = function( ent )
		ent:EmitSound("lvs/vehicles/aat/overheat.mp3")
	end
	weapon.Attack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		if base:GetIsCarried() then return true end

		local ID = base:LookupAttachment( "muzzle" )
		local Muzzle = base:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= Muzzle.Ang:Forward()
		bullet.Spread 	= Vector(0,0,0)
		bullet.TracerName = "lvs_laser_red_aat"
		bullet.Force	= 16000
		bullet.HullSize 	= 0
		bullet.Damage	= 500
		bullet.SplashDamage = 250
		bullet.SplashDamageRadius = 250
		bullet.Velocity = 12000
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
			local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
			util.Effect( "lvs_laser_explosion_aat", effectdata )
		end
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetStart( Vector(255,50,50) )
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( Muzzle.Ang:Forward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle_colorable", effectdata )

		ent:TakeAmmo()

		base:PlayAnimation( "fire" )

		local PhysObj = base:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceOffset( -Muzzle.Ang:Forward() * 25000, Muzzle.Pos )
		end

		if not IsValid( base.SNDTurret ) then return end

		base.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + ent:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not base.GetTurretEnabled then return end

		if not base:GetTurretEnabled() then return end
		local ID = base:LookupAttachment( "muzzle" )

		local Muzzle = base:GetAttachment( ID )

		if Muzzle then
			local traceTurret = util.TraceLine( {
				start = Muzzle.Pos,
				endpos = Muzzle.Pos + Muzzle.Ang:Forward() * 50000,
				filter = base:GetCrosshairFilterEnts()
			} )

			local MuzzlePos2D = traceTurret.HitPos:ToScreen() 

			ent:PaintCrosshairSquare( MuzzlePos2D, COLOR_WHITE )
			ent:LVSPaintHitMarker( MuzzlePos2D )
		end
	end
	weapon.OnThink = function( ent, active )
		if ent:GetSelectedWeapon() ~= 1 then return end

		local base = ent:GetVehicle()

		if not IsValid( base ) or not base.SetTurretEnabled then return end

		if base:GetIsCarried() then
			if base:GetTurretEnabled() then
				base:SetTurretEnabled( false )
			end

			return
		end

		if base:GetTurretEnabled() then return end

		base:SetTurretEnabled( true )
	end
	self:AddWeapon( weapon, 2 )

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/tank_noturret.png")
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	weapon.OnSelect = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		if base.SetTurretForceCenter then
			base:SetTurretForceCenter( true )
		end
	end
	weapon.OnDeselect = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		if base.SetTurretForceCenter then
			base:SetTurretForceCenter( false )
		end
	end
	self:AddWeapon( weapon, 2 )
end

ENT.EngineSounds = {
	{
		sound = "lvs/vehicles/aat/loop.wav",
		Pitch = 70,
		PitchMin = 0,
		PitchMax = 255,
		PitchMul = 30,
		FadeIn = 0,
		FadeOut = 1,
		FadeSpeed = 1.5,
		UseDoppler = true,
		SoundLevel = 85,
	},
	{
		sound = "lvs/vehicles/aat/loop_hi.wav",
		Pitch = 70,
		PitchMin = 0,
		PitchMax = 255,
		PitchMul = 30,
		FadeIn = 0,
		FadeOut = 1,
		FadeSpeed = 1.5,
		UseDoppler = true,
		SoundLevel = 85,
	},
	{
		sound = "^lvs/vehicles/aat/dist.wav",
		Pitch = 70,
		PitchMin = 0,
		PitchMax = 255,
		PitchMul = 30,
		FadeIn = 0,
		FadeOut = 1,
		FadeSpeed = 1.5,
		SoundLevel = 90,
	},
}

sound.Add( {
	name = "LVS.AAT.FIRE_MISSILE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lvs/vehicles/aat/fire_missile.mp3"
} )

sound.Add( {
	name = "LVS.AAT.LASER_EXPLOSION",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {160, 180},
	sound = {
		"lvs/vehicles/aat/turret/impact1.ogg",
		"lvs/vehicles/aat/turret/impact2.ogg",
		"lvs/vehicles/aat/turret/impact3.ogg",
		"lvs/vehicles/aat/turret/impact4.ogg"
	}
} )