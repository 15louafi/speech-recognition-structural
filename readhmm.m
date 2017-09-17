function hmms = readhmm(file)
%READHMM  read an HTK HMM definition file [hmms]=readhmm(file)
%
% Only works on text files.
% Only works for Gaussian emissions with diagonal covariance.
%
% Input:
%    file = name of hmmdefs file
% Output:
%    hmms = cell array of a hmm
%
% ** GMM
%  - gmm.nmix   - number of components in the mixture
%  - gmm.priors - array of prior log probabilities over each state
%  - gmm.means  - matrix of means (column x is mean of component x)
%  - gmm.covars - matrix of covariance (column x is the diagonal of the
%                 covariance matrix of component x)
%
% ** HMM with GMM observations
%  - hmm.name          -
%  - hmm.nstates       - number of states in the HMM
%  - hmm.emission_type - 'GMM'
%  - hmm.start_prob    - array of log probs P(first observation is state x)
%  - hmm.end_prob      - array of log probs P(last observation is state x)
%  - hmm.transmat      - matrix of transition log probs (transmat(x,y)
%                        = log(P(transition from state x to state y)))
%  - hmm.labels        - optional cell array of labels for each state in the HMM
%                        (for use in composing HMMs)
%  - hmm.gmms          - array of GMM structures
%
% ** HMM with Gaussian observations
%  - hmm.nstates       - number of states in the HMM
%  - hmm.emission_type - 'gaussian'
%  - hmm.start_prob    - array of log probs P(first observation is state x)
%  - hmm.end_prob      - array of log probs P(last observation is state x)
%  - hmm.transmat      - matrix of transition log probs (transmat(x,y)
%                        = log(P(transition from state x to state y)))
%  - hmm.labels        - optional cell array of labels for each state in the HMM
%                        (for use in composing HMMs)
%  - hmm.means         - matrix of means (column x is mean of state x)
%  - hmm.covars        - matrix of means (column x is the diagonal of the
%                        covariance matrix of component x)

% https://github.com/ronw/matlab_htk/

% Copyright (C) Masayuki Suzuki
% GAVORIN is a toolbox for speech processing.

% Read the M-file into a cell array of strings:
fid = fopen(file, 'rt');
if fid < 0; error( sprintf('Cannot read from %s', file) ); end
file = textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '');
fclose(fid);

file = file{1};
% Remove any empty lines
file = file(cellfun('length', file) > 0);

nhmms = 1;
lastlinewashmm = 0;
for x = 1:length(file)

    % is this a new HMM?
    if ~lastlinewashmm
        if length(file{x}) >= 2
            if strcmp(file{x}(1:2), '~h') || ~isempty(strmatch(upper(file{x}), '<BEGINHMM>'))
                hmms(nhmms) = readNextHMM(file, x);
                nhmms = nhmms+1;
                lastlinewashmm = 1;
            end
        end
    else
        lastlinewashmm = 0;
    end
end


%% functions
function hmm = readNextHMM(file, linenum)

x = linenum;
if ~isempty(findstr(file{x}, '~h'))
    c = strread(file{linenum}, '~h %q');
    hmm.name = c{1};
    x = x + 1;
else
    hmm.name = 'matlabhmm';
end

x = x + 1;
% first and last state in
hmm.nstates = strread(upper(file{x}), '<NUMSTATES> %d')-2;

x = x + 1;
while isempty(findstr(upper(file{x}),'<TRANSP>'))
    state = strread(upper(file{x}), '<STATE> %d') - 1;
    x = x+1;

    if ~isempty(findstr(upper(file{x}), '<NUMMIXES>'))
        nmix = strread(upper(file{x}), '<NUMMIXES> %d');
        x = x+1;

        hmm.gmms(state).nmix = nmix;
        hmm.gmms(state).priors(1:nmix) = -Inf;
    else
        nmix = 1;
    end

    for n = 1:nmix
        if ~isempty(findstr(file{x}, '~s "'))
            x = x+1;
            break
        end

        if nmix > 1
            if isempty(findstr(upper(file{x}), '<MIXTURE>'))
                % sometimes HTK skips mixture components.  If we make sure
                % that is a prior of -Inf, then it won't be a problem.
                % Luckilly this is take care of in the initialization above.
                continue
            end

            [currmix, prior] = strread(upper(file{x}), '<MIXTURE> %d %f');
            x = x+1;
        end

        ndim = strread(upper(file{x}), '<MEAN> %d');
        x = x+1;

        if n == 1 && nmix > 1
            hmm.gmms(state).means(1:ndim,1:nmix) = 0;
            hmm.gmms(state).covars(1:ndim,1:nmix) = 1;
        end

        mu = strread(file{x}, '%f', ndim);
        x = x+1;

        ndim = strread(upper(file{x}), '<VARIANCE> %d');
        x = x+1;
        covar = strread(file{x}, '%f', ndim);
        x = x+1;

        if ~isempty(findstr(upper(file{x}), '<GCONST>'))
            gconst = strread(upper(file{x}), '<GCONST> %f');
            hmm.gconsts(state)=gconst;   % modified by ozaki 06/07/12
            x = x+1;
        end

        if nmix == 1
            % Gaussian emissions
            hmm.emission_type = 'gaussian';
            hmm.means(:, state) = mu;
            hmm.covars(:, state) = covar;
        else
            % GMM emissions
            hmm.emission_type = 'GMM';
            hmm.gmms(state).priors(currmix) = log(prior);
            hmm.gmms(state).nmix = nmix;
            hmm.gmms(state).means(:, currmix) = mu;
            hmm.gmms(state).covars(:, currmix) = covar;
        end
    end
end

nstates = strread(upper(file{x}), '<TRANSP> %d');
x = x+1;

transmat = zeros(nstates);
for n = 1:nstates
    transmat(n,:) = strread(file{x}, '%f', nstates);
    x = x+1;
end

w = warning('query', 'MATLAB:log:logOfZero');
if strcmp(w.state, 'on')
    warning('off', 'MATLAB:log:logOfZero');
end
hmm.start_prob = log(transmat(1,2:end-1));
hmm.transmat = log(transmat(2:end-1,2:end-1));
hmm.end_prob = log(transmat(2:end-1,end));
warning(w.state, w.identifier);
