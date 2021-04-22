pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--mobs and items

function addmob(typ,mx,my)
	local m={
		x=mx,
		y=my,
		ox=0,
		oy=0,
		flp=false,
		ani={},
		flash=0,
		hp=mob_hp[typ],
		hpmax=mob_hp[typ],
		atk=mob_atk[typ],
		defmin=0,
		defmax=0,
		los=mob_los[typ],
		task=ai_wait
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
	mb.flp = dx==0 and mb.flp or dx<0
end

function mov_walk(self)
	local tme=1-p_t
	self.ox=self.sox*tme
	self.oy=self.soy*tme
end


function mov_bump(self)
	local tme= p_t>0.5 and 1-p_t or p_t
	self.ox=self.sox*tme
	self.oy=self.soy*tme
end -- wall duang!

function doai()
	local moving = false
	for m in all(mob) do
		if m!=p_mob then
		--	debug[1]=los(m.x,m.y,p_mob.x,p_mob.y)
			m.mov=nil
			-- bug
			moving=m.task(m) or moving
		end
	end
	if moving then
		_upd=update_aiturn
		p_t=0
	end
end

function ai_wait(m)
	if cansee(m,p_mob) then
		addfloat("!",m.x*8+4,m.y*8,8)
		m.task=ai_attac
		m.tx,m.ty=p_mob.x,p_mob.y
		return true
	end
	return false
end

function ai_attac(m)
	if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then
		--attack player
		dx,dy=p_mob.x-m.x,p_mob.y-m.y
		mobbump(m,dx,dy)
		hitmob(m,p_mob)
		return true
	else	
		--move to player
		if cansee(m,p_mob) then
			m.tx,m.ty=p_mob.x,p_mob.y
		end
		
		if m.x==m.tx and m.y==m.ty then
		-- hang out
			m.task=ai_wait
			addfloat("?",m.x*8+4,m.y*8,8)
		else 
			local bdst,cand=999,{}
			calcdist(m.tx,m.ty)
			for i=1,4 do
				local dx,dy=dirx[i],diry[i]
				local tx,ty=m.x+dx,m.y+dy
				if iswalkable(tx,ty,"checkmobs") then
					local dst=distmap[tx][ty]
					if dst<bdst then
						cand={}
						bdst=dst
					end
					if dst==bdst then
						add(cand,{x=dx,y=dy})
					end
				end
			end
			if #cand>0 then
				local c=getrnd(cand)
				mobwalk(m,c.x,c.y)
				return true
			end
		end
	end
	return false
end

function cansee(m1,m2)
	return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y)
end


--------------------------
--items
--------------------------

function takeitem(itm)
	local i=freeinvslot()
	if i==0 then return false end
	inv[i]=itm
	return true
end

--find a free slot
function freeinvslot()
	for i=1,6 do
		if not inv[i] then
			return i
		end
	end
	return 0
end