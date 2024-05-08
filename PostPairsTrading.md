# A Match Made in Trading: Step-by-Step Pairs Trading Guide

KDB+/Q stands out as **a powerful tool in finance**, renowned for its ability to handle vast volumes of real-time data amidst the relentless dynamics of the market. In this article, we embark on an insightful exploration of Pairs Trading and its implementation in Q, offering a comprehensive guide to one of the most popular strategies in the trading world.

Our objective is to **provide a deep understanding of the intricacies of pair trading**, bridging the gap between theory and practice. Through a blend of theoretical insights and practical examples, we aim to equip you with the knowledge and skills necessary to navigate every aspect of this financial modelling strategy.

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

Imagine **we selected 13 world indexes** and aimed to assess whether they are **cointegrated or not**. In this scenario, a crucial tool at our disposal is the Augmented Dickey-Fuller (ADF) test, an essential statistical test for assessing the stationarity of time series data.

The ADF test assesses whether movements in a given time series are dependent on previous movements. It does so by formulating a **null hypothesis**, which it aims to reject. To achieve this, we seek **a negative statistical value** that is as significant as possible and **falls below certain critical values** representing confidence limits or thresholds. Additionally, we examine the **p-value**, which succinctly expresses the probability of making an incorrect inference with the test. Consequently, we aim for the p-value to be as low as possible.

💡 Please note that for simplicity in this code, we will be using [PyKX](https://code.kx.com/pykx/2.4/index.html). This is necessary as we require importing our ADF test function and plotting a heatmap of our results. Developing these functionalities directly in Q might introduce errors and would be time-consuming, to say the least. Hence, we rely on PyKX to streamline the process by importing relevant libraries such as statsmodels.

```q
system "l pykx.q"
```

Next, we import the **statsmodels library**, a prominent tool in Python for statistical modeling and hypothesis testing. It equips analysts with a robust toolkit for data analysis, encompassing regression analysis, time series analysis, and multivariate analysis. Specifically, within the **statsmodels** package, the **statsmodels.tsa.stattools** module features **the Augmented Dickey-Fuller (ADF) test**.

We proceed to define a custom cointegration function, which returns a dictionary containing the results of the Augmented Dickey-Fuller (ADF) test for two assets. Subsequently, we apply this custom cointegration function to **the Cartesian product of every pair of assets** to obtain a matrix comprising the **p-values** associated with each pair.

---

![cointegration](https://github.com/hablapps/pairstrading/blob/5-Post/resources/CointFunction.png?raw=true)

---

```q
// We import the cointegration function from statsmodels library in python
coint:.pykx.import[`statsmodels.tsa.stattools]`:coint; 

p1:0f^(exec close from superTab where sym=x); // AssetX
p2: 0f^(exec close from superTab where sym=y); // AssetY

// Receives 2 symbols and returns a dictionary
fCoint: {[p1;p2] r: 0f^coint[p1;p2]`; // Coint results
        `pair`score`pvalue`percentages!(enlist (x,y);r[0];r[1];enlist r[2])}; // Get every result into a dictionary

// We extract every distinct symbol
symList: exec distinct sym from superTab;

crossedList: symList cross symList

matrix: fCoint .' crossedList;
```

### Code explanation

1. The `coint` function **is imported from statsmodels**, thanks to the PyKX library, which provides a cointegration tool in Python. 

2. We retrieve data from **"supertab"**, a consolidated table that aggregates all our assets into a single table. This consolidation allows us to streamline our queries and access all relevant information in one place.

3. We then proceed to **create our custom cointegration function** called `fCoint`, which utilizes the previously imported coint function to obtain the results and inserts them into **a dictionary**. (`symbol1symbol2...!(;v1;v2;...)`)

| Pair            | Score             | P-value                    | Percentages |
| --------------- | ----------------- | -------------------------- | ----------- |
| Pair of symbols | Statistical value | Probability of being wrong | Thresholds  |

4. We use qSQL to **extract every distinct symbol** from our table with the keyword [`exec`](https://code.kx.com/q/ref/exec/).

> 💡[qSQL](https://code.kx.com/q/basics/qsql/) is a set of feautures that permits users to perform SQL-operations with a very similar syntax on tables in KDB+/Q. Which makes it pretty accesible for newcomers to this language.

5. We utilize the `cross` operator, which conducts a [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product) on every symbol, **generating all possible pair combinations**.

6. Finally, **we apply our function from step 2 to our list of every pair of symbols from step 4**. We can achieve this by using the [apply operator](https://code.kx.com/q/ref/apply/) (`.`) followed by an [`each`](https://code.kx.com/q/ref/maps/#each) (`'`). So that we apply our function (`fCoint .' `) to each and every pair (`crossedList`)

---

Now, with our matrix in hand, we can plot it and **visually identify** which asset is more favorable. Given our following assets:

| SP500 | NASDAQ100 | BFX     | FCHI   | GDAXI   | HSI       | KS11    | MXX    | N100   | N225  | NYA | RUT | STOXX  |
|:-----:|:---------:|:-------:|:------:|:-------:|:---------:|:-------:|:------:|:------:|:-----:|:---:|:---:|:------:|
| USA   | USA       | Belgium | France | Germany | Hong Kong | S.Korea | Mexico | Europe | Japan | USA | USA | Europe |

![ADF heatmap](https://github.com/hablapps/pairstrading/blob/5-Post/resources/ADFgif.gif?raw=true)

As we can observe, there are several cointegrated indices, but our attention will be drawn towards the **NASDAQ100 and SP500** synergy. Both of these indices belong to the American market and share numerous characteristics. They encompass American companies traded within the same scenario, which is what makes them a perfect fit for our case.

 In the heatmap, they exhibit a vibrant green color, indicative of a high degree of cointegration, or, in simpler terms, a very low probability of not being cointegrated. They demonstrate low p-values suggesting their strength as candidates.

![Prices](https://github.com/hablapps/pairstrading/blob/5-Post/resources/Prices%20gif.gif?raw=true)

If we plot their prices like the graphs above, we observe a similar tendency corresponding to the cointegration we just verified.

In this case, we are using a [KX Dashboard](https://code.kx.com/dashboards/) to plot our data. We stream this data in one process to our local dashboard, which listens to that process and accesses the data to render visualizations.

## Cointegration, then what?

Let's recap our progress:

1. We've acknowledged the randomness of the market, yet discovered that certain assets **exhibit similar movements**.

2. By employing the **cointegration method and the ADF test**, we pinpointed a promising pair of assets for our analysis: NASDAQ100 and SP500.

Now we're faced with a crucial question: **"What do I do with these assets?"**

As mentioned earlier, the market is inherently random and doesn't always behave predictably. While NASDAQ100 and SP500 often follow similar trends, their individual values **can sometimes diverge significantly**. For instance, NASDAQ100 may rise while SP500 falls, or vice versa. 

However, this presents **an opportunity for profit** because we know that these assets tend to revert to their shared mean over time. If one asset is **overpriced** and likely to decrease, we may consider **selling it** (going short). Conversely, if an asset is **underpriced** and expected to increase, we may consider **buying it** (going long). And that is what we call Pairs Trading.

> 💡 This strategy possesses intriguing financial characteristics: our **profitability remains unaffected by the broader market trends**, as our focus lies solely on the disparity between the two assets. It's about relative movements rather than absolute ones; we're indifferent to whether prices are rising or falling. This quality defines it as a **neutral market strategy**.

## Spreading spreads

To check for deviations in our prices, we could simply subtract them and observe if the difference deviates significantly from zero, considering their scale difference.

Indeed, just subtracting the prices of two assets, as in $priceY−priceX$ may not provide a clear understanding of their relationship. Let's illustrate this with an example:

Consider the following series:

---

```q
priceX: 5 10 7 4 8

priceY: 23 30 25 30 35

spreads: priceY - priceX // = 18 20 18 26 27
```

> 💡 As you can see and verify through KDB+/Q array properties, spreads can be calculated by simply computing the difference between two vectors without the need for special functions or loops.

---

**These spread values don't offer much insight** into the relationship between the two assets. Are both assets increasing? Are they moving in opposite directions? It's unclear from these numbers alone.

Let's consider **using logarithms**, as they possess favourable properties for our pricing model. They inherently prevent negative values and tend to approach zero:

--- 

```q
log priceX = 1.609438 2.302585 1.94591 1.386294 2.079442

log priceY = 3.135494 3.401197 3.218876 3.401197 3.555348

spreads: log[priceY] - log priceX // = 1.526056 1.098612 1.272966 2.014903 1.475907
```

---

We're making progress, as we observe **numbers now fluctuating within much smaller ranges**. However, we're still missing a clear understanding of the underlying relationship. While we've normalized the data using logarithms, we now need to align their discrepancies to a single asset. 

Since both assets are related, **we can leverage linear regression** to our advantage. This enables us to simplify our spreads effectively. So, we'll conduct a basic linear regression analysis using historical data to discern the disparity between them:

--- 

```q
historical_data_priceX: 7 10 6 5 8

historical_data_priceY: 23 25 16 20 15

beta: betaF[historical_data_priceX;historical_data_priceY] // = 0.2679227

alpha: alphaF[historical_data_priceX;historical_data_priceY] // = 2.444817
```

### Code Explanation

As you can observe, we utilize the `betaF` and `alphaF` functions to compute the beta and alpha coefficients for a given dataset. Specifically, these functions perform linear regression to estimate alpha and beta based on historical values.

The implementation of these functions is based on the following formulas:

$\beta = \frac{{(n \cdot \sum(x \cdot y)) - (\sum x \cdot \sum y)}}{{(n \cdot \sum(x^2)) - (\sum x)^2}}$

$\alpha = \text{Mean}(y) - \beta \cdot \text{Mean}(x)$

---

We've already calculated the alpha and beta using the logarithmic values of our historical data (since we don't have prior knowledge of the real-time price values for priceX and priceY). Now, all that remains is to join everything together and apply linear reggresion to our price logarithms:

---

$spread = log(priceY) - (beta * log(priceX)+alpha)$

```q
spreads: historical_data_priceY - ((historical_data_priceX*beta)+alpha) // = -0.1493929 0.0451223 -0.08835117 0.0451223 0.1579725
```

> 🖥️ In KDB+/Q, operand priority is strictly from right to left, without any precedence rules except those involving parentheses. Therefore, it's crucial to exercise caution when writing Q code to ensure accurate results.

---

This precisely meets our objective—a **comprehensive method for representing relative changes between both assets**. As we can deduce, our mean is now 0 because our assets are normalized, cointegrated and on the same scale. Therefore, ideally, the differential between their prices should be 0. Consequently, when our spread is below 0, we infer that asset X is overpriced, whereas if it's above 0, then asset Y is overpriced.

![Spreads](https://github.com/hablapps/pairstrading/blob/5-Post/Spreads.gif?raw=true)

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
priceX: 0!1_(update delta:0f^deltas dateTime from 
        distinct select distinct dateTime, log bid, log ask from
        (update dateTime:"P"$@[;19;:;"."] each dateTime from 
        tab1) where not null bid);

priceY: 0!1_(update delta:0f^deltas dateTime from 
        distinct select distinct dateTime, log bid, log ask from 
        (update dateTime:"P"$@[;19;:;"."] each dateTime from 
        tab2) where not null bid);

// Read historical data
historial_tab2: 1_ flip `open`high`low`close`adjClose`vol!("FFFFFF";",") 0: `:/data/stocks/NASDAQ100_hist.csv;

historial_tab1: 1_ flip `open`high`low`close`adjClose`vol!("FFFFFF";",") 0: `:data/stocks/SP500_hist.csv;
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
