disp('test001: Should return empty images if input image is empty');

image = [];
cropimage = [];
way = 'ml';
bgsub = 'nobgsub';
threshmeth = 'nih';

[procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);

assert(isempty(procImg));
assert(isempty(imgMask));
assert(isempty(resImg));

disp('Test passed.');