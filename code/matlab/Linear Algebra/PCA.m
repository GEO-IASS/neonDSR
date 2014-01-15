%% Expriment linear algebra concepts in matlab

a = 10 * randn(1000,1);  % generate vector a

b = randn(1000, 1); % generate vector b


plot([a; b], '.') % append to the end of the column
pause(0.7);

clf; plot([a, b], '.') % append each element as another item in row. draws both vectors
pause(0.7);

clf; plot(a, b, '.') % actual (x, y) = (a, b) plotting

R = [cosd(75) -sind(75); sind(75) cosd(75)]  % rotate matrix by 75 degrees

G = R*[a,b]'; 
size(G)

x = G(1,:); % first row of data
y = G(2,:); % second row of data

hold on
plot(x,y,'.g');

[COEFF] = princomp([x; y]');

COEFF
R
% COEFF and R are very close. so PCA can tell us the rotational matrix
size([x;y]')   % it's a thousand rows by two columns data

y = G(2, :) + 10; % translate y
plot(x,y,'.r')

[COEFF] = princomp([x; y]');

COEFF  % translation will not change result of principal component analysis
R