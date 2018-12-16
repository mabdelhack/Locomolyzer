%this function will take each point in the spline, find the distance
%between each point, and output 'n' equally spaced points.
function [xs,ys]=divideSpline(x,y,n)

dist=zeros(1,length(x)-1);
for i=2:length(x)
    if i~=2
        dist(i-1)=ptDist(x(i-1),y(i-1),x(i),y(i))+dist(i-2);
    else
        dist(i-1)=ptDist(x(i-1),y(i-1),x(i),y(i));
    end
end
segLength=dist(end)/n;

xs=x(1);    %the first point should always be in there
ys=y(1);

index(1)=1;

for target=segLength:segLength:(n-1)*segLength
    index=[index findClosest(dist,target)];
end
index=[index length(x)];

xs=x(index);
ys=y(index);

% disp('Spline divided into segments');

function index=findClosest(dist,target) 
%minimize distance to target, output the index of the point that is closest
lowestDist=1e6;
for i=1:length(dist)
    currDist=abs(dist(i)-target);
    if currDist<lowestDist
        lowestDist=currDist;
        index=i;
    end
end