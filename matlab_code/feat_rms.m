function rms_val = feat_rms(x)
    x = x(:);
    rms_val = sqrt(mean(x.^2));
end
