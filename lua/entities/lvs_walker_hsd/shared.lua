
ENT.Base = "lvs_walker_atte_hoverscript"

ENT.PrintName = "Homing Spider Droid"
ENT.Author = "Luna"
ENT.Information = ""
ENT.Category = "[LVS] - Star Wars"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.MDL = "models/blu/hsd.mdl"
ENT.GibModels = {
	"models/blu/hsd.mdl",
	"models/blu/hsd_foot.mdl",
	"models/blu/hsd_leg_1.mdl",
	"models/blu/hsd_leg_2.mdl",
	"models/blu/hsd_leg_3.mdl",
	"models/blu/hsd_leg_4.mdl",
}

ENT.AITEAM = 1

ENT.MaxHealth = 12000

ENT.ForceLinearMultiplier = 1

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.HoverHeight = 250
ENT.HoverTraceLength = 300
ENT.HoverHullRadius = 20

ENT.TurretTurnRate = 100

ENT.CanMoveOn = {
	["func_door"] = true,
	["func_movelinear"] = true,
	["prop_physics"] = true,
}

function ENT:OnSetupDataTables()
end
