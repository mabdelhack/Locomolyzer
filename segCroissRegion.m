function Phi = segCroissRegion(tolerance,Igray,x,y)
if(x == 0 || y == 0)
    imshow(Igray,[0 255]);
    [x,y] = ginput(1);
end
% figure;
Phi = false(size(Igray,1),size(Igray,2));
ref = true(size(Igray,1),size(Igray,2));
PhiOld = Phi;
Phi(x,y) = 1;
% imshow(Phi);
% drawnow;
while(sum(Phi(:)) ~= sum(PhiOld(:)))
    PhiOld = Phi;
    segm_val = Igray(Phi);
    meanSeg = mean(segm_val);
    posVoisinsPhi = imdilate(Phi,strel('disk',1,0)) - Phi;
    voisins = find(posVoisinsPhi);
    valeursVoisins = Igray(voisins);
    Phi(voisins(valeursVoisins > meanSeg - tolerance & valeursVoisins < meanSeg + tolerance & valeursVoisins <163)) = 1;
    
end
imshow(Phi);
drawnow;
% Uncomment this if you only want to get the region boundaries
% SE = strel('disk',1,0);
% ImErd = imerode(Phi,SE);
% Phi = Phi - ImErd;