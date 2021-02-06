function _init()
  t=0
  -- player animation
  p_ani={64,65,66,67}
  -- direction
  dirx={-1,1,0,0,-1,1,-1,1}
  diry={0,0,-1,1,-1,-1,1,1}
  
  mob_ani={64,112}
  mob_atk={1,1}
  mob_hp ={5,1}
  
   _upd=update_game
   _drw=draw_game
   startgame()
 end
 
 
 function _update60()
   t+=1
   _upd()
 end
 
 function _draw()
   _drw()
   drawind()
 end
 
 function startgame()
   buttbuff=-1
   mob={}
   
   p_mob=addmob(1,1,1)
   addmob(2,2,2)
   --p_x=1
   --p_y=1
   --player offset
   --p_ox=0
   --p_oy=0
   --player start offset
   --p_sox=0
   --p_soy=0
   --player flip
   --p_flip=false
   --player move
   --p_mov=nil --player move style
   --p_t=0
   
   wind={}
   talkwind=nil
 end