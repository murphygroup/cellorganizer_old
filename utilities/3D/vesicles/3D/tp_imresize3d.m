function img_resized = tp_imresize3d(img,newSize,method)

% Resize a 3D stack image
%   img - input 3D image
%   newsize - the target image size
%   method - the interpolation method for resizing

% Original image coordinate
[Ydim, Xdim, Zdim] = size(img);
Yhalf = (Ydim-1)/2;
Xhalf = (Xdim-1)/2;
Zhalf = (Zdim-1)/2;
[X,Y,Z] = meshgrid(-Xhalf:Xhalf,-Yhalf:Yhalf,-Zhalf:Zhalf);

% New image coordinate
Yhalf2 = (newSize(1)-1)/2;
Xhalf2 = (newSize(2)-1)/2;
Zhalf2 = (newSize(3)-1)/2;
R = size(img)./newSize;     % The resizing ratio
[Xi,Yi,Zi] = meshgrid( (-Xhalf2:Xhalf2)*R(2),...
                    (-Yhalf2:Yhalf2)*R(1),...
                    (-Zhalf2:Zhalf2)*R(3));

% Interpolation
img_resized = interp3(X, Y, Z, img, Xi, Yi, Zi, method);
