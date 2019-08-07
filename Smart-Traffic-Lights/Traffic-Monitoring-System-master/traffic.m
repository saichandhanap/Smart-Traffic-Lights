clc;
clear all;
close all;
%%
rpi = raspi();
s = servo (rpi, 4);
cam = cameraboard(rpi, 'Resolution', '1920x1080', 'Quality', 100, 'FrameRate', 90, 'Brightness', 60);
area=zeros(1, 4);
for j = 1:4
    writePosition(s, (j-1)*60);
    pause(5);
    for i = 1:30
        if(i == 10)%buffer error
            background = snapshot(cam);%will capture image
            figure;
            image(background);%showing
            drawnow;%drawing at the current moment
            disp("Background Set");
            pause(2);
            figure;
        else
            foreground = snapshot(cam);
            image(foreground);
            drawnow;
        end;
    end;
    a = background;
    b = foreground;
    c=b-a;%Extract Objects from Image by Eliminating background
    d=imbinarize(rgb2gray(c)); %Convert Image to GrayScale and then binarizes it by adapting some threshold
    e=imopen(d,strel('square', 3));%Eliminating small square disturbances which are less than or equal to size 3 from above image
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'CentroidOutputPort', false, ...
        'MinimumBlobArea', 150);%Analyses image for objects, extracts required images by eliminating images less than 150px and calculates bounding box for required objects
    bbox=step(blobAnalysis,e);%Finds the positions of rectangle by doing something!!!!
    for i=1:size(bbox,1)
        p=bbox(i,:);
        area(j)=area(j)+p(1)*p(2);
    end
    display(area(j));
    result=insertShape(b,'Rectangle',bbox,'Color','green');%Inserts rectangles on the original image
    figure;
    imshow(result);%Shows the image
    drawnow;
end;
red=[0,0,0,0]; %red array (red(i)=1 means ith red signal glows. red(i)=0 means it doesn't glow.)
yellow=[0,0,0,0]; %yellow array for each signal
green=[0,0,0,0]; %green array for each signal
t1 = area(1);
t2 = area(2);
t3 = area(3);
t4 = area(4);
a = [t1, t2, t3, t4]; %array of cars in each traffic way.
a
pins = [12:23]; %labels of each pin
[p,ind] = max(a); % find details of max element (val,ind)
q = min(a);
while 1 == 1    
    green(ind)=1;
    for i=1:4
        yellow(i)=0;
        if i~=ind
            green(i)=0;
            red(i)=1;
        end
    end
    for i=1:3:12
        writeDigitalPin(rpi,pins(i),red((i+2)/3));
        writeDigitalPin(rpi,pins(i+1),yellow((i+2)/3));
        writeDigitalPin(rpi,pins(i+2),green((i+2)/3));
    end;
    pause(3);
    green(ind)=0;
    yellow(ind)=1;
    a(ind) = q-1;
    [p,ind] = max(a);
    q = min(a);
    for i=1:3:12
        writeDigitalPin(rpi,pins(i),red((i+2)/3));
        writeDigitalPin(rpi,pins(i+1),yellow((i+2)/3));
        writeDigitalPin(rpi,pins(i+2),green((i+2)/3));
    end;
    pause(1.2);
    yellow(ind)=1;
    red(ind)=0;
    for i=1:3:12
        writeDigitalPin(rpi,pins(i),red((i+2)/3));
        writeDigitalPin(rpi,pins(i+1),yellow((i+2)/3));
        writeDigitalPin(rpi,pins(i+2),green((i+2)/3));
    end;
    pause(0.8);
end;