function kr = feat_kurtosis(x)
%   Kr = ( (1/N) * sum((x - mu).^4) ) / ((sigma^4): maybe) - 3
    x = x(:);
    mu = mean(x);
    sigma = std(x, 1);
    kr = mean((x - mu).^4) / (sigma^4) - 3;
end
