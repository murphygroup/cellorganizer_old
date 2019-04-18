disp('test005: Should use default value if threshmeth is not a proper method');

image = uint8(rand(1024,1024) * 255);
cropimage = [];
way = 'ml';
bgsub = 'yesbgsub';
threshmeth = 'notapropermethod';

[procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);

assert(~isempty(procImg));
assert(~isempty(imgMask));
assert(~isempty(resImg));

disp('Test passed.');