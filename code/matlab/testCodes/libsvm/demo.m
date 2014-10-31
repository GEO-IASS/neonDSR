[label, data] = libsvmread('/opt/zshare/zproject/apps/libsvm-3.19/heart_scale');

(data - repmat(min(data,[],1),size(data,1),1))*spdiags(1./(max(data,[],1)-min(data,[],1))',0,size(data,2),size(data,2))

bestcv = 0;
for log2c = -1:3,
  for log2g = -4:1,
    cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = svmtrain(label, data, cmd);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
    end
    fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
  end
end

%cmd = ['-t 2 -c ', num2str(bestc), ' -g ', num2str(bestg)];
%model = svmtrain(l, d, cmd);

%[predicted_label, accuracy, decision_values] = svmpredict(zeros(size(dd,1),1), dd, model);