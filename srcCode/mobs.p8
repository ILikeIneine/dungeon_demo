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
		stun=false,
		bless=0,
		charge=1,
		lastmoved=false,
		spec=mob_spec[typ],
		hp=mob_hp[typ],
		hpmax=mob_hp[typ],
		atk=mob_atk[typ],
		defmin=0,
		defmax=0,
		los=mob_los[typ],
		task=ai_wait,
		name=mob_name[typ]
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
			if m.stun then
				m.stun=false
			else
				m.lastmoved=m.task(m)
				debug[1]=m.lastmoved
				moving= m.lastmoved or moving
			end
		end
	end
	if moving then
		_upd=update_aiturn
		p_t=0
	else
		p_mob.stun=false
	end
end

function ai_wait(m)
	if cansee(m,p_mob) then
		addfloat("!",m.x*8+4,m.y*8,8)
		m.task=ai_attac
		m.tx,m.ty=p_mob.x,p_mob.y
		return false
	end
	return false
end

function ai_attac(m)
	if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then
		--attack player
		dx,dy=p_mob.x-m.x,p_mob.y-m.y
		mobbump(m,dx,dy)
		if m.spec=="stun" and m.charge>0 then
			stunmob(p_mob)
			m.charge-=1
		elseif m.spec=="ghost" and m.charge>0 then
			hitmob(m,p_mob)
			blessmob(p_mob,-1)
			m.charge-=1
		else
			hitmob(m,p_mob)
		end
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
			if m.spec=="slow" and m.lastmoved then
				return false
			end
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
						add(cand,i)
					end
				end
			end
			if #cand>0 then
				local c=getrnd(cand)
				mobwalk(m,dirx[c],diry[c])
				return true
			end
		end
	end
	return false
end

function cansee(m1,m2)
	return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y)
end

function spawnmobs()
	mobpool={}
	for i=2, #mob_name do
		if  mob_minf[i]<=floor and mob_maxf[i]>=floor then
			add(mobpool,i)
		end
	end
	
	if #mobpool==0 then return end
	
	local minmons=explodeval("1,5,7,9,9,10,11,12,13")
	local maxmons=explodeval("3,10,14,18,18,20,22,22,22")

	local placed,rpot=0,{}
	
	for r in all(rooms) do
		add(rpot,r)
	end
	
	repeat
		local r=getrnd(rpot)
		placed+=infestroom(r)
		del(rpot,r)
	until #rpot==0 or placed>maxmons[floor]
	
	if placed<minmons[floor] then
		local cand={}
		for _x=0,15 do
			for _y=0,15 do
			 if iswalkable(_x,_y,"checkmobs") then
			 	add(cand,{x=_x,y=_y})
			 end
			end
		end
		repeat
			local pos=getrnd(cand)
			
--			repeat
--				x,y=flr(rnd(16)),flr(rnd(16))
--			until iswalkable(x,y,"checkmobs")
			addmob(getrnd(mobpool),pos.x,pos.y)
			del(cand,pos)
			placed+=1
		until placed>=minmons[floor]
	end
end

function infestroom(r)
	local target_num,x,y=2+flr(rnd((r.w*r.w)/6-1))
	target_num=min(5,target_num)
	local x,y
	
	for i=1,target_num do
		repeat
			x=r.x+flr(rnd(r.w))
			y=r.y+flr(rnd(r.h))
		until iswalkable(x,y,"checkmobs")
		addmob(getrnd(mobpool),x,y)
	end
		
	return target_num
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

function makeipool()
	ipool_rare={}
	ipool_comm={}
	
	for i=1,#itm_name do
		local t=itm_type[i]
		if t=="wep" or t=="arm" then
			add(ipool_rare,i)
		else
			add(ipool_comm,i)
		end
	end

end

function makefipool()
	fipool_rare={}
	fipool_comm={}

	for i in all(ipool_rare) do
		if itm_minf[i]<=floor and
					itm_maxf[i]>=floor then
			add(fipool_rare,i)
		end
	end
	for i in all(ipool_comm) do
		if itm_minf[i]<=floor and
					itm_maxf[i]>=floor then
			add(fipool_comm,i)
		end
	end
end

function getitm_rare()
	if #fipool_rare>0 then
		local itm=getrnd(fipool_rare)
		del(fipool_rare,itm)
		del(ipool_rare,itm)
		return itm
	else
		return getrnd(fipool_comm)
	end
end

function foodnames()
	local fud,fu=explode("clarity,faerie fire,magic wand,mekansm,healing salve,bottle")
	local adj,ad=explode("blue,yellow,green,soft,clever,bad,holy")
	itm_known={}
	for i=1, #itm_name do
		if itm_type[i]=="fud" then
			fu,ad=itm_name[i],getrnd(adj)
			del(fud,fu)
			del(adj,ad)
			itm_name[i]=ad.." "..fu
--			itm_known[i]=
		end
	end
end
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
						add(cand,i)
					end
				end
			end
			if #cand>0 then
				local c=getrnd(cand)
				mobwalk(m,dirx[c],diry[c])
				return true
			end
		end
	end
	return false
end

function cansee(m1,m2)
	return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y)
end

function spawnmobs()
	local minmons=3
	local placed,rpot=0,{}
	
	for r in all(rooms) do
		add(rpot,r)
	end
	
	repeat
		local r=getrnd(rpot)
		placed+=infestroom(r)
		del(rpot,r)
	until #rpot==0 or placed>minmons
end

function infestroom(r)
	local target=2+flr(rnd(3))
	local x,y
	
	for i=1,target do
		repeat
			x=r.x+flr(rnd(r.w))
			y=r.y+flr(rnd(r.h))
		until iswalkable(x,y,"checkmobs")
		addmob(2,x,y)
	end
		
	return target
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