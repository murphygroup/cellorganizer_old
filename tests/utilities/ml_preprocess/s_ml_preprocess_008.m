disp('test008: Should use default value if threshmeth is not a proper method');

image = uint8(rand(1024,1024, 10) * 255);
cropimage = [];
way = 'ml';
bgsub = 'yesbgsub';
threshmeth = 'notapropermethod';
highpass = 0;

[procImg, imgMask, resImg] = ml_preprocess(image, cropimage, way, bgsub, threshmeth, highpass);

assert(~isempty(procImg));
assert(~isempty(imgMask));
assert(~isempty(resImg));

disp('Test passed.');