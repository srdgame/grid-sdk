--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Image class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local images = image and image.images or {}

local graphics = love.graphics

class( "image" )

image.images = images

local modtime  = nil
local errormsg = nil

local function reloadImage( i, filename )
	-- i.image = nil
	print( "Reloading " .. filename .. "..." )
	local status, ret = pcall( graphics.newImage, filename )
	i.modtime = modtime
	if ( status == false ) then
		print( ret )
	else
		i.image = ret

		if ( game ) then
			game.call( "client", "onReloadImage", filename )
		else
			hook.call( "client", "onReloadImage", filename )
		end
	end
end

function image.update( dt )
	for filename, i in pairs( images ) do
		local info, errormsg = love.filesystem.getInfo( filename )
		if ( info and info.modtime ~= i.modtime ) then
			reloadImage( i, filename )
		end
	end
end

function image:image( filename )
	self:setFilename( filename )
end

function image:getDrawable()
	local filename = self:getFilename()
	if ( not filename ) then
		if ( self._image ) then
			return self._image
		else
			return _G.graphics.error:getDrawable()
		end
	end

	if ( not images[ filename ] ) then
		local image = graphics.newImage( filename )
		local info = love.filesystem.getInfo( filename ) or {}
		images[ filename ] = {
			image   = image,
			modtime = info.modtime
		}
	end

	return images[ filename ].image
end

accessor( image, "filename" )

function image:getHeight()
	local image = self:getDrawable()
	return image:getHeight()
end

function image:getWidth()
	local image = self:getDrawable()
	return image:getWidth()
end

function image:getData()
	if ( not self._image ) then
		return nil
	end

	return self._imageData
end

function image:refresh()
	if self._image then
		return self.image:replacePixels(self._imageData)
	end
end

function image:setImageData( imageData )
	self._imageData = imageData
	if ( self._image ) then
		self._image:replacePixels( imageData )
	else
		self._image = graphics.newImage( imageData )
	end
end

function image:setFilter( min, mag, anisotropy )
	local image = self:getDrawable()
	image:setFilter( min, mag, anisotropy )
end

local function getHighResolutionVariant( filename )
	local extension = "." .. string.fileextension( filename )
	local hrvariant = string.gsub( filename, extension, "" )
	hrvariant       = hrvariant .. "@2x" .. extension

	if ( love.filesystem.getInfo( hrvariant ) ) then
		return hrvariant
	end
end

function image:setFilename( filename )
	if ( love.window.getDPIScale() > 1 ) then
		local variant = getHighResolutionVariant( filename )
		if ( variant ) then
			filename = variant
		end
	end

	self.filename = filename
end

function image:setWrap( horiz, vert )
	local image = self:getDrawable()
	image:setWrap( horiz, vert )
end

function image:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "image" )
	setmetatable( self, t )
	return s
end
