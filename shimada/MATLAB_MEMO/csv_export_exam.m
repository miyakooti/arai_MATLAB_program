%% CSV�o�͕��@����

% ���炩�̃f�[�^�����[�h����
task = normalize_mean(:,:);
task2 = normalize_FC3(:,:);

% CSV�o�̓v���O����

% num2cell()�ɂ��A�z��f�[�^��cell�z��ɕϊ��ł���
Vname = {'Mean','FC3'};
data = [num2cell(task), num2cell(task2)];
C = [Vname;data];

writecell(C,'mydata1.csv')% �o��