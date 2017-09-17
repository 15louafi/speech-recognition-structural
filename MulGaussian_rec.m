function class=MulGuassian_rec(mean_train,var_train,test,classNum) %%mean_train and var_train is a x*y dimesional data. x is class, y is structure mean or var. test is just the feature vector of test data.
p=zeros(1,classNum);%probabilities for each class
dim=size(mean_train,2);%get dimension of one vector
class=0;
max=-Inf;

%find class for max propability
for i=1:classNum
    gconst=dim*log(2*pi)+sum(log(var_train(i,:)));
    p(i)=-0.5*((test-mean_train(i,:))./var_train(i,:)*(test-mean_train(i,:))'+gconst);
    if p(i)>=max
        max=p(i);
        class=i;
    end
end
end