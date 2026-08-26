const fs = require('fs');
const { execSync } = require('child_process');

const sizes = [
    { size: 20, scale: 2, idiom: "iphone" },
    { size: 20, scale: 3, idiom: "iphone" },
    { size: 29, scale: 2, idiom: "iphone" },
    { size: 29, scale: 3, idiom: "iphone" },
    { size: 40, scale: 2, idiom: "iphone" },
    { size: 40, scale: 3, idiom: "iphone" },
    { size: 60, scale: 2, idiom: "iphone" },
    { size: 60, scale: 3, idiom: "iphone" },
    { size: 20, scale: 1, idiom: "ipad" },
    { size: 20, scale: 2, idiom: "ipad" },
    { size: 29, scale: 1, idiom: "ipad" },
    { size: 29, scale: 2, idiom: "ipad" },
    { size: 40, scale: 1, idiom: "ipad" },
    { size: 40, scale: 2, idiom: "ipad" },
    { size: 76, scale: 1, idiom: "ipad" },
    { size: 76, scale: 2, idiom: "ipad" },
    { size: 83.5, scale: 2, idiom: "ipad" },
    { size: 1024, scale: 1, idiom: "ios-marketing" }
];

const appIconPath = "MellClicker/Resources/Assets.xcassets/AppIcon.appiconset";
const srcImage = `${appIconPath}/AppIcon.png`;

const imagesJson = [];

for (const s of sizes) {
    const dim = s.size * s.scale;
    const filename = `icon_${s.size}x${s.size}@${s.scale}x.png`;
    execSync(`convert ${srcImage} -resize ${dim}x${dim} ${appIconPath}/${filename}`);
    
    imagesJson.push({
        size: `${s.size}x${s.size}`,
        idiom: s.idiom,
        filename: filename,
        scale: `${s.scale}x`
    });
}

const contents = {
    images: imagesJson,
    info: { version: 1, author: "xcode" }
};

fs.writeFileSync(`${appIconPath}/Contents.json`, JSON.stringify(contents, null, 2));
console.log("Done generating icons");
