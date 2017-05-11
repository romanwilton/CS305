import sys
import wave

file_in = open(sys.argv[1], "rb")
wr = wave.open(file_in)

if wr.getframerate() != 48000:
    raise "Sample rate must be 48kHz"

if wr.getnchannels() != 1:
    raise "Must be mono audio"

file_out = open(sys.argv[1].replace(".wav", ".mif"), "w")

width = wr.getsampwidth()
num_frames = 20000 #wr.getnframes()
maxi = int("FF"*width, 16)
raw_frames = wr.readframes(num_frames)

header = """WIDTH = 8;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN\n"""
file_out.write("-- %.2f seconds of audio\n" % (num_frames/48e3))
file_out.write("-- %d kb memory\n\n" % (num_frames*8))
file_out.write("DEPTH = " + str(num_frames) + ";\n")
file_out.write(header)

for i in range(num_frames):
    frame = raw_frames[i*width:(i+1)*width]
    data = int.from_bytes(frame, byteorder='little')
    output = data*130//maxi
    file_out.write("%04X:\t%02X;\n" % (i, output))
