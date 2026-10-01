function spec_kurt = feat_spec_kurtosis(Pxx, f)
% Formula:
%   Spec_Kurt = M_4^* / (M_2^*)^2
    df = f(2) - f(1);
    m0 = sum(Pxx) * df;
    m1 = sum(f .* Pxx) * df;
    mpf = m1 / m0;
    
    m2_c = sum((f - mpf).^2 .* Pxx) * df;
    m4_c = sum((f - mpf).^4 .* Pxx) * df;
    if m2_c >0
    spec_kurt = m4_c / (m2_c^2);
end
