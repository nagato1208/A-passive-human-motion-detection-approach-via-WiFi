% to make a demo video with dynamic csi signals when there are 1 transmitter and 3 receivers 
% when the number of the transmitters is over 1, change the LINE26 and LINE 27 

clear all;close all;clc;
csi_trace = read_bf_file('sample_data/real001.dat');
%bTimeStep = 0.0125;
bSaveVD = 1;    % set as 1 if you want to save the video, 0 if not
pltHold = 0;    % a index for current csi package
holdPeriod = 10; % draw the 10 lastest csi amplitude curves of 3 receive antennas
buffer = zeros(holdPeriod,3);
StartPackage = 1500;
EndPackage = 1800;

if bSaveVD
    Objname = input('input the file name for your video: ','s');
    writerObj = VideoWriter(Objname,'MPEG-4');
    writerObj.FrameRate = 5;
    open(writerObj);
end

for i = StartPackage:1:EndPackage
    i  
    csi_entry = csi_trace{i};
    %string=(['E:\CSI tool\matlab\testpic\Real'  int2str(i)])
    csi = get_scaled_csi(csi_entry);
    MultiAmpli = abs(squeeze(csi).');    % replace csi with csi(YOUR_TRANSMITTER_NUMBER,:,:)
    MultiAmpli = abs(squeeze(csi).');    % replace csi with csi(YOUR_TRANSMITTER_NUMBER,:,:)
    MultiPhase = angle(squeeze(csi).')/pi;    
    %plot(db(abs(squeeze(csi).')));    
    subplot(121);   
    if pltHold >= holdPeriod
        delete(buffer(mod(i,holdPeriod)+1,:));
    end    
    hold on;
    buffer(mod(i,holdPeriod)+1,:) = plot(MultiAmpli);    
    pltHold = pltHold+1;   
    axis([0,30,-10,40]);
    xlabel('Subcarrier index');
    ylabel('CSI amplitude');
    legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
    subplot(322);    plot(MultiPhase(:,1),'b');    axis([0,30,-2,2]);
    subplot(324);    plot(MultiPhase(:,2),'g');    axis([0,30,-2,2]);    ylabel('CSI phase');
    subplot(326);    plot(MultiPhase(:,3),'r');    axis([0,30,-2,2]);    xlabel('Subcarrier index');
    
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
    %pause(bTimeStep);
    %saveas(gcf,string,'jpg');
end

if bSaveVD
    close(writerObj);
end
%db(get_eff_SNRs(csi), 'pow')

fprintf('SUCCEED\n')




