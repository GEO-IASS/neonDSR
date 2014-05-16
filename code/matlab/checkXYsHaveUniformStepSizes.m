function checkXYsHaveUniformStepSizes( envi )
% makes sure the step size does't change between pixels and is always the
% same

first_StepX = envi.x(2) - envi.x(1);
consistent_x_step = true;
for i=2:size(envi.x')
    diff = envi.x(i) - envi.x(i-1);
   if diff == first_StepX
      %     disp('=')  
   else
     consistent_x_step = false;
     sprintf('Expected %d but found %d', first_StepX, diff)
   end
end
if consistent_x_step == false
    disp('INCONSISTENT step size')
else
    disp('X step sizes, OK')
end

first_StepY = envi.y(2) - envi.y(1);
consistent_y_step = true;
for i=2:size(envi.y')
   diff = envi.y(i) - envi.y(i-1);
   if (diff == first_StepY)
     %disp('=')  
   else
     consistent_y_step = false;
   end
end
if consistent_y_step == false
    disp('INCONSISTENT step size')
else
    disp('Y step sizes, OK')
end

end

