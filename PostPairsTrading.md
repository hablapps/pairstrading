# A Match Made in Trading: Step-by-Step Pairs Trading Guide

KDB+/Q stands out as **a powerful tool in finance**, renowned for its ability to handle vast volumes of real-time data amidst the relentless dynamics of the market. In this article, we embark on an insightful exploration of Pairs Trading and its implementation in Q, offering a comprehensive guide to one of the most popular strategies in the trading world.

Our objective is to **provide an easy to understand explanation about some of the intricacies of pair trading**, bridging the gap between theory and practice.

We'll proceed methodically, ensuring each question leads to a comprehensive answer. To start, we'll contextualize our current situation by addressing key questions such as **"What do we know about the market and how can we benefit from it?"**. This will lay the foundation for constructing a real-time simulated environment on Pairs Trading that will exemplify everything we have explained thus far.

Whether taking a technical or quantitative approach, these insights will provide valuable foundations for constructing this algorithm effectively.

## In the untamed realm of the market

The market has often been described as a **stochastic** (a term which essentially means random) **process** where prices fluctuate irregularly. However, amidst this apparent randomness, we observe that **certain assets move in tandem** due to their inherent relationships. 

For instance, it's logical to expect that if the prices of petrol rise, the prices of cars should also rise. This is because auto companies rely on petrol for their operations, indicating an interconnectedness between the two. Over the long run, they tend to follow similar trends, **reflecting their underlying relationship**.

Is this described mathematically? **Yes**:

The concept we're referring to is **cointegration** (although there are other methods, we'll focus on this one).

> 💡 Which should not be confused with correlation; cointegration is a statistical property of two-time series, indicating a long-term relationship between them despite short-term fluctuations. Cointegrated series move together over time, sharing a common stochastic drift. On the other hand, correlation measures the strength and direction of the linear relationship between two variables at a specific point in time. While correlation captures the degree of association between variables, cointegration reflects a deeper, underlying relationship that persists over time.

Hence, we're interested in **cointegrated assets**, which are assets that exhibit the following characteristics:

1. They have a similar trend, meaning the difference between both assets maintains a constant mean, and this difference fluctuates around that same mean.

2. This inherent relationship persists in the long run, meaning that our series is not dependent on time.

## A pair in the hand is worth two in the bush

### ADF testing

Imagine **we selected 13 world indexes** and aimed to assess whether they are **cointegrated or not**. In this scenario, a crucial tool at our disposal is the Augmented Dickey-Fuller (ADF) test, an essential statistical test for assessing the stationarity of time series data. The more stationary the time series are, the more cointegrated they are likely to be.

This statistical test is a **hypothesis test**, where we use our data to see if we can accept or reject a hypothesis. In our case, the hypothesis is whether the time series is non-stationary. To determine this, we use **p-values**.

**P-values** help us decide whether to reject the null hypothesis. If the p-value is low, it indicates that we can reject the hypothesis that the time series is non-stationary, suggesting that our assets are cointegrated. The lower the p-value, the greater the confidence in rejecting the null hypothesis. It is very common to use a threshold of 0.05 on the p-value to reject hypotheses.

For the sake of simplicity, we will be using [PyKX](https://code.kx.com/pykx/2.4/index.html). This is necessary as we require importing our ADF test function and plotting a heatmap of our results. Developing these functionalities directly in Q might introduce errors and would be time-consuming, to say the least. Hence, we rely on PyKX to streamline the process by importing relevant libraries from the Python ecosystem.

```q
system "l pykx.q"
```

One such library is **statsmodels**, a prominent tool in Python for statistical modeling and hypothesis testing. It equips analysts with a robust toolkit for regression, time series, and multivariate analysis. Specifically, within the **statsmodels** package, the **statsmodels.tsa.stattools** module features **the Augmented Dickey-Fuller (ADF) test**.

```q
coint:.pykx.import[`statsmodels.tsa.stattools]`:coint
```
For our study, we retrieved data for the different indexes using the [Yahoo Finance API](https://pypi.org/project/yfinance/) and stored them in the `data/stocks/` directory, where we'll find one csv file for each index. Additionally, for simplicity, we only use the closing prices (float), but the API also provides other typical values such as high, low, and open prices.

We declare the function `rs` (_read stock_) to read the closing data of a given index.
This function uses `0:` to read the files, which takes the delimiter and the schema. In this case, we only want to read the closing price column as a float. Additionally, since the data does not include any reference to the index being read, we need to make a small adjustment to our table to add the index associated with each price.

```q
rs:{([]sym:x;close:first((5#" "),"F";csv) 0:`$":data/stocks/",string[x],".csv")}
```

Then, we apply this function to `each` of the indexes from which we want to read the data, concatenate (`raze`) all the data into a table, and finally group (`xgroup`) by index. We declare a variable, **syms**, as a list of symbols, representing each of the indexes we want to check for cointegration.

```q
syms:`SP500_hist`NASDAQ100_hist`BFX`FCHI`GDAXI`HSI`KS11`MXX`N100`N225`NYA`RUT`STOXX
t: `sym xgroup raze rs each syms
```

We then proceed to create a function called **fCoint** to call our imported function from PyKX, handle any null values by filling them with 0, using `0f^` and return the second value, which in this case is the p-value.

```q
fcoint: {@[;1]0f^coint[x;y]`}
```

We generate all combinations (`cross`) of indexes to see which pair is most cointegrated. Then, we index (`@`) each pair in our table. Additionally, we take (`#`) the last **trange** days of data for both indexes, and finally apply our **fcoint** function to each (`.'`) pair of data lists. **trange** symbolizes the number of working days in the last 4 years.


```q
trange:4*252
matrix: fcoint .' 0f^neg[trange]#''@\:[;`close](@/:[t]')syms cross syms
```

Now, with our matrix in hand, we can plot it and **visually identify** which asset is more favorable. In order to do that, we can leverage PyKX once again to bring the `heatmap` module to q:

```q
pyhm:.pykx.import[`seaborn]`:heatmap
pyhm[pvalues;`xticklabels pykw syms;`yticklabels pykw syms;`cmap pykw `RdYlGn_r]
```

And plot it:

```q
pyshow:.pykx.import[`matplotlib.pyplot]`:show
pyshow[::]
```

Given our following assets:

| SP500 | NASDAQ100 |   BFX   |  FCHI  |  GDAXI  |    HSI    |  KS11   |  MXX   |  N100  | N225  |  NYA  |  RUT  | STOXX  |
| :---: | :-------: | :-----: | :----: | :-----: | :-------: | :-----: | :----: | :----: | :---: | :---: | :---: | :----: |
|  USA  |    USA    | Belgium | France | Germany | Hong Kong | S.Korea | Mexico | Europe | Japan |  USA  |  USA  | Europe |

Our heatmap looks like this:

![ADF heatmap](https://github.com/hablapps/pairstrading/blob/5-Post/resources/ADFgif.gif?raw=true)

As we can observe, there are several cointegrated indices, but our attention will be drawn towards the **NASDAQ100 and SP500** synergy. Both of these indices belong to the American market and share numerous characteristics. They encompass American companies traded within the same scenario, which is what makes them a perfect fit for our case.
In this heatmap, they exhibit a vibrant green color, indicative of a high degree of cointegration, or, in simpler terms, a very low probability of not being cointegrated. They demonstrate low p-values suggesting their strength as candidates.

 > 💡 As we can see, this pair of indexes is not the best candidate according to our ADF tests. However, we chose it because the tick data for their prices is publicly available. We used TickStory to obtain the data.

![Prices](resources/cointegration.png)


The plotted graph displays the prices of both indexes together, providing a clearer comparison that showcases the cointegration between them. The blue line represents SP500, and NASDAQ100 is represented by the green line. The close alignment of their price movements indicates that they are cointegrated to some extent. This means that, despite short-term deviations, the indices tend to move together as time goes on, maintaining a stable relationship. This graph was generated by [KX Dashboard](https://code.kx.com/dashboards/), which receives data from the Pairs Trading process and renders visualizations.

## Cointegration, then what?

Let's recap our progress:

1. We've acknowledged the randomness of the market, yet discovered that certain assets **exhibit similar movements**.

2. By employing the **cointegration method and the ADF test**, we pinpointed a promising pair of assets for our analysis: NASDAQ100 and SP500.

Now we're faced with a crucial question: **"How can I benefit from this knowledge?"**

As mentioned earlier, the market is inherently random and doesn't always behave predictably. While NASDAQ100 and SP500 often follow similar trends, their individual values **can sometimes diverge significantly**. For instance, NASDAQ100 may rise while SP500 falls, or vice versa. 

However, this presents **an opportunity for profit** because we know that these assets tend to revert to their shared mean over time. If one asset is **overpriced** and likely to decrease, we may consider **selling it** (going short). Conversely, if an asset is **underpriced** and expected to increase, we may consider **buying it** (going long). And that is what we call Pairs Trading.

> 💡 This strategy possesses financial characteristics: our **profitability remains unaffected by the broader market trends**, as our focus lies solely on the disparity between the two assets. It's about relative movements rather than absolute ones; we're indifferent to whether prices are rising or falling. This quality defines it as a **neutral market strategy**.

## Spreading spreads

To check for deviations in our prices, we could simply subtract them and observe if the difference deviates significantly from zero, considering their scale difference.

Indeed, just subtracting the prices of two assets, as in $price_y−price_x$ may not provide a clear understanding of their relationship. Let's illustrate this with an example:

```q
q)price_x: 5 10 7 4 8
q)price_y: 23 30 25 30 35
q)spreads: price_y - price_x
18 20 18 26 27
```

**These spread values don't offer much insight** into the relationship between the two assets. Are both assets increasing? Are they moving in opposite directions? It's unclear from these numbers alone.


Let's consider **using logarithms**, as they possess favourable properties for our pricing model. They prevent negative values and stabilize variance. Log returns are time-additive and symmetric, simplifying the calculation and analysis of returns. This improves the accuracy of statistical models and ensures non-negative pricing, enhancing model robustness and reliability:

```q
q)log price_x
1.609438 2.302585 1.94591 1.386294 2.079442
q)log price_y
3.135494 3.401197 3.218876 3.401197 3.555348
q)spreads: log[price_y] - log price_x
1.526056 1.098612 1.272966 2.014903 1.475907
```

We're making progress, as we observe **numbers now fluctuating within much smaller ranges**. However, we're still missing a clear understanding of the underlying relationship. While we've normalized the data using logarithms, we now need to align their discrepancies to a single asset. 

Since both assets are related, **we can leverage linear regression** to our advantage. This enables us to simplify our spreads effectively. So, we'll conduct a basic linear regression analysis using historical data to discern the disparity between them. The generic formulae for one is:

$$Y = \alpha + \beta X + \varepsilon$$

In this context, Y represents the NASDAQ 100 index, X represents the S&P 500 index, α is the intercept, β is the slope (which indicates the relationship strength between the two indices), and ε is the error term.

![LinearRegression](resources/linear_regression.png)

The plotted graph above illustrates the relationship between the NASDAQ 100 and the S&P 500 indices, with each purple dot representing a data point of their prices at a given time. The linear trend visible in the scatter plot suggests a strong positive cointegration between the two indices. By applying linear regression, we can model this relationship mathematically, allowing us to predict the NASDAQ 100 index price based on the S&P 500 index price. This predictive power is crucial for pair trading, as it helps identify mispricings and potential trading opportunities.

Linear regression aims to identify relationships between historical data, which we then extrapolate to current data. The differences between these relationships, or deviations, are our spreads. We've already calculated the 𝛼 and 𝛽 using the logarithmic values of our historical data (since real-time price values for price_x and price_y are unknown). Now, we simply combine everything and apply linear regression to our price logarithms:

$$spread = log(price_y) - (\beta \cdot log(price_x)+\alpha)$$

```q
q)spreads: log[price_y] - alpha + log[price_x] * beta
-0.1493929 0.0451223 -0.08835117 0.0451223 0.1579725
```

There are different methods we can use to obtain the best alpha and beta values that minimize the spreads or, in other words, there are mathematical ways to find the line that best fits the prices.

The aim of this post is not to delve deeply into them but to mention that the most popular one is called the least squares method. For this case, it provides a closed-form solution that depends on our historical data. This means we do not need any iterative algorithm or anything more complex to find these optimal alpha and beta values.

>💡 For those interested in our implementation of these formulas in kdb+/q, the code can be found in our repository [Pair-Trading](https://github.com/hablapps/pairstrading/blob/5-Post/linear_regression.q).

This precisely meets our objective—a **comprehensive method for representing relative changes between both assets**. As we can deduce, our mean is now 0 because our assets are normalized, cointegrated and on the same scale. Therefore, ideally, the differential between their prices should be 0. Consequently, when our spread is below 0, we infer that asset X is overpriced, whereas if it's above 0, then asset Y is overpriced.


## Real-Time Pair Party

Now that we have selected a pair of cointegrated indices and understand how to calculate their relationships, let's see how we can create a real-time pair trading scenario.

The first step to implementing this pair trading algorithm in real time is to declare a `.z.ts` function. This `.z.ts` function will be called automatically every x milliseconds which can be configured with `\t`. In our case, it will be called every 100 milliseconds.

```q
.z.ts: {.stream_pair.gen_pair[]} 
\t 100
```

Let's now see how our **.stream_pair.gen_pair** function should be defined. We are only simulating real time; we do not have a 100% real-time product. Therefore, we already have the data loaded into memory and only need to display it one by one. For this, we will use an index *.stream_pair.i** which we will update with each execution of our function. Please keep in mind that if we wanted to run this in a real real-time scenario, the code would need to be modified.

```q
.stream_pair.i+:1;
resX: price_x[.stream_pair.i];
resY: price_y[.stream_pair.i];
```

The purpose of this function is to calculate the corresponding price spreads. For this, we will use the spread formula that we already know.

```q
spread: price_y[.stream_pair.i][`bid] - ((price_x[.stream_pair.i][`bid] * beta_lr)+alpha_lr);
```

Putting everything together and returning a table with the time instant and the spread, we would get the function:

```q
 .stream_pair.gen_pair:{
      .stream_pair.i+:1;
      resX: price_x[.stream_pair.i];
      resY: price_y[.stream_pair.i];
      s: resY[`bid] - alpha_lr+resX[`bid] * beta_lr;
      enlist `dt`spread`mean!
            ("p"$(resX[`dt]);"f"$(s);"f"$(0));  
 }
```

Using this approach, we will end up with something like this:

![SpreadsD](resources/spreads.gif)

And there we have it! **A perfectly plotted spread series in real-time**, ready to be utilized for further analysis and exploitation.

## What's left to start making a profit?

Finally, once we have our spreads accurately calculated and observe how our data is being updated we can **execute buy and sell orders when spread discrepancies occur** based on some signal windows.

A simple approach to window signals is to set these windows as twice the historical standard deviation of the spreads. Therefore, if either of these limits is reached, we should sell the overvalued index and buy the undervalued one, and then unwind our position when the spread returns to 0. Let's clarify this with a specific example:

![WSignals](resources/window_signals.gif)

In this instance, we can see that the spread (purple line) is positive and above the signal (blue line), indicating that our Y index (NASDAQ100) is overvalued relative to the SP500. Therefore, we should sell NASDAQ100 and buy SP500. At the end of the gif, it can be observed that the spread returns to 0 (green line), meaning the indexes are no longer overvalued or undervalued, respectively. At this point, we should unwind the positions we acquired earlier.

> 💡 Signal windows play a pivotal role in implementing Pairs Trading strategies. They serve as indicators for determining when to execute buy and sell actions, acting as arbitrary thresholds that guide our algorithm's decision-making process. These windows are derived from the variance of our data, representing a static variance assumption due to our consideration of a time-independent cointegrated series.

## Conclusion and Future Work

In this post, we have provided a comprehensive overview of Pairs Trading, covering its implementation and intricacies in KDB+/Q.

We have discussed:

1. An examination of cointegrated assets within the market.
2. Multiple Augmented Dickey-Fuller (ADF) tests on real assets.
3. An introduction to the pairs trading strategy itself.
4. A clear and guided explanation of spread calculation and interpretation in KDB+/Q.

One valid concern is that our calculations might be heavily influenced by past data and rely too much on historical changes that may not accurately reflect the present reality. To address this, we could implement a rolling window approach where the linear regression is continuously updated, ensuring our model remains responsive to changes in the underlying data over time. Additionally, using the Kalman Filter to dynamically fit the alpha and beta of the linear regression can effectively filter noise and predict states in a dynamic system, allowing for real-time adjustments and providing a more accurate reflection of current market conditions. We will delve deeper into the topic of window signals as well, exploring more advanced techniques and their applications in real-time pair trading. This will further enhance our model's responsiveness and accuracy, providing a robust framework for effective trading strategies.

Our goal was to demonstrate the capabilities of KDB+/Q and its potential in implementing a simplified yet powerful financial strategy. By doing so, we hope to make these concepts more accessible and empower individuals to leverage these tools in their own work. If you have any questions or need further clarification, don't hesitate to reach out.

Special thanks to [...] for [...]

## References and Documentation

For the technical implementation, we relied on:

* Kx Documentation: https://code.kx.com/q/ref/
* Q for mortals: https://code.kx.com/q4m3/
* PyKX Documentation: https://code.kx.com/pykx/2.4/index.html
* statsmodels Documentation: https://www.statsmodels.org/dev/generated/statsmodels.tsa.stattools.coint.html

For the financial implementation, we used:

* QuantResearch: https://github.com/QuantConnect/Research/blob/master/Analysis/02%20Kalman%20Filter%20Based%20Pairs%20Trading.ipynb
