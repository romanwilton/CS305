import sys
from PIL import Image

header_2 = """WIDTH = 16;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN\n"""

if (len(sys.argv) > 2):
	input_filename = sys.argv[1]
	output_filename = sys.argv[2]

	im = Image.open(input_filename)

	f = open(output_filename, 'w');

	print("> Image size: ")
	print(im.size)
	print("")
	w = im.size[0]
	h = im.size[1]

	print("> Writing to file: " + output_filename)

	f.write("\n")
	f.write("-- MADE BY T. Dendale\n")
	f.write("-- WIDTH =  " + str(w) + "\n")
	f.write("-- HEIGHT = " + str(h) + "\n")
	f.write("\n")
	f.write("DEPTH = " + str(w*h) + ";\n")
	f.write(header_2)

	index = 0;

	for x in range(0, w):
		for y in range(0, h):
		
			pixel = im.getpixel((x, y))
			mask = 0b11111000
		
			r = pixel[0] & mask
			g = pixel[1] & mask
			b = pixel[2] & mask
			
			# Enable bit based on alpha channel
			if len(pixel) > 3:
				if pixel[3] > 0:
					enable = 1
				else:
					enable = 0
			else:
				enable = 1

			total = enable<<15 | r<<7 | g << 2 | b >> 3;

			hexa = hex(total)

			if (total == 0):
				hexa = "0x0000"

			f.write(hex(index)[2:] + ":\t"+hexa[2:]+";\n")

			index += 1

	f.write("END;")

	print(">>> DONE");

else:
	print("NEED MORE INFO")
