close all
clear all
clc
%% Loading Functions
addpath('C:\Users\asus\Desktop\MIAP_HW4\Q1\Functions'); % if you want to run the code, please change the path

%% Part 1.1
data=load("data.mat");
imageMask=data.imageMask;
imageData=data.imageData;
scaledData = mat2gray(imageData);
imwrite(scaledData, 'imageData.jpg');
scaledData = mat2gray(imageMask);
imwrite(scaledData, 'imageMask.jpg');
%% Part 1.2 and 1.3
%{
Description: Returns the initial segmentation using K-means algorithm
Inputs:
    img  : The input image
    mask : The background mask
    k    : The number of classes to segment into
    eps  : We stop the iterations when |loss_new - loss_prev|/loss_prev <= eps 
Outputs:
    seg   : The segmented image, each pixel \in {1,...,k}
    mu    : k-vector with the class means
    sigma : k-vector with the class std devs
%}
k=3;
q=5;
bConst=1;
[R, C] = size(imageMask);
bInit=(bConst * ones(R, C)) .* imageMask;
kerSize=9;
gaussianKernel=fspecial('gaussian',kerSize,2.5);
eps=1e-7;
[seg, mu, sigma] = KMeans(imageData, imageMask, k, eps);
figure;
path = 'K-Means Result';
title_str = 'K-Means Result';
showSegmented(seg, k, title_str, path);
%% Part 1.4
%{
Description: Runs the specified algorithm / Driver class for the algorithm
Inputs:
    img : The corrupted image
    mask: The background mask
    u   : The class memberships
    b   : The bias field
    c   : The class means
    q   : The q-parameter as specified in the slides
    w   : The neighbourhood mask
    J_init : The initial value of the loss function
    eps : Specifes when the algorithm stops the iterations
    N_max : Maximum number of iterations to run for in any case 
Outputs:
    u   : The updated class memberships
    b   : The updated bias field
    c   : The updated class means
    J   : Array that stores the loss function values for each iteration
%}
u = zeros(R, C, k);
for i=1:k
    u(:, :, i) = (seg == i);
end
b = bInit;      
c = mu;   
q = 5;
w = gaussianKernel; 
J_init = objectiveFunction(imageData, b, c, q, u, w); % Initial value of the loss function
eps = 1e-5;
N_max = 200;
[u, b, c, J] = iterate(imageData, imageMask, u, b, c, q, w, J_init, eps, N_max);
biasRemovedImage = imageMask .* imageData ./ b;
figure;
plot(1:N_max, J);
title(['Objective Function (N=', num2str(N_max), ')']);
xlabel('Number of Itteration')
ylabel('J')
grid minor;
figure;
path = 'Segmentation Result';
title_str = 'Segmented Image';
showSegmented(u, 1, title_str, path);
%% Showing the Results
figure;
imshow(imageData);
title('Corrupted Image');
figure;
fig = imshow(b);
title('Bias Field');
saveas(fig, 'BiasRemovedField', "jpg");
figure;
fig = imshow(biasRemovedImage);
title('Bias Removed Image');
saveas(fig, 'BiasRemovedImage', "jpg");
figure;
showSegmented(seg, k, 'Initial Image: using K-Means', 'K-Means Result');
figure;
showSegmented(u, 1, 'Segmented Image', 'SegmentedImage');
figure;
fig = imshow(imageData - imageMask .* imageData);
title('Residual Image');
saveas(fig, 'ResidualImage', "jpg");

