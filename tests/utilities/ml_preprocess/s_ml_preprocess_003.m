disp('test003: Should return images and display warning if cropimg is not a matrix');

image = uint8(rand(1024,1024, 10) * 255);
cropimage = 'notamatrix';
way = 'ml';
bgsub = 'nobgsub';
threshmeth = 'nih';
highpass = 0;

[procImg, imgMask, resImg] = ml_preprocess(image, cropimage, way, bgsub, threshmeth, highpass);

assert(~isempty(procImg));
assert(~isempty(imgMask));
assert(~isempty(resImg));

disp('Test passed.');