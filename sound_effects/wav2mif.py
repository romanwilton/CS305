import sys
import wave

file_in = open(sys.argv[1], "rb")
wr = wave.open(file_in)

if wr.getframerate() != 32000:
    raise ValueError("Sample rate must be 32kHz")

if wr.getnchannels() != 1:
    raise ValueError("Must be mono audio")

if wr.getsampwidth() != 1:
    raise ValueError("Must be 8-bit audio")

file_out = open(sys.argv[1].replace(".wav", ".mif"), "w")

num_frames = wr.getnframes()
raw_frames = wr.readframes(num_frames)

header = """WIDTH = 8;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN\n"""
file_out.write("-- %.2f seconds of audio\n" % (num_frames/32e3))
file_out.write("-- %d kb memory\n\n" % (num_frames*8))
file_out.write("DEPTH = " + str(num_frames) + ";\n")
file_out.write(header)

for i in range(num_frames):
    frame = raw_frames[i]
    file_out.write("%04X:\t%02X;\n" % (i, frame))

file_out.write("END;")
