dofile("lcd.lua").cls()
dofile("lcd.lua").home()
dofile("lcd.lua").cursor(1) --To show cursor
dofile("lcd.lua").cursor(0) --to hide cursor
dofile("lcd.lua").lcdprint("Hello World!",0,0)