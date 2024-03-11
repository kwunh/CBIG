function [group_FC, group_FCD_CDF] = CBIG_pFIC_generate_PNC_group_level_FC_FCD(TC_path, subject_list)

% [group_FC, group_FCD_CDF] = CBIG_pFIC_generate_PNC_group_level_input(TC_path, subject_list)
% This function generates a group-level FC and FCD from the GUSTO dataset. 
% Note that this function requires access to the subject's time
% series data, which are not open to public under the DUA. Thus this
% function is for CBIG internal usage only.
%
% Input:
%   - TC_path: an absolute path to the directory containing subject time series
%   - subject_list: the path to the subject list
% Output:
%   - group_FC: a 68-by-68 group-level, session-specific FC
%   - group_FCD_CDF: a 10000-by-1 group-level FCD culumative distribution function (CDF)
%
% Example:
% [group_FC, group_FCD_CDF] = ...
%   CBIG_pFIC_generate_PNC_group_level_FC_FCD['/isilon/CSC1/Yeolab/Data/PNC/' ... 
%   'desikan_tc_from_vol/rest'], ('/replication/PNC/age_effect/input/1/training_subject_list.txt')
%
% Written by Shaoshi Zhang and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

fid = fopen(subject_list, 'r');
stringPattern = textscan(fid,'%s');
fclose(fid);
subject_list = string(stringPattern{:});

%% initialize group-level FC and FCD_CDF
FC_all = zeros(68, 68, length(subject_list));
FCD_all = zeros(length(subject_list), 10000);

% group-level FC requires Fisher transformation before averaging
for i = 1:length(subject_list)
   subject = convertStringsToChars(subject_list(i));
   disp(['Processing id: ' subject '...'])
   [FC, FCD_CDF] = CBIG_pFIC_generate_PNC_subject_level_FC_FCD(TC_path, subject);
   FC_all(:, :, i) = CBIG_StableAtanh(FC);
   FCD_all(i, :) = FCD_CDF;
end

group_FC = tanh(mean(FC_all, 3));
group_FCD_CDF = mean(FCD_all);
group_FCD_CDF = round(group_FCD_CDF);

end