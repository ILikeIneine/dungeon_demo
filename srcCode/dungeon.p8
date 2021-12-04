pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()
 t=0
 shake=0
 
 open_c={0,1,2,8,14,15,7,0,0,0,0,0}
 open_t=400
 first=true


 dpal=explodeval("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14")
 -- player animation
 -- direction
 -- ⬅️➡️⬆️⬇️
 dirx=explodeval("-1,1,0,0,1,1,-1,-1")
 diry=explodeval("0,0,-1,1,-1,1,1,-1")
 
 
--	itm_name=explode("butter knife,cheese knife,iron axe,jinfu punch,rusty blade,crude cloth,stout shield,chain mail,shiva's guard,assault cuirass,clarity,faerie fire,magic wand,mekansm,healing salve,bottle,iron branch,javelin,energy booster,fate coin,trident")
--	itm_type=explode("wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,fud,fud,fud,fud,fud,fud,thr,thr,thr,thr,thr")
--	itm_stat1=explodeval("2,2,3,4,5,0,0,0,1,2,1,5,2,6,3,4,1,2,3,3,7")
--	itm_stat2=explodeval("0,2,0,0,0,1,2,4,3,3,0,0,0,0,0,0,0,0,0,0,0")
--	itm_minf=explodeval("1,2,3,4,5,1,2,3,4,5,1,1,3,3,1,1,1,2,3,4,6")
--	itm_maxf=explodeval("3,4,5,6,8,3,4,5,6,8,3,10,8,7,4,10,5,6,7,8,9")
--	itm_desc=explode(",,,,,,,,,,,curse,,bless,,stuns,,,,,")
--	
	itm_name=explode("butter knife,cheese knife,iron axe,jinfu punch,rusty blade,crude cloth,stout shield,chain mail,shiva's guard,assault cuirass,clarity,faerie fire,magic wand,mekansm,healing salve,bottle,iron branch,javelin,energy booster,fate coin,trident")
	itm_type=explode("wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,fud,fud,fud,fud,fud,fud,thr,thr,thr,thr,thr")
	itm_stat1=explodeval("2,2,3,4,5,0,0,0,1,2,1,5,2,6,3,4,1,2,3,3,7")
	itm_stat2=explodeval("0,2,0,0,0,1,2,4,3,3,0,0,0,0,0,0,0,0,0,0,0")
	itm_minf=explodeval("1,2,3,4,5,1,2,3,4,5,1,1,3,3,1,1,1,2,3,4,6")
	itm_maxf=explodeval("3,4,5,6,8,3,4,5,6,8,3,10,8,7,4,10,5,6,7,8,9")
	itm_desc=explode(",,,,,,,,,,heals,curse,heals alot,bless,plus maxhp,stuns,,,,,")
		
	mob_name=explode("player,slime,melt,shoggoth,mantis-man,giant scroption,ghost,golem,drake")
	mob_ani=explodeval("240,192,196,200,204,208,212,216,220")
	mob_atk=explodeval("1,1,2,1,2,3,4,5,5")
	mob_hp=explodeval("10,1,2,3,3,4,4,14,8")
	mob_los=explodeval("4,4,4,4,4,4,4,4,4")
	mob_minf=explodeval("0,1,2,3,4,5,6,7,8")
	mob_maxf=explodeval("0,3,4,5,6,7,8,8,8")
	mob_spec=explode(",,,,,stun,ghost,slow,")
																	 	--⬇️         ➡️         ⬆️         ⬅️                       
	crv_sig={0b11111111,0b11010110,0b01111100,0b11101001,0b10110011}
	crv_msk={0,0b00001001,0b00000011,0b00000110,0b00001100}
 
 free_sig={
 	0b00000000,
 	0b00000000,
 	0b00000000,
 	0b00000000,
 	0b00010000,
 	0b01000000,
 	0b00100000,
 	0b10000000,
 	0b10100001,
 	0b01101000,
 	0b01010100,
 	0b10010010
 }
 
 free_msk={
 	0b00001000,
 	0b00000100,
 	0b00000010,
 	0b00000001,
 	0b00000110,
 	0b00001100,
 	0b00001001,
 	0b00000011,
 	0b00001010,
 	0b00000101,
 	0b00001010,
 	0b00000101
 }
 
	wall_sig=explodeval("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252")
	wall_msk=explodeval("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")

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
 
	doshake()
 _drw()
 
 	drawind()
	drawlogo()

 --fadeperc=0
 checkfade()
 --★
 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end
 
function startgame()
	poke(0x3101,194)
	music(0)
	tani=0
	fadeperc=1
 buttbuff=-1
	
	logo_t=140
	logo_y=35

	skipai=false
	win=false
	winfloor=9
	
 mob={}
 dmob={}
 
 p_mob=addmob(1,1,1)
 p_t=0 
 
 inv,eqp={},{}
	makeipool()
 foodnames()
-- takeitem(16)
-- takeitem(14)
-- takeitem(14)


 wind={} 
 float={}
 
 talkwind=nil
 
 hpwind=addwind(5,5,28,13,{})
 
 --throwing direction
 thrdx,thrdy=1,0
 
 _upd=update_openning
 _drw=draw_openning
 
 st_steps,st_kills,st_meals,st_killer=0,0,0,""
 
 
end
-->8
-- update
function update_openning()
	open_t-=1
	if open_t==200 then
		fadeout()
	elseif open_t>0 then
		drawthanks()
	else
		fadeout()
		genfloor(0)
		_upd=update_game
		_drw=draw_game
	end
end

function update_game()
	if talkwind!=nil then
		if getbutt()==5 then
			sfx(53)
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
	if move_mue(curwind) and curwind==invwind then
		showhint()
	end
	if btnp(4) then
		sfx(53)
		if curwind==invwind then
			_upd=update_game
			invwind.dur=0
			statwind.dur=0
			if hintwind then
				hintwind.dur=0
			end
		--★
		elseif curwind==usewind then
			curwind=invwind
			usewind.dur=0
		end
	elseif btnp(5) then
		sfx(54)
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
		throw()
	end
end

function move_mue(wnd)
	local moved=false
	if btnp(2) then
		sfx(56)
		wnd.cur-=1
		moved=true
	elseif btnp(3) then
		sfx(56)
		wnd.cur+=1
		moved=true
	end
	wnd.cur=(wnd.cur-1)%#wnd.txt+1
	return moved
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
		if checkend() then
			if p_mob.stun then
				p_mob.stun=false
				doai()
			end
		end
	end--if
end -- smooth!!!!!


function update_gover()
	if btnp(❎) then
		sfx(54)
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
	if logo_t>0 then logo_t=0 end
	if open_t>0 then open_t=10 end
	if butt>=0 and butt<4 then
	 moveplayer(dirx[butt+1],diry[butt+1]) 
	elseif butt==5 then
		showinv()
		sfx(54)
	elseif butt==4 then
--		win=true
		genfloor(floor+1)
	end
end
-->8
-- draw
function draw_openning()
	if open_t>200 then
		fillp(0xa5a5)
		dopenning()
		fillp()
	end
end

function draw_game()
--	if open_t>0 then
--		fillp(0xa5a5)
--		dopenning()
--		fillp()
--		open_t-=1
--		return
--	elseif open_t==0 and first then
--		first=false
--		fadeout()
--	end
--	
	
	cls()
	if fadeperc==1 then return end
	animap()
	map()
	
--dead mob
	for m in all(dmob) do
		if sin(time()*8)>0 or m==p_mob then
			drawmob(m)
		end
		m.dur-=1
		if m.dur<=0 and m!=p_mob then
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

function drawlogo()
	if logo_t>=-100 then
		logo_t-=1
		if logo_t<=0 then
			logo_y+=logo_t/20	
		end
		palt(11,true)
		palt(0,false)
		spr(144,7,logo_y,14,3)
		palt()
		oprint8("by alphaworks",60,logo_y+25,14,0)
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

--[[function draw_gover()
	cls(2)
	print("y ded",50,50,7)
end

function draw_win()
	cls(2)
	print("y win",50,50,7)
end]]--

function draw_gover()
	cls()
	palt(12,true)
	spr(gover_spr,gover_x,30,gover_w,2)
	if not win then
		print(st_killer.." just killed you",25,45,8)
	end
	palt()
	color(5)
	cursor(44,50)
	print("")
	print("floor: "..floor)
	print("steps: "..st_steps)
	print("kills: "..st_kills)
	print("meals: "..st_meals)     
	
	print("press ❎",46,90,5+abs(sin(time()/2)*1.9))
	
end

function animap()
	tani+=1
	if(tani<15) return
	tani=0
	for x=0,15 do
		for y=0,15 do
			local tle=mget(x,y)
			if tle==64 or tle==66 then
				tle+=1
			elseif tle==65 or tle==67 then
				tle-=1
			end
			mset(x,y,tle)
		end
	end
end

function drawthanks()
	cls()
	color(5)
	cursor(22,50)
	print("")
	print("developed by alphaworks")
	color(10)
	print("     alphaworks")
	print("")
	color(5)
 print(" environment art by")
 color(13)
 print("     pixelartm")
	print("")
	color(5)
	print(" music was composed by")
	color(14)
	print("  sebastian haれかler")

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

function explode(s)
	local retval,lastpos={},1
	for i=1,#s do
		if sub(s,i,i)=="," then
			add(retval,sub(s, lastpos, i-1))
			i+=1
			lastpos=i
		end
	end
	add(retval,sub(s,lastpos,#s))
	return retval
end

function explodeval(_arr)
	return toval(explode(_arr))
end

function toval(_arr)
	local _retarr={}
	for _i in all(_arr) do
		add(_retarr,tonum(_i))
	end
	return _retarr
end

function doshake()
	local shakex,shakey=16-rnd(32),16-rnd(32)
	camera(shakex*shake,shakey*shake)
	shake*=0.95
	if (shake<0.05) shake=0
end

function dopenning()
	for w=3,68,.1 do
		a=4/w+time()/4
		k=145/w
		x=64+cos(a)*k
		y=64+sin(a)*k
		i=35/w+2+time()*3
		rect(x-w,y-w,x+w,y+w,f(i)*16+f(i+.5))
	end
end

function f(i)
	return open_c[flr(1.5+abs(6-i%12))]
end
-->8
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
 if _upd==update_openning then
 	return
 end

	for w in all(wind) do
		local wx,wy,ww,wh=w.x,w.y,w.w,w.h
		rectfill2(wx,wy,ww,wh,0)
		rect(wx+1,wy+1,ww+wx-2,wh+wy-2,6)
		wx+=4
		wy+=4
		clip(wx,wy,ww-8,wh-8)
		if w.cur then--if have cursor
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

	local txt="ok    "
	if p_mob.bless<0 then
		txt="curse "
	elseif p_mob.bless>0 then
		txt="bless "
	end

	statwind=addwind(5,5,84,13,{txt.."atk:"..p_mob.atk.." def:"..p_mob.defmin.."-"..p_mob.defmax})
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
		if hintwind then
			hintwind.dur=0
		end
	end
end

function floormsg()
	showmsg("floor "..floor,120)
end

function showhint()
	if hintwind then
		hintwind.dur=0
		hintwind=nil
	end
	
	if invwind.cur>3 then
		local itm=inv[invwind.cur-3]
		
		if itm and itm_type[itm]=="fud" then
			local txt=itm_known[itm] and itm_desc[itm] or "???"
			hintwind=addwind(5,78,#txt*4+7,13,{txt})
		end
	end
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

-->8
--gen
function genfloor(f)
	floor=f
	makefipool()
	mob={}
	add(mob,p_mob)
	fog=blankmap(0)
	if floor==1 then
		st_step=0
		poke(0x3101,66)
	end
	if floor==0 then
		copymap(16,0)
	elseif floor==winfloor then
		copymap(32,0)
	else
	 fog=blankmap(1)
		mapgen()
		unfog()
	end
end

function mapgen()
	repeat
		copymap(48,0)
		rooms={}
		roomap=blankmap(0)
		doors={}
		genrooms()
		mazeworm()
	 placeflags()
		carvedoors()
	until #flaglib==1
	
	carvescuts()
	startend()
	fillends()
	prettywalls()
	
	installdoors()
	
	spawnchests()
	spawnmobs()
	decorooms()
	
	debug[1]=#flaglib
end

function snapshot()
--	cls()
--	map()
--	for i=0,10 do
--		flip()
--	end
end
-----------------
-- rooms
-----------------
function genrooms()
--fmax -> how many times u failed
--rmax -> how many rooms should played
	local fmax,rmax=5,4
	local mw,mh=10,10
	
	repeat
		local r=rndroom(mw,mh)
		if placeroom(r) then
			if #rooms==1 then
				mw/=2
				mh/=2
			end
			rmax-=1
			snapshot()
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
		snapshot()
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
		return  sigarray(getsig(x,y),crv_sig,crv_msk)!=0
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

function sigarray(sig,arr,marr)
	for i=1,#arr do
		if bcomp(sig,arr[i],marr[i]) then 
			return i 
		end
	end
	return 0
end
------------
-- doorways
------------

function placeflags()
	local curf=1
	flags,flaglib=blankmap(0),{}
	for _x=0,15 do
		for _y=0,15 do
			if iswalkable(_x,_y) and flags[_x][_y]==0 then
				growflag(_x,_y,curf)
				add(flaglib,curf)
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
						add(drs,{x=_x,y=_y,f1=_f1,f2=_f2})
					end--if
				end--if
			end--for
		end--for
		if #drs>0 then
			local d=getrnd(drs)
			add(doors,d)
			mset(d.x,d.y,1)
			snapshot()
			growflag(d.x,d.y,d.f1)
			del(flaglib,d.f2)
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
			snapshot()
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
					snapshot()
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

function nexttoroom(x,y,dirs)
	local dirs= dirs or 4
	for i=1,dirs do
			if inbounds(x+dirx[i],y+diry[i]) and 
						roomap[x+dirx[i]][y+diry[i]]!=0 then
			return true
		end
	end
	return false
end

function installdoors()
	for d in all(doors) do
		local dx,dy=d.x,d.y
		if (mget(dx,dy)==1 or 
					mget(dx,dy)==4) and 
					isdoor(dx,dy) then
			mset(dx,dy,13)
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
			if tmp>=0 then
				local score=starscore(x,y)
				tmp=tmp-score
				if tmp<low and score>=0 then
					px,py,low=x,y,tmp
				end
			end
		end
	end
	
	
	mset(px,py,15)
	p_mob.x=px
	p_mob.y=py
end

function starscore(x,y)
	if roomap[x][y]==0 then
		if nexttoroom(x,y,8) then return -1 end
		if freestanding(x,y)>0 then
			return 5
		else 
			if cancarve(x,y) then
				return 0
			end
		end
	else
		local scr=freestanding(x,y)
		if scr>0 then
			return scr<=8 and 3 or 0
		end
	end
	return -1
end

function next2tile(_x,_y,tle)
	for i=1,4 do
		if inbounds(_x+dirx[i],_y+diry[i]) and mget(_x+dirx[i],_y+diry[i])==tle then
			return true
		end
	end
	return false
end

function prettywalls()
	for x=0,15 do
	 for y=0,15 do
	 	local tle=mget(x,y)
	 	if tle==2 then
	 		local ntle=sigarray(getsig(x,y),wall_sig,wall_msk)
	 		tle = ntle==0 and 3 or 15+ntle
	 		mset(x,y,tle)
	 	elseif tle==1 then
	 		if not iswalkable(x,y-1) then
	 			mset(x,y,4)
	 		end
	 	end
	 end
	end
end

function decorooms()
	tarr_dirt=explodeval("1,74,75,76")
	tarr_farn=explodeval("1,70,70,70,71,71,72,73")
	tarr_vase=explodeval("1,1,7,8")
	local funcs,func={
		deco_dirt,
		deco_torch,
		deco_carpet,
		deco_farn,
		deco_vase
	},deco_vase
	
	for r in all(rooms) do		
		for x=0,r.w-1 do
			for y=1,r.h-1 do
				if mget(r.x+x,r.y+y)==1 then
		 		func(r,r.x+x,r.y+y,x,y)		 
		 	end
		 end
		end	
		func=getrnd(funcs)
	end
end

function deco_torch(r,tx,ty,x,y)
	if rnd(3)>1 and y%2==1 and not next2tile(tx,ty,13) then
		if x==0 then
		 mset(tx,ty,64)
		elseif x==r.w-1 then
			mset(tx,ty,66)
		end
	end
end

function deco_carpet(r,tx,ty,x,y)
	deco_torch(r,tx,ty,x,y)
	if x>0 and x<r.w-1 and y<r.h-1 then
		mset(tx,ty,68)
	end
end

function deco_dirt(r,tx,ty,x,y)
	mset(tx,ty,getrnd(tarr_dirt))
end


function deco_farn(r,tx,ty,x,y)
	mset(tx,ty,getrnd(tarr_farn))
end

function deco_vase(r,tx,ty,x,y)
	if iswalkable(tx,ty,"checkmobs") and 
				not next2tile(tx,ty,13) and
				not bcomp(getsig(tx,ty),0,0b00001111)	then
				
		mset(tx,ty,getrnd(tarr_vase))
	end
end

function	spawnchests()
	local chestdice,rpot,rare,place=explodeval("0,1,1,1,2,3"),{},true
	place=getrnd(chestdice)
	
	for r in all(rooms) do
		add(rpot,r)
	end
	
	while place>0 and #rpot>0 do
		local r=getrnd(rpot)
		placechest(r,rare)
		rare=false
		place-=1
		del(rpot,r)
	end
	
end

function placechest(r,rare)
	local x,y
	repeat
		x=r.x+flr(rnd(r.w-2))+1
		y=r.y+flr(rnd(r.h-2))+1
	until mget(x,y)==1 
	if rare then
		mset(x,y,12)
	else
	 mset(x,y,10)
	end
end

function freestanding(x,y)
	return sigarray(getsig(x,y),free_sig,free_msk)
end
__gfx__
000000000000000066606660000000006660666066606660aaaaaaaa00aaa00000aaa00000000000000000000000000000aaa000a0aaa0a0a000000055555550
000000000000000000000000000000000000000000000000aaaaaaaa0a000a000a000a00066666600aaaaaa06666666000aaa00000000000a0aa000000000000
007007000000000060666060000000006066606060000060a000000a0a000a000a000a00060000600a0000a060000060a00000a0a0aaa0a0a0aa0aa055000000
00077000000000000000000000000000000000000000000000aa0a0000aaa000a0aaa0a0060000600a0aa0a060000060a00a00a000a0a00000aa0aa055055000
000770000000000066606660000000000000000060000060a000000a0a00aa00aa00aaa0066666600aaaaaa066666660aaa0aaa0a0a0a0a0a0000aa055055050
007007000005000000000000000000000005000000000000a0a0aa0a0aaaaa000aaaaa000000000000000000000000000000000000aaa000a0aa000055055050
000000000000000060666060000000000000000060666060a000000a00aaa00000aaa000066666600aaaaaa066666660aaaaaaa0a0aaa0a0a0aa0aa055055050
000000000000000000000000000000000000000000000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006666660666666000666666006666600666666006660666066666660000066606660000066666660000066600000666066600000
00000000000000000000000066666660666666606666666066666660666666606660666066666660000066606660000066666660000066600000666066600000
00000000000000000000000066666660666666606666666066666660666666606660066066666660000006606600000066666660000066600000066066600000
00000000000000000000000066600000000066606660000066606660000066606660000000000000000000000000000000000000000066600000000066600000
00000660666666606600000066600000000066606660666066606660666066606660066066000660660006606600066000000660660066606666666066600660
00006660666666606660000066600000000066606660666066606660666066606660666066606660666066606660666000006660666066606666666066606660
00006660666666606660000066600000000066606660666066606660666066606660666066606660666066606660666000006660666066606666666066606660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660066666006660000066600000000066600666666066606660666666006660666066606660666066606660666066606660666000006660666066666660
00006660666666606660000066600000000066606666666066606660666666606660666066606660666066606660666066606660666000006660666066666660
00006660666666606660000066600000000066606666666066000660666666606600066066006660660006606600066066600660660000006600666066666660
00006660666066606660000066600000000066606660000000000000000066600000000000006660000000000000000066600000000000000000666000000000
00006660666666606660000066666660666666606666666066000660666666606666666066006660000006606600000066600000666666600000666066000000
00006660666666606660000066666660666666606666666066606660666666606666666066606660000066606660000066600000666666600000666066600000
00006660066666006660000006666660666666000666666066606660666666006666666066606660000066606660000066600000666666600000666066600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660666666606660000066666660666066606660666066606660666066600000666066600000000066600000000066606660666000005000000000000000
00006660666666606660000066666660666066606660666066606660666066600000666066600000000066600000000066606660666000005055000000000000
00000660666666606600000066666660666066606660666066606660666066600000066066000000000006600000000066000660660000005055000000000000
00000000000000000000000000000000666066606660000066606660000066600000000000000000000000000000000000000000000000000055055000000000
00000000000000000000000066666660666066606666666066666660666666606600000000000660000006606600066000000000660000005000055000000000
00000000000000000000000066666660666066606666666066666660666666606660000000006660000066606660666000000000666000005055000000000000
00000000000000000000000066666660666066600666666006666600666666006660000000006660000066606660666000000000666000005055055000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000000060000000000505050506660666000000000000330000000000000300000000000000000000000000000000000000000000000000000
60000000060000000000006000000600000000000000000000300300000000303000000030000030000000000000005005000000000000000000000000000000
66000000660000000000066000000660505050506066606000030000033003003000003030030300005000500050055000550000000000000000000000000000
00000000000000000000000000000000000000000000000003030000333030000000003000030300000000000000000000000050000000000000000000000000
66000000660000000000066000000660505050505050505000003030000030300003000000300300000000000000000000000500000000000000000000000000
00050000000500000005000000050000000000000000000000303000000300000003030030000300000050000055005005550050000000000000000000000000
60000000600000000000006000000060505050505050505000003000000300003003030030000000000550000555500000555500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000003000000000000000000005500000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000
c7777cc7777cccccccccccccccccccc77777777cccccccccccccccccccccc77ccccccccccccccccccccccccccccccccc00000000000000000000000000000000
cc77cccc77cccccccccccccccccccccc77cccc77ccccccccccccccccccccc77ccccccccccccccccccccccccccccccccc00000000000000000000000000000000
ccc77cc77cc77777cc7777cc7777cccc77ccccc77cc777777c7777777cccc77ccccccccccccccccccccccccccccccccc00000000000000000000000000000000
cccc7777cc77ccc77cc77cccc77ccccc77cccccc77cc77cc7cc77ccc77ccc77ccccccccccccccccccccccccccccccccc00000000000000000000000000000000
cccc7777c77ccccc77c77cccc77ccccc77cccccc77cc77ccccc77cccc77cc77ccccccccccccccccccccccccccccccccc0000000000aaaaa00000000000000000
ccccc77cc77ccccc77c77cccc77ccccc77cccccc77cc7777ccc77cccc77cc77ccccccccccccccccccccccccccccccccc000000000aaaaaaaa000000000aaaa00
ccccc77cc77ccccc77c77cccc77ccccc77cccccc77cc77ccccc77cccc77cc77ccccccccccccccccccccccccccccccccc00000000aa0aaaaaaaa00000aaaaaaa0
ccccc77cc77ccccc77c77cccc77ccccc77ccccc77ccc77ccccc77cccc77cc77ccccccccccccccccccccccccccccccccc00000000a00aaaaaaaaaaaaaaaaaaaaa
ccccc77ccc77ccc77ccc77cc77cccccc77cccc77cccc77cc7cc77ccc77cccccccccccccccccccccccccccccccccccccc00000000aaaaaaaaaaaaaaaaaaaaaaaa
cccc7777ccc77777ccccc7777cccccc77777777cccc777777c7777777cccc77ccccccccccccccccccccccccccccccccc00000000aaaaaaaaaaaaaaaaaaaaaa0a
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000aaaaaaaaaaaaaaaaaaaaa0aa
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000aaaaaaaaaaaaaaaaaaa0aa0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000aaaa0aaaaaaaaaa0a0a0a0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000a00aaa0a0a0a0a0a0a0a0a0a
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000a0000aaaa0a0a0a0a0aaa00a
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000aa000000aaaaaaaaaaa000aa
c7777cc7777cccccccccccccccccccc7cccc77777cccccccccccccccccccc77ccccccccccccccccccccccccccccccccc00000000aa000aa000000000000000aa
cc77cccc77cccccccccccccccccccccccc777ccc77ccccccccccccccccccc77ccccccccccccccccccccccccccccccccc000000000aa0000aaaaaaaaaa0000aa0
ccc77cc77cc77777cc7777cc7777cccccc77cccc77c7777777c77777777cc77ccccccccccccccccccccccccccccccccc000000000a0aa00000000000000aa0a0
cccc7777cc77ccc77cc77cccc77cccccc77ccccccccc77ccc7cccc77cc7cc77ccccccccccccccccccccccccccccccccc0000000000a00aa0000000000aa00a00
cccc7777c77ccccc77c77cccc77cccccc77ccccccccc77cccccccc77ccccc77ccccccccccccccccccccccccccccccccc00000000000aa00aaaaaaaaaa00aa000
ccccc77cc77ccccc77c77cccc77cccccc77ccccccccc77cccccccc77ccccc77ccccccccccccccccccccccccccccccccc0000000000000aa0000000000aa00000
ccccc77cc77ccccc77c77cccc77cccccc77cccc7777c7777cccccc77ccccc77ccccccccccccccccccccccccccccccccc000000000000000aaaaaaaaaa0000000
ccccc77cc77ccccc77c77cccc77cccccc77ccccc77cc77cccccccc77ccccc77ccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
ccccc77ccc77ccc77ccc77cc77cccccccc77cccc77cc77cccccccc77ccccc77ccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
cccc7777ccc77777ccccc7777cccccc7ccc77ccc77cc77ccc7cccc77cccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
cccccccccccccccccccccccccccccccccccc77777cc7777777ccc7777cccc77ccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
bbbbbbbbbbbbbbbbb77ccc7ccc77bbbbbbbbbbbb99999bb77aaaaa77bbbbbbbbb777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000
bbbbbbbbbbbbbbb77cc7777c7cc777bbbbbbbbb99999977aaaaaaaaa77bbbbbb70007bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000
bbbbbbbbbbbbbb77ccc7cc7c7cccc77bbbbbbbb9999977aaaaaaaaaaa77bbbb77070777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000
bbbbbbbbbbbb777cc7cccccc7c7ccc777bbbbbb999777aaaaaaaaaaaaaa77bb770700c77bbbbbbbbbbbbbbbb77777bbbbbbbbbbbbbbbbbbb0000000000000000
bbbbbbbbbbb77cccccccccccccccccc77bbbbbbb977aaaaaaaaaaaaaaaaa777c07770cc77bbbbbbbbbbbb777cccc7777bbbbbbbbbbbbbbbb0000000000000000
bbbbbbbbbb77cccccccccccccccccccc77bbbbbb77aaaaaaaaaaaaaaaaaaa77c07770ccc77bbbbbbbb7777cccc7cccc777bbbbbbbbbbbbbb0000000000000000
bbbbbbbbb77ccccccccccccccccccccccc77bbb77aaaaaaaaaaaaaaaaaaa77cc07770cc77777bb7777cccccc777cccccc77bbbbbbbbbbbbb0000000000000000
bbbbbbb777ccccccccccccccccccccccccc77b77aaaaaaaaaaaaaaaaaaa77ccc07770ccc7cc7777ccccc7ccccccccccccc77bbbbbbbbbbbb0000000000000000
bbbbb777cccccccccccccccccccccccccccc777aaaaaaaa8a8aaaaaaa777cccc07770ccc7cc0000000cccccc00000000000000000bbbbbbb0000000000000000
bbb777cccccccccccccccccccccccccccccccc77aaaaaaa88800000777ccc77c07070ccccc007777700ccc0077777777777777700bbbbbbb0000000000000000
bb00000000000000000000000000000ccc0000000aaaaaa087777707ccccc7cc07070cc7cc0777777700cc0770000000000000000bbbbbbb0000000000000000
bb0777777777007777777770077770cccc0777707aaaaaa077777770cccccccc07070ccccc0770777770c00770cccccc0077777700bbbbbb0000000000000000
bb077777770000700070007007770ccccc07770c77aaaaa0777787700ccccccc07070ccccc0770077770c00770cccccc07770007700bbbbb0000000000000000
bb077777700cc000c070c0000700cccccc0700ccc77aaaa07777877e0cccccc0070700cccc0770007770c07700cccccc07000cc0770bbbbb0000000000000000
bb07777000ccccccc070cccc070ccccccc070ccccc77aaa0777777700cccccc0770770cccc0777777700c077000000cc0700cccc070bbbbb0000000000000000
bb077000ccccccccc070cccc070ccccccc070cccccc777707777770cccccccc0777770cccc077700000cc0777777770000b0000007007bbb0000000000000000
bb0000ccccccccccc070cccc070ccccccc070ccccccc77b07070700cc00ccc007070700ccc07777000000c0777777770cc007777777077bb0000000000000000
bb07700cccccccccc070cccc070cccccc0070ccccccc777077777770070ccc077070770ccc0777770777000000007770c00777777770c7bb0000000000000000
bb077700ccccccccc070cccc070ccccc00070ccccc000b7076677777670ccc077070770ccc077777777770ccccc00770c07777777770c77b0000000000000000
bb0777700cccccccc070c000070ccccc07070ccccc070bb077767777670c0007707077000c077707777770ccccc00770007777077770cc770000000000000000
bb077777000cc000c070c070070cccc007070cccc0070bb077667777670c0777777777770c077000070770c000007770077770077000ccc70000000000000000
bb0777777700c07000700070070000007707000000770bb0776777776700070077777007000770bb0707700777777700007777777000cccb0000000000000000
bb0777777770007777777770077777777707777777770bb0077777706700777770007777707770bb00777077777770b0700777770770cccb0000000000000000
bb0000000000000000000000000000000000000000000bbb000000000000000000b00000000000bbbb00000000000bbb000000000070bbbb0000000000000000
00000000000000000000000000000000000006000000000006000000000000006600660000000000600060000000000000666000006660000006600000666000
00000000006660000000000000000000006600600006600060066000006600000060006066006600600060006600660000606600006066000060660000606600
00666000060666000066600000000000006660606066600060666000006660600060006000600060060006000060006066066660660666600006666000066660
06066600060666000606660006666660066666006066006006666600600660600606660006066600060666000606660060666660606666606666666066666660
60666660066666006066666060066666600660000666660006660060066666006060606060606660606666606066606000606600006606606060660060666660
66666660066666006666666066666666606600000666600000666060006666006066066060666060606060606060066000000660000660660000066000066066
06666600006660000666660006666660006666000066660006666000066660000666666006606660066606600666606000006600006606000000660000660660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066600000000000000000000000000000000000000000000000000006600000000000000666000000000000000000000666600666666000066660000666600
00600660006666000000000000666600006600000000000000660000066660000066600066666600006660000000000066066000660660006606600066666000
00000060060006606666660006000660066660000066000006666000006060006666660060666600666666000066600066666600006666006666660066666600
00006660000066600000666000006660006060000666600000606000666660606066660066666660606666006666660000006000000060000000600000006000
00666600006666000066660000666600666660606060600066666060606666606666666000666660666666606066660000660060006600000066006000660060
66066060660660606606606066066060606666606666606060666660000666000066666066666660006666606666666006660060066600000666006006660060
06606060066060600660606006606060000666000066666000066600000000006666666060606660666666600066666000666600006666600066660000666600
00000000000000000000000000000000000000000006660000000000000000006060666000066660606066606666666000000000000000000000000000000000
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
0000050000050703030103010307020205050505050505050505050505050505050505050505050505050505050505050505050505050505050505050501000000000000000004040000000000000000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000050505050505050505050505050505050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020f0101010708020108010201010e0200000000000000000000000000000000050000000000000000000000000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010101c001010d01c001020101010200000000000000000000000000000000050000000010111111111112000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010101c0060a02020201020201010200000000000000101112000000000000050000000020020202020222000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0207010107010102010101020101082200000000000000200e22000000000000050000000020020502050222000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020102020202020201140a020801012200000000101111244423111112000000050000000020020202020222000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020102010101c001010101020101012200000000200404454445040422000000050000000020040404040422000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020202010102020102020115333d00000000204001440644014222000000050000001024015d5e5f0122000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010c02010102010101020135333d00000000200101444444010122000000050000002001016d6e6f0122000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020d0202010d012200000000200101010101010122000000050000002001017d7e7f0122000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010d010101010101020201012200000000303131140113313132000000050000002001010101010122000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010102020108010202020201012200000000000000200f22000000000000050000003014010101010122000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02070101020102020201080201010802000000000000003031320000000000000500000000200f0013313132000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010d010101010101020101010200000000000000000000000000000000050000000000000000000000000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02070a01020101010101010d0101010200000000000000000000000000000000050000000000000000000000000000050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000050505050505050505050505050505050202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011600000217502705021150200002135000000210402104021250000002105000000215500000000000211401175017050111500105011350010500105001050112500105001050010501135001000000000000
01160000215101d510195251a535215351d520195151a5152151221515215252252521525215150e51511515205141c510195251c535205351c520195151c5152051220515205252152520525205150d51510515
0116000000000215101d510195151a515215151d510195151a5152151221515215152251521515215150e51511515205141c510195151c515205151c510195151c5152051220515205152151520515205150d515
01160000150051d00515015150151a0251a0151d0151d015220252201521025210151d0251d0151502515015140201402214025140151400514004140050d000100140c0100d0201003014030150201401210015
011600000217502705021150200002135000000000000000021250000000000000000215500000000000211405175001050511500105051350010500105001050512500105001050010505135000000000000000
01160000215141d510195251a525215251d520195151a5152151221515215202252021525215150e52511515205141d5101852519525205251d520185151951520512205151c5201d52020525205151052511515
0116000000000215141d510195151a515215151d510195151a5152151221515215102251021515215150e51511515205141d5101851519515205151d510185151951520512205151c5101d510205152051510515
01160000000002000015015150151a0251a0151d0251d015220252201521015210151d0251d01526015260152502025012250152501518000000000000000000100000d02011030140401505014040190301d010
011600000717502005071150200007135000000000000000071250000000000000000715500000000000711403175001050311500105031350010500105001050312500105001050010503155000000000000000
01160000091750200509115020000913500000000000000009125000000000000000091550000000000091140a175001050a115001050a1250010504105001050a125001050910500105041350c1000912500100
01160000225121f5201a5251f515225251f5201a5151f515215122151222525215251f5251f5150e52513515225141f5101b5251f525225251f5201b5151f515215122151222525215251f5251f5150f52513515
01160000215141c510195251d515215251c520195151d5152151222510215201f51021512215150d52510515205141d5101a52516515205151d5201a5151651520522205151d515205251f5251d5151c52519515
0116000000000225121f5101a5151f515225151f5101a5151f515215122151222515215151f5151f5150e51513515225141f5101b5151f515225151f5101b5151f515215122151222515215151f5151f5150f515
0116000000000215141c510195151d515215151c510195151d5152151222510215101f51021510215150d51510515205141d5101a51516515205151d5101a5152051520510205151d515205151f5151d5151c515
01160000000000000022015220151f0251f0151a0151a01522025220151f0151f01519020190221a0251a0151f0201f0221f0151f01518000000000000000000000000f010130201603015030160321502013015
011600001902519015220252201521015210151c0251c015220252201521025210151c0221c0151d0251d01520020200222001520015110051a0151d015220152601226012280102601625010250122501025015
011600000217509035110150203502135090351101502104021250000002105000000212511035110150211401175080351001501035011350803510015001050112500105001050010501135100351001500000
0116000002175090351101502035021350903511015021040212500000021050000002155110351101502114051750c0351401505035051350c03514015001050512500105001050010505135140351401500000
01160000071750e0351601507035071350e0351601502104071250000002105000000715516035160150711403175160351301503035031351603513015001050312500105001050010503135160351601500000
0116000009175100351101509035091351003511015021040912500000021050000009155100350d015091140a17510035110150a0350a1351003511015001050a12500105001050010509135150350d01509020
0116000002215020451a7051a7050e70511705117050e7050e71511725117250e7250e53511535115450e12501215010451a6001a70001205012051a3001a2001071514725147251072510535155351554514515
0116000002215020451a7051a7050e70511705117050e7050e71511725117250e7250e53511535115450e12505215050451a6001a70001205012051a3001a2001171514725147251172511535195351954518515
0116000007215070451a7051a7050e70511705117050e705137151672516725137251353516535165451312503215030451a6001a70001205012051a3001a2001371516725167250d7250f535165351654513515
0116000009215090451a7051a7050e70511705117050e7050d715157251572510725115351653516545157250a2150a0451a6001a70001205012051a3001a2000e71510725117250e7250d5350e5351154510515
0116000021005210051d00515015150151a0151a0151d0151d015220152201521015210151d0151d01515015150151401014012140151401518000000000000000000100100c0100d01010010140101501014010
0116000000000000002000015015150151a0151a0151d0151d015220152201521015210151d0151a01526015260152501019015190151900518000000000000000000000000d0101101014010150101401019010
0116000000000000000000022015220151f0151f0151a0151a01522015220151f0151f01519010190121a0151a0151f0101f012130151300518000000000000000000000000f0101301016010150101601215010
01160000190051901519015220152201521015210151c0151c015220152201521015210151c0121c0151d0151d015200102001220015200051d0051a015220152901029012260102801628010280122801528005
01160000097140e720117300e730097250e7251173502735057240e725117350e735097450e7401174002740087400d740107200d720087350d7351072501725047240d725107250d725087350d7301074001740
01160000097240e720117300e730097450e745117350e735117240e725117350e735097450e740117400e740087400d740117200d720087350d735117250d725117240d725117250d725087350d730117400d740
011600000a7240e720137300e7300a7450e745137350e735137240e725137350e7350a7450e740137400e7400a7400f740137200f7200a7350f735137250f725137240f725137250f7250a7350f730137400f740
0116000010724097201073009730107450974510735097351072409725107350973510745097401074009740117400e740117200e720117350e735117250e725117240e725117250e725097350d730107400d740
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0113000029700297002670026700257002570022700227000000026700217000e7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300000255011555165501555016555115550d5500a5500e5500e5520e5520e5521400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001170015700197001a700117001670019700197001a7001a70025700257002570025700257002570025700197021970219702000000000000000000000000000000000000000000000000000000000000
001300000d2200c2200b220154000000000000000000000029720287302672626745287402173029720217322673026732267350210526702267020e705021050000000000000000000000000000000000000000
0113000000000000000000000000000000000000000000000e1100d1200a1300e1350d135091000a120091300e1220e1200e1200e1000e1020e10200000000000000000000000000000000000000000000000000
0113000000000000000000000000000000000000000000000a14300000000000a060090600a000090000900002072020720207202005020020200500000000000000000000000000000000000000000000000000
011200001b0001f0002200023000220001f0002000022000230002700023000200001f000200001f0001b0001f00022000200002200023000270001d000200001f0001f0001f0001f00000000000000000000000
011200001f5001f5001b5001b50022500225002350023500225002250020500205001f5001f500205002050022500225002350023500255002550023500235002250022500225002250000000000000000000000
01120000030000300003000130000700007000080000800008000170000b0000b0000a0000a0000a0000f00003000030000800008000080001100005000050000300003000030000300003000030000300000000
011200001e0201e0201e032210401a0401e0401f0301f0321f0301f0301e0201e0201f0201f020210302103022030220322902029020290222902228020280202602026020260222602200000000000000000000
011200001a7041a70415534155301a5321a5301c5401c5401c5451a540155401554516532165301a5301a5351f5401f54522544225402254222545215341f5301e5441e5401e5421e54500000000000000000000
00120000110250e000120351500015045150000e0550e00512045150051503515005130251500516035260051a0452100513045210051604526005100251f0050e0500e0520e0520e0500c000000000000000000
0002000031530315302d500315003b5303b5302e5000050031530315302e5002d50039530395302d5000050031530315303153031530315203152000500005000050000500005000050000500005000050000500
000100003101031010300102f0102d0202c0202a02028030270302503023050210501e0501d0501b05018050160501405012050120301103011010110100e0100b01007010000000000000000000000000000000
00010000240102e0202b0202602021010210101a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000024010337203372033720277103a7103a71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000096201163005620056150160000600006001160011600116001160001620006200a6100a6050a6000a6000f6000f6000f6000f6000060000600026100261002615016000160005600056000160001600
00010000145201a520015000150001500015000150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000211102114015140271300f6300f6101c610196001761016600156100f6000c61009600076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b61006540065401963018630116100e6100c610096100861000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001f5302b5302e5302e5303250032500395002751027510285102a510005000050000500275102951029510005000050000500005002451024510245102751029510005000050000500005000050000500
0001000024030240301c0301c0302a2302823025210212101e2101b2101b21016210112100d2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100020000200
0001000024030240301c0301c03039010390103a0103001030010300102d010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000210302703025040230301a030190100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000d720137200d7100c40031200312000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00424344
00 00031843
00 04071947
00 080e1a4e
00 090f1b4f
00 10010243
00 11050647
00 120a0c4e
00 130b0d4f
00 001c0344
00 041d0744
00 081e0e44
00 091f0f44
00 00145c44
00 04155d44
00 08165e44
02 13175f44
00 41424344
00 41424344
00 41424344
00 41424344
00 68696744
04 2a2b2c44
00 6d6e6f44
04 30313244
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
03 00424344

