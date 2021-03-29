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
	 if mob==false then
	 	if fget(tle,1) then
	 		trig_bump(tle,destx,desty)
	 	end
	 else
	 	hitmob(p_mob,mob)	
	 end 
	end
end

function trig_bump(tle,destx,desty)
	
	if tle==7 or tle==8 then
		--vase
		sfx(1,1)
		mset(destx,desty,1)
	elseif tle==10 or tle==12 then
		--chest
		sfx(2,1)
		mset(destx,desty,tle-1)
 elseif tle==13 then
  --door
  sfx(3,1)
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
	if mode==nil then mode="" end
	if inbounds(x,y) then
		local tle=mget(x,y)
		if fget(tle,0)==false then
			if mode=="checkmobs" then
				return getmob(x,y)==false
			end
			return true
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
		return false
	end
	return true
end 

function los(x1, y1, x2, y2)
	local frst, sx, sy, dx, dy=true

	if dist(x1,y1,x2,y2)==1 then return true end
	if x1<x2 then
		sx=1
		dx=x2-x1
	else
		sx=-1
		dx=x1-x2
	end
	if y1<y2 then
		sy=1
		dy=y2-y1
	else
		sy=-1
		dy=y1-y2
	end
	local err, e2 = dx-dy, nil
	
	while not(x1==x2 and y1==y2) do
		if not frst and iswalkable(x1,y1,"sight")==false then return false end
		frst = false
		e2=err+err
		if e2>-dy then
			err=err-dy
			x1=x1+sx
		end
		if e2<dx then
			err=err+dx
			y1=y1+sy
		end
	end
	return true
end