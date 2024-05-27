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

Next, we need to import the **statsmodels library**, a prominent tool in Python for statistical modeling and hypothesis testing. It equips analysts with a robust toolkit for regression, time series, and multivariate analysis. Specifically, within the **statsmodels** package, the **statsmodels.tsa.stattools** module features **the Augmented Dickey-Fuller (ADF) test**.

```q
coint:.pykx.import[`statsmodels.tsa.stattools]`:coint
```
For our study, we retrieved data for the different indexes using the [Yahoo Finance API](https://pypi.org/project/yfinance/) and stored them in the `data/stocks/` directory, where we'll find one csv file for each index. Additionally, for simplicity, we only use the closing prices (float), but the API also provides other typical values such as high, low, and open prices.

We declare the function **read_stock** to read the closing data of a given index.
This function uses `0:` to read the files, which takes the delimiter and the schema. In this case, we only want to read the closing price column as a float. Additionally, since the data does not include any reference to the index being read, we need to make a small adjustment to our table to add the index associated with each price. Then, we apply this function to `each` of the indexes from which we want to read the data, concatenate (`raze`) all the data into a table, and finally group (`xgroup`) by index. We declare a variable, **syms**, as a list of symbols, representing each of the indexes we want to check for cointegration.

```q
rs:{([]sym:x;close:first((5#" "),"F";csv) 0:`$":data/stocks/",string[x],".csv")}
syms:`SP500_hist`NASDAQ100_hist`BFX`FCHI`GDAXI`HSI`KS11`MXX`N100`N225`NYA`RUT`STOXX
t: `sym xgroup raze rs each syms
```

We then proceed to create a function called **fCoint** to call our imported function from PyKX, handle any null values by filling them with 0, using `0f^` and return the second value, which in this case is the p-value.

```q
fCoint: {@[;1]0f^coint[x;y]`}
```

We generate all combinations (`cross`) of indexes to see which pair is most cointegrated. Then, we index (`@`) each pair in our table. Additionally, we take (`#`) the last **trange** days of data for both indexes, and finally apply our **fCoint** function to each (`.'`) pair of data lists. **trange** symbolizes the number of working days in the last 4 years.


```q
trange:4*252
matrix: fCoint .' 0f^neg[trange]#''@\:[;`close](@/:[t]')syms cross syms
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

| SP500 | NASDAQ100 | BFX     | FCHI   | GDAXI   | HSI       | KS11    | MXX    | N100   | N225  | NYA | RUT | STOXX  |
|:-----:|:---------:|:-------:|:------:|:-------:|:---------:|:-------:|:------:|:------:|:-----:|:---:|:---:|:------:|
| USA   | USA       | Belgium | France | Germany | Hong Kong | S.Korea | Mexico | Europe | Japan | USA | USA | Europe |

Our heatmap looks like this:

![ADF heatmap](https://github.com/hablapps/pairstrading/blob/5-Post/resources/ADFgif.gif?raw=true)

As we can observe, there are several cointegrated indices, but our attention will be drawn towards the **NASDAQ100 and SP500** synergy. Both of these indices belong to the American market and share numerous characteristics. They encompass American companies traded within the same scenario, which is what makes them a perfect fit for our case.
In this heatmap, they exhibit a vibrant green color, indicative of a high degree of cointegration, or, in simpler terms, a very low probability of not being cointegrated. They demonstrate low p-values suggesting their strength as candidates.

 > 💡 As we can see, this pair of indexes is not the best candidate according to our ADF tests. However, we chose it because the tick data for their prices is publicly available. We used TickStory to obtain the data.
![Prices](https://github.com/hablapps/pairstrading/blob/5-Post/resources/Prices%20gif.gif?raw=true)


The graphs illustrate the concept of cointegration between two indexes. The top two graphs show the prices of SP500 (left) and NASDAQ100 (right) over the same time period. We can observe that the price movements of these two indices follow similar patterns, suggesting some level of cointegration.

The bottom graph displays the prices of both indices together, providing a clearer comparison. The blue line represents SP500, and NASDAQ100 is represented by the red line. The close alignment of their price movements indicates that they are cointegrated to some extent. This means that, despite short-term deviations, the indices tend to move together as time goes on, maintaining a stable relationship.

In this case, we are using a [KX Dashboard](https://code.kx.com/dashboards/) to plot our data. We stream this data in one process to our local dashboard, which listens to that process and accesses the data to render visualizations.

## Cointegration, then what?

Let's recap our progress:

1. We've acknowledged the randomness of the market, yet discovered that certain assets **exhibit similar movements**.

2. By employing the **cointegration method and the ADF test**, we pinpointed a promising pair of assets for our analysis: NASDAQ100 and SP500.

Now we're faced with a crucial question: **"What do I do with these assets?"**

As mentioned earlier, the market is inherently random and doesn't always behave predictably. While NASDAQ100 and SP500 often follow similar trends, their individual values **can sometimes diverge significantly**. For instance, NASDAQ100 may rise while SP500 falls, or vice versa. 

However, this presents **an opportunity for profit** because we know that these assets tend to revert to their shared mean over time. If one asset is **overpriced** and likely to decrease, we may consider **selling it** (going short). Conversely, if an asset is **underpriced** and expected to increase, we may consider **buying it** (going long). And that is what we call Pairs Trading.

> 💡 This strategy possesses financial characteristics: our **profitability remains unaffected by the broader market trends**, as our focus lies solely on the disparity between the two assets. It's about relative movements rather than absolute ones; we're indifferent to whether prices are rising or falling. This quality defines it as a **neutral market strategy**.

## Spreading spreads

To check for deviations in our prices, we could simply subtract them and observe if the difference deviates significantly from zero, considering their scale difference.

Indeed, just subtracting the prices of two assets, as in $priceY−priceX$ may not provide a clear understanding of their relationship. Let's illustrate this with an example:

```q
q)priceX: 5 10 7 4 8
q)priceY: 23 30 25 30 35
q)spreads: priceY - priceX
18 20 18 26 27
```

**These spread values don't offer much insight** into the relationship between the two assets. Are both assets increasing? Are they moving in opposite directions? It's unclear from these numbers alone.


Let's consider **using logarithms**, as they possess favourable properties for our pricing model. They prevent negative values and stabilize variance. Log returns are time-additive and symmetric, simplifying the calculation and analysis of returns. This improves the accuracy of statistical models and ensures non-negative pricing, enhancing model robustness and reliability:

```q
q)log priceX
1.609438 2.302585 1.94591 1.386294 2.079442
q)log priceY
3.135494 3.401197 3.218876 3.401197 3.555348
q)spreads: log[priceY] - log priceX
1.526056 1.098612 1.272966 2.014903 1.475907
```

We're making progress, as we observe **numbers now fluctuating within much smaller ranges**. However, we're still missing a clear understanding of the underlying relationship. While we've normalized the data using logarithms, we now need to align their discrepancies to a single asset. 

Since both assets are related, **we can leverage linear regression** to our advantage. This enables us to simplify our spreads effectively. So, we'll conduct a basic linear regression analysis using historical data to discern the disparity between them. The generic formulae for one is:

$$Y = \alpha + \beta X + \varepsilon$$

Linear regression aims to identify relationships between historical data, which we then extrapolate to current data. The differences between these relationships, or deviations, are our spreads. We've already calculated the 𝛼 and 𝛽 using the logarithmic values of our historical data (since real-time price values for priceX and priceY are unknown). Now, we simply combine everything and apply linear regression to our price logarithms:

$$spread = log(priceY) - (\beta \cdot log(priceX)+\alpha)$$

```q
q)spreads: log[priceY] - alpha + log[priceX] * beta
-0.1493929 0.0451223 -0.08835117 0.0451223 0.1579725
```

The most common method to find the best relationships (alpha and beta) is the least squares method, which minimizes the sum of the squared residuals:
$$S(\alpha, \beta) = (log(priceY) - (\beta \cdot log(priceX)+\alpha))^2$$

After taking partial derivatives with respect beta and setting to zero, and then solving, we can arrive at this formula:
$$\beta = \frac{{(n \cdot \sum(x \cdot y)) - (\sum x \cdot \sum y)}}{{(n \cdot \sum(x^2)) - (\sum x)^2}}$$
Which we can see implemented in the following functions:

```q
q)betaF:{dot:{sum x*y};                                      
      ((n*dot[x;y])-(*/)(sum')(x;y))%                         
      ((n:count[x])*dot[x;x])-sum[x]xexp 2}
q)beta: betaF[historical_data_priceX;historical_data_priceY]
0.2679227
```

Now, following the same steps as before but for alpha, we arrive at:

$$\alpha = \bar y - \beta \cdot \bar x$$

Which is implemented in the following lines of code:

```q
q)alphaF: {avg[y]-betaF[x;y]*avg[x]}
q)alpha: alphaF[historical_data_priceX;historical_data_priceY]
2.444817
```

This precisely meets our objective—a **comprehensive method for representing relative changes between both assets**. As we can deduce, our mean is now 0 because our assets are normalized, cointegrated and on the same scale. Therefore, ideally, the differential between their prices should be 0. Consequently, when our spread is below 0, we infer that asset X is overpriced, whereas if it's above 0, then asset Y is overpriced.


## Two steps forward, one step back

Before proceeding to plot the NASDAQ100-SP500 spreads, we need to first plan our algorithm. In this post, we intend to create **a real time scenario** for Pairs Trading, so careful planning is essential for our sake.

Decomposing our steps, let's start from the very beginning:

1. Data management part

	1.1. Read data

    1.2. Filter data

2. Outside the .z.ts

    2.1. Linear regression

    2.2. Initialize values 

3. Inside the .z.ts

    3.1. Calculate spreads

    3.2. Write on buffers

As previously mentioned, historical data is crucial for generating accurate spreads. We need to calculate each spread in real-time **using precomputed alpha and beta values** derived from both prices. Therefore, once we have obtained our historical values, we can proceed with calculating our linear regression.

---

```q
// Fix data and take log(prices) -> Simulated data
readTick:{1_ flip `dateTime`bid`ask`bidVol`askVol!("*FFFF";",")0: `$":data/",string[x],".csv"}

tab1:readTick `USA500IDXUSD
tab2:readTick `USATECHIDXUSD

// Read historical data
readHist:{1_ flip enlist[`close!("   F  ";",") 0: `$":data/",string[x],"_hist.csv"}

historial_tab1:readHist `SP500
historial_tab2:readHist `NASDAQ100
```

---

## Linear regression

Now, armed with logarithms, we can replicate the process from our previous example and calculate both alpha and beta values. To do this, we'll start by taking the historical data for NASDAQ100 and SP500 and applying our linear regression function to derive the desired values.

---

```q
// Calculate alpha and beta from historical values
beta_lr: betaF[px:-100#log historial_tab1`close;py:-100#log historial_tab2`close]; // we only take most recent 100 values 

alpha_lr: alphaF[px;py];
```

---

Now we just calculate our spreads as we did before like:

---

```q
spread: priceY[.streamPair.i][`bid] - ((priceX[.streamPair.i][`bid] * beta_lr)+alpha_lr);
```

---

> 💡 You may notice that we retrieve bid price data from our price stream using an index (`.streamPair.i`). This occurs because we simulate the arrival of these records dynamically, based on a delta time, and thus read from our buffer (a table of 1000 elements), utilizing our updated index `.streamPair.i` with each passing second.

This approach will provide us with:

![SpreadsD](https://github.com/hablapps/pairstrading/blob/5-Post/resources/Spreads%20gif.gif?raw=true)

And there we have it! **A perfectly plotted spread series in real-time**, ready to be utilized for further analysis and exploitation.

## What's left to start making a profit?

Finally, once we have our spreads accurately calculated and observe how our data is being updated second by second, we can **execute buy and sell orders when spread discrepancies occur** based on some signal windows. Those windows, however, will be explored in greater depth in a follow up post about the Kalman Filter and its application in Pairs Trading.

> 💡 Signal windows play a pivotal role in implementing Pairs Trading strategies. They serve as indicators for determining when to execute buy and sell actions, acting as arbitrary thresholds that guide our algorithm's decision-making process. These windows are derived from the variance of our data, representing a static variance assumption due to our consideration of a time-independent cointegrated series. However, we'll delve deeper into this topic in a subsequent post that will expand the scope of the current discussion as we previously mentioned.

For now, it's crucial to clarify **our spread formulation and understand what it represents**. With this knowledge, we can identify instances where one asset is overpriced while the other is underpriced.

One might argue that our calculations are heavily influenced by past data and that we rely too much on historical changes that **may not accurately reflect the present reality**. This is indeed a **valid concern**. To address this issue, we can utilize **the Kalman Filter**, a mathematical method for filtering noise and predicting states in a dynamic system. But we'll delve into the Kalman Filter in our upcoming posts as previously mentioned.

Additionally, even though we fit our model with historical data, we could implement **a rolling window approach** where the linear regression is continuously updated. This would ensure that our model remains responsive to changes in the underlying data over time.

## The End

In conclusion, this post aims to provide a comprehensive overview that explains Pairs Trading from beginning to end, covering every aspect that may be relevant to understanding this topic and its intricacies in KDB+/Q.

Recapping, we have covered:

1. An introductory overview of the market as a whole.
2. An examination of cointegrated assets within the market.
3. Multiple Augmented Dickey-Fuller (ADF) tests on real assets.
4. A presentation of the pairs trading strategy itself.
5. A clear and guided explanation of spread calculation, interpretation, and implementation in KDB+/Q.
6. Additional knowledge necessary to master the strategy.

We aimed to demonstrate the capabilities of KDB+/Q and its potential in a simplified manner that anyone can implement, particularly in the context of a widely used financial strategy. By doing so, we hope to make complex concepts more accessible and empower individuals to leverage these powerful tools in their own endeavours.

We hope you found this information valuable and gained a good understanding of this financial tactic from both technical and economic perspectives. If you have any questions or need further clarification, don't hesitate to reach out. 

Be sure to stay tuned for more posts and updates on this blog to deepen your knowledge even further. 

Special thanks to [...] for [...]

## References and Documentation

For the technical implementation, we relied on:

* Kx Documentation: https://code.kx.com/q/ref/
* Q for mortals: https://code.kx.com/q4m3/
* PyKX Documentation: https://code.kx.com/pykx/2.4/index.html
* statsmodels Documentation: https://www.statsmodels.org/dev/generated/statsmodels.tsa.stattools.coint.html

For the financial implementation, we used:

* QuantResearch: https://github.com/QuantConnect/Research/blob/master/Analysis/02%20Kalman%20Filter%20Based%20Pairs%20Trading.ipynb
