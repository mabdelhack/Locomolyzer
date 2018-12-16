function l=wormLength(x,y)

dist=zeros(1,length(x)-1);
for i=2:length(x)
    if i~=2
        dist(i-1)=ptDist(x(i-1),y(i-1),x(i),y(i))+dist(i-2);
    else
        dist(i-1)=ptDist(x(i-1),y(i-1),x(i),y(i)); 
    end
end
l=dist(end);