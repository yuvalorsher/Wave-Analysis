function [eventTimes] = getBicucullineEvents(recObj,varargin)
%GETBICUCULLINEEVENTS Finds the times (ms) in recObj where epileptic events
%occur. It does so by deviding the recording into smaller batches, looking 
%at the channel with strongest response per batch, smoothing by average
%moving window and finding the times where channel crosses 10*std
%   Input:
%       - recObj - recording object
%       - Varargins (given as 'Key',Value pairs):
%           - batchLength_ms - the length of batch into which the whole
%           recording is devided to. Default is 100000
%           - smoothingWindow - size of the moving average window
%           (samples). Default is 100.
%           - dispBachNum - display current batch number. Default is true.
%	Output:
%       - eventTimes - array of detected times (ms) of epilleptic events.

batchLength_ms=100000;
smoothingWindow=100;
dispBachNum=1;

for i=1:2:length(varargin)
   eval([varargin{i} '=varargin{' num2str(i+1) '};']);
end

nBatches=max(round(recObj.recordingDuration_ms/batchLength_ms),1);

eventTimes=[];

for i=1:nBatches
    if dispBachNum
        disp(['Batch ' num2str(i) ' out of ' num2str(nBatches)])
    end
    [data,time]=recObj.getData([1:50:252],(i-1)*batchLength_ms,batchLength_ms);
%     find ch with strongest response
    [minVal,strongestCh]=min(min(squeeze(data),[],2));
    chSTD=std(squeeze(data(strongestCh,1,:)));
    smoothed=smooth(squeeze(data(strongestCh,1,1:end)),smoothingWindow);
    eventSamples=find(smoothed(1:end-1)>(-chSTD*10)&smoothed(2:end)<(-chSTD*10));
    eventTimes=[eventTimes;eventSamples*recObj.sample_ms+(i-1)*batchLength_ms];
%     % plot(smoothed)
%     plot(squeeze(data(5,1,:)))
%     hold on
%     plot(eventTimes,length(eventTimes),'or')
%     plotShifted(time'+(i-1)*betchLength_ms,squeeze(data)');
end

end

