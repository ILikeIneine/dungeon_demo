pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
  t=0
  
  dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
  -- player animation
  p_ani={240,241,242,243}
  -- direction
  dirx={-1,1,0,0,-1,1,-1,1}
  diry={0,0,-1,1,-1,-1,1,1}
  
  mob_ani={240,192}
  mob_atk={1,1}
  mob_hp ={5,2}
  
  debug={}
  startgame()
 
end
 
 
function _update60()
  t+=1
  _upd()
  dofloats()
end
 
function _draw()
 _drw()
 dohpwind()
 drawind()
 checkfade()

 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end
 
function startgame()
	fadeperc=1
 buttbuff=-1
 
 mob={}
 dmob={}
 p_mob=addmob(1,1,1)
   
 for x=0,15 do
 	for y=0,15 do
  	if mget(x,y)==3 then
 			addmob(2,x,y)
 		end
 	end
 end

 p_t=0 
 wind={} 
 float={}
 talkwind=nil
 
 hpwind=addwind(5,5,28,13,{})
   
 _upd=update_game
 _drw=draw_game
end