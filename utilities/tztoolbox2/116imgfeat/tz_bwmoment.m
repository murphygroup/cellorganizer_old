function mom=tz_bwmoment(img)
%TZ_BWMOMENT Obsolete. See ML_BWMOMENT.
%   MOM = TZ_BWMOMENT(IMG) returns the moments of the binary version of 
%   an image up to the second order. MOM is a structure with the follwoing
%   fileds:
%       cx - X coordinate of the center
%       cy - Y coordinate of the center
%       mu00 - zero order moment, always 1
%       mu20 - the second moment of X coordinate
%       mu02 - the second moment of Y coordinate
%   
%   See also

%   ??-???-???? Initial write T. Zhao
%   30-OCT-2004 Modified T. Zhao
%       - add comments
%   23-Mar-2005 Modified T. Zhao
%       - standarize coordinate system
%   Copyright (c) Murphy Lab, Carnegie Mellon University

error(tz_genmsg('of','tz_bwmoment','ml_bwmoment'));

if nargin < 1
    error('Exactly 1 argument is required')
end

if sum(img(:))==0
    mom=[];
    warning('black image');
    return;
end

[x,y]=find(img>0);
center=mean([x,y],1);
mu00=1;
S=length(x);

covxy=cov(x-center(1),y-center(2),1);
mu11=covxy(1,2);
mu20=covxy(1,1);
mu02=covxy(2,2);

mom = struct('cx',center(1),'cy',center(2),'mu00',mu00,'mu11', ...
    mu11,'mu20', mu20,'mu02',mu02);


% posy=repmat(1:size(img,2),size(img,1),1);
% posx=repmat(1:size(img,1),size(img,2),1)';
% 
% maskposy=posx.*img;
% maskposx=posy.*img;
% 
% projy=sum(img,1);
% projx=sum(img,2);
% 
% maskposx(:,projy==0)=[];
% maskposx(projx==0,:)=[];
% maskposy(:,projy==0)=[];
% maskposy(projx==0,:)=[];
% 
% mu00=sum(img(:));   
% 
% mu10=0;
% mu01=0;
% cx=sum(maskposx(:))/mu00;
% cy=sum(maskposy(:))/mu00;
% 
% fx=maskposx-cx;
% fy=maskposy-cy;
% 
% fx(maskposx==0)=0;
% fy(maskposy==0)=0;
% 
% mu20=sum(sum(fx.*fx))/mu00;
% mu02=sum(sum(fy.*fy))/mu00;
% mu11=sum(sum(fx.*fy))/mu00;
% 
