function bd=bhattacharyya(mean1,covar1, mean2, covar2)
% calculate bhattacharyya distance between two distributions

mean1= mean1;
mean2= mean2;
mean12=mean1-mean2;

%should use the diagonal elements (do it later)
%covar1=diag(covar1);
%covar2=diag(covar2);
covar1= covar1';
covar2= covar2';
covar12=(covar1+covar2)/2;
tmp= sum(log(abs(covar12)))-0.5*sum(log(abs(covar1)))-0.5*sum(log(abs(covar2)));
tmp=tmp/2;


bd = (mean12*(covar12.\mean12'))/8+tmp;


%bd = sqrt(abs(bd));
