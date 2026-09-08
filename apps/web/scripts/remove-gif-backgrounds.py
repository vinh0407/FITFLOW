from pathlib import Path
import numpy as np
import cv2
from PIL import Image

SOURCE = Path(__file__).resolve().parents[1] / 'public' / 'media'
TARGET = Path(__file__).resolve().parents[1] / 'public' / 'media-transparent'
TARGET.mkdir(parents=True, exist_ok=True)

def is_background(pixel):
    r, g, b = pixel[:3]
    return r >= 238 and g >= 238 and b >= 238 and max(pixel[:3]) - min(pixel[:3]) <= 12

def remove_connected_white(frame):
    frame = frame.convert('RGBA')
    array = np.array(frame)
    white = ((array[:, :, :3] >= 238).all(axis=2) & (array[:, :, :3].max(axis=2) - array[:, :, :3].min(axis=2) <= 12)).astype(np.uint8) * 255
    padded = np.pad(white, 1, constant_values=255)
    cv2.floodFill(padded, None, (0, 0), 128)
    array[padded[1:-1, 1:-1] == 128, 3] = 0
    return Image.fromarray(array, 'RGBA')

for source in sorted(SOURCE.glob('*.gif')):
    target = TARGET / source.name
    with Image.open(source) as image:
        frames = []
        durations = []
        for index in range(getattr(image, 'n_frames', 1)):
            image.seek(index)
            frames.append(remove_connected_white(image.copy()))
            durations.append(image.info.get('duration', 100))
        first, rest = frames[0], frames[1:]
        first.save(target, save_all=True, append_images=rest, duration=durations, loop=image.info.get('loop', 0), disposal=2, transparency=0)
print(f'Processed {len(list(TARGET.glob("*.gif")))} transparent GIFs into {TARGET}')
