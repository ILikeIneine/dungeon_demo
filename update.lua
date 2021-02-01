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
	p_mov()
	
	if p_t==1 then
		_upd=update_game
	end--if
end -- smooth!!!!!


function update_gameover()

end


function mov_walk()
	p_ox=p_sox*(1-p_t)
	p_oy=p_soy*(1-p_t)
end


function mov_bump()
	local tme=p_t
	if tme>0.5 then
		tme=1-p_t
	end
	p_ox=p_sox*tme
	p_oy=p_soy*tme
end -- wall duang!


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
		return 
	end
end