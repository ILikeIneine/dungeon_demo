pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

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
end-- update

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

function update_inv()
	--inventory
	move_mue(curwind)
	if btnp(4) then
		if curwind==invwind then
			_upd=update_game
			invwind.dur=0
			statwind.dur=0
		--★
		elseif curwind==usewind then
			curwind=invwind
			usewind.dur=0
		end
	elseif btnp(5) then
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
		sfx(58)
		throw()
	end
end

function move_mue(wnd)
	if btnp(2) then
		wnd.cur-=1
	elseif btnp(3) then
		wnd.cur+=1
	end
	wnd.cur=(wnd.cur-1)%#wnd.txt+1
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
	elseif butt==5 then
		showinv()
	elseif butt==4 then
		mapgen()
	end
end