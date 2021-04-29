pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()
 t=0
 
 dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
 -- player animation
 p_ani={240,241,242,243}
 -- direction
 -- ⬅️➡️⬆️⬇️
 dirx={-1,1,0,0,1,1,-1,-1}
 diry={0,0,-1,1,-1,1,1,-1}
 
 
 mob_ani={240,192}
 mob_atk={1,1}
 mob_hp ={1,1}
 mob_los={4,4}
 
 itm_name={"grass swords","leather armor","red potion","ninja star","rusty sword"}
	itm_type={"wep","arm","fud","thr","wep"}
	itm_stat1={2,0,1,1,1}
	itm_stat2={0,2,0,0,0}
	--defmin
	--defmax
																	 	--⬇️         ➡️         ⬆️         ⬅️                       
	crv_sig={0b11111111,0b11010110,0b01111100,0b11101001,0b10110011}
	crv_msk={0,0b00001001,0b00000011,0b00000110,0b00001100}
 debug={}
 startgame()

end
 
 
function _update60()
  t+=1
  _upd()
  dofloats()
  dohpwind()
end
 
function _draw()
 _drw()
 drawind()
 fadeperc=0
 --checkfade()
 --★
 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end
 
function startgame()
	fadeperc=1
 buttbuff=-1

	skipai=false
	win=false
	winfloor=9
	
 mob={}
 dmob={}
 p_mob=addmob(1,1,1)
 
-- for x=0,15 do
-- 	for y=0,15 do
-- 		if mget(x,y)==192 then
-- 			addmob(2,x,y)
-- 			mset(x,y,1)
-- 		end
-- 	end
-- end

 p_t=0 
 
 inv,eqp={},{}
 --eqp[1] -weapon
 --eqp[2] -armor
 --inv[1-6] - inventory
-- takeitem(1)
-- takeitem(2)
-- takeitem(3)
-- takeitem(4)
-- takeitem(5)
 
 wind={} 
 float={}
 fog=blankmap(0)
 talkwind=nil
 
 hpwind=addwind(5,5,28,13,{})
 --throwing direction
 thrdx,thrdy=1,0
 
 _upd=update_game
 _drw=draw_game
 
 genfloor(0)
 
 unfog()
end
-->8
-- update

function update_game()
	if talkwind!=nil then
		if getbutt()==5 then
			talkwind.dur=0
			talkwind=nil
		end
	else
		checkbuttbuff()
		dobutt(buttbuff)
		buttbuff=-1
	end
end --function

function update_inv()
	--inventory
	move_mue(curwind)
	if btnp(4) then
		if curwind==invwind then
			_upd=update_game
			invwind.dur=0
			statwind.dur=0
		--★
		elseif curwind==usewind then
			curwind=invwind
			usewind.dur=0
		end
	elseif btnp(5) then
		if curwind==invwind and invwind.cur!=3 then
			showuse()
		elseif curwind==usewind then
			triguse()
		end
	end
end

function update_throw()
	local b=getbutt()
	if b>=0 and b<=3 then
		thrdx=dirx[b+1]
		thrdy=diry[b+1]
	end

	if b==4 then
		_upd=update_game
	elseif b==5 then
		sfx(58)
		throw()
	end
end

function move_mue(wnd)
	if btnp(2) then
		wnd.cur-=1
	elseif btnp(3) then
		wnd.cur+=1
	end
	wnd.cur=(wnd.cur-1)%#wnd.txt+1
end

function update_pturn()
	checkbuttbuff()
	p_t=min(p_t+0.125,1)
	
	if p_mob.mov then
		p_mob:mov()
	end
	
	if p_t==1 then	
		_upd=update_game
		if trig_step() then return end
		if checkend() and not skipai then
			doai()
		end
		skipai=false
--		calcdist(p_mob.x,p_mob.y)
	end--if
end

function update_aiturn()
	checkbuttbuff()
	p_t=min(p_t+0.125,1)	
	for m in all(mob) do
		if m!=p_mob and m.mov then
			m:mov()
		end
	end
	if p_t==1 then
		_upd=update_game
		checkend()
	end--if
end -- smooth!!!!!


function update_gover()
	if btnp(❎) then
		fadeout()
		startgame()
	end
end


function checkbuttbuff()
	if buttbuff==-1 then
		buttbuff=getbutt()
	end
end -- check button state


function getbutt()
	for i=0,5 do
 	if btnp(i) then
 		return i
 	end--if
	end--for
	return -1
end -- return button num


function dobutt(butt)
	if butt<0 then return end
	if butt>=0 and butt<4 then
	 moveplayer(dirx[butt+1],diry[butt+1]) 
	elseif butt==5 then
		showinv()
	elseif butt==4 then
		mapgen()
	end
end
-->8
-- draw

function draw_game()
	cls()
	if fadeperc==1 then return end
	map()
	
--dead mob
	for m in all(dmob) do
		if sin(time()*8)>0 then
			drawmob(m)
		end
		m.dur-=1
		if m.dur<=0 then
			del(dmob,m)
		end
	end	
	
--live mob
	for i=#mob,1,-1 do
		drawmob(mob[i])
	end

--throw
	if _upd==update_throw then
		local tx,ty=throwtile()
		local lx1=p_mob.x*8+3+thrdx*4
		local ly1=p_mob.y*8+3+thrdy*4
		local lx2=mid(0,tx*8+3,127)
		local ly2=mid(0,ty*8+3,127)
--		line(lx1+thrdy,ly1+thrdx,lx2+thrdy,ly2+thrdx,0)
--		line(lx1-thrdy,ly1-thrdx,lx2-thrdy,ly2-thrdx,0)
		rectfill(lx1+thrdy,ly1+thrdx,lx2-thrdy,ly2-thrdx,0)
		local thrani,mb=flr(t/7)%2==0,getmob(tx,ty)
		if thrani then
			fillp(0b1010010110100101)
		else
			fillp(0b0101101001011010)
		end
		line(lx1,ly1,lx2,ly2,7)
		fillp()
		oprint8("+",lx2-1,ly2-2,7,0)
		
		if mb and thrani then
			mb.flash=1
		end
	end

-- fog
	for x=0,15 do
		for y=0,15 do
			if fog[x][y]==1 then
				rectfill2(x*8,y*8,8,8,0)
			end
		end
	end	
	
---- flags
--	for x=0,15 do
--		for y=0,15 do
--			if flags[x][y]!=0 then
--				pset(x*8+3,y*8+5,flags[x][y])
--			end
--		end
--	end	

--damage value
	for f in all(float) do
		oprint8(f.txt,f.x,f.y,f.c,0)
	end					
end

function drawmob(m)
	local col=10
	if m.flash>0 then
		m.flash-=1
		col=7
	end
	drawspr(getframe(m.ani),m.x*8+m.ox,m.y*8+m.oy,col,m.flp)
end

function draw_gover()
	cls(2)
	print("y ded",50,50,7)
end

function draw_win()
	cls(2)
	print("y win",50,50,7)
end
-->8
-- tools

function getframe(ani)
	return ani[flr(t/15)%#ani+1]
end

function drawspr(_spr,_x,_y,_c,_flip)
	palt(0,false)
	pal(6,_c)
	spr(_spr,_x,_y,1,1,_flip)
	pal()
end

function rectfill2(_x,_y,_w,_h,_c)
	rectfill(_x,_y,
										_x+max(_w-1,0),_y+max(_h-1,0),
										_c)
end

function oprint8(_s,_x,_y,_c,_c2)
	for i=1,8 do
		print(_s,_x+dirx[i],_y+diry[i],_c2)
	end
	print(_s,_x,_y,_c)
end

function dist(fx,fy,tx,ty)
	local dx,dy=fx-tx,fy-ty
	return sqrt(dx*dx+dy*dy)
end

function dofade()
	local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
	for j=1,15 do
		col=j
		kmax=flr((p+(j*1.46))/22)
		for k=1,kmax do
			col=dpal[col]
		end
		pal(j,col,1)
	end
end

function checkfade()
	if fadeperc>0 then
		fadeperc=max(fadeperc-0.04,0)
		dofade()
	end
end

function wait(_wait)
	repeat
		_wait-=1
		flip()
	until _wait<0
end

function fadeout(spd,_wait)
if(spd==nil) spd=0.04 
if(_wait==nil) _wait=0 
	repeat
		fadeperc=min(fadeperc+spd,1)
		dofade()
		flip()
	until fadeperc==1
	wait(_wait)
end

function blankmap(_dflt)
	local ret={}
	if (_dflt==nil) _dflt=0
	
	for x=0,15 do
	 ret[x]={}
	 for y=0,15 do
	 	ret[x][y]=_dflt
	 end
	end
	return ret
end

function getrnd(arr)
	return arr[1+flr(rnd(#arr))]
end

function copymap(x,y)
	local tle
	for _x=0,15 do
		for _y=0,15 do
			tle=mget(_x+x,_y+y)
			mset(_x,_y,tle)
			if tle==15 then
				p_mob.x,p_mob.y=_x,_y
			end
		end
	end
end
-->8
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
	 	else
	 		skipai=true
	 		mset(destx,desty,1)
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
		if rnd(3)<1 then
			local itm=flr(rnd(#itm_name))+1
			takeitem(itm)
			showmsg(itm_name[itm],60)
		end
	elseif tle==10 or tle==12 then
		--chest
		sfx(5,1)
		mset(destx,desty,tle-1)
		local itm=flr(rnd(#itm_name))+1
		takeitem(itm)
		showmsg(itm_name[itm],60)
 elseif tle==13 then
  --door
  sfx(2,1)
  mset(destx,desty,1)
 elseif tle==6 then
 	--stone tablet
 	--showmsg("hello world",120)
 	if floor==0 then
 	 showtalk({"welcome to ","dark planet","","climb the mountain ","to reach the truth"})
 	end
 	if floor==winfloor then
 		win=true
		end
 end
end

function trig_step()
	local tle=mget(p_mob.x,p_mob.y)
	if tle==14 then
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
	
	local def=defm.defmin+flr(rnd(defm.defmax-defm.defmin+1))
	dmg-=min(def,dmg)
	
	defm.hp-=dmg
	defm.flash=10
	if atkm!=p_mob then
		sfx(1)
	else
		sfx(6)
	end
	if dmg==0 then
		addfloat("!no dmg",defm.x*8,defm.y*8,6)
	else
		addfloat("-"..dmg,defm.x*8,defm.y*8,9)
	end
	if defm.hp<=0 then
		--what if defm is player
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
end


function checkend()
	if win then
		wind={}
		_upd=update_gover
		_drw=draw_win
		fadeout(0.02)
	elseif p_mob.hp<=0 then
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
	--★
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
	
	if effect==1 then
		--heal
		healmob(mb,1)
	end
end

function throw()
	local itm,tx,ty=inv[thrslt],throwtile()
	
	if inbounds(tx,ty) then
		local mb=getmob(tx,ty)
		if mb then
			if itm_type[itm]=="fud" then
				eat(itm,mb)
			else
				hitmob(nil,mb,itm_stat1[itm])
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
-->8
-- ui

function addwind(_x,_y,_w,_h,_txt)
	local w={x=_x,y=_y,
										w=_w,h=_h,
										txt=_txt}
	add(wind,w)
	return w
end

function drawind()
	for w in all(wind) do
		local wx,wy,ww,wh=w.x,w.y,w.w,w.h
		rectfill2(wx,wy,ww,wh,0)
		rect(wx+1,wy+1,ww+wx-2,wh+wy-2,6)
		wx+=4
		wy+=4
		clip(wx,wy,ww-8,wh-8)
		if w.cur then
			wx+=6
		end
		for i=1,#w.txt do
			local txt,c=w.txt[i],6
			if w.col and w.col[i] then
				c=w.col[i]
			end
			
			print(txt,wx,wy,c)
			if i==w.cur then
				spr(255,wx-5+sin(time()),wy)
			end
			wy+=6 --linefeeder
		end -- for
		clip()
		if w.dur then
			w.dur-=1
			if w.dur<=0 then
				local dif=w.h/4
				w.y+=dif/2
				w.h-=dif
				if w.h<3 then
					del(wind,w)
				end--if
			end--if
		else 
			if w.butt then
			oprint8("❎",wx+ww-15,wy-1+sin(time()),6,0)
			end
		end
	end--for
end

function showmsg(txt,dur)
	local wid=(#txt+2)*4+7
	local w=addwind(63-wid/2,50,wid,13,{" "..txt})
	w.dur=dur
end

function showtalk(txt)
	talkwind=addwind(16,32,94,#txt*6+7,txt)
	talkwind.butt=true
end

function addfloat(_txt,_x,_y,_c)
	add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
	for f in all(float) do
		f.y+=(f.ty-f.y)/10
		f.t+=1
		if f.t>70 then
			del(float,f)
		end
	end
end

function dohpwind()
	hpwind.txt[1]="♥"..p_mob.hp.."/"..p_mob.hpmax
	local hpy=5
	if p_mob.y<8 then
		hpy=110
	end
	hpwind.y+=(hpy-hpwind.y)/6
end

function showinv()
	local txt,col,itm,eqt={},{}
	_upd=update_inv
	for i=1,2 do
		itm=eqp[i]
		if itm then
			eqt=itm_name[itm]
			add(col,10)
		else
			eqt= i==1 and "[weapon]" or "[armor]"
			add(col,5)
		end
		add(txt,eqt)
	end
	add(txt,"…………………")
	add(col,6)
	for i=1,6 do
		itm=inv[i]
		if itm then
			add(txt,itm_name[itm])
			add(col,6)
		else
			add(txt,"…")
			add(col,5)
		end
	end
	invwind=addwind(5,17,84,64,txt)
	invwind.cur=3
	invwind.col=col

	statwind=addwind(5,5,84,13,{"atk: "..p_mob.atk.."  def: "..p_mob.defmin.."-"..p_mob.defmax})
	
	curwind=invwind
end

function showuse()
	local itm=invwind.cur<3 and eqp[invwind.cur] or inv[invwind.cur-3]
	if itm==nil then return end
	local typ,txt=itm_type[itm],{}

	if (typ=="wep" or typ=="arm") and invwind.cur>3 then
		add(txt,"equip")
	end
	if typ=="fud" then
		add(txt,"eat")
	end
	if typ=="thr" or typ=="fud" then
		add(txt,"throw")
	end
	add(txt,"trash")
	
	usewind=addwind(84,invwind.cur*6+11,36,7+#txt*6,txt)
	usewind.cur=1
	curwind=usewind
end

function triguse()
	local verb,i,back=usewind.txt[usewind.cur],invwind.cur,true
	local itm=i<3 and eqp[i] or inv[i-3]
	if verb=="trash" then
		if i<3 then
			eqp[i]=nil
		else
			inv[i-3]=nil
		end
	elseif verb=="equip" then
		local slot=2
		if itm_type[itm]=="wep" then
			slot=1
		end
		inv[i-3]=eqp[slot]
		eqp[slot]=itm
	elseif verb=="eat" then
		eat(itm,p_mob)
		_upd,inv[i-3]=update_pturn,nil
		p_mob.mov=nil
		back=false
		p_t=0
	elseif verb=="throw" then
		_upd,thrslt,back=update_throw,i-3,false
	end
	
	updatestats()
	usewind.dur=0
	
	if back then
		del(wind,invwind)
		del(wind,statwind)
		showinv()
		invwind.cur=i
	else 
		invwind.dur=0
		statwind.dur=0
	end
end

function floormsg()
	showmsg("floor "..floor,120)
end
-->8
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
-->8
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
__gfx__
00000000000000002222222000000000e0eee0e000000000aaaaaaaa00aaa00000aaa00000000000000000000000000000aaa000a0aaa0a0a000000055555550
000000000000000022222220000000000000000000000000aaaaaaaa0a000a000a000a00066666600aaaaaa06666666000aaa00000000000a0aa000000000000
00700700000000002222222000000000eee0eee000000000a000000a0a000a000a000a00060000600a0000a060000060a00000a0a0aaa0a0a0aa0aa055000000
00077000000000002222222000000000000000000000000000aa0a0000aaa000a0aaa0a0060000600a0aa0a060000060a00a00a000aaa00000aa0aa055055000
00077000000000002222222000000000e0eee0e000000000a000000a0a00aa00aa00aaa0066666600aaaaaa066666660aaa0aaa0a0aaa0a0a0000aa055055050
007007000005000022222220000000000000000000000000a0a0aa0a0aaaaa000aaaaa000000000000000000000000000000000000aaa000a0aa000055055050
00000000000000002222222000000000eee0eee000000000a000000a00aaa00000aaa000066666600aaaaaa066666660aaaaaaa0a0aaa0a0a0aa0aa055055050
000000000000000000000000000000000000000000000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000
22222220222222202222222026666660666666200666666006666600666666006662666066666660222266606662222066666660222266602222666066622220
22222220222222202222222066666660666666606666666066666660666666606662666066666660222266606662222066666660222266602222666066622220
22222220222222202222222066666660666666606666666066666660666666606662266066666660222226606622222066666660222266602222266066622220
22222220222222202222222066622220222266606662222066626660222266606662222022222220222222202222222022222220222266602222222066622220
22222660666666606622222066622220222266606662666066626660666266606662266066222660662226606622266022222660662266606666666066622660
22226660666666606662222066622220222266606662666066626660666266606662666066626660666266606662666022226660666266606666666066626660
22226660666666606662222066622220222266606662666066626660666266606662666066626660666266606662666022226660666266606666666066626660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22226660066666006662222066622220222266600666666066626660666666006662666066626660666266606662666066626660666222206662666066666660
22226660666666606662222066622220222266606666666066626660666666606662666066626660666266606662666066626660666222206662666066666660
22226660666666606662222066622220222266606666666066222660666666606622266066226660662226606622266066622660662222206622666066666660
22226660666266606662222066622220222266606662222022222220222266602222222022226660222222202222222066622220222222202222666022222220
22226660666666606662222066666660666666606666666066222660666666606666666066226660222226606622222066622220666666602222666066222220
22226660666666606662222066666660666666606666666066626660666666606666666066626660222266606662222066622220666666602222666066622220
22226660066666006662222026666660666666200666666066626660666666006666666066626660222266606662222066622220666666602222666066622220
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22226660666666606662222066666660666266606662666066626660666266602222666066622220222266602222222066626660666222200000000000000000
22226660666666606662222066666660666266606662666066626660666266602222666066622220222266602222222066626660666222200000000000000000
22222660666666606622222066666660666266606662666066626660666266602222266066222220222226602222222066222660662222200000000000000000
22222220222222202222222022222220666266606662222066626660222266602222222022222220222222202222222022222220222222200000000000000000
22222220222222202222222066666660666266606666666066666660666666606622222022222660222226606622266022222220662222200000000000000000
22222220222222202222222066666660666266606666666066666660666666606662222022226660222266606662666022222220666222200000000000000000
22222220222222202222222066666660666266600666666006666600666666006662222022226660222266606662666022222220666222200000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666000060666000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06066600060666000606660006666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666660066666006066666060066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660066666006666666066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666600006660000666660006666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000606000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000
00060600006666000006060000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
00666600000606660066660000060666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000
00060666000666660006066600066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
06066666006000000006666606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000
66000000066066000660000066066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66066606066066000660660066066606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600000660000060060000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
60666060606660606066606060666060606660606066606000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660666066606660666066606660666066606660666000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060606660606066606060666060606660606066606000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660666066606660666066606660666066606660666000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606660600000000000000000000000000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a0a000000000000000000000000000a000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000
6660666000aaaa000000000000000000000000000a000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a0aaa00000000000000000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000aaaaa0000000000000000000000000a00aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aa000000005000000050000000500000aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
666066600aa0aa0000000000000000000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a00a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6660666000000000000000000000000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000a0aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000000000000000000000000a0aaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000005000000050000aaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666066600000000000000000000000000aaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6066606000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
6660666000000000000000000000000000aaa000a000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000a0aaa0000aa0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000000000000000000000000a0aaaaa0a000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000005000000050000aaaaaaa0a0a0aa0a00000000000000000000000000000000000000000000000000000000000000000000000000000000
666066600000000000000000000000000aaaaa00a000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
6066606000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666066600a000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606660600a00aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaa000005000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6660666000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000000006066606060666060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660000000006660666066606660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060000000006066606060666060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660000000006660666066606660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060006606600660066600060006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060006666600060060600600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060006666600060060600600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000666000060060600600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000060000666066606000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000050505000703030103010307020205050505050505050000000005050505050505050505000500000000050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020f0101010708020108010201010e0202020202020210111202020202020202000000000000000000000000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010101c001010d01c0010201010102020202020202200e2202020202020202000000000000000000000000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010101c0060a02020201020201010202020210111124012311111202020202000000000000000000000000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0207010107010102010101020101082202020220010101010101012202020202000000000000000000000000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020102020202020201140a020801012202020220010101060101012202020202000000000000020202020000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020102010101c001010101020101012202020220070101010101072202020202000000000000020101020000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020202010102020102020115333d02020220080701010107082202020202000000000000020101020000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010c02010102010101020135333d02020230313114011331313202020202000000000000020101020000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020d0202010d0122020202020202200f2202020202020202000000000000020101020000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010d010101010101020201012202020202020230313202020202020202000000000000020101020000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010102020108010202020201012202020202020202020202020202020202000000000000020101020000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0207010102010202020108020101080202020202020202020202020202020202000000000000020202020000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010d010101010101020101010202020202020202020202020202020202000000000000000000000000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02070a01020101010101010d0101010202020202020202020202020202020202000000000000000000000000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000000000653007500075300753000000000001f0001f0001f0001f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000000000000029610246101e610176101361014610166101761017610186101861019610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000077500a7500d7500f7501175013750147501675018750197501a7501a7501a7501a7501875017750157501475012750107500d7500b750087500775005750047500475003750037500375000000
00030000000001260015600186001a6001c6001f600206002160021650206501e6001c60019650176301460012600106301062000000000000000000000000000000000000000000000000000000000000000000
00100000000000000026220212201d2201b21018210172100000000000000000000000000000001d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900001a0201d0201f020210202702027020270201d0001d0001a0001a0001e0001c00015000135001250011500105001450000000000000000000000000000000000000000000000000000000000000000000
000200001053014530185301d5301e53012530165301c53024530255001b5001b5001a1001710014100101000c1000b1001560015600000000000000000000000000000000000000000000000000000000000000
00020000092300a2300b2300e2301123015230182301b2301c2301020011200132001620017200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001a0501e0502205026050290502b0502c0502c0502d0502d0502d0502c0502b0502a05029050270502505023050210501f0501d0501b0401904018040170401503014030130301302012020110200e010
