%export_PLIを一気に回すスクリプト
mats = dir("data/**/*.mat");
keySet = ["kumakura_rest","kumakura_practice",...
           ];

for i=1:length(mats)
    path = strcat(mats(i).folder,"/", mats(i).name);
    load(path);
    if ~ismember(subject, keySet)
        continue
    end

    run("export_PLI");
end
