%main image processing function!
function [splineData, edgevData, edgedData] = Skeletonize(handles)
frameRate = handles.frameps;
numberofframes = handles.Vidobj.NumberOfFrames;

splineDatax=zeros(numberofframes,13);    %splineData is what will eventually be exported.
splineDatay=zeros(numberofframes,13);    
edgevDatax = zeros(numberofframes,11);
edgevDatay = zeros(numberofframes,11);
edgedDatax = zeros(numberofframes,11);
edgedDatay = zeros(numberofframes,11);
splineDatax(1,:)=handles.output(1,:)*handles.xcal;
splineDatay(1,:)=handles.output(2,:)*handles.ycal;
edgevDatax(1,:) = (handles.edgev(:,1)*handles.xcal)';
edgevDatay(1,:) = (handles.edgev(:,2)*handles.ycal)';
edgedDatax(1,:) = (handles.edged(:,1)*handles.xcal)';
edgedDatay(1,:) = (handles.edged(:,2)*handles.ycal)';
for i = 2 : numberofframes
    
    previousspline = handles.output;
    xcl = previousspline(1,:);
    ycl = previousspline(2,:);
    delta = 4000/frameRate;
    Imsize = size(handles.imthresh,1);
    Imsize2 = size(handles.imthresh,2);
    bounds = [ min(xcl)-delta               max(xcl)+delta ;...
               min(Imsize-ycl+1)-delta      max(Imsize-ycl+1)+delta];
    bounds = round(bounds);
    if min(xcl)-delta<0
        bounds(1,1) = 1;
    end
    if min(Imsize-ycl+1)-delta<0
        bounds(2,1) = 1;
    end
    if max(xcl)+delta > Imsize2
        bounds(1,2) = Imsize2;
    end
    if max(Imsize-ycl+1)+delta > Imsize
        bounds(2,2) = Imsize;
    end
    Head = [xcl(1), ycl(1)];
    Tail = [xcl(end), ycl(end)];
    l=wormLength(xcl,ycl);
    handles.Video = read(handles.Vidobj,i);
    axes(handles.vidwindow);
    imthresh = handles.Video;
    if size(imthresh,3) > 1
        imthresh = rgb2gray(imthresh);
    end
    h = imshow(imthresh);
    startimg = imthresh<=handles.Multiplier*1.5 & handles.imthresh;
    startimg = imfill(startimg, 'holes');
    L = bwlabel(startimg);
    Stats = regionprops(L,'Area');
    Areas = cat(1,Stats.Area);
    startimg = L == find(Areas == max(Areas));
    imshow(startimg);
    drawnow;
    pause(0.2);
%     startimg = bwselect(startimg,handles.startpoint(1),handles.startpoint(2),4);
    intrm = imthresh;
    intrm(~startimg | intrm>handles.Multiplier) = 255;
    startimg = intrm;
    drawnow;
    hold on;
    headpt = [Head(1)  , Imsize-Head(2) ];
    tailpt = [Tail(1)  , Imsize-Tail(2) ];
%     headpt = [Head(1) - bounds(1,1) , Imsize-Head(2) - bounds(2,1)];
%     tailpt = [Tail(1) - bounds(1,1) , Imsize-Tail(2) - bounds(2,1)];
%     imthresh=imthresh(bounds(2,1):bounds(2,2),bounds(1,1):bounds(1,2));
% 
    imthresh = imhmin(imthresh,handles.Multiplier);
    [startptx, startpty] = find(startimg <= handles.startintensity);
    handles.startpoint(2) = startptx(floor(end/2));
    handles.startpoint(1) = startpty(floor(end/2));
%     [handles.startpoint(2),handles.startpoint(1)] = ind2sub(size(startimg),median(startpt));
%     plot(handles.trackpoints(:,1), handles.trackpoints(:,2),'r+');
%     [handles.trackpoints, isFound] = step(handles.pointTracker, imthresh);
%     foundpoints  = handles.trackpoints(isFound,:);
%     handles.startpoint = foundpoints(1,:);
    plot(handles.startpoint(1), handles.startpoint(2),'b+');
%     handles.startpoint = dsearchn([startptx startpty],handles.startpoint);
%     plot(startpty(handles.startpoint), startptx(handles.startpoint),'g*');
    hold off;
%     imthresh(startptx(handles.startpoint), startpty(handles.startpoint))
    drawnow;
%     handles.startpoint = [startptx(handles.startpoint) startpty(handles.startpoint)];
    ik = imthresh<=handles.Multiplier*2;
    imthresh(~ik) = 255;
    imthresh = segCroissRegion(handles.Multiplier,imthresh,floor(handles.startpoint(2)),floor(handles.startpoint(1)));
    imshow(imthresh);
    drawnow;
    
    imthresh = imfill(imthresh, 'holes');
    Strelsize = str2num(get(handles.Strel,'String'));
    handles.imthreshtemp = edge(imthresh,'canny',0.5,Strelsize);
    handles.imthreshtemp = bwmorph(handles.imthreshtemp,'bridge');
    imshow(handles.imthreshtemp);
    drawnow
    handles.imthresh = handles.imthreshtemp;
    handles.imthresh = imclose(handles.imthresh, strel('disk',Strelsize+2));
    imshow(handles.imthresh);
    drawnow;
    handles.imthresh = imfill(handles.imthresh, 'holes');
    imshow(handles.imthresh);
    drawnow
    handles.imthresh = bwmorph(handles.imthresh, 'thin',Inf);
    %%%%%%%%%%
    img = handles.imthresh;
    branchpoints = bwmorph(handles.imthresh,'branchpoints');
    endpoints = [];
    [endpoints(:,2), endpoints(:,1)] = find(bwmorph(img,'endpoints'));
    headpti = dsearchn(endpoints,headpt);
    headpt = endpoints(headpti,:);
    tailpti = dsearchn(endpoints,tailpt);
    branchcut = 0;
    while max(max(branchpoints))>0
        endpoints = [];
        [endpoints(:,2), endpoints(:,1)] = find(bwmorph(img,'endpoints'));
        % tailpt = endpoints(tailpti,:);
        endpoints([headpti,tailpti],:) = [];
        % endpoints(tailpti,:) = [];
        endpoints =  sub2ind(size(img),endpoints(:,2),endpoints(:,1));


        extendedbranch = strel('diamond',1);
        branchpoints1 = imdilate(branchpoints,extendedbranch);

        labelled = img & (~branchpoints1);
        labelled = bwlabel(labelled,8);

        for j = 1:max(max(labelled))
            labelpixels = find(labelled == j);
            if (~isempty(intersect(labelpixels,endpoints)))
                labelled(labelpixels) = 0;
            end
        end
        img = (branchpoints & img) | (labelled>0);
        img = bwmorph(img,'bridge');
        img = bwmorph(img,'thin',Inf);
    %     figure;
    %     imshow(img);
        selected = bwselect(img,headpt(1),headpt(2),8);
        img = img & selected;
        branchpoints = bwmorph(img,'branchpoints');
        branchcut = branchcut + 1;
    end
    handles.imthresh = img;
    %%%%%%%%%
    imshow(handles.imthresh);
    drawnow
    headpt = handles.output(:,1)';
    headpt(2) = Imsize - headpt(2) +1;
    tailpt = handles.output(:,end)';
    tailpt(2) = Imsize - tailpt(2) +1;
    endpoints = [];
    [endpoints(:,2), endpoints(:,1)] = find(bwmorph(handles.imthresh,'endpoints'));
    headpti = dsearchn(endpoints,headpt);
    headpt = endpoints(headpti,:);
    tailpti = dsearchn(endpoints,tailpt);
    tailpt = endpoints(tailpti,:);
    selected = bwselect(handles.imthresh,headpt(1),headpt(2),8);
    mat_dist = bwdistgeodesic(selected,headpt(1),headpt(2),'quasi-euclidean'); %'quasi-euclidean'
    comp = find(selected);
    comp(:,2) = mat_dist(comp(:,1));
    ordered_list_ind = sortrows(comp,2);
    [yCenterLine, xCenterLine] = ind2sub(size(selected),ordered_list_ind(:,1));
    [xCenterLine,yCenterLine]=divideSpline(xCenterLine,yCenterLine,12);
    imshow(handles.Video);
    hold on;
    plot(xCenterLine,yCenterLine,'.c','MarkerSize',6);
    plot(xCenterLine(1),yCenterLine(1),'xc','MarkerSize',12,'LineWidth',2);
    handles.length=wormLength(xCenterLine,yCenterLine);
    pause(1);
    
    yCenterLine = size(handles.imthresh,1) - yCenterLine +1;
    handles.output=[xCenterLine';yCenterLine'];
    %%%%%%%%%%%%%%%%
%     handles.imthresh = bwmorph(handles.imthresh, 'remove');
    %%%%%%%%%%%%%%
%     imshow(handles.imthresh + handles.imthreshtemp);
    %%%%%%%%%%%%%%%%%
    [handles.edgev, handles.edged]= EdgePoints(handles.imthreshtemp,handles.output);
    handles.imthresh = imclose(handles.imthresh, strel('disk',Strelsize));
    handles.imthresh = imfill(handles.imthreshtemp, 'holes');
    splineDatax(i,:)=xCenterLine*handles.xcal;
    splineDatay(i,:)=yCenterLine*handles.ycal;
    edgevDatax(i,:) = (handles.edgev(:,1)*handles.xcal)';
    edgevDatay(i,:) = (handles.edgev(:,2)*handles.ycal)';
    edgedDatax(i,:) = (handles.edged(:,1)*handles.xcal)';
    edgedDatay(i,:) = (handles.edged(:,2)*handles.ycal)';
    drawnow;
    
end

for i=1:numberofframes
    splineData(2*i-1:2*i,:)=[splineDatax(i,:);splineDatay(i,:)];
    edgevData(2*i-1:2*i,:)=[edgevDatax(i,:);edgevDatay(i,:)];
    edgedData(2*i-1:2*i,:)=[edgedDatax(i,:);edgedDatay(i,:)];
end
