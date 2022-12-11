%% トリガーdiffの出�?
% 

%これでファイルの名前を決めて
s = sprintf('trigger_diff_%s_%s.csv', nowtime, subject);
disp(s);
%export(trg_index0, 'File', 'trigger_20211215T180038.csv','Delimiter',',');

%これでファイルの名前を書き換えてから保存す�?
csvwrite('C:\Users\YairiLAB\Desktop\ito_MATLAB_program\trg_csv/trigger_diff_20220309T160759_rinako.csv', diff0);