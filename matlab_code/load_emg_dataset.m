function [signals, labels, Fe, filenames] = load_emg_dataset(data_dir)
    if nargin < 1 || isempty(data_dir)
        % Check local or parent directories
        if exist('EMG_database', 'dir')
            data_dir = 'EMG_database';
        elseif exist(fullfile('..', 'EMG_database'), 'dir')
            data_dir = fullfile('..', 'EMG_database');
        else
            error('EMG_database folder could not be found.');
        end
    end

    Fe = 10000; % 10 kHz
    N_files = 20;
    signals = cell(1, N_files);
    filenames = cell(1, N_files);
    labels = [zeros(1, 10), ones(1, 10)]; % 0: Class 1, 1: Class 2

    for i = 1:N_files
        fname = fullfile(data_dir, sprintf('EMG%d.mat', i));
        if ~exist(fname, 'file')
            error('File not found: %s', fname);
        end
        loaded = load(fname);
        signals{i} = loaded.EMG(:); % Store as column vector
        filenames{i} = fname;
    end
end
