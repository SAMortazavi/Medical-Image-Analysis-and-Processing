clc
clear all 
close all 
%% Loading image
handImage = imread('hand.jpg');
%% Part A 
noisyHandImage = imnoise(handImage, "gaussian", 0.05, 0.01);
grayHandImage = rgb2gray(handImage);
noisyHandImage = rgb2gray(noisyHandImage);
grayHandImage = double(grayHandImage);
noisyHandImage = double(noisyHandImage);
mont_array = reshape([grayHandImage,noisyHandImage],[size(noisyHandImage),2]);
figure;
montage(uint8(mont_array))
title("Pure image                     Noisy image ")
SNR = 10 * log10(sum(grayHandImage .^ 2, "all") / sum((grayHandImage - noisyHandImage) .^2, "all"));
disp("SNR is equal to "+num2str(SNR))
%% Part B
%   Gaussian matrix with size of l*l and l must be odd
l = 5;
normalizedNoisyImage = noisyHandImage/255;
centerOfFilter = (l+1)/2;
Gx_B = zeros(l);
hx_B = 1;
for i = 1:l
    for j = 1:l
        Gx_B(i, j) = exp(-((i-centerOfFilter)^2 + (j-centerOfFilter)^2) / (2*hx_B^2));
    end
end
Gx_B = Gx_B/sum(sum(Gx_B));
denoisedImage = conv2(1.0*normalizedNoisyImage,Gx_B,'same')*255;
mont_array = reshape([noisyHandImage,denoisedImage],[size(noisyHandImage),2]);
figure;
montage(uint8(mont_array))
title(" Noisy image ----- Denoised image using gaussain filtering")
SNR1 = 10 * log10(sum(grayHandImage .^ 2, "all") / sum((grayHandImage - denoisedImage) .^2, "all"));
disp("SNR is equal to "+num2str(SNR1))
%% Part C 
l = 7;
Gx_C = zeros(l);
hx_C = 0.95;
centerOfFilter = (l+1)/2;
for i = 1:l
    for j = 1:l
        Gx_C(i, j) = exp(-((i-centerOfFilter)^2 + (j-centerOfFilter)^2) / (2*hx_C^2));
    end
end

Gx_C = Gx_C/sum(sum(Gx_C));
new_size = size(grayHandImage)+(l-1);
img_extended = zeros(new_size);
img_extended(centerOfFilter:end-(centerOfFilter-1), centerOfFilter:end-(centerOfFilter-1)) = normalizedNoisyImage;
hg = 0.45;
denoisedImage2 = zeros(size(grayHandImage));
for i = 1:651
    for j = 1:719
        Gg = exp(-(img_extended(i:i+(l-1), j:j+(l-1)) - img_extended(i+(l-1)/2, j+(l-1)/2))^2 / (2*hg^2));
        G = Gg .* Gx_C;
        denoisedImage2(i, j) = round(255*(sum(img_extended(i:i+(l-1), j:j+(l-1)) .* G, "all") / sum(G, "all")));
    end
end
mont_array = reshape([noisyHandImage,denoisedImage2],[size(noisyHandImage),2]);
figure;
montage(uint8(mont_array))
title(" Noisy image    --------    Filtered image using Bilateral filtering")
SNR2 = 10 * log10(sum(grayHandImage .^ 2, "all") / sum((grayHandImage - denoisedImage2) .^2, "all"));
disp("SNR is equal to "+num2str(SNR2));

