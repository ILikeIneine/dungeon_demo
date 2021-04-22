pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--gen

function mapgen()
	for x=0,15 do
		for y=0,15 do
			mset(x,y,2)
		end
	end
	
	genrooms()
end

-----------------
-- rooms
-----------------
function genrooms()
--fmax -> how many times u failed
--rmax -> how many rooms should played
	local fmax,rmax=5,1
	local mw,mh=5,5
	
	repeat
		local r=rndroom(mw,mh)
		if placeroom(r) then
			rmax-=1
		else
			fmax-=1
			if r.w>r.h then
				mw=max(mw-1,3)
			else
				mh=max(mh-1,3)
			end
		end
	until fmax<=0 or rmax<=0
	mazeworm()
end

function rndroom(mw,mh)
	--clamp max area
	--_w:[3,max_width]
	--_h:[3,max_height]
	--ps: max_height:[3,35/_w]
	local _w=3+flr(rnd(mw-2))
	mh=max(35/_w,3)
	local _h=3+flr(rnd(mh-2))
	return {
		x=0,
		y=0,
		w=_w,
		h=_h
	}
end

function placeroom(r)
	local cand,c={}
	for _x=0,16-r.w do
		for _y=0,16-r.h do
			--check if room can be put at (_x,_y)
			--if could then put the
			--(_x,_y) into candidates list
			if doesroomfit(r,_x,_y) then
				add(cand,{x=_x,y=_y})
			end
		end
	end
	--if no coordinate suit
	if #cand==0 then return false end
	
	--get a random coordinate from
	--candidates list
	c=getrnd(cand)
	r.x=c.x
	r.y=c.y
	--place then room
	for _x=0,r.w-1 do
		for _y=0,r.h-1 do
			mset(_x+r.x,_y+r.y,1)
		end
	end
	return true
end

--check room fittable
function doesroomfit(r,x,y)
	for _x=-1,r.w do
		for _y=-1,r.h do
		--a room must be "all walls"
		--and surrounded by walls
		--thats y we count from -1 
		-- _x+x:[x-1,x+r.w]
		-- -y+y:[y-1,y+r.h]
			if iswalkable(_x+x,_y+y) then
				return false
			end
		end
	end
	
	return true
end

-----------------
-- maze
-----------------

function mazeworm()
	repeat
		local cand={}
	 for _x=0,15 do
	 	for _y=0,15 do
	 	--find unwalkable tiles which are sorrounded by 8 tiles
				if not iswalkable(_x,_y) and getsig(_x,_y)==255 then
					add(cand,{x=_x,y=_y})
				end	
			end
		end
		if #cand>0 then
			local c=getrnd(cand)
			digworm(c.x,c.y)
		end
		-- last one is defenately no use
	until #cand<=1
end

function digworm(x,y)
	local dr,step=1+flr(rnd(4)),0

	repeat	
		mset(x,y,1)
		--we have 50% chance to change direction
		--or if this direction cant carve
		--find another direction
		if not cancarve(x+dirx[dr],y+diry[dr]) or (rnd()<0.5 and step>=2) then
			local cand={}
			step=0
			for i=1,4 do
				--get carveable direction
				if cancarve(x+dirx[i],y+diry[i]) then
					add(cand,i)
				end
			end--for
			if #cand==0 then
				dr=8
			else
				dr=getrnd(cand)
			end
		end
		x+=dirx[dr]
		y+=diry[dr]
		step+=1
	until dr==8
	
end

function cancarve(x,y)
	--if a tile is not walkable
	--we can then try carving it
	if inbounds(x,y) and not iswalkable(x,y) then
		local sig=getsig(x,y)
		for i=1,#crv_sig do
			if bcomp(sig,crv_sig[i],crv_msk[i]) then 
				return true 
			end
		end
	end
	return false
end

function bcomp(sig,match,mask)
--must bit : 0
--optional : 1 
	local mask= mask and mask or 0
	return bor(sig,mask)==bor(match,mask)

end

function getsig(x,y)
--if theres wall : 1
--else : 0
	local sig,digit=0
	for i=1,8 do
		local dx,dy=x+dirx[i],y+diry[i]
		if iswalkable(dx,dy) then
			digit=0
		else
			digit=1
		end
		sig=bor(sig,shl(digit,8-i))
	end
	return sig
end