pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

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
		for i=1,#w.txt do
			local txt=w.txt[i]
			print(txt,wx,wy,6)
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


function showmsg(txt)
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
	hpwind.y+=(hpy-hpwind.y)/5
end