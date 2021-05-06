pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
 t=0
 shake=0
 
 open_c={0,1,2,8,14,15,7,0,0,0,0,0}
 open_t=400
 first=true


 dpal=explodeval("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14")
 -- player animation
 -- direction
 -- ⬅️➡️⬆️⬇️
 dirx=explodeval("-1,1,0,0,1,1,-1,-1")
 diry=explodeval("0,0,-1,1,-1,1,1,-1")
 
 
--	itm_name=explode("butter knife,cheese knife,iron axe,jinfu punch,rusty blade,crude cloth,stout shield,chain mail,shiva's guard,assault cuirass,clarity,faerie fire,magic wand,mekansm,healing salve,bottle,iron branch,javelin,energy booster,fate coin,trident")
--	itm_type=explode("wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,fud,fud,fud,fud,fud,fud,thr,thr,thr,thr,thr")
--	itm_stat1=explodeval("2,2,3,4,5,0,0,0,1,2,1,5,2,6,3,4,1,2,3,3,7")
--	itm_stat2=explodeval("0,2,0,0,0,1,2,4,3,3,0,0,0,0,0,0,0,0,0,0,0")
--	itm_minf=explodeval("1,2,3,4,5,1,2,3,4,5,1,1,3,3,1,1,1,2,3,4,6")
--	itm_maxf=explodeval("3,4,5,6,8,3,4,5,6,8,3,10,8,7,4,10,5,6,7,8,9")
--	itm_desc=explode(",,,,,,,,,,,curse,,bless,,stuns,,,,,")
--	
	itm_name=explode("butter knife,cheese knife,iron axe,jinfu punch,rusty blade,crude cloth,stout shield,chain mail,shiva's guard,assault cuirass,clarity,faerie fire,magic wand,mekansm,healing salve,bottle,iron branch,javelin,energy booster,fate coin,trident")
	itm_type=explode("wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,fud,fud,fud,fud,fud,fud,thr,thr,thr,thr,thr")
	itm_stat1=explodeval("2,2,3,4,5,0,0,0,1,2,1,5,2,6,3,4,1,2,3,3,7")
	itm_stat2=explodeval("0,2,0,0,0,1,2,4,3,3,0,0,0,0,0,0,0,0,0,0,0")
	itm_minf=explodeval("1,2,3,4,5,1,2,3,4,5,1,1,3,3,1,1,1,2,3,4,6")
	itm_maxf=explodeval("3,4,5,6,8,3,4,5,6,8,3,10,8,7,4,10,5,6,7,8,9")
	itm_desc=explode(",,,,,,,,,,heals,curse,heals alot,bless,plus maxhp,stuns,,,,,")
		
	mob_name=explode("player,slime,melt,shoggoth,mantis-man,giant scroption,ghost,golem,drake")
	mob_ani=explodeval("240,192,196,200,204,208,212,216,220")
	mob_atk=explodeval("1,1,2,1,2,3,4,5,5")
	mob_hp=explodeval("10,1,2,3,3,4,4,14,8")
	mob_los=explodeval("4,4,4,4,4,4,4,4,4")
	mob_minf=explodeval("0,1,2,3,4,5,6,7,8")
	mob_maxf=explodeval("0,3,4,5,6,7,8,8,8")
	mob_spec=explode(",,,,,stun,ghost,slow,")
																	 	--⬇️         ➡️         ⬆️         ⬅️                       
	crv_sig={0b11111111,0b11010110,0b01111100,0b11101001,0b10110011}
	crv_msk={0,0b00001001,0b00000011,0b00000110,0b00001100}
 
 free_sig={
 	0b00000000,
 	0b00000000,
 	0b00000000,
 	0b00000000,
 	0b00010000,
 	0b01000000,
 	0b00100000,
 	0b10000000,
 	0b10100001,
 	0b01101000,
 	0b01010100,
 	0b10010010
 }
 
 free_msk={
 	0b00001000,
 	0b00000100,
 	0b00000010,
 	0b00000001,
 	0b00000110,
 	0b00001100,
 	0b00001001,
 	0b00000011,
 	0b00001010,
 	0b00000101,
 	0b00001010,
 	0b00000101
 }
 
	wall_sig=explodeval("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252")
	wall_msk=explodeval("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")

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
 
	doshake()
 _drw()
 
 	drawind()
	drawlogo()

 --fadeperc=0
 checkfade()
 --★
 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end
 
function startgame()
	poke(0x3101,194)
	music(0)
	tani=0
	fadeperc=1
 buttbuff=-1
	
	logo_t=140
	logo_y=35

	skipai=false
	win=false
	winfloor=9
	
 mob={}
 dmob={}
 
 p_mob=addmob(1,1,1)
 p_t=0 
 
 inv,eqp={},{}
	makeipool()
 foodnames()
-- takeitem(16)
-- takeitem(14)
-- takeitem(14)


 wind={} 
 float={}
 
 talkwind=nil
 
 hpwind=addwind(5,5,28,13,{})
 
 --throwing direction
 thrdx,thrdy=1,0
 
 _upd=update_openning
 _drw=draw_openning
 
 st_steps,st_kills,st_meals,st_killer=0,0,0,""
 
 
end
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