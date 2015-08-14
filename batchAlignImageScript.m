function batchAlignImageScript(channelNum,numFramesToSkip)
    % Aligns and creates average images for selected files as a batch. This is
    % done using the parallel processing toolbox.
    % NOTE: This starts up a parallel pool with the maximum number of workers
    % your processor supports or the number of files you select (whichever is
    % lower). The starting up takes a while but it is worth it for large
    % numbers of files.
    % TODO: Clone this and make versions for GPU or cluster.
    % Accepts:
    %   channelNum          - channel number to use for alignment; default to 1 if not specified
    %   numFramesToSkip     - number of frames to skip; default to 100 if not specified
    % Returns:
    %   Nothing.

    % default values if not specified.
    if ~exist('channelNum','var') || isempty(channelNum);           channelNum = 1;         end
    if ~exist('numFramesToSkip','var') || isempty(numFramesToSkip); numFramesToSkip = 100;  end

    % select all the files to align in a batch
    [filename,pathname] = uigetfile( ...
        {'*.sbx','Scanbox image files (*.sbx)'; '*.*', 'All Files (*.*)'},...
        'Pick a file','F:\','MultiSelect', 'on');

    if iscell(filename); numFiles = length(filename); else numFiles = 1; end

    batchAlignCluster = parcluster('local'); 
    batchAlignCluster.NumWorkers = numFiles; 
    parpool(batchAlignCluster,numFiles);

    parfor i=1:numFiles
        % matlab has no way of looking at cells vs strings. this is a workaround
        if numFiles > 1
            fullFileName = [pathname filename{i}];
        else
            fullFileName = [pathname filename];                             %#ok<PFBNS>
        end

        [filepath,thisfilename] = fileparts(fullFileName);                  % removing file extension and getting the path
        fullFileName = [filepath '\' thisfilename];                         % concatenating file path and file name.
        
        sbxread(fullFileName,0,1);                                          % so that info is corrected
        a = load(fullFileName); info = a.info;                              % load info file

        % align
        [m,T] = align(fullFileName,0:info.max_idx,channelNum); 
        disp(['Aligned ' thisfilename]);
        info.aligned.m          = m;
        info.aligned.T          = T;
        info.aligned.channel    = channelNum;
        parsave([fullFileName '.mat'],info);
        parsave([fullFileName '.align'],m,T,channelNum);

        % create image
        [zGreen,zRed]     = readskip(fullFileName,0,numFramesToSkip);
        disp(['Created average image for ' thisfilename]);
        avgImage = normImage(zGreen);
%         avgImage = [avgImage; normImage(zRed)];

        parsave([fullFileName '.image'],avgImage,channelNum,numFramesToSkip);
    end
end
