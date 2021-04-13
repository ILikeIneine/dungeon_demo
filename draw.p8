pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- draw

function draw_game()
	cls()
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

-- fog
	for x=0,15 do
		for y=0,15 do
			if fog[x][y]==1 then
				rectfill2(x*8,y*8,8,8,0)
			end
		end
	end	
	


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