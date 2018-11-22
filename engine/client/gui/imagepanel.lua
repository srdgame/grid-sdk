--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Image class
--
--==========================================================================--

class "gui.imagepanel" ( "gui.panel" )

local imagepanel = gui.imagepanel

function imagepanel:imagepanel( parent, name, image )
	gui.panel.panel( self, parent, name )
	self.color      = color( 255, 255, 255, 255 )
	self.imageDatum = nil
	self.imageQuad  = nil
	self:setImage( image )
end

function imagepanel:draw()
	local image = self:getImage()
	if ( image ) then
		gui.panel._maskedPanel = self
		love.graphics.stencil( gui.panel.drawMask )
		love.graphics.setStencilTest( "greater", 0 )
			love.graphics.setColor( self:getColor() )
			love.graphics.draw( image, self:getQuad() )
		love.graphics.setStencilTest()
	else
		self:drawMissingImage()
	end
end

function imagepanel:drawMissingImage()
	love.graphics.setColor( color( color.red, 255 * 0.42 ) )
	love.graphics.setLineStyle( "rough" )
	local lineWidth = 1
	local width     = self:getWidth()
	local height    = self:getHeight()
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		width - lineWidth / 2, 0,                      -- Top-right
		width - lineWidth / 2, height - lineWidth / 2, -- Bottom-right
		0,                     height - lineWidth / 2  -- Bottom-left
	)
end

accessor( imagepanel, "color" )
accessor( imagepanel, "quad",  "imageQuad" )
accessor( imagepanel, "image", "imageDatum" )

function imagepanel:setImage( image )
	if ( type( image ) == "image" ) then
		self.imageDatum = image
	elseif ( image ~= nil and love.filesystem.getInfo( image ) ) then
		self.imageDatum = love.graphics.newImage( image )
		self.imageDatum:setFilter( "linear", "linear" )
	else
		self.imageDatum = nil
	end

	self:updateQuad()
end

function imagepanel:setWidth( width )
	gui.panel.setWidth( self, width )
	self:updateQuad()
end

function imagepanel:setHeight( height )
	gui.panel.setHeight( self, height )
	self:updateQuad()
end

function imagepanel:updateQuad()
	local missingImage = self:getImage() == nil
	if ( missingImage ) then
		return
	end

	local w  = self:getWidth()  - ( missingImage and love.window.toPixels( 1 ) or 0 )
	local h  = self:getHeight() - ( missingImage and love.window.toPixels( 1 ) or 0 )
	local sw = self.imageDatum:getWidth()
	local sh = self.imageDatum:getHeight()
	if ( self.imageQuad == nil ) then
		self.imageQuad = love.graphics.newQuad( 0, 0, w, h, sw, sh )
	else
		self.imageQuad:setViewport( 0, 0, w, h )
	end
end
