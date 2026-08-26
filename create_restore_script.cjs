const fs = require('fs');
const path = require('path');

const filesToRestore = [
    {
        src: 'MellClicker/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024@1x.png',
        dest: 'MellClicker/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024@1x.png'
    },
    {
        src: 'MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton.png',
        dest: 'MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton.png'
    },
    {
        src: 'MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton@2x.png',
        dest: 'MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton@2x.png'
    },
    {
        src: 'MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton@3x.png',
        dest: 'MellClicker/Resources/Assets.xcassets/MellButton.imageset/MellButton@3x.png'
    }
];

let scriptContent = `#!/bin/bash
echo "Restoring valid binary images from Base64..."
`;

for (const file of filesToRestore) {
    if (fs.existsSync(file.src)) {
        const base64Data = fs.readFileSync(file.src, 'base64');
        const chunks = base64Data.match(/.{1,76}/g).join('\\n');
        
        scriptContent += `
echo "Restoring ${file.dest}"
mkdir -p $(dirname "${file.dest}")
cat << 'B64EOF' | base64 --decode > "${file.dest}"
${chunks}
B64EOF
`;
    }
}

scriptContent += `
echo "Generating additional AppIcon sizes..."
cat << 'PYSCRIPT' > gen.py
import subprocess
import os
import json

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
PYSCRIPT
python3 gen.py
rm gen.py
echo "Image restoration complete."
`;

fs.writeFileSync('restore_images.sh', scriptContent);
console.log("restore_images.sh created!");
