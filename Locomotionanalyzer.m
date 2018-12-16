function varargout = Locomotionanalyzer(varargin)
% LOCOMOTIONANALYZER MATLAB code for Locomotionanalyzer.fig
%      LOCOMOTIONANALYZER, by itself, creates a new LOCOMOTIONANALYZER or raises the existing
%      singleton*.
%
%      H = LOCOMOTIONANALYZER returns the handle to a new LOCOMOTIONANALYZER or the handle to
%      the existing singleton*.
%
%      LOCOMOTIONANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOCOMOTIONANALYZER.M with the given input arguments.
%
%      LOCOMOTIONANALYZER('Property','Value',...) creates a new LOCOMOTIONANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Locomotionanalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Locomotionanalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Locomotionanalyzer

% Last Modified by GUIDE v2.5 08-Jun-2015 01:01:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Locomotionanalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @Locomotionanalyzer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Locomotionanalyzer is made visible.
function Locomotionanalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Locomotionanalyzer (see VARARGIN)

% Choose default command line output for Locomotionanalyzer
handles.output = hObject;
set(handles.slider1,'Enable','off');
set(handles.Threshold,'Enable','off');
handles.filename = '';
handles.pathname = '';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Locomotionanalyzer wait for user response (see UIRESUME)
% uiwait(handles.locomotionanalyzer);


% --- Outputs from this function are returned to the command line.
function varargout = Locomotionanalyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in fileloadbutton.
function fileloadbutton_Callback(hObject, ~, handles)
% hObject    handle to fileloadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.filename, handles.pathname] = uigetfile({'*.avi;*.wmv;*.mpg;*.mp4','Video files';'*.tif','Image stack'},'Pick a video file or image stack');
try
    handles.Vidobj = VideoReader([handles.pathname,handles.filename]);
    handles.Video = read(handles.Vidobj,1);
%     handles.Video = rgb2gray(handles.Video);
    axes(handles.vidwindow);
    imshow(handles.Video);
    set(handles.framenumber, 'String',sprintf('Frame = 1'));
    set(handles.slider1,'Enable','on');
    set(handles.slider1,'Max',handles.Vidobj.NumberOfFrames);
    set(handles.slider1,'Min',1);
    set(handles.slider1,'Value',1);
    set(handles.slider1,'SliderStep',[(1/handles.Vidobj.NumberOfFrames) ,(1/handles.Vidobj.NumberOfFrames*10)  ]);
    set(handles.Threshold,'Max',255);
    set(handles.Threshold,'Min',0);
    set(handles.Threshold,'Value',0);
    set(handles.Threshold,'SliderStep',[1/255, 10/255]);
    set(handles.statusstring,'String',sprintf('Image loaded successfully\nPress Skeletonize to start tracking'));
    set(gcf, 'WindowButtonMotionFcn', {@mouseover,handles});

catch
    set(handles.statusstring,'String',sprintf('Error\nFile invalid... Please choose a valid file format'));
end
guidata(hObject,handles);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Framedisp = get(hObject,'Value');
axes(handles.vidwindow);
hold off;
handles.Video = read(handles.Vidobj,floor(Framedisp));
handles.Video = rgb2gray(handles.Video);
imshow(handles.Video);
set(handles.framenumber, 'String',sprintf('Frame = %d',floor(Framedisp)));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in exitbutton.
function exitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;


% --- Executes on button press in skeletonbutton.
function skeletonbutton_Callback(hObject, eventdata, handles)
% hObject    handle to skeletonbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Video = read(handles.Vidobj,1);
axes(handles.vidwindow);
imthresh = handles.Video;
if size(imthresh,3) > 1
    imthresh = rgb2gray(imthresh);
end
h = imshow(imthresh);
ht = size(imthresh,1);
set(handles.Threshold,'Enable','on');
set(handles.statusstring,'String',sprintf('Specify manual spline for the first frame from head to tail'));
% h=get(handles.locomotionanalyzer,'UserData');
hold on
set(h,'buttondownfcn',{@click,handles})
set(handles.done,'UserData',0);
f=1;
while f
    if get(handles.done,'UserData')==1
        f=0;
    end
    pause(.1)
end
splinePoints=get(h,'UserData');
x=splinePoints(:,1);
y=splinePoints(:,2);
xi=interp(x,4);   %interpolate to get a proper spline curve
yi=interp(y,4);
xi=xi(1:end-3);
yi=yi(1:end-3);
x=xi;
y=yi;
hold off
imshow(imthresh) %clear the points
hold on
[xs,ys]=divideSpline(x,y,12);
plot(xs,ys,'.c','MarkerSize',6)
plot(xs(1),ys(1),'xc','MarkerSize',12,'LineWidth',2)
pause(1);
xcl=xs'; ycl=ys'; 
ycl=ht-ycl+1; 
hold off
handles.output=[xcl;ycl];
Multiplier = floor(get(handles.Threshold,'Value'));
mean (mean(imthresh))
handles.MeanIntensity = int16(0);
startpoint = sub2ind(size(imthresh),floor(splinePoints(:,1)),floor(splinePoints(:,2)));
startptloc = find(imthresh(startpoint) == min(imthresh(startpoint)));
[handles.startpoint(1), handles.startpoint(2)] = ind2sub(size(imthresh),startpoint(startptloc(1)));
startpoint = startpoint(2:end-1);
startpoint = [startpoint;startpoint-1;startpoint+1;startpoint-2;startpoint+2;startpoint-3;startpoint+3];

handles.trackpoints = [];
[handles.trackpoints(:,1), handles.trackpoints(:,2)] = ind2sub(size(imthresh),startpoint);
handles.startintensity = imthresh(handles.startpoint(1),handles.startpoint(2));
% handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize', [51 51]);
% initialize(handles.pointTracker, handles.trackpoints, imthresh);
roundedPoints = round(splinePoints);
for i = 1:size(splinePoints,1)
    handles.MeanIntensity = handles.MeanIntensity + int16(imthresh(roundedPoints(i,1),roundedPoints(i,2)));
end
handles.MeanIntensity = handles.MeanIntensity/size(splinePoints,1);
Threshold = Multiplier;
imthresh = imhmin(imthresh,Threshold);
imthresh = segCroissRegion(Threshold,imthresh,floor(splinePoints(5,2)),floor(splinePoints(5,1)));
imthresh = imfill(imthresh, 'holes');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Framedisp = get(handles.slider1,'Value');
% Imageoi = rgb2gray(handles.Video(:,:,:,floor(Framedisp)));
% Imageoi = edge(Imageoi);
% Imageoi= bwareaopen(Imageoi,50);
% se = strel('disk',10);
% Imageoi = imclose(Imageoi,se);
% Imageoi = bwmorph(Imageoi,'thin',Inf);
% [skelx skely] = find(Imageoi);
% axes(handles.vidwindow);
% hold on;
% plot(skely, skelx,'r+');
% guidata(hObject,handles);



function xcalib_Callback(hObject, eventdata, handles)
% hObject    handle to xcalib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xcalib as text
%        str2double(get(hObject,'String')) returns contents of xcalib as a double


% --- Executes during object creation, after setting all properties.
function xcalib_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xcalib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ycalib_Callback(hObject, eventdata, handles)
% hObject    handle to ycalib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ycalib as text
%        str2double(get(hObject,'String')) returns contents of ycalib as a double


% --- Executes during object creation, after setting all properties.
function ycalib_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ycalib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FPS_Callback(hObject, eventdata, handles)
% hObject    handle to FPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FPS as text
%        str2double(get(hObject,'String')) returns contents of FPS as a double


% --- Executes during object creation, after setting all properties.
function FPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold as text
%        str2double(get(hObject,'String')) returns contents of Threshold as a double

Threshold = get(hObject,'Value');
set(handles.text9,'String',Threshold);
if get(handles.done,'UserData')==1
    set(handles.statusstring,'String',sprintf('Please wait'));
    drawnow;
    imthresh = handles.Video;
    if size(imthresh,3) > 1
        imthresh = rgb2gray(imthresh);
    end
    handles.Multiplier = floor(get(handles.Threshold,'Value'));
    Threshold = handles.Multiplier;
    imthresh = imhmin(imthresh,Threshold);
    imthresh = segCroissRegion(Threshold,imthresh,handles.startpoint(2),handles.startpoint(1));
    imthresh = imfill(imthresh, 'holes');
    drawnow;

    set(handles.statusstring,'String',sprintf('Adjust threshold until body of the worm is wholly shaded and then press Done again'));
end
handles.imthresh = imthresh;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ThresholdON.
function ThresholdON_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Threshold = get(handles.Threshold,'Value');



% --- Executes on button press in ThresholdOFF.
function ThresholdOFF_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdOFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.vidwindow);
imshow(histeq(handles.Video));

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over fileloadbutton.
function fileloadbutton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to fileloadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on skeletonbutton and none of its controls.
function skeletonbutton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to skeletonbutton (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function mouseover(varargin)
    
    c = get (gca, 'CurrentPoint'); % get mouse coordinates
    handles = varargin{3};
    if c(1,1)>0 && c(1,2)>0 && c(1,1)<handles.Vidobj.Width && c(1,2)<handles.Vidobj.Height
        set(handles.xcoordinate,'String',sprintf('x = %d',round(c(1,1))));  
        set(handles.ycoordinate,'String',sprintf('y = %d',round(c(1,2))));  
        pixelvalue = impixel(handles.Video,c(1,1),c(1,2));
        set(handles.pixelvalue,'String',sprintf('Pixel Value = %d         ',pixelvalue)); 
    end


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'UserData') == 0;
    set(handles.statusstring,'String',sprintf('Adjust threshold until body of the worm is wholly shaded and then press Done again'));
    set(hObject,'UserData',1);
elseif get(hObject,'UserData') == 1;
    set(handles.statusstring,'String',sprintf('First frame data specified\nPlease wait until analysis is done'));
    set(hObject,'UserData',2);
    drawnow;
%     handles.imthresh = handles.imthreshtemp;
    Strelsize = str2num(get(handles.Strel,'String'));
    handles.imthresh = imclose(handles.imthresh, strel('disk',Strelsize));
    handles.imthresh = imfill(handles.imthresh, 'holes');
    %%%%%%%%%%%%%%%%%%
    handles.imthreshtemp = bwmorph(handles.imthresh, 'thin',Inf);
    ht=size(handles.imthresh,1);
    headpt = handles.output(:,1)';
    headpt(2) = ht - headpt(2) +1;
    tailpt = handles.output(:,end)';
    tailpt(2) = ht - tailpt(2) +1;
    [endpoints(:,2), endpoints(:,1)] = find(bwmorph(handles.imthreshtemp,'endpoints'));
    headpti = dsearchn(endpoints,headpt);
    headpt = endpoints(headpti,:);
    tailpti = dsearchn(endpoints,tailpt);
    tailpt = endpoints(tailpti,:);
    selected = bwselect(handles.imthreshtemp,headpt(1),headpt(2),8);
    mat_dist = bwdistgeodesic(selected,headpt(1),headpt(2),'quasi-euclidean'); %'quasi-euclidean'
    comp = find(selected);
    comp(:,2) = mat_dist(comp(:,1));
    ordered_list_ind = sortrows(comp,2);
    [yCenterLine, xCenterLine] = ind2sub(size(selected),ordered_list_ind(:,1));
    [xCenterLine,yCenterLine]=divideSpline(xCenterLine,yCenterLine,12);
    handles.length=wormLength(xCenterLine,yCenterLine);
    
    yCenterLine = size(handles.imthresh,1) - yCenterLine +1;
    handles.output=[xCenterLine';yCenterLine']
    %%%%%%%%%%%%%%%%
    handles.imthresh = bwmorph(handles.imthresh, 'remove');
    %%%%%%%%%%%%%%
    imshow(handles.imthresh + handles.imthreshtemp);
    %%%%%%%%%%%%%%%%%
    [handles.edgev, handles.edged]= EdgePoints(handles.imthresh,handles.output);
    handles.imthresh = imfill(handles.imthresh, 'holes');
    %%%%%%%%%%%%%%%%
    handles.frameps = str2num(get(handles.FPS,'String'));
    handles.xcal = str2num(get(handles.xcalib,'String'));
    handles.ycal = str2num(get(handles.ycalib,'String'));
    [splineData, edgevData, edgedData] = Skeletonize(handles);
    labels=[{'%%Head'} {'%%Node 2'} {'%%3'} {'%%4'} {'%%5'} {'%%6'} {'%%7'} {'%%8'} {'%%9'} {'%%10'} {'%%11'} {'%%12'} {'%%Tail'}];
    savePath=[handles.pathname '\batchProduced_splineData.txt'];
    saveDataMatrix(labels,splineData,savePath);
    labels=[{'%%Node 2'} {'%%3'} {'%%4'} {'%%5'} {'%%6'} {'%%7'} {'%%8'} {'%%9'} {'%%10'} {'%%11'} {'%%12'} ];
    savePath=[handles.pathname '\batchProduced_edgevData.txt'];
    saveDataMatrix(labels,edgevData,savePath);
    savePath=[handles.pathname '\batchProduced_edgedData.txt'];
    saveDataMatrix(labels,edgedData,savePath);
end

function click(varargin)
gcbo = varargin{1};
handles = varargin{3};
if get(handles.done,'UserData')==0
    data=get(gcbo,'UserData');
    p=get(gca,'CurrentPoint');
    p=p(1,1:2);
    plot(p(1),p(2),'d','MarkerSize',5,'MarkerFaceColor','r','MarkerEdgeColor','r');
    data=[data;p];
    set(gcbo,'UserData',data); %store some userdata in the image temporarily   
end


% --- Executes on button press in zoombutton.
function zoombutton_Callback(hObject, eventdata, handles)
% hObject    handle to zoombutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom;



function Strel_Callback(hObject, eventdata, handles)
% hObject    handle to Strel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Strel as text
%        str2double(get(hObject,'String')) returns contents of Strel as a double
Strelsize = str2num(get(handles.Strel,'String'));
handles.imthreshtemp = edge(handles.imthresh,'canny',0.5,Strelsize);
handles.imthreshtemp = bwareaopen(handles.imthreshtemp,50);
% Strelsize = str2num(get(handles.Strel,'String'));
% imthreshtemp = imdilate(handles.imthresh,strel('disk',Strelsize))
% handles.imthreshtemp = imopen(imthreshtemp,strel('disk',Strelsize));
imshow(handles.imthreshtemp);
drawnow;
guidata(hObject,handles);
    

% --- Executes during object creation, after setting all properties.
function Strel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Strel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
