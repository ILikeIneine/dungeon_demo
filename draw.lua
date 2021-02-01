-- draw

function draw_game()
	cls()
	map()
	
	drawspr(getframe(p_ani),
									p_x*8+p_ox,p_y*8+p_oy,
									10,p_flip)
									
end