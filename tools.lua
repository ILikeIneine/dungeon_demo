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