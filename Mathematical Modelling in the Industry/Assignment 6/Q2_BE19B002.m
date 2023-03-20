clear
clc
%References used: chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/viewer.html?pdfurl=https%3A%2F%2Fstaff.fnwi.uva.nl%2Fr.vandenboomgaard%2Fnldiffusionweb%2Fnldiffusioncode.pdf&clen=946779&chunk=true
%Image gradient: https://in.mathworks.com/help/matlab/ref/gradient.html
%More about Anisotropic diffusion:https://in.mathworks.com/matlabcentral/fileexchange/14995-anisotropic-diffusion-perona-malik

% Image 1 stores the original image 
image_1 = imread('cameraman.tif');
imshow(image_1);

% Image 2 stores the noisy image
image_2 = im2double(imnoise(image_1,'gaussian', 0, 0.02));
figure(1)
imshow(image_2)

% This is the filtered version of the image, using PM filtering with different contrast parameter values
for l = 0:3
    J = PM(image_2, 1.6, 20, 10^-l);
    disp(['Peak Signal-to-Noise Ratio for lambda: ', num2str(10^-l), ' is: ', num2str(psnr(J, im2double(image_1)))]);
    figure(2+l)
    imshow(J)
end


% Following is the estimation of optimal contrast parameter
[Gx, Gy] = imgradient(image_2);    %Calculating the gradient of the image
A = Gx.^2 + Gy.^2;  % Norm square of gradient at each pixel
[counts, bins] = imhist(A(:));  % counts, bins is the Histogram of the gradient matrix
cdf =sum(triu(counts(:)*ones(1,numel(counts))),1);   % Cumulative Distribution Function from the histogram
ncdf = cdf / cdf(size(bins, 1));    % Normalized CDF 
idx = find(ncdf >= 0.95);   % Indices for which CDF >= 95% 
optimal_lambda = bins(min(idx))    
J = PM(image_2, 1.4, 20, optimal_lambda);
figure
imshow(J)
psnr(J, im2double(image_1))

% Best stopping criteria
for i=0.1:0.2:2
    J = PM(image_2, i, 20, optimal_lambda);
    disp(['i=', num2str(i), '-PSNR: ' ,num2str(psnr(J, im2double(image_1)))])
end 

%Function for applying the PM filter
function J = PM(I, t, N_iter, l)
    dt = t / N_iter;
    K = zeros(size(I,1), size(I,2), N_iter+1);
    K(:, :, 1) = I;
    C = zeros(size(I,1), size(I,2), N_iter+1);
    
    % Computing c_ij at t=0
    C(2:length(C)-1, 2:length(C)-1, 1) = ones(size(I,1)-2, size(I,2)-2) ./ (ones(size(I,1)-2, size(I,2)-2) ...
        + (0.25/l^2)*((K(3:length(K), 2:length(K)-1, 1) - K(1:length(K)-2, 2:length(K)-1, 1)).^2 ...
        + (K(2:length(K)-1, 3:length(K), 1) - K(2:length(K)-1, 1:length(K)-2, 1)).^2));
    C(1, 2:length(C)-1, 1) = ones(1, size(I,2)-2) ./ (ones(1, size(I,2)-2) + (1/l^2)*((K(2, 2:length(K)-1, 1) - K(1, 2:length(K)-1, 1)).^2 ...
        + (K(1, 3:length(K), 1) - K(1, 2:length(K)-1, 1)).^2));      % Boundary
    C(length(C), 2:length(C)-1, 1) = ones(1, size(I,2)-2) ./ (ones(1, size(I,2)-2) + (1/l^2)*((K(length(K), 2:length(K)-1, 1) - K(length(K)-1, 2:length(K)-1, 1)).^2 ...
        + (K(length(K), 3:length(K), 1) - K(length(K), 2:length(K)-1, 1)).^2));  % Boundary
    C(2:length(C)-1, 1, 1) = ones(size(I, 1)-2, 1) ./ (ones(size(I, 1)-2, 1) + (1/l^2)*((K(3:length(K), 1, 1) - K(2:length(K)-1, 1, 1)).^2 ...
        + (K(2:length(K)-1, 2, 1) - K(2:length(K)-1, 1, 1)).^2));    % Boundary
    C(2:length(C)-1, length(C), 1) = ones(size(I, 1)-2, 1) ./ (ones(size(I, 1)-2, 1) + (1/l^2)*((K(3:length(K), length(K), 1) - K(2:length(K)-1, length(K), 1)).^2 ...
        + (K(2:length(K)-1, length(K)-1, 1) - K(2:length(K)-1, length(K), 1)).^2));  % Boundary

    for i = 1:N_iter
        % Image at next time step (inner nodes)
        K(2:length(K)-1, 2:length(K)-1, i+1) = K(2:length(K)-1, 2:length(K)-1, i) + 0.5*dt*...
            ((C(3:length(C), 2:length(C)-1, i) + C(2:length(C)-1, 2:length(C)-1, i)).*(K(3:length(K), 2:length(K)-1, i) - K(2:length(K)-1, 2:length(K)-1, i)) -...
            (C(2:length(C)-1, 2:length(C)-1, i) + C(1:length(C)-2, 2:length(C)-1, i)).*(K(2:length(K)-1, 2:length(K)-1, i) - K(1:length(K)-2, 2:length(K)-1, i)) +...
            (C(2:length(C)-1, 3:length(C), i) + C(2:length(C)-1, 2:length(C)-1, i)).*(K(2:length(K)-1, 3:length(K), i) - K(2:length(K)-1, 2:length(K)-1, i)) -...
            (C(2:length(C)-1, 2:length(C)-1, i) + C(2:length(C)-1, 1:length(C)-2, i)).*(K(2:length(K)-1, 2:length(K)-1, i) - K(2:length(K)-1, 1:length(K)-2, i)));
        % Boundary conditions
        K(1, 2:length(K)-1, i+1) = K(2, 2:length(K)-1, i+1);
        K(length(K), 2:length(K)-1, i+1) = K(length(K)-1, 2:length(K)-1, i+1);
        K(2:length(K)-1, 1, i+1) = K(2:length(K)-1, 2, i+1);
        K(2:length(K)-1, length(K), i+1) = K(2:length(K)-1, length(K)-1, i+1);
        K(1, 1, i+1) = 0;
        K(1, length(K), i+1) = 0;
        K(length(K), 1, i+1) = 0;
        K(length(K), length(K), i+1) = 0;
        % C_ij for the next time step
        C(2:length(C)-1, 2:length(C)-1, i+1) = ones(size(I,1)-2, size(I,2)-2) ./ (ones(size(I,1)-2, size(I,2)-2) ...
            + (0.25/l^2)*((K(3:length(K), 2:length(K)-1, i+1) - K(1:length(K)-2, 2:length(K)-1, i+1)).^2 ...
            + (K(2:length(K)-1, 3:length(K), i+1) - K(2:length(K)-1, 1:length(K)-2, i+1)).^2));
            % C_ij at boundaries
        C(1, 2:length(C)-1, i+1) = ones(1, size(I,2)-2) ./ (ones(1, size(I,2)-2) + (1/l^2)*(K(1, 3:length(K), i+1) - K(1, 2:length(K)-1, i+1)).^2);
        C(length(C), 2:length(C)-1, i+1) = ones(1, size(I,2)-2) ./ (ones(1, size(I,2)-2) + (1/l^2)*(K(length(K), 3:length(K), i+1) - K(length(K), 2:length(K)-1, i+1)).^2);
        C(2:length(C)-1, 1, i+1) = ones(size(I, 1)-2, 1) ./ (ones(size(I, 1)-2, 1) + (1/l^2)*(K(3:length(K), 1, i+1) - K(2:length(K)-1, 1, i+1)).^2);
        C(2:length(C)-1, length(C), i+1) = ones(size(I, 1)-2, 1) ./ (ones(size(I, 1)-2, 1) + (1/l^2)*(K(3:length(K), length(K), i+1) - K(2:length(K)-1, length(K), i+1)).^2);
    end
    J = K(:, :, length(K)); %gives the final image at the end time t.
end