include("shared.lua")


ENT.GlowPos1 = Vector(46,-2.89,294.88)
ENT.GlowPos2 = Vector(41.15,5.82,295.63)
ENT.GlowColor = Color( 255, 0, 0, 255)
ENT.GlowMaterial = Material( "sprites/light_glow02_add" )

function ENT:PreDrawTranslucent()
	
	render.SetMaterial( self.GlowMaterial )
	render.DrawSprite( self:LocalToWorld( self.GlowPos1 ), 32, 32, self.GlowColor )
	render.DrawSprite( self:LocalToWorld( self.GlowPos2 ), 16, 16, self.GlowColor )

	return false
end