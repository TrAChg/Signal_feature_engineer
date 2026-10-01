function m0 = feat_spectral_power(Pxx, f)
% Formula:
%   M0 = integral_0^{f_max} PSD(f) df
    df = f(2) - f(1);
    m0 = sum(Pxx) * df;
end
