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
		sfx(63)
		mobwalk(p_mob,dx,dy)
		st_steps+=1
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
	 	else
	 		skipai=true
	 		--mset(destx,desty,1)
	 	end	 	
	 end 
	end
	unfog()
end

function trig_bump(tle,destx,desty)
	
	if tle==7 or tle==8 then
		--vase
		sfx(59)
		mset(destx,desty,76)
		if rnd(3)<1 and floor>0 then
			if rnd(5)<1 then
				sfx(60)
				addmob(getrnd(mobpool),destx,desty)
			else
				if freeinvslot()==0 then
					showmsg("bag fulled!",120)
					sfx(60)
				else
			  sfx(61)
					local itm=getrnd(fipool_comm)
					takeitem(itm)
					showmsg(itm_name[itm].."!",60)
				end
			end
		end
	elseif tle==10 or tle==12 then
		--chest
		if freeinvslot()==0 then
			showmsg("bag fulled!",120)
			skipai=true
			sfx(60)
		else
			local itm=getrnd(fipool_comm)
			if tle==12 then
				itm=getitm_rare()
			end
			sfx(61)
			mset(destx,desty,tle-1)
			takeitem(itm)
			showmsg(itm_name[itm].."!",60)
		end
 elseif tle==13 then
  --door
  sfx(62)
  mset(destx,desty,1)
 elseif tle==6 then
 	--stone tablet
 	--showmsg("hello world",120)
 	if floor==0 then
 		sfx(54)
 	 showtalk(explode("welcome to ,dark planet,,climb the mountain ,to reach the truth"))
		end
		
	elseif tle==110 then
		--kielbasa
		win=true
 end
end

function trig_step()
	local tle=mget(p_mob.x,p_mob.y)
	--floors 
	if tle==14 then
			sfx(55)
			p_mob.bless=0
			fadeout()
			genfloor(floor+1)
			floormsg()
			return true
	end
	return false
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

function hitmob(atkm,defm,rowdmg)
	local dmg= atkm and atkm.atk or rowdmg

	--add curse/bless
	if defm.bless<0 then
		dmg*=2
	elseif defm.bless>0 then
		dmg=flr(dmg/2)
	end
	defm.bless=0
	local def=defm.defmin+flr(rnd(defm.defmax-defm.defmin+1))
	dmg-=min(def,dmg)
	
	defm.hp-=dmg
	defm.flash=10
	if defm==p_mob then
		shake=0.08
		sfx(57)
	else
		shake=0.03
		sfx(58)
	end
	if dmg==0 then
		addfloat("no dmg!",defm.x*8,defm.y*8,6)
	else
		addfloat("-"..dmg,defm.x*8,defm.y*8,9)
	end
	
	
	if defm.hp<=0 then
		--what if defm is player
		if defm!=p_mob then
			st_kills+=1
		else
			st_killer=atkm.name
		end
		add(dmob,defm)
		del(mob,defm)
		defm.dur=60
	end
end

function healmob(mb,hp)
	hp=min(mb.hpmax-mb.hp,hp)
	mb.hp+=hp
	mb.flash=10

	addfloat("+"..hp,mb.x*8,mb.y*8,11)
	sfx(51)
end

function stunmob(mb)
	mb.stun=true
	mb.flash=10

	addfloat("stun",mb.x*8-3,mb.y*8,7)
	sfx(51)
end

function blessmob(mb,val)
	mb.bless=mid(-1,1,mb.bless+val)
	mb.flash=10
	
	local txt="bless"
	if val<0 then txt="curse" end

	addfloat(txt,mb.x*8-6,mb.y*8,7)
	
	if mb.spec=="ghost" and val>0 then
		add(dmob,defm)
		del(mob,mb)
		mb.dur=10
	end
	sfx(51)
end

function checkend()
	if win then
		music(24)
		gover_spr=112
		gover_x=30
		gover_w=9
		showgover()
		return false
	elseif p_mob.hp<=0 then
		music(22)
		gover_spr=80
		gover_x=30 
		gover_w=9
		showgover()
		return false
	end
	return true
end 

function showgover()
		wind={}
		_upd=update_gover
		_drw=draw_gover
		fadeout(0.02)
end

function los(x1, y1, x2, y2)
	local frst, sx, sy, dx, dy=true
	--★
	if dist(x1,y1,x2,y2)==1 then return true end
	
	if y1>y2 then
		x1,x2,y1,y2=x2,x1,y2,y1
	end
		sy,dy=1,y2-y1
	
	if x1<x2 then
		sx,dx=1,x2-x1
	else
		sx,dx=-1,x1-x2
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
	local cand,step,candnew={},0
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

function updatestats()
	local atk,dmin,dmax=1,0,0
	if eqp[1] then
		atk+=itm_stat1[eqp[1]]
	end
	
	if eqp[2] then
		dmin+=itm_stat1[eqp[2]]
		dmax+=itm_stat2[eqp[2]]
	end
	p_mob.atk=atk
	p_mob.defmin=dmin
	p_mob.defmax=dmax
end

function eat(itm,mb)
	local effect=itm_stat1[itm]
	
	if not itm_known[itm] then
		showmsg(itm_name[itm].." "..itm_desc[itm],120)
		itm_known[itm]=true
	end
	if mb==p_mob then
	 st_meals+=1
	end
	
	if effect==1 then
		--heal
		healmob(mb,1)
	elseif effect==2 then
		--heal a lot
		healmob(mb,3)
	elseif effect==3 then
		--plus maxhp
		mb.hpmax+=2
		healmob(mb,1)
	elseif effect==4 then
		--stun
		stunmob(mb)
	elseif effect==5 then
		--curse
		blessmob(mb,-1)
	elseif effect==6 then
		--bless
		blessmob(mb,1)
	end
end

function throw()
	local itm,tx,ty=inv[thrslt],throwtile()
	sfx(52)
	if inbounds(tx,ty) then
		local mb=getmob(tx,ty)
		if mb then
			if itm_type[itm]=="fud" then
				eat(itm,mb)
			else
				hitmob(nil,mb,itm_stat1[itm])
				sfx(58)
			end
		end
	end
	mobbump(p_mob,thrdx,thrdy)
	
	inv[thrslt]=nil
	p_t=0
	_upd=update_pturn
end

function throwtile()
	local tx,ty=p_mob.x,p_mob.y
	
	repeat
		tx+=thrdx
		ty+=thrdy
	until not iswalkable(tx,ty,"checkmobs")
	return tx,ty
end