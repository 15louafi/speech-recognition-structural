function [strVec, strMatrix]=structure(mu,Sigma)
%
% USING:
%    bhattacharyya.m
%
% INPUT
%    mu    : mean vector of hmm [state x dim]
%    Sigma : diag of covariance matrix [state x dim]
%
% OUTPUT
%    strVec     : structure vector
%    strMatrix	: structure Matrix
%

    nState=size(mu,1);

    strMatrix=zeros(nState,nState);
    strVec=zeros(1,nState*(nState-1)/2);

    % calcurate Bhattacharyya Distance
    k=1;
    for ii=1:nState-1
        for jj=ii+1:nState
            strMatrix(ii,jj)=bhattacharyya(mu(ii,:),Sigma(ii,:), mu(jj,:), Sigma(jj,:));
            strMatrix(jj,ii)=strMatrix(ii,jj);
            strVec(k)=strMatrix(ii,jj);
            k=k+1;
        end % jj
    end % ii

end % function