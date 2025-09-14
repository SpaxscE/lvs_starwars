
ENT.OpticsFov = 30
ENT.OpticsEnable = true
ENT.OpticsZoomOnly = true
ENT.OpticsFirstPerson = true
ENT.OpticsThirdPerson = false
ENT.OpticsPodIndex = {
	[1] = false,
	[2] = true,
}

ENT.OpticsCrosshairMaterial = Material( "lvs/circle_filled.png" )
ENT.OpticsCrosshairColor = Color(0,0,0,150)
ENT.OpticsCrosshairSize = 4

local circle = Material( "lvs/circle_hollow.png" )
local tri1 = Material( "lvs/triangle1.png" )
local tri2 = Material( "lvs/triangle2.png" )
local scope = Material( "lvs/scope_aat.png" )
local reticle = Material( "lvs/reticle_aat.png" )

function ENT:PaintOpticsCrosshair( Pos2D )
	local Res = 512
	local ScrW = ScrW()
	local ScrH = ScrH()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( reticle )
	surface.DrawTexturedRect( Pos2D.x - Res * 0.5, Pos2D.y - Res * 0.5, Res, Res )

	surface.SetDrawColor( 51, 218, 232, 100 )
	surface.DrawRect( Pos2D.x - 1, Pos2D.y + Res * 0.5, 2, ScrH )
	surface.DrawRect( Pos2D.x - 1, Pos2D.y - Res * 0.5 - ScrH, 2, ScrH )

	surface.DrawRect( Pos2D.x + Res * 0.5, Pos2D.y - 2, ScrW, 4 )
	surface.DrawRect( Pos2D.x - Res * 0.5 - ScrW, Pos2D.y - 2, ScrW, 4 )

	surface.SetMaterial( circle )
	surface.SetDrawColor( 51, 218, 232, 255 )
	surface.DrawTexturedRect( Pos2D.x - 8, Pos2D.y - 8, 16, 16 )
end

function ENT:PaintOptics( Pos2D, Col, PodIndex, Type )
	local size = self.OpticsCrosshairSize

	surface.SetMaterial( self.OpticsCrosshairMaterial )
	surface.SetDrawColor( self.OpticsCrosshairColor )
	surface.DrawTexturedRect( Pos2D.x - size * 0.5, Pos2D.y - size * 0.5, size, size )

	local ScrW = ScrW()
	local ScrH = ScrH()

	local diameter = ScrH + 64
	local radius = diameter * 0.5

	surface.SetMaterial( scope )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( Pos2D.x - radius, Pos2D.y - radius, diameter, diameter )

	-- black bar left + right
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, Pos2D.x - radius, ScrH )
	surface.DrawRect( Pos2D.x + radius, 0, Pos2D.x - radius, ScrH )
end

