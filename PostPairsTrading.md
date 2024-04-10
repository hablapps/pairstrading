# A Match Made in Trading: Step by Step Pairs Trading Guide

Q/kdb+ stands out as **a powerful tool in finance**, renowned for its ability to handle vast volumes of real-time data amidst the relentless dynamics of the market. In this article, we embark on an insightful exploration of pair trading and its implementation in Q, offering a comprehensive guide to one of the most popular strategies in the trading world.

Our objective is to **provide a deep understanding of the intricacies of pair trading**, bridging the gap between theory and practice. Through a blend of theoretical insights and practical examples, we aim to equip you with the knowledge and skills necessary to navigate every aspect of this financial modeling strategy.

We'll proceed methodically, ensuring each question leads to a comprehensive answer. To start, we'll contextualize our current situation by addressing key questions such as **"What's our current situation?"** and **"What do we know about the market?"** Whether taking a technical or quantitative approach, these insights will provide valuable foundations for constructing our algorithm effectively.

## In the untamed realm of the market.

The market has often been described as a **stochastic** (a term which essentially means random) **process** where prices fluctuate irregularly. However, amidst this apparent randomness, we observe that **certain assets move in tandem** due to their inherent relationships. 

For instance, it's logical to expect that if the prices of petrol rise, the prices of cars should also rise. This is because auto companies rely on petrol for their operations, indicating an interconnectedness between the two. Over the long run, they tend to follow similar trends, **reflecting their underlying relationship**.

Is this described mathematically? **Yes**:

The concept we're referring to is **cointegration** (although there are other methods, we'll focus on this one).

Hence, we're interested in **cointegrated assets**, which are assets that exhibit the following characteristics:

1. They have a similar trend, meaning the difference between both assets maintains a constant mean, and this difference fluctuates around that same mean.

2. This inherent relationship persists in the long run, meaning that our series is not dependent on time.

## A pair in the hand is worth two in the bush.

### ADF testing

Imagine **we selected 13 world indexes** and aimed to assess whether they are **cointegrated or not**. In this scenario, a crucial tool at our disposal is the Augmented Dickey-Fuller (ADF) test.

> 💡 Please note that for simplicity in this code, we will be using pykx. This is necessary as we need to import our ADF test function and plot a heatmap of our results.
 
> `system "l pykx.q"`

Next, we import the statsmodels.tsa.stattools library and define a custom cointegration function that returns a dictionary with the ADF test results given 2 assets. We then apply our cointegration function to the Cartesian product of every pair of assets to get a matrix with every p-value. 

![cointegration](https://github.com/hablapps/pairstrading/blob/5-Post/CointAlGif.gif?raw=true)

q) 
---
`// Recieves 2 symbols and returns a dictionary`

`fCoint {[assetX;assetY;]
        ... }`

`crossedList: symList cross symList`

`matrix: fCoint .' crossedList;`

---

Now, with our matrix in hand, we can plot it and visually identify which asset is more favorable. Given our following assets:


|   SP500   | NASDAQ100 |   BFX    |   FCHI   |  GDAXI   |   HSI    |   KS11   |   MXX    |   N100   |   N225   |   NYA    |   RUT    |  STOXX   |
|:---------:|:---------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|
|   USA     |   USA     | Belgium  |  France  | Germany  | Hong Kong|S.Korea   |  Mexico  |  Europe  |  Japan   |   USA    |   USA    |  Europe  |

![ADF heatmap](https://github.com/hablapps/pairstrading/blob/5-Post/ADFgif.gif?raw=true)

As we can observe, there are several cointegrated indices, but our attention will be drawn towards the **NASDAQ100 and SP500** synergy. Both of these indices belong to the American market and share numerous characteristics. They encompass American companies traded within the same scenario, what makes them a perfect fit for our case.

## Cointegration, then what?

Let's recap our progress:

1. We've acknowledged the randomness of the market, yet discovered that certain assets exhibit similar movements.

2. By employing the cointegration method and the ADF test, we pinpointed a promising pair of assets for our analysis: NASDAQ100 and SP500.

3. These two assets exhibit similar movements and tend to gravitate around a shared mean.

Now we're faced with a crucial question: **"What do I do with these assets?"**

As mentioned earlier, the market is inherently random and doesn't always behave predictably. While NASDAQ100 and SP500 often follow similar trends, their individual values **can sometimes diverge significantly**. For instance, NASDAQ100 may rise while SP500 falls, or vice versa. 

However, this presents **an opportunity for profit** because we know that these assets tend to revert to their shared mean over time. If one asset is **overpriced** and likely to decrease, we may consider **selling it** (going short). Conversely, if an asset is **underpriced** and expected to increase, we may consider **buying it** (going long).

> 💡 This strategy possesses intriguing financial characteristics: our **profitability remains unaffected by the broader market trends**, as our focus lies solely on the disparity between the two assets. It's about relative movements rather than absolute ones; we're indifferent to whether prices are rising or falling. This quality defines it as a **neutral market strategy**.

## Spreading spreads

Indeed, just subtracting the prices of two assets, as in: $priceY−priceX$ may not provide a clear understanding of their relationship. Let's illustrate this with an example:

Consider the following series:

---

$priceX$: 5 10 7 4 8

$priceY$: 23 30 25 30 35

$spreads: priceY - priceX$ = 18 20 18 26 27

---

〽 These spread values don't offer much insight into the relationship between the two assets. Are both assets increasing? Are they moving in opposite directions? It's unclear from these numbers alone.

Let's consider using logarithms, as they possess favorable properties for our pricing model. They inherently prevent negative values and tend to approach zero:

--- 

$log priceX$: 1.609438 2.302585 1.94591 1.386294 2.079442

$log priceY$: 3.135494 3.401197 3.218876 3.401197 3.555348

$spreads: log priceY - log priceX$ = 1.526056 1.098612 1.272966 2.014903 1.475907

---

We're making progress, as we observe numbers now fluctuating within much smaller ranges. However, we're still missing a clear understanding of the underlying relationship. While we've normalized the data using logarithms, we now need to align their discrepancies to a single asset. 

Since both assets are related, we can leverage linear regression to our advantage. This enables us to simplify our spreads effectively. So, we'll conduct a basic linear regression analysis using historical data to discern the disparity between them:

--- 

$FORMULA: spread = log(priceY) - (beta * log(priceX)+alpha)$

$historical/data/priceX$: 7 10 6 5 8

$historical/data/priceY$: 23 25 16 20 15

$beta$ = 0.2679227

$alpha$ = 2.444817

---

We've already calculated the alpha and beta using the logarithmic values of our historical data (since we don't have prior knowledge of the real-time price values for priceX and priceY). Now, all that remains is to apply the previous formula to derive our spreads:

---

$spreads$ = -0.1493929 0.0451223 -0.08835117 0.0451223 0.1579725

---

And this precisely meets our objective—a comprehensive method for representing relative changes between both assets. As we can deduce, our mean is now 0 because our assets are normalized and cointegrated. Therefore, ideally, the differential between their prices should be 0. Consequently, when our spread is below 0, we infer that asset X is overpriced, whereas if it's above 0, then asset Y is overpriced.

![Spreads](https://github.com/hablapps/pairstrading/blob/5-Post/Spreads.gif?raw=true)





