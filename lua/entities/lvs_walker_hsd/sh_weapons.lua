
function ENT:AimTurretSecondary()
	local trace = self:GetEyeTrace()

	local AimAngles = self:WorldToLocalAngles( (trace.HitPos - self:LocalToWorld( Vector(0,0,100)) ):GetNormalized():Angle() )

	self:SetPoseParameter("turret_secondary_pitch", -AimAngles.p )
	self:SetPoseParameter("turret_secondary_yaw", AimAngles.y )
end

function ENT:WeaponsInRange()
	local Forward = self:GetForward()
	local AimForward = self:GetAimVector()

	return self:AngleBetweenNormal( Forward, AimForward ) < 45
end

function ENT:InitWeapons()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = 100
	weapon.Delay = 0.5
	weapon.HeatRateUp = 0.5
	weapon.HeatRateDown = 0.4
	weapon.OnOverheat = function( ent )
		timer.Simple( 0.4, function()
			if not IsValid( ent ) then return end

			ent:EmitSound("lvs/overheat.wav")
		end )
	end
	weapon.Attack = function( ent )
		if not ent:WeaponsInRange() then return true end

		local effectdata = EffectData()
		effectdata:SetOrigin( ent:LocalToWorld( Vector(0,0,200) ) )
		effectdata:SetEntity( ent )
		effectdata:SetAttachment( ent:LookupAttachment( "muzzle_secondary" ) )
		util.Effect( "lvs_laser_charge", effectdata )

		timer.Simple( 0.4, function()
			if not IsValid( ent ) then return end

			local ID = ent:LookupAttachment( "muzzle_secondary" )
			local Muzzle = ent:GetAttachment( ID )

			if not Muzzle then return end

			local bullet = {}
			bullet.Src 	= Muzzle.Pos
			bullet.Dir 	= ent:WeaponsInRange() and (ent:GetEyeTrace().HitPos - Muzzle.Pos):GetNormalized() or -Muzzle.Ang:Right()
			bullet.Spread 	= Vector(0,0,0)
			bullet.TracerName = "lvs_laser_red_aat"
			bullet.Force	= 10
			bullet.HullSize 	= 1
			bullet.Damage	= 200
			bullet.SplashDamage = 300
			bullet.SplashDamageRadius = 250
			bullet.Velocity = 10000
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
			effectdata:SetNormal( Muzzle.Ang:Up() )
			effectdata:SetEntity( ent )
			util.Effect( "lvs_muzzle_colorable", effectdata )

			ent:TakeAmmo()

			if not IsValid( ent.SNDTurret ) then return end

			ent.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + ent:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )
		end )
	end
	weapon.OnThink = function( ent, active )
		ent:AimTurretSecondary()
	end
	self:AddWeapon( weapon )
end