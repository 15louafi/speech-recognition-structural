function ml2MAP(train_scp,convert_scp)
tic
%
% USING:
% readhmm.m, writehmm.m, split.m
% 

    % definition
    weight=1;    % weight of commonParams
%    train_scp='tmp.scp';
%    convert_scp='tmp2.scp';
    del_scp=' ';

    % get common parameters for MAP adaptation
    [mu_0, Sigma_0, Omega]=calc_commonParams(train_scp);

    % ML -> MAP
    fid=fopen(convert_scp, 'rt'); 

        while ~feof(fid)
            % read scp
            line=fgetl(fid);
            line=strsplit(line, del_scp);
            inputName=line{1};
            outputName=line{2};
            disp(inputName);
            disp(outputName);
            % convert hmms
            hmms = readhmm(inputName);
            hmms = convert_hmms(hmms, mu_0, Sigma_0, Omega, weight);

            % save MAP-hmmfile
            writehmm(outputName, hmms);
        end % while
    
    fclose(fid);
toc
end

% --------------------------------------------------------------

function [mu_0, Sigma_0, Omega]=calc_commonParams(train_scp)
        
    % read hmms
    fid=fopen(train_scp, 'rt'); 
        % read hmm & store variables
        % first line
        filename=fgetl(fid);
        hmms=readhmm(filename);
        means=hmms.means;
        covars=hmms.covars;
        nstates=hmms.nstates;
        % line 2 ~
        m=2;
        while ~feof(fid)
            filename=fgetl(fid);
            hmms(m)=readhmm(filename);
            means=means+hmms(m).means;
            covars=covars+hmms(m).covars;
            m=m+1;
        end % while
        M=m-1;
    fclose(fid);
        
    % calculate commonParams
    % mu_0 & Sigma_0
    mu_0=mean(means')/M;
    Sigma_0=mean(covars')/M;
    % Omega
    S_mu=zeros(1, 24);
    for m=1:length(hmms)
        for n=1:nstates
            S_mu = S_mu + (hmms(m).means(:, n)'-mu_0).*(hmms(m).means(:, n)'-mu_0);
        end % n
    end % m
    S_mu=S_mu/(M*nstates);
    Omega=Sigma_0./S_mu;

end % 

% --------------------------------------------------------------

function hmms = convert_hmms(hmms, mu_0, Sigma_0, Omega, n)
    % definitions
    dim=size(hmms.means,1);
    nstates=hmms.nstates;

    mu_ML=hmms.means';
    Sigma_ML=hmms.covars';

    % calculate MAP adaptation parameters
    E= ones(1, 24);
    A= E./Sigma_0;
    A_hat= A + 0.5*n*E;
    Omega_hat= Omega+ n*E;

    % convert hmms
    for ii=1:nstates
        % means
        tmp= diag(Omega./Omega_hat)*mu_0';
        mu_MAP(ii, :)= tmp' + n*(mu_ML(ii,:)./Omega_hat);
                
        % covars
        tmp= diag(Omega)*(square(mu_ML(ii, :)-mu_0)./Omega_hat)';
        B_hat= E + 0.5*n*Sigma_ML(ii, :) + 0.5*n*tmp';
        Sigma_MAP(ii, :)=B_hat./A_hat;
    end % ii

    hmms.means=mu_MAP';
    hmms.covars=Sigma_MAP';

end % function
