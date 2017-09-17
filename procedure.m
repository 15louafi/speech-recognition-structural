function procedure(inputDir,outputRoot,dim,blockSize)
% 
% USING: hmm2str.m, structure.m, readhmm.m, bhattacharyya.m

tic
    % directories
    outputDir=strcat(outputRoot,'/block',num2str(blockSize),'/')
    mkdir(outputDir);

    % structure parameters
    useDim=[1:12];

    % read directory
    tmp=dir(inputDir);

    l=1;
    for k=1:length(tmp)
        [path, name, ext]=fileparts(tmp(k).name); % divide filename
        if strcmp(ext, '.hmm') list{l}=name; l=l+1; end % if
    end % k

    % run hmm2str & output strVec to outputDir
    for l=1:length(list)
        inputfile=strcat(inputDir, list(l), '.hmm');
        %%calculate by multistream
        strVec=hmm2str(inputfile{1}, dim, blockSize, useDim);
        %%calculate by Energy
        strVec_E=hmm2str(inputfile{1},dim,1,13);
        
        strVec=[strVec,strVec_E];
        outfile=strcat(outputDir, list(l), '.str');
        fid=fopen(outfile{1}, 'wt');
            fprintf(fid, '%f', strVec(1));
            for d=2:length(strVec) fprintf(fid, ' %f', strVec(d)); end % d
        fclose(fid);
        [path, name, ext]=fileparts(outfile{1});
        fprintf('%s is done.\n',name);
    end % l
toc
end % function
