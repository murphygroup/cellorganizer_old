disp('test004: Should use default value if improper way argument is passed in');

image = uint8(rand(1024,1024, 10) * 255);
cropimage = [];
way = 'notavalidway';
bgsub = 'nobgsub';
threshmeth = 'nih';
highpass = 0;

[procImg, imgMask, resImg] = ml_preprocess(image, cropimage, way, bgsub, threshmeth, highpass);

assert(~isempty(procImg));
assert(~isempty(imgMask));
assert(~isempty(resImg));

disp('Test passed.');