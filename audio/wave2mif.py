import sys
import wave

file_in = open(sys.argv[1], "rb")
wr = wave.open(file_in)

if wr.getframerate() != 48000:
    raise "Sample rate must be 48kHz"

if wr.getnchannels() != 1:
    raise "Must be mono audio"

hex_out = open(sys.argv[1].replace(".wav", ".hex"), "w")

width = wr.getsampwidth()
num_frames = wr.getnframes()
maxi = int("FF"*width, 16)
raw_frames = wr.readframes(num_frames)

for i in range(num_frames):
    frame = raw_frames[i*width:(i+1)*width]
    data = int.from_bytes(frame, byteorder='little')
    output = data*130//maxi
    hex_out.write("%02X" % (output))

hex_out.close()
