AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

ENT.SpawnNormalOffset = 25

function ENT:OnSpawn( PObj )
	PObj:SetMass( 1000 )

	self:AddDriverSeat( Vector(-28,0,50), Angle(0,-90,0) ).HidePlayer = true

	self:AddEngine(  Vector(-105,0,58) )
	self:AddEngineSound( Vector(-105,0,58) )

	self.SNDLeft = self:AddSoundEmitter( Vector(5,56.3,55), "lvs/vehicles/vwing/fire.mp3", "lvs/vehicles/vwing/fire.mp3" )
	self.SNDLeft:SetSoundLevel( 110 )

	self.SNDRight = self:AddSoundEmitter( Vector(5,-56.3,55), "lvs/vehicles/vwing/fire.mp3", "lvs/vehicles/vwing/fire.mp3" )
	self.SNDRight:SetSoundLevel( 110 )
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/vehicles/naboo_n1_starfighter/start.wav" )
	else
		self:EmitSound( "lvs/vehicles/naboo_n1_starfighter/stop.wav" )
		self:SetFoils( false )
	end
end

function ENT:OnVehicleSpecificToggled( new )
	local cur = self:GetFoils()

	if cur ~= new then
		self:SetFoils( new )
	end
end
