pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--gen
function genfloor(f)
	floor=f
	mob={}
	add(mob,p_mob)
	
	if floor==0 then
		copymap(16,0)
	elseif floor==winfloor then
		copymap(32,0)
	else
		mapgen()
	end
end

function mapgen()
	copymap(48,0)
	

	
	rooms={}
	roomap=blankmap(0)
	doors={}
	genrooms()
	mazeworm()
 placeflags()
	carvedoors()
	carvescuts()
	startend()
	fillends()
	installdoors()
	spawnmobs()
end

function snapshot()
	cls()
	map()
	flip()
end
-----------------
-- rooms
-----------------
function genrooms()
--fmax -> how many times u failed
--rmax -> how many rooms should played
	local fmax,rmax=5,3
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
	--mazeworm()
end

function rndroom(mw,mh)
	--clamp max area
	--_w:[3,max_width]
	--_h:[3,max_height]
	--ps: max_height:[3,35/_w]
	local _w=3+flr(rnd(mw-2))
	mh=mid(mh,35/_w,3)
	local _h=3+flr(rnd(mh-2))
	--room struct
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
	add(rooms,r)
	--place then room
	for _x=0,r.w-1 do
		for _y=0,r.h-1 do
			mset(_x+r.x,_y+r.y,1)
			roomap[_x+r.x][_y+r.y]=#rooms
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
				if cancarve(_x,_y,false) and not nexttoroom(_x,_y) then
					add(cand,{x=_x,y=_y})
				end
			end
		end
		
		if #cand>0 then
			local c=getrnd(cand)
			--we put the worms down here
			digworm(c.x,c.y)
		end
		-- last one is defenately no use
	until #cand<=1
	
	--deal with double walls!
	--we no longer need this
	repeat
		local cand={}
	 for _x=0,15 do
	 	for _y=0,15 do
	 	--find unwalkable tiles which are sorrounded by 8 tiles
				if cancarve(_x,_y,false) and not nexttoroom(_x,_y)then
					add(cand,{x=_x,y=_y})
				end	
			end
		end
		if #cand>0 then
			local c=getrnd(cand)
			mset(c.x,c.y,1)
		end
	until #cand<=1
	
end

function digworm(x,y)
	local dr,step=1+flr(rnd(4)),0

	repeat	
		mset(x,y,1)
		--we have 50% chance to change direction
		--or if this direction cant carve
		--find another direction
		if not cancarve(x+dirx[dr],y+diry[dr],false) or (rnd()<0.5 and step>=2) then
			local cand={}
			step=0
			for i=1,4 do
				--get carveable direction
				if cancarve(x+dirx[i],y+diry[i],false) then
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

function cancarve(x,y,walk)
	--if a tile is not walkable
	--we can then try carving it
	if not inbounds(x,y) then return false end
	local walk= walk==nil and iswalkable(x,y) or walk
	
	if iswalkable(x,y)==walk then
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

------------
-- doorways
------------

function placeflags()
	local curf=1
	flags=blankmap(0)
	for _x=0,15 do
		for _y=0,15 do
			if iswalkable(_x,_y) and flags[_x][_y]==0 then
				growflag(_x,_y,curf)
				curf+=1
			end
		end
	end
end

function growflag(_x,_y,flg)
	local cand,candnew={{x=_x,y=_y}}
	flags[_x][_y]=flg
	repeat
		candnew={}
		for c in all(cand) do
			for d=1,4 do
				local dx,dy=c.x+dirx[d],c.y+diry[d]
				if iswalkable(dx,dy) and flags[dx][dy]!=flg then
					--★
					flags[dx][dy]=flg
					add(candnew,{x=dx,y=dy})
				end
			end
		end
		cand=candnew
	until #cand==0
end

function carvedoors()
	local x1,y1,x2,y2,found,_f1,_f2,drs=1,1,1,1
		repeat
		drs={}
		for _x=0,15 do
			for _y=0,15 do
				if not iswalkable(_x,_y) then
					local sig=getsig(_x,_y)
					found=false
					if bcomp(sig,0b11000000,0b00001111) then
						x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
					elseif bcomp(sig,0b00110000,0b00001111) then
						x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true
					end
					_f1=flags[x1][y1]
					_f2=flags[x2][y2]
					-- the door must have two 
					-- different type area
					if found and _f1!=_f2 then
						add(drs,{x=_x,y=_y,f=_f1})
					end--if
				end--if
			end--for
		end--for
		if #drs>0 then
			local d=getrnd(drs)
			add(doors,d)
			mset(d.x,d.y,1)
			growflag(d.x,d.y,d.f)
		end--if
	until #drs==0
end

function carvescuts()
	local x1,y1,x2,y2,cut,found,drs=1,1,1,1,0
		repeat
		drs={}
		for _x=0,15 do
			for _y=0,15 do
				if not iswalkable(_x,_y) then
					local sig=getsig(_x,_y)
					found=false
					if bcomp(sig,0b11000000,0b00001111) then
						x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
					elseif bcomp(sig,0b00110000,0b00001111) then
						x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true
					end
					
					if found then
						calcdist(x1,y1)
						if distmap[x2][y2]>15 then
							add(drs,{x=_x,y=_y})
						end
					end--if
				end--if
			end--for
		end--for

		if #drs>0 then
			local d=getrnd(drs)
			add(doors,d)
			mset(d.x,d.y,1)
			cut+=1
		end--if
	until #drs==0 or cut>=3
end

function	fillends()
	local filled,tle
	repeat
		filled=false
		for _x=0,15 do
			for _y=0,15 do
				tle=mget(_x,_y)
				if cancarve(_x,_y,true) and tle!=14 and tle!=15 then
					filled=true
					mset(_x,_y,2)
				end
			end
		end
	until not filled
end

function isdoor(x,y)
	local sig=getsig(x,y)
	if bcomp(sig,0b11000000,0b00001111) or bcomp(sig,0b00110000,0b00001111) then	
		return nexttoroom(x,y)
	end
	return false
end

function nexttoroom(x,y)
	for i=1,4 do
			if inbounds(x+dirx[i],y+diry[i]) and 
						roomap[x+dirx[i]][y+diry[i]]!=0 then
			return true
		end
	end
	return false
end

function installdoors()
	for d in all(doors) do
		if mget(d.x,d.y)==1 and isdoor(d.x,d.y) then
			mset(d.x,d.y,13)
		end
	end
end
--------------
-- decoration
--------------

function startend()
	local high,low,px,py,ex,ey=0,9999
	repeat
		px,py=flr(rnd(16)),flr(rnd(16))
	until iswalkable(px,py)
	calcdist(px,py)
	for x=0,15 do
		for y=0,15 do
			local tmp=distmap[x][y]
			if iswalkable(x,y) and tmp>high then
				px,py=x,y
				high=tmp
			end
		end
	end
	calcdist(px,py)
	high=0
	for x=0,15 do
		for y=0,15 do
			local tmp=distmap[x][y]
			if tmp>high and cancarve(x,y) then
				ex,ey,high=x,y,tmp
			end
		end
	end
	mset(ex,ey,14)
	
	for x=0,15 do
		for y=0,15 do
			local tmp=distmap[x][y]
			if tmp>=0 and tmp<low and cancarve(x,y) then
				px,py,low=x,y,tmp
			end
		end
	end
	mset(px,py,15)
	p_mob.x=px
	p_mob.y=py


end