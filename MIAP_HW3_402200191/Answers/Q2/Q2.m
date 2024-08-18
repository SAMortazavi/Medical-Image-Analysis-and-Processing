close all
clear
clc
%% Loading Image and adding noise
img = imread('image2.png');
img = im2double(img);
imgNoisy = imnoise(img, 'gaussian');
%% Cross-Validation for Selecting Hyperparameters 
%% Cross-Validation for Aniso
bestSsim = -Inf;
bestNiqe = Inf;
bestLambda = 0;
bestKappa = 0;
nIter = 5;

for option = 1:2
    for lambdaVal = 0.05:0.05:0.2
        t = 20:5:100;
        ssims = [];
        niqes = [];
        
        for kappaVal = 20:5:100
            anisoImgDenoised = anisodiff(imgNoisy, nIter, kappaVal, lambdaVal, option);
            ssimScore = ssim(anisoImgDenoised, img);
            niqeScore = niqe(anisoImgDenoised);
            ssims = [ssims, ssimScore];
            niqes = [niqes, niqeScore];
%             fprintf("lambda=%.2f, kappa=%.2f, ", lambdaVal, kappaVal);
%             fprintf("ssim=%.2f, niqe=%.2f\n", ssimScore, niqeScore);

            % Update best SSIM and NIQE scores
            if ssimScore > bestSsim
                bestSsim = ssimScore;
                bestLambda = lambdaVal;
                bestKappa = kappaVal;
                bestOption=option;
            end
            if niqeScore < bestNiqe
                bestNiqe = niqeScore;
                bestLambda = lambdaVal;
                bestKappa = kappaVal;
                bestOption=option;
            end
        end
        
        % Plot SSIM and NIQE for the current lambda and option
        figure;
        subplot(1, 2, 1); plot(t, ssims); title(['SSIM (lambda=', num2str(lambdaVal), ', option=', num2str(option), ')']);
        subplot(1, 2, 2); plot(t, niqes); title(['NIQE (lambda=', num2str(lambdaVal), ', option=', num2str(option), ')']);
    end
end

fprintf("Best SSIM: %.2f, with lambda=%.2f, kappa=%.2f and option:%.2f \n ", bestSsim, bestLambda, bestKappa,bestOption);
fprintf("Best NIQE: %.2f, with lambda=%.2f, kappa=%.2f and option:%.2f \n", bestNiqe, bestLambda, bestKappa, bestOption);


%% Cross-Validation for Iso

best_ssim = -Inf;
best_niqe = Inf;
best_lambda = 0;
best_constant = 0;

for lambdaVal = 0.05:0.05:0.2
    t = 1.1:0.05:2;
    ssims = [];
    niqes = [];
    for constantVal = 1.1:0.05:2
        isoImgDenoised = isodiff(imgNoisy, lambdaVal, constantVal);
        ssimScore = ssim(isoImgDenoised, img);
        niqeScore = niqe(isoImgDenoised);
        ssims = [ssims, ssimScore];
        niqes = [niqes, niqeScore];
%         fprintf("lambda=%.2f, c=%.2f, ", lambdaVal, constantVal);
%         fprintf("ssim=%.2f, niqe=%.2f\n", ssimScore, niqeScore);
        
        % finding the best SSIM and NIQE scores
        if ssimScore > best_ssim
            best_ssim = ssimScore;
            best_lambda = lambdaVal;
            best_constant = constantVal;
        end
        if niqeScore < best_niqe
            best_niqe = niqeScore;
            best_lambda = lambdaVal;
            best_constant = constantVal;
        end
    end
    figure;
        subplot(1, 2, 1); plot(t, ssims); title(['SSIM (lambda=', num2str(lambdaVal),')']);
        subplot(1, 2, 2); plot(t, niqes); title(['NIQE (lambda=', num2str(lambdaVal),')']);
end

fprintf("Best SSIM: %.2f, with lambda=%.2f and constant=%.2f\n", best_ssim, best_lambda, best_constant);
fprintf("Best NIQE: %.2f, with lambda=%.2f and constant=%.2f\n", best_niqe, best_lambda, best_constant);


%% Denoising
% Denoise the image using anisotropic diffusion
niter = 5;          % Number of iterations
kappa = 20;         % Conduction coefficient
lambda = 0.15;       % Maximum value for stability
option = 1;         % Diffusion equation No 2
anisoImgDenoised = anisodiff(imgNoisy, niter, kappa, lambda, option);

% Denoise the image using isotropic diffusion
lambda = 0.1;
constant = 1.8;
isoImgDenoised = isodiff(imgNoisy, lambda, constant);

subplot(2,2,1); imshow(img);
title(['Original image: SSIM=', num2str(ssim(img, img)), ', NIQE=', num2str(niqe(img))]);
subplot(2,2,2); imshow(imgNoisy);
title(['Noisy image: SSIM=', num2str(ssim(imgNoisy, img)), ', NIQE=', num2str(niqe(imgNoisy))]);

subplot(2,2,3); imshow(anisoImgDenoised);
title(['Aniso Denoised image: SSIM=', num2str(ssim(anisoImgDenoised, img)), ', NIQE=', num2str(niqe(anisoImgDenoised))]);
subplot(2,2,4); imshow(isoImgDenoised);
title(['Iso Denoised image: SSIM=', num2str(ssim(isoImgDenoised, img)), ', NIQE=', num2str(niqe(isoImgDenoised))]);




