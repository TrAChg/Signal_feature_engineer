function fmed = feat_fmed(Pxx, f)
%   integral_0^{fmed} PSD(f) df = (1/2) * integral_0^{f_max} PSD(f) df

    df = f(2) - f(1);
    m0 = sum(Pxx) * df;
    cum_power = cumsum(Pxx) * df; % [Pxx(1), Pxx(1)+Pxx(2),...] * df    
    idx_med = find(cum_power >= m0 / 2.0, 1, 'first');
    if isempty(idx_med)
        fmed = f(end);
    else
        fmed = f(idx_med);
    end
end
