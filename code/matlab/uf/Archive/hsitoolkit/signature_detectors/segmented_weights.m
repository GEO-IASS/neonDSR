function [det_out,varargout] = segmented_weights(detector_fn,hsi_img,tgt_sig,segments,weights,varargin)
%
%function [det_out,varargout] = segmented_weights(detector_fn,hsi_img,tgt_sig,segments,weights,varargin)
%
% Segmented Detector Wrapper
%  uses any detector with the signature detector(img,tgt_sig,mask,args...)
%  as a segmented detector over the given segments
%
% inputs:
%  detector_fn - function handle for wrapped detector
%  hsi_img - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  segments - cell array of segment masks, n_row x n_col binary images
%  weights - weights of detector output by segment
%  varargin - variable array of arguments passed to the detector function
%
% outputs:
%  det_out - detector output image, concatenation of outputs from each segment
%            NaN valued in pixels not contained by a segment
%  varargou - other outputs, assumed to be images, but segment weights are not applied
%
% 11/1/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

[n_row,n_col,~] = size(hsi_img);

n_seg = numel(segments);

det_out = NaN(n_row,n_col);

n_out = nargout(detector_fn);
        
if n_out > 1
    varargout = cell(1,n_out-1);
    for i=1:n_out-1        
        % assume other outputs are also images
        varargout{i} = NaN(n_row,n_col);
    end
    
    for i=1:n_seg
        argout = cell(1,n_out-1);
        
        [seg_out,argout{:}] = detector_fn(hsi_img,tgt_sig,segments{i},varargin{:});
        
        if ~iscell(weights)
            det_out(segments{i}) = weights(i)*seg_out(segments{i});
        else
            det_out(segments{i}) = weights{i}(segments{i}).*seg_out(segments{i});
        end
        
        for j=1:numel(argout)
            varargout{j}(segments{i}) = argout{j}(segments{i});            
        end
    end
else
    
    for i=1:n_seg
        
        seg_out = detector_fn(hsi_img,tgt_sig,segments{i},varargin{:});
        if ~iscell(weights)
            det_out(segments{i}) = weights(i)*seg_out(segments{i});
        else
            det_out(segments{i}) = weights{i}(segments{i}).*seg_out(segments{i});
        end
        
    end

end

end