
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
local scopeheat = Material( "lvs/scope_aat_heatwarning.png" )
local reticle = Material( "lvs/reticle_aat.png" )
local reticleheat = Material( "lvs/reticle_heat_aat.png" )

function ENT:PaintOpticsCrosshair( Pos2D )
	local Res = 512
	local ScrW = ScrW()
	local ScrH = ScrH()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( reticle )
	surface.DrawTexturedRect( Pos2D.x - Res * 0.5, Pos2D.y - Res * 0.5, Res, Res )

	local Res05 = Res * 0.5

	local pod = self:GetGunnerSeat()
	if IsValid( pod ) then
		local weapon = pod:lvsGetWeapon()
		if IsValid( weapon ) then
			local heat = weapon:GetNWHeat()
			local invheat = 1 - heat
			local min = 0.38
			local max = 0.65
			local Mul = min * heat + max * invheat

			local invheatexp = invheat
			local heatexp = heat ^ 2
			local R = 51 * invheatexp + 255 * heatexp
			local G = 218 * invheatexp
			local B = 232 * invheatexp
	
			surface.SetMaterial( reticleheat )
			surface.SetDrawColor( R, G, B, 255 )

			render.SetScissorRect( Pos2D.x - Res05, Pos2D.y - Res05 + Res * Mul, Pos2D.x + Res05, Pos2D.y + Res05 , true )
				surface.DrawTexturedRect( Pos2D.x - Res05, Pos2D.y - Res05, Res, Res )
			render.SetScissorRect( 0, 0, 0, 0, false )
		end
	end

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

	local pod = self:GetGunnerSeat()
	if IsValid( pod ) then
		local weapon = pod:lvsGetWeapon()
		if IsValid( weapon ) and weapon:GetNWOverheated() then
			surface.SetMaterial( scopeheat )
			surface.SetDrawColor( 255, 0, 0, 255 * math.abs( math.cos( CurTime() * 7 ) ) )
			surface.DrawTexturedRect( Pos2D.x - radius, Pos2D.y - radius, diameter, diameter )
		end
	end

	-- black bar left + right
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, Pos2D.x - radius, ScrH )
	surface.DrawRect( Pos2D.x + radius, 0, Pos2D.x - radius, ScrH )
end

