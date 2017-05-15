import sys
import wave

file_in = open(sys.argv[1], "rb")
wr = wave.open(file_in)

if wr.getframerate() != 48000:
    raise ValueError("Sample rate must be 48kHz")

if wr.getnchannels() != 1:
    raise ValueError("Must be mono audio")

if wr.getsampwidth() != 1:
    raise ValueError("Must be 8-bit audio")

hex_out = open(sys.argv[1].replace(".wav", ".hex"), "w")

num_frames = wr.getnframes()
raw_frames = wr.readframes(num_frames)

for i in range(num_frames):
    frame = raw_frames[i]
    hex_out.write("%02X" % frame)

hex_out.close()
wr.close()
file_in.close()

print("%dkB of data used" % (num_frames//1000))
