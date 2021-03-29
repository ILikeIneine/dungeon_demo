pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

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
	return (dx*dx+dy*dy)
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