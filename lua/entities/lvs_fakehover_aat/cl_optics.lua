
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
local scope = Material( "lvs/scope_viewblocked.png" )

function ENT:PaintOpticsCrosshair( Pos2D )
	surface.SetDrawColor( 255, 255, 255, 5 )
	surface.SetMaterial( tri1 )
	surface.DrawTexturedRect( Pos2D.x - 17, Pos2D.y - 1, 32, 32 )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawTexturedRect( Pos2D.x - 16, Pos2D.y, 32, 32 )

	for i = -3, 3, 1 do
		if i == 0 then continue end

		surface.SetMaterial( tri2 )
		surface.SetDrawColor( 255, 255, 255, 5 )
		surface.DrawTexturedRect( Pos2D.x - 11 + i * 32, Pos2D.y - 1, 20, 20 )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawTexturedRect( Pos2D.x - 10 + i * 32, Pos2D.y, 20, 20 )
	end

	local ScrH = ScrH()

	local Y = Pos2D.y + 64
	local height = ScrH - Y

	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( Pos2D.x - 2,  Y, 4, height )
end

function ENT:PaintOptics( Pos2D, Col, PodIndex, Type )
	local size = self.OpticsCrosshairSize

	surface.SetMaterial( self.OpticsCrosshairMaterial )
	surface.SetDrawColor( self.OpticsCrosshairColor )
	surface.DrawTexturedRect( Pos2D.x - size * 0.5, Pos2D.y - size * 0.5, size, size )

	local ScrW = ScrW()
	local ScrH = ScrH()

	surface.SetDrawColor( 0, 0, 0, 200 )

	local diameter = ScrH + 64
	local radius = diameter * 0.5

	surface.SetMaterial( scope )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawTexturedRect( Pos2D.x - radius, Pos2D.y - radius, diameter, diameter )

	-- black bar left + right
	surface.DrawRect( 0, 0, Pos2D.x - radius, ScrH )
	surface.DrawRect( Pos2D.x + radius, 0, Pos2D.x - radius, ScrH )
end

