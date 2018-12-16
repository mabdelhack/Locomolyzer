function [edgev, edged] =  EdgePoints(edgeimg,splinepoints)

edgev = zeros(11,2);
edged = zeros(11,2);
x = splinepoints(1,:);
y = 512 - splinepoints(2,:) + 1;

diffx = diff(x);
diffy = diff(y);
norms = sqrt(diffx.^2 + diffy.^2);
unitx = diffx./norms;
unity = diffy./norms;
munitx = tsmovavg(unitx,'s',2,2);
munitx = munitx(2:end);
munity = tsmovavg(unity,'s',2,2);
munity = munity(2:end);
t = -20:20;
for i = 1 : length(munitx)
    perpx = munitx(i)*t;
    perpy = munity(i)*t;
    pointv = 0;
    pointd = 0;
    for j = 1:length(perpx)
        
        if(edgeimg(round(-perpx(j)+y(i+1)),round(perpy(j)+x(i+1))) == 1)
            if t(j) < 0
                edgev(i,:) = [round(perpy(j)+x(i+1)),round(-perpx(j)+y(i+1))];
                pointv = 1;
            elseif t(j) > 0
                edged(i,:) = [round(perpy(j)+x(i+1)),round(-perpx(j)+y(i+1))];
                pointd = 1;
                break;
            end
        end
    end
    if (pointv == 0)
        edgev(i,1) = 2*x(i+1)-edged(i,1);
        edgev(i,2) = 2*y(i+1)-edged(i,2);
    elseif (pointd == 0)
        edged(i,1) = 2*x(i+1)-edgev(i,1);
        edged(i,2) = 2*y(i+1)-edgev(i,2);
    end
end