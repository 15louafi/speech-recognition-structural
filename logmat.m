function logmat(inputDir,outputDir)
    myFiles = dir(fullfile(inputDir,'*.mfcc'));
    for k = 1:length(myFiles)
        baseFileName = myFiles(k).name;
        disp(baseFileName);
        fullFileName = fullfile(inputDir, baseFileName);
        [d,fp,dt,tc,t]=readhtk(fullFileName);
        
        B = arrayfun(@(x) log(x), d);
        s = strcat(outputDir,baseFileName);
        writehtk(s,B,fp,tc);
    end
    
   