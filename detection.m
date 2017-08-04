clear all;close all;clc;
%antenna_k=-29:2:29;tmp=find(antenna_k==0);antenna_k(tmp)=[];antenna_k=antenna_k';
%Linearation = zeros(30,1);
test_antenna = 1;
test_subcar = 1;
width = 20;
threshold = 10;
pointerThreshold = 20;  
 
restore = zeros(200000,30);
quiet=1;

bSaveVD = 1;    % set as 1 if you want to save the video, 0 if not
pltHold = 0;    % a index for current csi package
holdPeriod = 10; % draw the 10 lastest csi amplitude curves of 3 receive antennas
buffer = zeros(holdPeriod,3);
StartPackage = 600;
EndPackage = 1900;
happenIndex = 0;
if bSaveVD
    Objname = input('input the file name for your video: ','s');
    writerObj = VideoWriter(Objname);  %'MPEG-4'
    writerObj.FrameRate = 5;
    open(writerObj);
end

for i=StartPackage:1:EndPackage
    %i=1;
    %while 1
    %    i=i+1;
    
    csi_trace = read_bf_file('/home/tm/CSI/AAA.dat');
    %mysize=size(csi_trace);
    %mysize(1)
    try
        %csi_entry = csi_trace{floor(mysize(1))};
        csi_entry = csi_trace{1};               % = 1
        %string=(['E:\CSI tool\matlab\testpic\Real'  int2str(i)])
        csi = get_scaled_csi(csi_entry);
        %MultiAmpli = abs(squeeze(csi).');    % replace csi with csi(YOUR_TRANSMITTER_NUMBER,:,:)
        MultiAmpli = db(abs(squeeze(csi(1,:,:)).'));    % replace csi with csi(YOUR_TRANSMITTER_NUMBER,:,:)
        %MultiPhase = angle(squeeze(csi(1,:,:)).');
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
        legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast');
        
        
        subplot(122);
        restore(i,:) = MultiAmpli(:,test_antenna);    % difference between before and after motion    set test_antenna
        
        restoreUpdate=restore;
        restoreUpdate(find(restoreUpdate(:,1)==0),:)=[];
        restoreUpdate(isinf(restoreUpdate))=0;

        singleVar=colfilt(restoreUpdate(:,:),[width 1],'Sliding','var');
        NONE = sum(isnan(singleVar));
        singleVar(find(isnan(singleVar))) = singleVar(find(isnan(singleVar))-NONE(1));
        
        totalVar=mean(singleVar,2);
        plot(totalVar(width/2:end-width/2));hold on;axis([0,1000,-10,80]);
        
        try           
            pointer = mean(aa(end-110:end-10,:),1);
            if max(totalVar(end-width:end-width/2))> threshold && quiet==1;    %  only entry this section for one time
                WARNING = text(500,75,'WARNING');
                try
                    delete(LEAVED);                    
                end
                quiet=0;
                calibration = pointer;
                happenIndex = i;
                %fprintf('ERROR of warnning section  ');
            end
            
            if quiet == 0 && sum(abs(pointer-calibration)) < pointerThreshold && i-happenIndex > 20
                fprintf(['LEAVED' int2str(mean(abs(pointer-calibration))) ' ' int2str(i) '  ']);
                LEAVED = text(500,-5,'LEAVED');
                delete(WARNING);
                quiet = 1;
            end
            fprintf([int2str(sum(abs(pointer-calibration))) ' ']);
        catch
            fprintf('not that long for pointer');
        end      
        
        % record the last "quite" sequence before the bursting;
        
        
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
        fprintf([int2str(i) ' clever\n']);
    catch
        fprintf('Unknown error\n');
    end
    %pause(bTimeStep);
    %saveas(gcf,string,'jpg');
    hold on;
end

if bSaveVD
    close(writerObj);
end

fprintf('SUCCEED\n')
