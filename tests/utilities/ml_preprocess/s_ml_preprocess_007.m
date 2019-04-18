disp('test007: Should use default a default value if threshmeth is not a string');

image = uint8(rand(1024,1024, 10) * 255);
cropimage = [];
way = 'ml';
bgsub = 'yesbgsub';
threshmeth = 1;
highpass = 0;

[procImg, imgMask, resImg] = ml_preprocess(image, cropimage, way, bgsub, threshmeth, highpass);

assert(~isempty(procImg));
assert(~isempty(imgMask));
assert(~isempty(resImg));

disp('Test passed.');