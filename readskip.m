function [zGreen,zRed] = readskip(filename,startFrame,numFramesToSkip)
    % Reads the specified sbx file in intervals of a specified number of
    % frames.
    % Accepts:
    %   filename        - sbx file name with full path
    %   startFrame      - the frame number from where the file is to be read; default to 0 if not specified
    %   numFramesToSkip - number of frames to skip; default to 100 if not specified
    % Returns:
    %   zGreen          - green channel frames read
    %   zRed            - red channel frames read
    
    % default values if not specified.
    if ~exist('startFrame','var') || isempty(startFrame);           startFrame = 0;         end
    if ~exist('numFramesToSkip','var') || isempty(numFramesToSkip); numFramesToSkip = 100;  end

    load(filename);
    numFramesToRead = floor(info.max_idx/numFramesToSkip);

    zGreen = sbxread(filename,startFrame,1);
    zGreen = zeros([size(zGreen,2) size(zGreen,3) numFramesToRead]);
    zRed = zGreen; 
    
    for j=1:numFramesToRead
        allFrames   = sbxread(filename,j*numFramesToSkip,1);
        
        if size(allFrames,1) > 1
            greenFrames = squeeze(allFrames(1,:,:));
            redFrames   = squeeze(allFrames(2,:,:));
        else
            greenFrames = allFrames;
            redFrames   = zeros(size(greenFrames));
        end
        
        
        if ~isempty(info.aligned)
            greenFrames = circshift(greenFrames,info.aligned.T(j*numFramesToSkip,:)); 
            if size(allFrames,1) > 1
                redFrames   = circshift(redFrames,info.aligned.T(j*numFramesToSkip,:));     
            end
        end
        zGreen(:,:,j)   = greenFrames;
        zRed(:,:,j)     = redFrames;
    end
end