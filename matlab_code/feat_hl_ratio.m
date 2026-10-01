function hl_ratio = feat_hl_ratio(Pxx, f, low_band, high_band)
% Formula:
%   H/L = ( integral_{f_H1}^{f_H2} PSD(f) df ) / ( integral_{f_L1}^{f_L2} PSD(f) df )

    if nargin < 3 || isempty(low_band)
        low_band = [20, 150];
    end
    if nargin < 4 || isempty(high_band)
        high_band = [150, 450];
    end

    idx_L = (f >= low_band(1)) & (f <= low_band(2));
    idx_H = (f >= high_band(1)) & (f <= high_band(2));
    
    e_low = trapz(f(idx_L), Pxx(idx_L));
    e_high = trapz(f(idx_H), Pxx(idx_H));
    
    hl_ratio = e_high / (e_low + eps);
end
