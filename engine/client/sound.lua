--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Sound class
--
--==========================================================================--

class( "sound" )

sound._sounds = sound._sounds or {}

local function copy( k )
	if ( string.find( k, "__" ) == 1 ) then
		return
	end

	sound[ k ] = function( self, ... )
		local filename = self:getFilename()
		local sound = sound._sounds[ filename ]
		if ( sound == nil ) then
			return
		end

		local self = sound.sound
		return self[ k ]( self, ... )
	end
end

local _R = debug.getregistry()
for k in pairs( _R.Source ) do
	copy( k )
end

local function reload( filename )
	print( "Updating " .. filename .. "..." )

	local status, ret = pcall( love.audio.newSource, filename )
	if ( status == true ) then
		local info, errormsg = love.filesystem.getInfo( filename )
		sound._sounds[ filename ].sound   = ret
		sound._sounds[ filename ].modtime = info.modtime

		if ( game ) then
			game.call( "client", "onReloadSound", filename )
		else
			hook.call( "client", "onReloadSound", filename )
		end
	else
		print( ret )
	end
end

function sound.update( dt )
	for k, v in pairs( sound._sounds ) do
		local info, errormsg = love.filesystem.getInfo( k )
		if ( info and info.modtime ~= v.modtime ) then
			reload( k )
		end
	end
end

function sound.reload( library )
	if ( string.sub( library, 1, 7 ) ~= "sounds." ) then
		return
	end
	-- TODO: Reload soundscript.
end

hook.set( "client", sound.reload, "onReloadScript", "reloadSound" )

function sound:sound( filename )
	local status, ret = pcall( require, filename )
	if ( status == true ) then
		self.data     = ret
		self.filename = self.data[ "sound" ]
	else
		self.filename = filename
	end
end

accessor( sound, "data" )
accessor( sound, "filename" )

function sound:parse()
	local filename = self:getFilename()
	local info = love.filesystem.getInfo( filename ) or {}
	sound._sounds[ filename ] = {
		sound   = love.audio.newSource( filename ),
		modtime = info.modtime
	}

	local data = self:getData()
	if ( data == nil ) then
		return
	end

	local volume = data[ "volume" ]
	if ( volume ) then
		self:setVolume( volume )
	end
end

function sound:play()
	local filename = self:getFilename()
	if ( sound._sounds[ filename ] == nil ) then
		self:parse()
	end

	local sound = sound._sounds[ filename ].sound
	if ( sound:isPlaying() ) then
		sound = sound:clone()
		sound:rewind()
	end

	love.audio.play( sound )
end

function sound:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sound" )
	setmetatable( self, t )
	return s
end
