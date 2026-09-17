# view_realsense.py
import argparse

import cv2

from openteach.utils.network import ZMQCameraSubscriber

parser = argparse.ArgumentParser()
parser.add_argument("--host", default="172.16.0.1")
parser.add_argument("--port", default="10005")
parser.add_argument("--topic_type", default="RGB")
args = parser.parse_args()

sub = ZMQCameraSubscriber(
    host=args.host,
    port=str(args.port),
    topic_type=args.topic_type,
)

print(f"Listening on tcp://{args.host}:{args.port}")
print("Press q to quit.")

while True:
    frames = sub.recv_rgb_image()
    img = frames[0] if isinstance(frames, (list, tuple)) else frames

    if img is None:
        continue

    cv2.imshow(f"RealSense {args.port}", img)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cv2.destroyAllWindows()