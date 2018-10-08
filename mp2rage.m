function [TI1real,TI1imag,TI2real,TI2imag] = mp2rage( ...
	nii_dir, ...
	out_dir, ...
	project, ...
	subject, ...
	session, ...
	scan ...
	)

% Find all Nifti files in this resource
d = dir([nii_dir '/*.nii.gz']);
fnames = cellstr(char(d.name));
fullfnames = strcat(nii_dir,'/',fnames);

% Which images are real and imaginary?
reals = cellfun(@(x) ~isempty(x),regexp(fullfnames,'.*real_t\d+\.nii.gz'));
imags = cellfun(@(x) ~isempty(x),regexp(fullfnames,'.*imaginary_t\d+\.nii.gz'));

% Find the actual phase time values
T = regexp(fullfnames(reals),'(.*)real_t(\d+)','tokens');
clear fbase ttimes
for t = 1:length(T)
	fbase{t} = T{t}{1}{1};
	ttimes{t} = T{t}{1}{2};
end

% Just use the first two ttimes to compute mp2rage
TI1real_file = [fbase{1} 'real_t' ttimes{1} '.nii.gz'];
TI1imag_file = [fbase{1} 'imaginary_t' ttimes{1} '.nii.gz'];
TI2real_file = [fbase{2} 'real_t' ttimes{2} '.nii.gz'];
TI2imag_file = [fbase{2} 'imaginary_t' ttimes{2} '.nii.gz'];

% Unzip
system(['gunzip "' TI1real_file '"']);
TI1real_file = TI1real_file(1:end-3);

system(['gunzip "' TI1imag_file '"']);
TI1imag_file = TI1imag_file(1:end-3);

system(['gunzip "' TI2real_file '"']);
TI2real_file = TI2real_file(1:end-3);

system(['gunzip "' TI2imag_file '"']);
TI2imag_file = TI2imag_file(1:end-3);


% Load images
V = spm_vol(TI1real_file);
TI1real = spm_read_vols(V);
TI1imag = spm_read_vols(spm_vol(TI1imag_file));
TI2real = spm_read_vols(spm_vol(TI2real_file));
TI2imag = spm_read_vols(spm_vol(TI2imag_file));


% Compute MP2RAGE and magnitude images
mp2rage = compute_mp2rage(TI1real,TI1imag,TI2real,TI2imag);
TI1magn = abs(TI1real + 1i*TI1imag);
TI2magn = abs(TI2real + 1i*TI2imag);


% Write out
Vout = rmfield(V,'pinfo');
Vout.dt(1) = spm_type('float32');
Vout.fname = fullfile(out_dir,'mp2rage.nii');
spm_write_vol(Vout,mp2rage);
system(['gzip "' Vout.fname '"']);


%% Make PDF report

% Figure out screen size so the figure will fit
ss = get(0,'screensize');
ssw = ss(3);
ssh = ss(4);
ratio = 8.5/11;
if ssw/ssh >= ratio
        dh = ssh;
        dw = ssh * ratio;
else
        dw = ssw;
        dh = ssw / ratio;
end

% Make figure
f1 = openfig('pdf_figure.fig','new');
colormap(gray)
set(f1,'Position',[0 0 dw dh]);
figH = guihandles(f1);

set(figH.scan_info, 'String', sprintf( ...
        '%s %s %s %s', ...
        project, subject, session, scan));
set(figH.date,'String',date);

% Show images
s = size(TI1real);
x = round(s(1)/2)+6;
y = round(s(2)/2);
z = round(s(3)/2);


axes(figH.slice_mag1);
imagesc(imrotate(TI1magn(:,:,z),90))
axis square off
title('Echo 1 Magnitude')

axes(figH.slice_real1);
imagesc(imrotate(TI1real(:,:,z),90))
axis square off
title('Echo 1 Real')

axes(figH.slice_imag1);
imagesc(imrotate(TI1imag(:,:,z),90))
axis square off
title('Echo 1 Imaginary')


axes(figH.slice_mag2);
imagesc(imrotate(TI2magn(:,:,z),90))
axis square off
title('Echo 2 Magnitude')

axes(figH.slice_real2);
imagesc(imrotate(TI2real(:,:,z),90))
axis square off
title('Echo 2 Real')

axes(figH.slice_imag2);
imagesc(imrotate(TI2imag(:,:,z),90))
axis square off
title('Echo 2 Imaginary')


axes(figH.mp2rage1);
imagesc(imrotate(squeeze(mp2rage(x,:,:)),90))
axis square off

axes(figH.mp2rage2);
imagesc(imrotate(squeeze(mp2rage(:,y,:)),90))
axis square off
title('MP2RAGE')

axes(figH.mp2rage3);
imagesc(imrotate(squeeze(mp2rage(:,:,z)),90))
axis square off

print(f1,'-dpdf',fullfile(out_dir,'mp2rage.pdf'))


