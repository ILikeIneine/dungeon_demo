-- gameplay
-- core details

function moveplayer(dx,dy)
	--finish end of the position
	local destx,desty=p_x+dx,p_y+dy
	local tle=mget(destx,desty)
	
	if dx<0 then
		p_flip=true
	elseif dx>0 then
	 p_flip=false
	end
	
	if fget(tle,0) then
		--wall
		p_sox,p_soy=dx*8,dy*8
	 p_ox,p_oy=0,0
	 p_t=0
	 _upd=update_pturn
	 p_mov=mov_bump -- wall
	 if fget(tle,1) then
	 	trig_bump(tle,destx,desty)
	 end
	else
	 sfx(0,0)
		p_x+=dx
	 p_y+=dy
	 --use an value to neutralize
	 --the offset(animate the action) 
	 p_sox,p_soy=-dx*8,-dy*8
	 p_ox,p_oy=-dx*8,-dy*8
	 p_t=0
	 _upd=update_pturn
	 p_mov=mov_walk -- normal walk
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