function rec_procedure(strDir,outDir)
  for n=1:212
	  trainlist=dir(strcat(strDir,'/','S1*',num2str(n),'.str'));
	      label=[];
    vec=[];
    for i=1:length(trainlist)
       [path name ext]=fileparts(trainlist(i).name);
       tmp=load(strcat(strDir,'/',trainlist(i).name));
       vec=[vec tmp'];
    end
    tmpmu=mean(vec,2);
    mu(n,:)=tmpmu';
    tmpsigma=var(vec,1,2);
    sigma(n,:)=tmpsigma';
  end
    outmodel=strcat(outDir,'/model.mat');
    save('outmodel','mu','sigma');
  
%    sigma=sigma';
    testlist=dir(strcat(strDir,'/','S2*.str'));
    rec=[];
    for i=1:length(testlist)
       [path name ext]=fileparts(testlist(i).name);
       tmp=load(strcat(strDir,'/',testlist(i).name)); %load(trainlist(i).name);
       rec(i)=MulGaussian_rec(mu,sigma,tmp,212);
       label(i)=str2num(regexprep(name,'S.*WN',''));
    end

    refer=[label' rec'];
    refer=refer';
    result=rec./label;
    numTrue=length(find(result==1));
    acc=numTrue/length(label)
end
