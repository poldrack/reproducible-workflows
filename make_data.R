# generate data for example

# set random seed for reproducibility
set.seed(12345)

nsubs=100
age=runif(100)*40 + 20
noise_sd=1
intercept=5
performance=age*-0.05 + rnorm(nsubs)*noise_sd + intercept
# add an outlier
age[16]=32767
plot(age,performance)
df=data.frame(age,performance)
write.table(df,file='testdata.csv')

