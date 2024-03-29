function SmallCellData=Ellipse_Fitting2(x)
% X is an array of two rows of N rows, the first column is a abscissa, and the second column is a vertical coordinate
% F=@(p,x)p(1)*x(:,1).^2+p(2)*x(:,1).*x(:,2)+p(3)*x(:,2).^2+p(4)*x(:,1)+p(5)*x(:,2)+p(6);
XY=x;
centroid = mean(XY);   % thecentroid of the data set  
D1 = [(XY(:,1)-centroid(1)).^2,(XY(:,1)-centroid(1)).*(XY(:,2)-centroid(2)),(XY(:,2)-centroid(2)).^2];  
D2 = [XY(:,1)-centroid(1),XY(:,2)-centroid(2), ones(size(XY,1),1)];  
S1 = D1'*D1;  
S2 = D1'*D2;  
S3 = D2'*D2;  
T = -inv(S3)*S2';  
M = S1 + S2*T;  
M = [M(3,:)./2; -M(2,:);M(1,:)./2];  
[evec,eval] = eig(M);  
cond =4*evec(1,:).*evec(3,:)-evec(2,:).^2;  
A1 = evec(:,cond>0);  
A = [A1; T*A1];  
A4 =A(4)-2*A(1)*centroid(1)-A(2)*centroid(2);  
A5 =A(5)-2*A(3)*centroid(2)-A(2)*centroid(1);  
A6 =A(6)+A(1)*centroid(1)^2+A(3)*centroid(2)^2+A(2)*centroid(1)*centroid(2)-A(4)*centroid(1)-A(5)*centroid(2);  
A(4) = A4;  A(5) = A5; A(6) = A6;  
A = A/norm(A);  
p=A;
F=@(p,x)p(1)*x(:,1).^2+p(2)*x(:,1).*x(:,2)+p(3)*x(:,2).^2+p(4)*x(:,1)+p(5)*x(:,2)+p(6);
A=p(1)/p(6);     
B=p(2)/p(6);
C=p(3)/p(6);
D=p(4)/p(6);
E=p(5)/p(6);
p2=[A,B,C,D,E];
% Elliptic central coordinate
X_center = (B*E-2*C*D)/(4*A*C - B^2);
Y_center = (B*D-2*A*E)/(4*A*C - B^2);
% Minor axis
a= 2*sqrt((2*A*(X_center^2)+2*C*(Y_center^2)+2*B*X_center*Y_center-2)/(A+C+sqrt(((A-C)^2+B^2))));
b= 2*sqrt((2*A*(X_center^2)+2*C*(Y_center^2)+2*B*X_center*Y_center-2)/(A+C-sqrt(((A-C)^2+B^2))));
q=0.5 * atan(B/(A-C));
xmin=min(x(:,1));
xmax=max(x(:,1));
ymin=min(x(:,2));
ymax=max(x(:,2));
% Draw a fitting ellipse
% hold on
% h=ezplot(@(x,y)F(p,[x,y]),[xmin,xmax,ymin,ymax]);
% set(h,'Color','r','LineWidth',3);
SmallCellData.Zhou=[a,b];
SmallCellData.equ={q,p,p2,F};
SmallCellData.Center=[X_center,Y_center];
SmallCellData.mimaxXY=[xmin,xmax,ymin,ymax];







