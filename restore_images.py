import os
import base64
import subprocess
import json

def restore_file(dest, b64_data):
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    with open(dest, "wb") as f:
        f.write(base64.b64decode(b64_data))

print("Restoring images from base64...")
restore_file("MellClicker/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024@1x.png", "iVBORw0KGgoAAAANSUhEUgAABAAAAAQACAIAAADwf7zUAAAAIGNIUk0AAHomAACAhAAA+gAAAIDo")
restore_file("MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton.png", "iVBORw0KGgoAAAANSUhEUgAAAO0AAADbCAIAAAAODIFoAAABUGlDQ1BpY2MAACiRfZCxS8NQEMa/")
restore_file("MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton@2x.png", "iVBORw0KGgoAAAANSUhEUgAAAdkAAAG2CAIAAAC8h2vaAAABUGlDQ1BpY2MAACiRfZCxS8NQEMa/")
restore_file("MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton@3x.png", "iVBORw0KGgoAAAANSUhEUgAAAsYAAAKRCAIAAADYgfitAAABUGlDQ1BpY2MAACiRfZCxS8NQEMa/")

print("Generating additional AppIcon sizes...")
sizes = [
    (20, 2, "iphone"), (20, 3, "iphone"), (29, 2, "iphone"), (29, 3, "iphone"),
    (40, 2, "iphone"), (40, 3, "iphone"), (60, 2, "iphone"), (60, 3, "iphone"),
    (20, 1, "ipad"), (20, 2, "ipad"), (29, 1, "ipad"), (29, 2, "ipad"),
    (40, 1, "ipad"), (40, 2, "ipad"), (76, 1, "ipad"), (76, 2, "ipad"),
    (83.5, 2, "ipad")
]

src = "MellClicker/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024@1x.png"
base_dir = "MellClicker/Resources/Assets.xcassets/AppIcon.appiconset"

images = [{"size":"1024x1024","idiom":"ios-marketing","filename":"icon_1024x1024@1x.png","scale":"1x"}]

for (s, scale, idiom) in sizes:
    dim = int(s * scale)
    filename = f"icon_{s}x{s}@{scale}x.png"
    subprocess.run(["sips", "-z", str(dim), str(dim), src, "--out", os.path.join(base_dir, filename)])
    size_str = str(s)
    if s == int(s):
        size_str = str(int(s))
    images.append({
        "size": f"{size_str}x{size_str}",
        "idiom": idiom,
        "filename": filename,
        "scale": f"{scale}x"
    })

with open(f"{base_dir}/Contents.json", "w") as f:
    json.dump({"images": images, "info": {"version":1,"author":"xcode"}}, f, indent=2)

print("Restoration and generation complete!")
