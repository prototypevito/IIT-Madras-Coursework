%the function used for comparing two matrices in matlab was taken from:
%https://www.mathworks.com/matlabcentral/answers/137776-comparing-two-matrix-in-matlab

clear
clc

%image1 has the cameraman image. 
image1 = imread('cameraman.tif');
imshow(image1);

%image2 = imread('peppers.png');
%imshow(image2);

%image2 has the noisy image of image1
image2 = im2double(imnoise(image1,'gaussian', 0, 0.02));
figure(1)
imshow(image2)

%Question 1,2,3,4 are in this block of the code. 
%You can find the image reconstructions upon running the file. 
%The PSNRs are also printed out for different values of sigma.
%The sigma values I have chosen are 0.1 to 1.5, with step size of 0.1
for sigma = 0.1:0.1:1.5
    J = linear_diffusion(image2, sigma);
    disp(['the peak Signal-to-Noise Ratio for sigma= ', num2str(sigma), 'is: ', num2str(psnr(J, im2double(image1)))])
    figure
    imshow(J)
end


%This is for the fifth part of the question: Verifying the properties of linear diffusion. The two images are compared within a tolerance range.
%The tolerance for every property is taken as 0.05.
%The properties are tested for in the order:
%Scale Invariance
%Translation invariance
%Gray level shift
%Conservation of average value
%Isometry Invariance
%Comparison Principle
%semigroup property
% Scale invariance
disp('Scale invariance:')
LHS = linear_diffusion(imresize(image2, 2), sigma);
R_ = linear_diffusion(image2, 2*sigma);
RHS = imresize(R_, 2);
absError = abs(LHS - RHS);
isequalRel(LHS, RHS, 0.05);

% Translation invariance
disp('Translation invariance:')
LHS = linear_diffusion(circshift(image2, 5, 1), sigma);
R_ = linear_diffusion(image2, sigma);
RHS = circshift(R_, 5, 1);
isequalRel(LHS, RHS, 0.05);

%Gray level shift
disp('Gray level shift:')
LHS = linear_diffusion(image2 + 2*ones(size(image2)), sigma);
R_ = linear_diffusion(image2, sigma);
RHS = R_ + 2*ones(size(image2));
isequalRel(LHS, RHS, 0.05);

% Conservation of average value
disp('Conservation of average value:')
LHS = linear_diffusion(mean(image2), sigma);
R_ = linear_diffusion(image2, sigma);
RHS = mean(R_);
isequalRel(LHS, RHS, 0.05);


% Semigroup property
disp('Semigroup property:')
t = 1;
LHS = linear_diffusion(image2, sqrt(2*(sigma+t)));
R_ = linear_diffusion(image2, sqrt(2*sigma));
RHS = linear_diffusion(R_, sqrt(2*t));
isequalRel(LHS, RHS, 0.05);

% Isometry invariance
disp('Isometry invariance:')
LHS = linear_diffusion(image2.', sigma);
R_ = linear_diffusion(image2, sigma);
RHS = R_.';
isequalRel(LHS, RHS, 0.05);




% Comparison Principle
disp('Comparison Principle:')
LHS = linear_diffusion(image2, sigma);
R_ = linear_diffusion(image2 + 5*ones(size(image2)), sigma);
RHS = R_;
C = RHS > LHS;
if isequal(C,ones(size(C)))
    disp('Comparison Principle true')
else
    disp('Comparison Principle failed')
end 

%defining the linear diffusion function
function J = linear_diffusion(I, sigma)
    J = imgaussfilt(I, sigma); 
end

%The function to compare the two images using a tolerance range from isequalRel.The third argument in the function is the tolerance.
function test = isequalRel(x,y,tolerance)
    test = ( abs(x-y) <= ( tolerance*max(abs(x),abs(y)) + eps) );
    if all(test)
        disp("True")
    else
        disp("fail");
    end
end
