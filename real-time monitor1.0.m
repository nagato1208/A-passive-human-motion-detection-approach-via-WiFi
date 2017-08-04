clear all;close all;clc;
f=fullfile('log.txt');
fid=fopen(f,'wb');
bSaveVD = 1;    % set as 1 if you want to save the video, 0 if not
pltHold = 0;    % a index for current csi package
holdPeriod = 10; % draw the 10 lastest csi amplitude curves of 3 receive antennas
buffer = zeros(holdPeriod,3);
StartPackage = 1;
EndPackage = 999999;  % use a large number if you want to observe for a long time or just use "while 1" 

if bSaveVD
    Objname = input('input the file name for your video: ','s');
    writerObj = VideoWriter(Objname);  %'MPEG-4'
    writerObj.FrameRate = 5;
    open(writerObj);
end

for i=StartPackage:1:EndPackage
    csi_trace = read_bf_file('/home/tm/CSI/AAA.dat');
    mysize=size(csi_trace);
    %mysize(1)
    try
        csi_entry = csi_trace{floor(mysize(1))};   % draw the last package of the csi data, if you use log_to_file1.0.c the value will always be 1
        %string=(['E:\CSI tool\matlab\testpic\Real'  int2str(i)])
        csi = get_scaled_csi(csi_entry);
        MultiAmpli = db(abs(squeeze(csi(1,:,:)).'));    % replace csi with csi(YOUR_TRANSMITTER_NUMBER,:,:)
        MultiPhase = angle(squeeze(csi(1,:,:)).')/pi;
        %plot(db(abs(squeeze(csi).')));
        subplot(121);
        if pltHold >= holdPeriod
            delete(buffer(mod(i,holdPeriod)+1,:));
        end
        hold on;
        fprintf('clever\n')
        buffer(mod(i,holdPeriod)+1,:) = plot(MultiAmpli);
        pltHold = pltHold+1;
        axis([0,30,-10,40]);
        xlabel('Subcarrier index');
        ylabel('CSI amplitude');
        legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
        subplot(122);
        plot(i,mysize(1),'*');hold on;
        axis([1,2000,0,20000]);
        fwrite(fid,mysize(1),'int');
        %pause(0.25);
        
        if bSaveVD
            if i == StartPackage
                frame = getframe(gcf);
                VDsize = size(frame.cdata);
                H = VDsize(1);  W = VDsize(2);
            else
                frame = getframe(gcf);
                frame.cdata = imresize(frame.cdata, [H W]); % Height*Width
            end
            writeVideo(writerObj,frame);
        end
        
    catch
        fprintf('error\n');
    end
    %pause(bTimeStep);
    %saveas(gcf,string,'jpg');
end

if bSaveVD
    close(writerObj);
end

fclose(fid);
fprintf('SUCCEED\n')
