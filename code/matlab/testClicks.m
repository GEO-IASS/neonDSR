function [x, y] = testClicks
   img = ones(300); % image to display
   h   = imshow(img,'Parent',gca);
   set(h,'ButtonDownFcn',{@ax_bdfcn});
   x = [] % define "scope" of x and y 
   y = []  

   % call back as nested function
   function ax_bdfcn(varargin)
       a = get(gca,'CurrentPoint');
       x = a(1,1); % set x and y at caller scope due to "nested"ness of function
       y = a(1,2);
   end  % close nested function
end % must have end for nested functions