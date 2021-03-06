# AssetMgmt

[![Build Status](https://travis-ci.org/cgroll/AssetMgmt.jl.png)](https://travis-ci.org/cgroll/AssetMgmt.jl)


# Full strategy

A full asset allocation strategy could make use of the following
sources of information:

- stochastic representation of asset returns and their future
  evolution
- asset prices: converting fractional weights to integers
- investment history
	- turnover minimization
	- historic portfolio performance and risks taken
	- taxable gains / losses for tax optimization
- cash-flow data
	- initial investment
	- deposit in / out
- client data: tax allowance, tax classes
- partial execution
	- live trading with feedback loop
- unknown unknowns?

# Strategy representation

Different strategies require different granularity of overall
information. All strategies are subtypes of abstract type
`FullStrategy`. 

## StaticStrategy

Fix weights regardless of market data.

## InitialStrategy

Optimizes portfolio with respect to single period. Turnover
problematic becomes irrelevant: only asset return model as additional
information required.

````
optimizeWgts(strat::InitialStrategy, univ::UniverseModel)
````

## 

Multi-period setting: portfolio rebalancing with turnover
maximization. Specifies initial investment strategy, rebalancing
strategy and turnover filter. Doesn't deal with weight discreteness,
cash-flows or taxes.

````
optimizeWgts(strat::??, univ::UniverseModel, invHistory::Investments)
````

# Backtesting 

## Repeated application of estimator

Estimate model for each date in order to get insights into variation
in asset return distributions. If possible, array of estimated models
is simplified to more concise output.

````
applyMuSigmaModelEstimator
````

Output: array of mus, sigmas and correlations, with values only for
those days with enough data for model estimation.

## Repeated application of strategy

Recursive. 

Output: investments, expected portfolio properties


# Glossary

- **estimator**: way of getting concrete specification of asset return
  model
- **model**: complete specification of asset return model
- **universe**: complete specification of asset return model together
  with information to redo estimation process (for resampling
  techniques to deal with estimation uncertainty)
	- model
	- estimator
	- data
- **strategy**: investment rules of different granularity
- **investments**: series of resulting portfolio weights
