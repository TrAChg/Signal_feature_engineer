function mpf = feat_mpf(Pxx, f)
% Formula:
%   MPF = M1 / M0 = ( integral f * PSD(f) df ) / ( integral PSD(f) df )
    df = f(2) - f(1);
    m0 = sum(Pxx) * df;
    m1 = sum(f .* Pxx) * df;
    mpf = m1 / m0;
end
