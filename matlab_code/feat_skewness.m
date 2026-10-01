function sk = feat_skewness(x)
% Formula:
%   Sk = ( (1/N) * sum((x - mu).^3) ) / ((sigma^3): perhaps)
    x = x(:);
    mu = mean(x);
    sigma = std(x, 1); 
    if sigma < 1e-12
        sigma = 1e-12;
    end
    sk = mean((x - mu).^3) / (sigma^3);
end
