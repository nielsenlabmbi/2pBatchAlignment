function [m,T] = align(fname,idx,channel,numIdx,h)
    % Aligns images in fname for all indices in idx
    % Adapted by Sam Numella and maintained by Ramanujan Srinath
    % Accepts:
    %   fname   - filename
    %   idx     - indices of frames to align
    %   channel - which channel to align
    %   numIdx  - (optional) total number of indices (this is for the progressbar)
    %   h       - (optional) handle for the progressbar
    % Returns:
    %   m - mean image after the alignment
    %   T - optimal translation for each frame

    if(length(idx)==1)
        A = sbxread(fname,idx(1),1);
        A = squeeze(A(channel,:,:));
        m = A;
        T = [0 0];
    elseif (length(idx)==2)
        A = sbxread(fname,idx(1),1);
        B = sbxread(fname,idx(2),1);
        A = squeeze(A(channel,:,:));
        B = squeeze(B(channel,:,:));

        [u,v] = fftalign(A,B);

        Ar = circshift(A,[u,v]);
        m = (Ar+B)/2;
        T = [[u v] ; [0 0]];
    else
        idx0 = idx(1:floor(end/2));
        idx1 = idx(floor(end/2)+1 : end);

        if nargin == 5 && ~isempty(h)
            waitbar(min(idx0)/numIdx,h);
        else
            numIdx = 0; h = [];
        end

        [A,T0] = align(fname,idx0,channel,numIdx,h);
        [B,T1] = align(fname,idx1,channel,numIdx,h);

        [u,v] = fftalign(A,B);

        Ar = circshift(A,[u, v]);
        m = (Ar+B)/2;
        T = [(ones(size(T0,1),1)*[u v] + T0) ; T1];
    end
end