%calcPLI_1s1を一気に回すスクリプト
%MにKinectとの同期時間を代入
mats = dir("data/**/*.mat");
keySet = ["kumakura_rest","kumakura_practice",...
           ];
valueSet = [0, 7636,...
            ];

M = containers.Map(keySet,valueSet);

for i=1:length(mats)
    path = strcat(mats(i).folder,"/", mats(i).name);
    load(path);
    if ~ismember(subject, keySet)
        continue
    end
    disp(subject); 
    disp(M(subject));
    bunsekikaisiten = M(subject);
    run("calcPLI_1s");
end
