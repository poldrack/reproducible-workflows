# load data and analyze relation between age and discount rate
# after https://neurohackweek.github.io/software-testing-for-scientists/02-example_script/

df=read.table('http://poldrack.github.io/reproducible-workflows/testdata.csv')

# check data using assertion tests

stopifnot(max(df$age<120))
stopifnot(min(df$age>12))

# run linear model

lm.result=lm(performance~age,data=df)
summary(lm.result)

