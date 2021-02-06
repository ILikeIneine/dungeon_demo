-- draw

function draw_game()
	cls()
	map()
	
	for m in all(mob) do
		drawspr(getframe(m.ani),m.x*8+m.ox,m.y*8+m.oy,10,m.flp)
	end								
end