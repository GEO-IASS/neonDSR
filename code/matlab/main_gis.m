init();
global setting;
fieldPath = setting.FIELD_PATH;
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io'));
addpath(strcat(setting.PREFIX,'/neonDSR/code/matlab/io/csvIO'));




[s_FNAI, a_FNAI] = shaperead('/opt/zshare/zproject/neonDSR/docs/osbs_gis_10_28_14/os_FNAI_drft_10_28_14.shp');
%[s_boundary, a_boundary] = shaperead('/opt/zshare/zproject/neonDSR/docs/osbs_gis_10_28_14/os_boundary_10_2014.shp');
%[s_mu, a_mu] = shaperead('/opt/zshare/zproject/neonDSR/docs/osbs_gis_10_28_14/os_mu.shp');
[s_rxfire, a_rxfire] = shaperead('/opt/zshare/zproject/neonDSR/docs/osbs_gis_10_28_14/os_rxfire_drft_10_28_14.shp');


[ species, reflectances, rois, northings, eastings, flights ] = get_field_pixels();

%%
n = northings(1)
e = eastings(1)

bb = [n e; n e]
w = 0.5
bb = [e-w n-w; e+w n+w]
[s_FNAI, a_FNAI] = shaperead('/opt/zshare/zproject/neonDSR/docs/osbs_gis_10_28_14/os_FNAI_drft_10_28_14.shp', 'BoundingBox', bb);

figure,
sp = subplot(2,2,1), mapshow(s_FNAI(1));  yt=get(sp,'ytick')'; set(sp,'yticklabel',num2str(yt,'%.0f')); xt=get(sp,'xtick')'; set(sp,'xticklabel',num2str(xt,'%.0f'))

sp = subplot(2,2,2), mapshow(s_FNAI(1));  yt=get(sp,'ytick')'; set(sp,'yticklabel',num2str(yt,'%.0f')); xt=get(sp,'xtick')'; set(sp,'xticklabel',num2str(xt,'%.0f'))
hold(sp, 'on')
plot(sp, n,e, '*')

sp = subplot(2,2,3), mapshow(s_FNAI(3));  yt=get(sp,'ytick')'; set(sp,'yticklabel',num2str(yt,'%.0f')); xt=get(sp,'xtick')'; set(sp,'xticklabel',num2str(xt,'%.0f'))
sp = subplot(2,2,4), mapshow(s_FNAI(4));  yt=get(sp,'ytick')'; set(sp,'yticklabel',num2str(yt,'%.0f')); xt=get(sp,'xtick')'; set(sp,'xticklabel',num2str(xt,'%.0f'))

%hold all
%hold on
n 
e

%disp(a_FNAI(1))
%disp(a_FNAI(2))
%disp(a_FNAI(3))
%disp(a_FNAI(4))
%bb

%figure , mapshow(s_FNAI)
