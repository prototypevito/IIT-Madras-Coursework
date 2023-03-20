clear
clc

%storing the original image
image_1 = imread('cameraman.tif');
imshow(image_1);

%storing the noisy image 
image_2 = im2double(imnoise(image_1,'gaussian', 0, 0.04));
figure(1)
imshow(image_2)

%we fix the sigma to be 1 as mentioned
sig = 1;
for l = 0:4
	J = Catte(image_2, 1, 15, 10^-l, sig);
	disp(['Peak Signal-to-Noise Ratio for lambda=', num2str(10^-l),' & sigma=', num2str(sig),' is: ', num2str(psnr(J, im2double(image_1)))]);
	figure(2+l)
    imshow(J)
end

function J = Catte(I, t, N_iter, cp, sigma)
    dt = t / N_iter;
    K = zeros(size(I,1), size(I,2), N_iter+1);
    K(:, :, 1) = I;
    C = zeros(size(I,1), size(I,2), N_iter+1);

    for i = 1:N_iter
        % Calculating c at time t=i*dt
        Kg = imgaussfilt(K(:, :, i), sigma);
        C(2:length(C)-1, 2:length(C)-1, i) = ones(size(I,1)-2, size(I,2)-2) ./ (ones(size(I,1)-2, size(I,2)-2) ...
            + (0.25/cp^2)*((Kg(3:length(Kg), 2:length(Kg)-1) - Kg(1:length(Kg)-2, 2:length(Kg)-1)).^2 ...
            + (Kg(2:length(Kg)-1, 3:length(Kg)) - Kg(2:length(Kg)-1, 1:length(Kg)-2)).^2));
        C(1, 2:length(C)-1, i) = ones(1, size(I,2)-2) ./ (ones(1, size(I,2)-2) + (1/cp^2)*((Kg(2, 2:length(Kg)-1) - Kg(1, 2:length(Kg)-1)).^2 ...
            + (Kg(1, 3:length(Kg)) - Kg(1, 2:length(Kg)-1)).^2));      
        C(length(C), 2:length(C)-1, i) = ones(1, size(I,2)-2) ./ (ones(1, size(I,2)-2) + (1/cp^2)*((Kg(length(Kg), 2:length(Kg)-1) - Kg(length(Kg)-1, 2:length(Kg)-1)).^2 ...
            + (Kg(length(Kg), 3:length(Kg)) - Kg(length(Kg), 2:length(Kg)-1)).^2)); 
        C(2:length(C)-1, 1, i) = ones(size(I, 1)-2, 1) ./ (ones(size(I, 1)-2, 1) + (1/cp^2)*((Kg(3:length(Kg), 1) - Kg(2:length(Kg)-1, 1)).^2 ...
            + (Kg(2:length(Kg)-1, 2) - Kg(2:length(Kg)-1, 1, 1)).^2));    
        C(2:length(C)-1, length(C), i) = ones(size(I, 1)-2, 1) ./ (ones(size(I, 1)-2, 1) + (1/cp^2)*((Kg(3:length(Kg), length(Kg)) - Kg(2:length(Kg)-1, length(Kg))).^2 ...
            + (Kg(2:length(Kg)-1, length(Kg)-1) - Kg(2:length(Kg)-1, length(Kg))).^2)); 
    
        % Image at time step i+1
        K(2:length(K)-1, 2:length(K)-1, i+1) = K(2:length(K)-1, 2:length(K)-1, i) + 0.5*dt*...
            ((C(3:length(C), 2:length(C)-1, i) + C(2:length(C)-1, 2:length(C)-1, i)).*(K(3:length(K), 2:length(K)-1, i) - K(2:length(K)-1, 2:length(K)-1, i)) -...
            (C(2:length(C)-1, 2:length(C)-1, i) + C(1:length(C)-2, 2:length(C)-1, i)).*(K(2:length(K)-1, 2:length(K)-1, i) - K(1:length(K)-2, 2:length(K)-1, i)) +...
            (C(2:length(C)-1, 3:length(C), i) + C(2:length(C)-1, 2:length(C)-1, i)).*(K(2:length(K)-1, 3:length(K), i) - K(2:length(K)-1, 2:length(K)-1, i)) -...
            (C(2:length(C)-1, 2:length(C)-1, i) + C(2:length(C)-1, 1:length(C)-2, i)).*(K(2:length(K)-1, 2:length(K)-1, i) - K(2:length(K)-1, 1:length(K)-2, i)));
        % Boundary conditions for the diffusion
        K(1, 2:length(K)-1, i+1) = K(2, 2:length(K)-1, i+1);
        K(length(K), 2:length(K)-1, i+1) = K(length(K)-1, 2:length(K)-1, i+1);
        K(2:length(K)-1, 1, i+1) = K(2:length(K)-1, 2, i+1);
        K(2:length(K)-1, length(K), i+1) = K(2:length(K)-1, length(K)-1, i+1);
        K(1, 1, i+1) = 0;
        K(1, length(K), i+1) = 0;
        K(length(K), 1, i+1) = 0;
        K(length(K), length(K), i+1) = 0;
    end
    J = K(:,:,length(K));
end

%As shown by the results, we get that linear diffusion is the worst type of diffusion amongst all, as the psnr value for the linear diffusion model is the least. 