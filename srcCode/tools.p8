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