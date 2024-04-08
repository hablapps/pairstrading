# A match made in trading: A step by step Pairs Trading guide

Q/kdb+ stands out as **a powerful tool in finance**, renowned for its ability to handle vast volumes of real-time data amidst the relentless dynamics of the market. In this article, we embark on an insightful exploration of pair trading and its implementation in Q, offering a comprehensive guide to one of the most popular strategies in the trading world.

Our objective is to **provide a deep understanding of the intricacies of pair trading**, bridging the gap between theory and practice. Through a blend of theoretical insights and practical examples, we aim to equip you with the knowledge and skills necessary to navigate every aspect of this financial modeling strategy.

We'll proceed methodically, ensuring each question leads to a comprehensive answer. To start, we'll contextualize our current situation by addressing key questions such as **"What's our current situation?"** and **"What do we know about the market?"** Whether taking a technical or quantitative approach, these insights will provide valuable foundations for constructing our algorithm effectively.

## In the untamed realm of the market.

The market has often been described as a **stochastic** (a term which essentially means random) **process** where prices fluctuate irregularly. However, amidst this apparent randomness, we observe that **certain assets move in tandem** due to their inherent relationships. For instance, it's logical to expect that if the prices of petrol rise, the prices of cars should also rise. This is because auto companies rely on petrol for their operations, indicating an interconnectedness between the two. Over the long run, they tend to follow similar trends, reflecting their underlying relationship.

Is this described mathematically? **Yes**:

The concept we're referring to is **cointegration** (although there are other methods, we'll focus on this one).

Hence, we're interested in **cointegrated assets**, which are assets that exhibit the following characteristics:

1. They have a similar trend, meaning the difference between both assets maintains a constant mean, and this difference fluctuates around that same mean.

2. This inherent relationship persists in the long run, meaning that our series is not dependent on time.

## A pair in the hand is worth two in the bush.

Imagine **we selected 13 world indexes** and aimed to assess whether they are **cointegrated or not**. In this scenario, a crucial tool at our disposal is the Augmented Dickey-Fuller (ADF) test.

[INSERT CODE HERE]

![cointegration](https://github.com/hablapps/pairstrading/blob/5-Post/tfg18.png?raw=true)

As we may see, there are many cointegrated indices, but we will focus on NASDAQ100 and SP500 synergie.


