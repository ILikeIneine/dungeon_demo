pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- gameplay
-- core details

function moveplayer(dx,dy)
	--finish end of the position
	local destx,desty=p_mob.x+dx,p_mob.y+dy
	local tle=mget(destx,desty)
	
	if iswalkable(destx,desty,"checkmobs") then
		sfx(0,0)
		mobwalk(p_mob,dx,dy)
		p_t=0
		_upd=update_pturn
	else
		--not walkable
		mobbump(p_mob,dx,dy)
		p_t=0
		_upd=update_pturn
		
	 local mob=getmob(destx,desty)
	 if mob then
	 	hitmob(p_mob,mob)	
	 else
	 	if fget(tle,1) then
	 		trig_bump(tle,destx,desty)
	 	end	 	
	 end 
	end
	unfog()
end

function trig_bump(tle,destx,desty)
	
	if tle==7 or tle==8 then
		--vase
		sfx(3,1)
		mset(destx,desty,1)
	elseif tle==10 or tle==12 then
		--chest
		sfx(5,1)
		mset(destx,desty,tle-1)
 elseif tle==13 then
  --door
  sfx(2,1)
  mset(destx,desty,1)
 elseif tle==6 then
 	--stone tablet
 	--showmsg("hello world",120)
 	showmsg({"welcome to ","dark planet","","climb the mountain ","to reach the truth"})
 end
end

function getmob(x,y)
	for m in all(mob) do
		if m.x==x and m.y==y then
			return m
		end
	end
	return false
end

function iswalkable(x,y,mode)
	local mode=mode or ""
	--if mode==nil then mode="" end
	--sight
	if inbounds(x,y) then
		local tle=mget(x,y)
		if mode=="sight" then
			return not fget(tle,2)
		else			
			if not fget(tle,0) then
				if mode=="checkmobs" then
					return not getmob(x,y)
				else 
					return true
				end
			end
		end
	end
	return false
end

function inbounds(x,y)
	return not(x<0 or y<0 or x>15 or y>15)
end

function hitmob(atkm,defm)
	local dmg=atkm.atk
	defm.hp-=dmg
	defm.flash=10
	if atkm!=p_mob then
		sfx(1)
	else
		sfx(6)
	end
	addfloat("-"..dmg,defm.x*8,defm.y*8,9)
	
	if defm.hp<=0 then
		--what if defm is player
		add(dmob,defm)
		del(mob,defm)
		defm.dur=60
	end
end

function checkend()
	if p_mob.hp<=0 then
		wind={}
		_upd=update_gover
		_drw=draw_gover
		fadeout(0.02)
		reload(0x2000,0x2000,0x1000)
		return false
	end
	return true
end 

function los(x1, y1, x2, y2)
	local frst, sx, sy, dx, dy=true

	if dist(x1,y1,x2,y2)==1 then return true end
	if x1<x2 then
		sx,dx=1,x2-x1
	else
		sx,dx=-1,x1-x2
	end
	if y1<y2 then
		sy,dy=1,y2-y1
	else
		sy,dy=-1,y1-y2
	end
	local err, e2 = dx-dy
	
	while not(x1==x2 and y1==y2) do
		if not frst and not iswalkable(x1,y1,"sight") then return false end
		e2,frst=err+err,false
		if e2>-dy then
			err-=dy
			x1=x1+sx
		end
		if e2<dx then
			err+=dx
			y1=y1+sy
		end
	end
	return true
end

function unfog()
	local px,py=p_mob.x,p_mob.y
	for x=0,15 do
		for y=0,15 do
			if fog[x][y]==1 and dist(px,py,x,y)<=p_mob.los and los(px,py,x,y) then
				unfogtile(x,y)
			end
		end
	end	
end

function unfogtile(x,y)
	fog[x][y]=0
	if iswalkable(x,y,"sight") then
		for i=1,4 do
			local tx,ty=x+dirx[i],y+diry[i]
			if inbounds(tx,ty) and not iswalkable(tx,ty,"sight") then
				fog[tx][ty]=0
			end
		end
	end
end

function calcdist(tx,ty)
	--unreachable
	local cand,step={},0
	distmap=blankmap(-1)
	add(cand,{x=tx,y=ty})
	distmap[tx][ty]=0
	repeat
		step+=1
		candnew={}
		for c in all(cand) do
			 for d=1,4 do
			 	local dx=c.x+dirx[d]
			 	local dy=c.y+diry[d]
			 	if inbounds(dx,dy) and distmap[dx][dy]==-1  then
			 		distmap[dx][dy]=step
			 		if iswalkable(dx,dy) then
			 			add(candnew,{x=dx,y=dy})
			 		end
			 	end
			 end
		end
		cand = candnew
	until #cand==0
	return distmap
end