
ENT.Base = "lvs_walker_atte_hoverscript"

ENT.PrintName = "Homing Spider Droid"
ENT.Author = "Luna"
ENT.Information = "OG-9 Separatist Walker Droid"
ENT.Category = "[LVS] - Star Wars"

ENT.VehicleCategory = "Star Wars"
ENT.VehicleSubCategory = "Walkers"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.MDL = "models/blu/hsd.mdl"
ENT.GibModels = {
	"models/blu/hsd_gib.mdl",
	"models/blu/hsd_foot.mdl",
	"models/blu/hsd_leg_1.mdl",
	"models/blu/hsd_leg_2.mdl",
	"models/blu/hsd_leg_3.mdl",
	"models/blu/hsd_leg_4.mdl",
}

ENT.AITEAM = 1

ENT.MaxHealth = 6000

ENT.ForceLinearMultiplier = 1

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.HoverHeight = 250
ENT.HoverTraceLength = 300
ENT.HoverHullRadius = 50

ENT.TurretTurnRate = 100

ENT.CanMoveOn = {
	["func_door"] = true,
	["func_movelinear"] = true,
	["prop_physics"] = true,
}

ENT.lvsShowInSpawner = true

function ENT:OnSetupDataTables()
	self:AddDT( "Int", "UpdateLeg" )
	self:AddDT( "Bool", "IsRagdoll" )
	self:AddDT( "Bool", "IsMoving" )
	self:AddDT( "Bool", "NWGround" )
	self:AddDT( "Bool", "ProjectorBeam" )
	self:AddDT( "Vector", "AIAimVector" )
end

function ENT:GetEyeTrace()
	local startpos = self:GetPos()

	local pod = self:GetDriverSeat()

	if IsValid( pod ) then
		startpos = pod:LocalToWorld( Vector(0,0,33) )
	end

	local trace = util.TraceLine( {
		start = startpos,
		endpos = (startpos + self:GetAimVector() * 50000),
		filter = self:GetCrosshairFilterEnts()
	} )

	return trace
end

function ENT:GetAimVector()
	if self:GetAI() then
		return self:GetAIAimVector()
	end

	local Driver = self:GetDriver()

	if IsValid( Driver ) then
		return Driver:GetAimVector()
	else
		return self:GetForward()
	end
end

function ENT:HitGround()
	return self:GetNWGround()
end
