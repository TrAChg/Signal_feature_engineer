function spec_skew = feat_spec_skewness(Pxx, f)
%   Spec_Skew = M_3^* / (M_2^*)^(3/2)
    df = f(2) - f(1);
    m0 = sum(Pxx)*df;
    m1 = sum(f .* Pxx)*df;
    mpf = m1 / (m0 + eps);
    
    m2_c = sum((f - mpf).^2 .* Pxx) * df;
    m3_c = sum((f - mpf).^3 .* Pxx) * df;
    
    spec_skew = m3_c / (m2_c^1.5);
end
