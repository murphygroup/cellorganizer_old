disp('test004: Should do contrast streching if the image is a logical matrix ')
img=[[0 1],[1 0]];
img2tif(img,'tmp.tif');
assert(isequal(tif2img('tmp.tif'),[[0 255],[255,0]]));
delete('tmp.tif');