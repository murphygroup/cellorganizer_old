function [I_out]= del2_2d(I_input)
% the discrete laplacian operation for a 2d image. This function is faster
% than the built-in one. 
% Authore: xruan 
% Date: 05/20/2016

    if ndims(I_input) ~= 2
        error('the input image must be in 2d');
    end

    [l, m] = size(I_input);

    f = I_input;

    gr = zeros(l, m);

    gr(2 : l - 1, :) = (diff(f(2 : l, :), 1, 1) - diff(f(1 : l - 1, :), 1, 1)) ./ 2;

    gr(1, :) = gr(2, :) .* 2 - gr(3, :);
    gr(l, :) = gr(l - 1, :) * 2 - gr(l - 2, :);

    gc = zeros(l, m);

    gc(:, 2 : m - 1) = (diff(f(:, 2 : m), 1, 2) - diff(f(:, 1 : m - 1), 1, 2)) ./ 2;

    gc(:, 1) = gc(:, 2) .* 2 - gc(:, 3);
    gc(:, m) = gc(:, m - 1) * 2 - gc(:, m - 2);

    I_out = (gr + gc) / 2;


end
