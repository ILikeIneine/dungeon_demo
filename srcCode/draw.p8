pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

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

end-- draw

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