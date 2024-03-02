
hook.Add( "LVS:Initialize", "[LVS] - Star Wars - Keys", function()
	local KEYS = {
		{
			name = "+THRUST_SF",
			category = "LVS-Starfighter",
			name_menu = "Thrust Increase",
			default = "+forward",
			cmd = "lvs_starfighter_throttle_up"
		},
		{
			name = "-THRUST_SF",
			category = "LVS-Starfighter",
			name_menu = "Thrust Decrease",
			default = "+back",
			cmd = "lvs_starfighter_throttle_down"
		},
		{
			name = "+PITCH_SF",
			category = "LVS-Starfighter",
			name_menu = "Pitch Up",
			default = "+speed",
			cmd = "lvs_starfighter_pitch_up"
		},
		{
			name = "-PITCH_SF",
			category = "LVS-Starfighter",
			name_menu = "Pitch Down",
			cmd = "lvs_starfighter_pitch_down"
		},
		{
			name = "-YAW_SF",
			category = "LVS-Starfighter",
			name_menu = "Yaw Left [Roll in Direct Input]",
			cmd = "lvs_starfighter_yaw_left"
		},
		{
			name = "+YAW_SF",
			category = "LVS-Starfighter",
			name_menu = "Yaw Right [Roll in Direct Input]",
			cmd = "lvs_starfighter_yaw_right"
		},
		{
			name = "-ROLL_SF",
			category = "LVS-Starfighter",
			name_menu = "Roll Left [Yaw in Direct Input]",
			default = "+moveleft",
			cmd = "lvs_starfighter_roll_left"
		},
		{
			name = "+ROLL_SF",
			category = "LVS-Starfighter",
			name_menu = "Roll Right [Yaw in Direct Input]",
			default = "+moveright",
			cmd = "lvs_starfighter_roll_right"
		},
		{
			name = "+VTOL_Z_SF",
			category = "LVS-Starfighter",
			name_menu = "VTOL Up",
			cmd = "lvs_starfighter_vtol_up"
		},
		{
			name = "-VTOL_Z_SF",
			category = "LVS-Starfighter",
			name_menu = "VTOL Down",
			cmd = "lvs_starfighter_vtol_dn"
		},
		{
			name = "-VTOL_Y_SF",
			category = "LVS-Starfighter",
			name_menu = "VTOL Right",
			cmd = "lvs_starfighter_vtol_right"
		},
		{
			name = "+VTOL_Y_SF",
			category = "LVS-Starfighter",
			name_menu = "VTOL Left",
			cmd = "lvs_starfighter_vtol_left"
		},
		{
			name = "-VTOL_X_SF",
			category = "LVS-Starfighter",
			name_menu = "VTOL Reverse",
			default = "+back",
			cmd = "lvs_starfighter_vtol_reverse"
		},
	}

	for _, v in pairs( KEYS ) do
		LVS:AddKey( v.name, v.category, v.name_menu, v.cmd, v.default )
	end
end )

LVS:AddWeaponPreset( "TURBO", {
	Icon = Material("lvs/weapons/nos.png"),
	HeatRateUp = 0.1,
	HeatRateDown = 0.1,
	UseableByAI = false,
	Attack = function( ent )
		local PhysObj = ent:GetPhysicsObject()
		if not IsValid( PhysObj ) then return end
		local THR = ent:GetThrottle()
		local FT = FrameTime()

		local Vel = ent:GetVelocity():Length()

		PhysObj:ApplyForceCenter( ent:GetForward() * math.Clamp(ent.MaxVelocity + 500 - Vel,0,1) * PhysObj:GetMass() * THR * FT * 150 ) -- increase speed
		PhysObj:AddAngleVelocity( PhysObj:GetAngleVelocity() * FT * 0.5 * THR ) -- increase turn rate
	end,
	StartAttack = function( ent )
		ent.TargetThrottle = 1.3
		ent:EmitSound("lvs/vehicles/generic/boost.wav")
	end,
	FinishAttack = function( ent )
		ent.TargetThrottle = 1
	end,
	OnSelect = function( ent )
		ent:EmitSound("buttons/lever5.wav")
	end,
	OnThink = function( ent, active )
		if not ent.TargetThrottle then return end

		local Rate = FrameTime() * 0.5

		ent:SetMaxThrottle( ent:GetMaxThrottle() + math.Clamp(ent.TargetThrottle - ent:GetMaxThrottle(),-Rate,Rate) )

		local MaxThrottle = ent:GetMaxThrottle()

		ent:SetThrottle( MaxThrottle )

		if MaxThrottle == ent.TargetThrottle then
			ent.TargetThrottle = nil
		end
	end,
	OnOverheat = function( ent ) ent:EmitSound("lvs/overheat_boost.wav") end,
} )

if CLIENT then return end

resource.AddWorkshop("2919757295")