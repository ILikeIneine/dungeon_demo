pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--mobs

function addmob(typ,mx,my)
	local m={
		x=mx,
		y=my,
		ox=0,
		oy=0,
		sox=0,
		soy=0,
		flp=false,
		mov=nil,
		ani={},
		flash=0,
		hp =mob_hp[typ],
		hpmax=mob_hp[typ],
		atk=mob_atk[typ]
		
	}
	for i=0,3 do
		add(m.ani,mob_ani[typ]+i)
	end
	add(mob,m)
	return m
end

function mobwalk(mb,dx,dy)
	mb.x+=dx
	mb.y+=dy
	mobflip(mb,dx)
	--use an value to neutralize
	--the offset(animate the action) 
	mb.sox,mb.soy=-dx*8,-dy*8
	mb.ox,mb.oy=-dx*8,-dy*8
	mb.mov=mov_walk -- normal walk
end

function mobbump(mb,dx,dy)
	mobflip(mb,dx)
	mb.sox,mb.soy=dx*8,dy*8
	mb.ox,mb.oy=0,0
	mb.mov=mov_bump -- unwalkable
end

function mobflip(mb,dx)
	if dx<0 then
		mb.flp=true
	elseif dx>0 then
	 mb.flp=false
	end
	
end

function mov_walk(mob,at)
	mob.ox=mob.sox*(1-at)
	mob.oy=mob.soy*(1-at)
end


function mov_bump(mob,at)
	local tme=at
	if tme>0.5 then
		tme=1-at
	end
	mob.ox=mob.sox*tme
	mob.oy=mob.soy*tme
end -- wall duang!


function doai()
	for m in all(mob) do
		if m!=p_mob then
			m.mov=nil
			if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then
				--attack player
				dx,dy=p_mob.x-m.x,p_mob.y-m.y
				mobbump(m,dx,dy)
				hitmob(m,p_mob)
			else	
				--move to player
				local bdst,bx,by=999,0,0
				for i=1,4 do
					local dx,dy=dirx[i],diry[i]
					local tx,ty=m.x+dx,m.y+dy
					if iswalkable(tx,ty,"checkmobs") then
						local dst=dist(tx,ty,p_mob.x,p_mob.y)
						if dst<bdst then
							bdst,bx,by=dst,dx,dy
						end
					end
				end
				mobwalk(m,bx,by)
				_upd=update_aiturn
				p_t=0
			end
		end
	end
end