-- draw

function draw_game()
	cls()
	map()
	
	drawspr(getframe(p_ani),
									p_x*8+p_ox,p_y*8+p_oy,
									10,p_flip)
	
	for m in all(mob) do
		drawspr(getframe(m.ani),m.x*8,m.y*8,10,false)
	end								
end