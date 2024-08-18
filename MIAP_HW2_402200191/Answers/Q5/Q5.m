clear
close all
clc
%% A
img = imread('TV.png');
img = im2double(img);
noisyImg = imnoise(img, 'gaussian', 0.01);
w1 = zeros(size(noisyImg));
w2 = zeros(size(noisyImg));   
maxIterations = 100;
tolerance = 1e-4;
verbose = true;


%% Cross-Validation to find hyperparameters
% This part takes time be patient or instead you can set the parameters
% manually for next section
% the best parameters are optimizedalpha=0.17 and optimizedlamda=16.8
mseMin=10000;
optimiezedLamda=0;
optimiezedAlpha=0;
for i_lambda = 14:0.2:18
    for i_alpha = 0.01:0.02:0.21
        [u_GPCL, ~, ~, ~, ~, ~, ~] = ...
            TV_Chambolle(w1, w2, noisyImg, i_lambda, i_alpha, maxIterations, tolerance, 0);

        mse = sum((u_GPCL - img) .^ 2, 'all');
        mse
        if mse < mseMin
            mseMin=mse;
            optimiezedAlpha=i_alpha;
            optimiezedLamda=i_lambda;
        end
    end
end
fprintf('Optimized alpha is: %f , optimized lambda: %f and min mse: %f \n', optimiezedAlpha,optimiezedLamda,mseMin);

%% Results
[u_GPCL, ~, ~, Energy_GPCL, Dgap_GPCL, ~, iter_GPCL] = ...
    TV_GPCL(w1, w2, noisyImg, optimiezedLamda, optimiezedAlpha, maxIterations, tolerance, verbose);

[u_Chambolle, ~, ~, Energy_Chambolle, Dgap_Chambolle, ~, iter_Chambolle] = ...
    TV_Chambolle(w1, w2, noisyImg, optimiezedLamda, optimiezedAlpha, maxIterations, tolerance, verbose);

figure;
subplot(2, 4, 1);
imshow(img);
title('Original Image');
subplot(2, 4, 2);
imshow(noisyImg);
title(['Noisy Image, PSNR=', num2str(psnr(noisyImg, img))]);

subplot(2, 4, 3);
imshow(u_GPCL);
title(['Denoised by TV\_GPCL, PSNR=', num2str(psnr(u_GPCL, img))]);

subplot(2, 4, 4);
imshow(u_Chambolle);
title(['Denoised by TV\_Chambolle, PSNR=', num2str(psnr(u_Chambolle, img))]);

subplot(2, 4, 5);
semilogx(0:iter_GPCL, Energy_GPCL);
xlabel('Iteration');
ylabel('Energy');
title('Objective Function (TV\_GPCL)');

subplot(2, 4, 6);
semilogx(0:iter_GPCL, Dgap_GPCL);
xlabel('Iteration');
ylabel('Duality Gap');
title('Duality Gap (TV\_GPCL)');

subplot(2, 4, 7);
semilogx(0:iter_Chambolle, Energy_Chambolle);
xlabel('Iteration');
ylabel('Energy');
title('Objective Function (TV\_Chambolle)');

subplot(2, 4, 8);
semilogx(0:iter_Chambolle, Dgap_Chambolle);
xlabel('Iteration');
ylabel('Duality Gap');
title('Duality Gap (TV\_Chambolle)');