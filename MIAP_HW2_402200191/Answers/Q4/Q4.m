close all
clear 
clc
%% A
phantomImg = phantom('Modified Shepp-Logan',500);
noisyPhantom=imnoise(phantomImg,'gaussian',0,0.0025);
% plot

figure()
subplot(1,2,1);
imshow(phantomImg);
title("Phantom image");
subplot(1,2,2)
imshow(noisyPhantom);
title("Phantom noisy image");

%% B
filteredPhantom=totalVariation(noisyPhantom,0.01,10,100);
figure()
subplot(1,3,1);
imshow(phantomImg);
title("Phantom image");
subplot(1,3,2)
imshow(noisyPhantom);
title("Phantom noisy image");
subplot(1,3,3)
imshow(filteredPhantom);
title("Phantom noisy image after total variation with dt=0.01");

%% B_2
filteredPhantom2=totalVariation(noisyPhantom,0.001,2,100);
figure()
subplot(1,3,1);
imshow(phantomImg);
title("Phantom image");
subplot(1,3,2)
imshow(noisyPhantom);
title("Phantom noisy image");
subplot(1,3,3)
imshow(filteredPhantom2);
title("Phantom noisy image after total variation with dt=0.001");

%% C
SNR_TV=SNR(phantomImg,filteredPhantom);
SNR_noise=SNR(phantomImg,noisyPhantom);
SNR_TV2=SNR(phantomImg,filteredPhantom2);
disp(['SNR for filtered phantom image: ', num2str(SNR_TV)]);
disp(['SNR for noisy phantom image: ', num2str(SNR_noise)]);
disp(['SNR for filtered phantom2 image: ', num2str(SNR_TV2)]);
%% Function
function output=totalVariation(img,dt,lambda,itNumber)
u_old=img;
[n,m]=size(img);
deltaPosX=zeros([n,m]);
deltaNegX=zeros([n,m]);
deltaPosY=zeros([n,m]);
deltaNegY=zeros([n,m]);
for it=1:itNumber
    deltaPosX(1:end - 1,:)=u_old(2:end,:)-u_old(1:end-1,:);
    deltaNegX(2:end,:)=u_old(2:end,:) - u_old(1:end -1 ,:);
    deltaPosY(:,1:end - 1)= u_old(:,2:end) - u_old(:,1:end - 1);
    deltaNegY(:,2:end) = u_old(:,2:end) - u_old(:,1:end - 1);

    numerator1=deltaPosX .*u_old;
    numerator2=deltaPosY .* u_old;

    mX= (sign(deltaPosX .*u_old) + sign(deltaNegX .* u_old)) .*(min(abs(deltaPosX .*u_old),abs(deltaNegX .* u_old)));
    mY= (sign(deltaPosY .*u_old) + sign(deltaNegY .* u_old)) .*(min(abs(deltaPosY .*u_old),abs(deltaNegY .* u_old)));
    denum1= sqrt((deltaPosX .* u_old).^2 + mY.^2 + eps);
    denum2=sqrt((deltaPosY .* u_old).^2 + mX.^2 + eps);
    temp1= numerator1./denum1;
    temp2= numerator2 ./denum2;
    finalTemp1=zeros([n,m]);
    finalTemp2=zeros([n,m]);
    finalTemp1(2:end,:)= temp1(2:end,:) - temp1(1:end-1,:);
    finalTemp2(:,2:end)=temp2(:,2:end) - temp2(:,1:end-1);
    u_new=u_old + dt*(finalTemp1 + finalTemp2) + dt*lambda*(img - u_old);


    u_new(1,:)=u_new(2,:);
    u_new(:,1)=u_new(:,2);
    u_new(end,:)=u_new(end-1,:);
    u_new(:,end) = u_new(:,end-1);
    u_old=u_new;
end
output = u_old;
end

function snr = SNR( X , Y)
x2 = X .* X;
temp1 = sum(x2,'all');
x_y =( X - Y).^2;
temp2 = sum(x_y , 'all');
snr = 10 * log( temp1 / temp2)/log(10);
end