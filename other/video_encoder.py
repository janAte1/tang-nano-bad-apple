# this script scales the bad apple music video down to 180x135px, reduces it to two colors and uses run-length encoding to store everything in less than 3MiB
# I got badapple.mp4 from https://github.com/bad-apple-lab/Bad-Apple/tree/main
import cv2
vid = cv2.VideoCapture("badapple.mp4")
width = int(vid.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(vid.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = vid.get(cv2.CAP_PROP_FPS)
frames = int(vid.get(cv2.CAP_PROP_FRAME_COUNT))

class VideoSerializer():
    def __init__(self, f):
        self.prev = 0
        self.ctr = 0
        self.total_bytes = 0
        self.f = f
    def feed(self, image):
        flat_img = image.flatten()
        for x in flat_img:
                if self.prev != x:
                    self.f.write(bytearray([self.ctr]))
                    self.total_bytes+=1
                    self.ctr=1
                    self.prev = x
                else:
                    self.ctr+=1
                    if self.ctr==255:
                        self.f.write(bytearray([self.ctr]))
                        self.total_bytes+=1
                        self.ctr=0
                        self.prev=255-self.prev

    def finish(self):
        self.f.write(bytearray([self.ctr]))
        self.total_bytes+=1
        print(f'{self.total_bytes=}')

print(width, height, fps, frames)
f = open("badapple.bin", "wb")
ser = VideoSerializer(f)
for i in range(frames):
    success, image = vid.read()
    image = cv2.resize(image, (180, 135))
    image = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
    success, image = cv2.threshold(image, 127, 255, cv2.THRESH_BINARY)
    ser.feed(image)
ser.finish()
f.close()