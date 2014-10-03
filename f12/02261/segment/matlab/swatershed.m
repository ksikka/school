function L = swatershed(A,seeds,conn)
% L = SWATERSHED(A,SEEDS,CONN)
% L is the output, watershed image regions (type double)
% A is the input gray level image (type uint16)
% SEEDS is the seed channel, a binary image)
% CONN is the connectivity, by default 8 for 2D, 26 for 3D

if ~exist( 'conn','var')
    if ndims(A)==2
        conn = 4;
    elseif ndims(A)==3
        conn = 6;
        % conn = 26;
    else
        error( 'Improper image dimensions');
    end
end

if size(A)~=size(seeds)
    error( 'Inputs are not compatible');
end

M = bwlabeln( seeds,conn);
L = watershed_meyer(A,conn,M);
