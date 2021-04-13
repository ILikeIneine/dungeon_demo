pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

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

function update_pturn()
	checkbuttbuff()
	p_t=min(p_t+0.125,1)	
	p_mob:mov()
	
	if p_t==1 then	
		_upd=update_game
		if checkend() then
			doai()
		end
		calcdist(p_mob.x,p_mob.y)
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
	end
end