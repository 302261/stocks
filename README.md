# Getting the software

We will need to use a number of packages, setting them
up can be onerous, for this reason download nix from

```
https://nixos.org/download/
```

and run 

``` sh
nix develop --experimental-features 'nix-command flakes'
```

in the git directory. Alternatively 

``` sh
nix develop -i --experimental-features 'nix-command flakes'
```

if you are having trouble. 

This will drop you into a shell with all of the packages 
available and ready to go.

This was tested on a linux x86 box. It should in principle
work on windows and mac too, but I have not tested it. 
If graphs are not displaying you may try removing 

``` sh
DISPLAY=":0";
```

from flake.nix 

# Creating the account. 

Go to https://alpaca.markets/ create an account. 

Obtain a paper account key and secret key. 

Go to https://docs.alpaca.markets/reference/stockbars to understand the API.

# Download the data.

Edit the script getData.sh and enter your key and secret key. 
To download the data you can use 

``` sh
bash ./getData.sh MSFT > MSFT.json
```

This would download data for MSFT and output it
into MSFT.json in JSON format. 

# Understanding the data. 

We now have data in MSFT.json.
We now need to parse the data. 

A typical entry looks like this:

``` json
{"c" :62.83, "h":63.36, "l":62.55,"n":115416,"o":62.56,"t":"2025-01-29T05:00:00Z","v":11325635,"vw":62.94999}
```

"c" is price at close 
"h" is the highest price for the time period
"o" is price at open
"l" is the lowest price for the time period 

In our case this is a per-day time period, and the 
day is 2025-01-29T05:00:00Z. 

This choice is due to the parameter timeframe=1D 
in the script getData.sh.

Also "v" is volume and "vw" is the volume weighted 
average price. 

# Formatting the data. 

First we can make the JSON output pretty by typing


``` sh
jq '.' VTI.json
```


Let's now extract just the info that we care about

``` sh
jq '.[] | .[] | .[] | {price: .c, time: .t}' VTI.json 
```

This is much better, but actually if we care only about the price
we can simply do

``` sh
jq '.[] | .[] | .[] | .c' VTI.json > VTI.txt
```

This outputs just the prices to VTI.txt. There is a small
script that does that in polishData.sh, so we could have
run instead

``` sh
bash ./polishData.sh VTI
```

# Plotting the data. 

Let's now plot the data to check that it looks good: 

``` sh
gnuplot -p -e "plot 'VTI.txt'"
gnuplot -p -e "plot 'TTT.txt'"
```

If you plot the NVDA data you will notice that there
was a stock split, and that data is not adjusted for
the stock split. Thus we should be careful with the NVDA
data without further processing. 

# Running a Bayesian regresion. 

We will now run a regression using the package stan
for probabilistic programming. 

The source code is available in beta.stan. 

The model is actually compiled and interpreted in R. 

We thus execute R by typing

``` sh
R
```

In R we then load the code from beta.r by typing

``` r
source('beta.r')
```

This will run a regression of QQQ on VTI. 
The gray shaded curves are all the curves 
sampled from the distribution function for \alpha
and \beta that was inferred by stan from the data
that we fed it. 

To get the numbers corresponding to our prediction
for \beta and \alpha we run in R

``` r
fit$summary()
```

This will display a summary of the main parameters of
the random variables \alpha and \beta. We see that 
our prediction for \beta are quite reliable in this case. 

It is instructive to modify the source code in beta.r
and run instead a regression of KO on VTI. In this case
the estimation of \beta is quite unreliable. If we then
run instead a regression of PBJ on VTI we will find however
again a reliable estimate for \beta. Notice that KO is just
one stock among many food-related stocks, while PBJ is an ETF
combining many food-related stocks. In ETF the diversifiable
risk has been substantially diminished and this accounts for the
more robust estimation of \beta. 

Notice also that the estimate for the Sharpe ratio are quite
unreliable already in the case of VTI. It is inadvisible
to base decisions on such point estimates with large variance. 
This can be however remedied by building a model that
takes into account the full distribution of values of the sharpe
ratio (which is of course possible using Bayesian methods).

# Backtesting portfolios

We also can use the R library portfolioBacktest to inspect 
various portfolios and their performance. 

We open R typing in the shell 

``` sh
R
```

and in R run

``` r
source('portfolio.r')
```

This will download a set of portfolios and backtest
several portfolios on the dataset. 

We can run summaries of the performance of these portfolios 
by typing

``` r
backtestSummary(bt)
```

We can also plot charts of cumulative returns and drawdowns
by typing

``` r
backtestChartCumReturn(bt)
backtestChartDrawdown(bt)
```

These simulations corresponds to a portfolio composed of 
VTI, KO and MSFT for the time period 2024-01-01 to 2025-01-01. 

The portfolios are rebalanced daily with a lookback period of 
20 (business) days (roughly a month). 

The Markowitz portfolio corresponds roughly to running Kelly's 
criterion on the stock market. This amounts to trying to maximize
once compounded returns in expectation. Notice the (typical) wild
swings of this portfolio. 

In general one has to be careful with the Markowitz portfolio as there
are some subtle issues related to the statistical estimation of the
covariance matrix used in the Markowitz portfolio. 

If you try to simulate the portfolio in Stan it will become clear
that sometimes the estimates for the inverse of the covariance matrix 
are completely unreliable and in those situation this portfolio can be roughly
equivalent to a "noise portfolio" where we just invested at random. Strictly,
speaking the portfolio used in the package is not a pure Markowitz portfolio
since it uses convex optimization method (quadratic programming in this case)
to find the optimal portfolio that involves no short-selling. There is a interesting
literature on "regularizing" the covariance matrix to obtain more accurate estimates
(this literature is unnecessary if one uses an entirely Bayesian approach).

It is also instructive to play around with the Markowitz portfolio and 
diminish 0.5 to 0.1 in the code. This amounts to an investor which is more
risk averse as he gets richer. 

# Implementing the algorithm. 

The steps here are convenient for what I would call exploratory analysis
where we try to decide on an investment strategy or understand the correlations
between various stocks. 

Once you have decided on a strategy it is reasonable to implement it in a robust
statically typed language (it would be a disaster if your program experiences
exceptions while uploading stock orders for example). 

