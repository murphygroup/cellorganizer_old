disp('test003: Should add .tif as a suffix if there is no suffix')
addpath('../..');
assert(img2tif(1,'tmp'));
assert(check({'tmp.tif'}));
delete('tmp.tif');

