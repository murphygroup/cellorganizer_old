disp('test003: Should return images and display warning if cropimg is not a matrix');

image = uint8(rand(1024,1024) * 255);
cropimage = 'notamatrix';
way = 'ml';
bgsub = 'nobgsub';
threshmeth = 'nih';

[procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);

assert(~isempty(procImg));
assert(~isempty(imgMask));
assert(~isempty(resImg));

disp('Test passed.');