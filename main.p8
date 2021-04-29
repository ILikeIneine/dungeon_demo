pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
	t=0
	
	dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
	-- player animation
	p_ani={240,241,242,243}
	-- direction
	-- ⬅️➡️⬆️⬇️
	dirx={-1,1,0,0,1,1,-1,-1}
	diry={0,0,-1,1,-1,1,1,-1}
	
	
	mob_ani={240,192}
	mob_atk={1,1}
	mob_hp ={1,1}
	mob_los={4,4}
	
	itm_name={"grass swords","leather armor","red potion","ninja star","rusty sword"}
	 itm_type={"wep","arm","fud","thr","wep"}
	 itm_stat1={2,0,1,1,1}
	 itm_stat2={0,2,0,0,0}
	 --defmin
	 --defmax
																			--⬇️         ➡️         ⬆️         ⬅️                       
	 crv_sig={0b11111111,0b11010110,0b01111100,0b11101001,0b10110011}
	 crv_msk={0,0b00001001,0b00000011,0b00000110,0b00001100}
	debug={}
	startgame()
 
 end
	
	
 function _update60()
	 t+=1
	 _upd()
	 dofloats()
	 dohpwind()
 end
	
 function _draw()
	_drw()
	drawind()
	fadeperc=0
	--checkfade()
	--★
	cursor(4,4)
	color(8)
	for txt in all(debug) do
	 print(txt)
	end
 end
	
 function startgame()
	 fadeperc=1
	buttbuff=-1
 
	 skipai=false
	 win=false
	 winfloor=9
	 
	mob={}
	dmob={}
	p_mob=addmob(1,1,1)
	
 -- for x=0,15 do
 -- 	for y=0,15 do
 -- 		if mget(x,y)==192 then
 -- 			addmob(2,x,y)
 -- 			mset(x,y,1)
 -- 		end
 -- 	end
 -- end
 
	p_t=0 
	
	inv,eqp={},{}
	--eqp[1] -weapon
	--eqp[2] -armor
	--inv[1-6] - inventory
 -- takeitem(1)
 -- takeitem(2)
 -- takeitem(3)
 -- takeitem(4)
 -- takeitem(5)
	
	wind={} 
	float={}
	fog=blankmap(0)
	talkwind=nil
	
	hpwind=addwind(5,5,28,13,{})
	--throwing direction
	thrdx,thrdy=1,0
	
	_upd=update_game
	_drw=draw_game
	
	genfloor(0)
	
	unfog()
 end