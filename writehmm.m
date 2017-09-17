function writehmm(file, hmms)
%WRITEHMM write hmm features in HTK format []=writehmm(file, hmms)
%
% Only works on text files.
% Only works for Gaussian emissions with diagonal covariance.
%
% Input:
%    hmms = 
%                 name : 'word'
%              nstates : 20
%        emission_type : 'gaussian'
%                means : [24x20 double]
%               covars : [24x20 double]
%           start_prob : [1x20 double]
%             transmat : [20x20 double]
%             end_prob : [20x1 double]
%
% History
%    make this file(Corresponding Only single gaussian)

    % hmm information arrange
    name=hmms.name;
    dim=size(hmms.means, 1);
    nstates=hmms.nstates+2;    % include dummy state
    type=hmms.emission_type;
    SOARCEKIND='<NULLD><USER><DIAGC>';

    means=hmms.means;
    covars=hmms.covars;
    gconsts=hmms.gconsts;

    TransP=exp([hmms.start_prob -Inf; hmms.transmat hmms.end_prob]);
    TransP=[zeros(nstates-1, 1) TransP; zeros(1,nstates)];

    % open target file
    fid = fopen(file, 'wt');
    if fid < 0; error( sprintf('Cannot read from %s', file) ); end

        % write header
        fprintf(fid,'~o\n');
        fprintf(fid,'<STREAMINFO> 1 %d\n', dim);
        fprintf(fid,'<VECSIZE> %d%s\n', dim, SOARCEKIND);
        fprintf(fid,'~h "%s"\n', hmms.name);
        fprintf(fid,'<BEGINHMM>\n');
        fprintf(fid,'<NUMSTATES> %d\n',nstates);

        % write STATES
        makeStates(fid, means, covars, gconsts);

        % write TransP
        makeTransP(fid, TransP);

        % write footer
        fprintf(fid,'<ENDHMM>\n');

    % close file discripter    
    fclose(fid);

end % function writehmm(file, hmms)

% -----------------------------------------------

function makeStates(fid, means, covars, gconsts)
% write STATE
    
    % definition
    dim=size(means, 1);
    nstates=size(means, 2);

    for s=1:nstates
        % STATE HEADER
        fprintf(fid,'<STATE> %d\n',s+1);

        % mean
        fprintf(fid,'<MEAN> %d\n',dim);
        for d=1:dim fprintf(fid,' %1.6e',means(d, s)); end % d
        fprintf(fid,'\n');

        % covariance
        fprintf(fid,'<VARIANCE> %d\n',dim);
        for d=1:dim fprintf(fid,' %1.6e',covars(d ,s)); end
        fprintf(fid,'\n');

        % GCONST
        % calculate
        g1=dim*log(2*pi);
        g2=0;
        for d=1:dim g2=g2 + log(covars(d, s)); end
        gconst=g1+g2;
        fprintf(fid,'<GCONST> %e\n', gconst);

        % get from hmmfile
        % fprintf(fid,'<GCONST> %e\n',gconsts(s));
     end % ii

end %

% -----------------------------------------------

function makeTransP(fid, TransP)
% write Transition Probability
    
    % definition
    nstates=size(TransP, 1);
    
    % TransP Header
    fprintf(fid,'<TRANSP> %d\n',nstates);

    % TransP Values
    for ii=1:nstates
        for jj=1:nstates
            fprintf(fid,' %1.6e', TransP(ii, jj));
        end % jj
        fprintf(fid,'\n');
    end % ii

end %
