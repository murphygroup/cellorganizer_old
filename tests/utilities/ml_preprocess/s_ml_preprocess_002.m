disp('test002: Should return empty images if input image is not a matrix');

image = 'notamatrix';
cropimage = [];
way = 'ml';
bgsub = 'nobgsub';
threshmeth = 'nih';
highpass = 0;
[procImg, imgMask, resImg] = ml_preprocess(image, cropimage, way, bgsub, threshmeth, highpass);

assert(isempty(procImg));
assert(isempty(imgMask));
assert(isempty(resImg));

disp('Test passed.');