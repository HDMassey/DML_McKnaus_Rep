# Proposal

I replicate Knaus (2022), "Double machine learning-based programme evaluation under unconfoundedness," published in *The Econometrics Journal*.

The data source is the restricted-use Swiss Active Labor Market Policy Evaluation dataset available through SwissUbase/FORSbase. The raw data are not committed to the public repository; the `input/README.md` file explains how to obtain and place the data.

The specific result I replicate is Table 4, "Group average treatment effects." This table reports group average treatment effects for job search, vocational, computer, and language programs relative to no program, with heterogeneity by female status, foreigner status, and employability.

My planned toolchain is R for preprocessing and estimation, using `dplyr`, `grf`, `causalDML`, `lmtest`, and `sandwich`; LaTeX for the paper; and a Makefile for automation.

This paper interests me because it connects causal machine learning to a real program evaluation problem. It also gives a useful application of double machine learning, which is directly related to class material on using machine learning for causal inference rather than pure prediction.
