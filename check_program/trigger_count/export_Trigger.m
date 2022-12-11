%% トリガーの出�?
% trg_index0は綺麗じ�?な�?ので、�?�力してまた綺麗にする

s = sprintf('trigger_%s_%s.csv', nowtime, subject);
disp(s);
%export(trg_index0, 'File', 'trigger_20211215T180038.csv','Delimiter',',');

csvwrite('C:\Users\YairiLAB\Desktop\ito_MATLAB_program\trg_csv\trigger_20220309T160759_rinako.csv', trg_index0);