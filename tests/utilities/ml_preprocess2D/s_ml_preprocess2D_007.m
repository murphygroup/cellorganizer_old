disp('test007: Should use a default value if threshmeth is not a string');

image = uint8(rand(1024,1024) * 255);
cropimage = [];
way = 'ml';
bgsub = 'yesbgsub';
threshmeth = 1;

[procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);

assert(~isempty(procImg));
assert(~isempty(imgMask));
assert(~isempty(resImg));

disp('Test passed.');