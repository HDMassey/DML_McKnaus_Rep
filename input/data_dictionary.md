# Data dictionary

This file documents the variables used downstream in the replication. Variable names correspond to the Swiss ALMP raw CSV file.

| Variable | Description | Units / coding | Used in |
|---|---|---|---|
| `treatment6` | Program category. Main values used are no program, job search, vocational, computer, and language. | Categorical | Treatment variable `w` |
| `canton_german` | Indicator for German-speaking canton. | 1 = German-speaking canton | Sample restriction |
| `start_q2` | Indicator for program start timing in months 4-6. | Binary | Timing / pseudo-start construction |
| `employed1`-`employed36` | Monthly employment indicators after unemployment registration. | Binary by month | Outcome construction |
| `age` | Age of unemployed individual. | Years | Covariate |
| `female` | Female indicator. | Binary | Covariate and Table 4 subgroup |
| `foreigner_b`, `foreigner_c` | Foreigner status indicators. | Binary | Covariate and Table 4 subgroup |
| `employability` | Caseworker/employment-office employability rating. | Ordered categories | Covariate and Table 4 subgroup |
| `past_income` | Previous income. | CHF | Covariate |
| `canton_moth_tongue` | Canton/mother-tongue related indicator. | Binary/categorical encoded | Covariate |
| `city_big`, `city_medium`, `city_no` | City-size indicators. | Binary | Covariates |
| `cw_age`, `cw_female`, `cw_missing` | Caseworker age, gender, and missing indicator. | Numeric/binary | Covariates |
| `cw_cooperative`, `cw_own_ue`, `cw_tenure` | Caseworker characteristics. | Numeric/binary | Covariates |
| `cw_educ_above_voc`, `cw_educ_tertiary`, `cw_voc_degree` | Caseworker education indicators. | Binary | Covariates |
| `emp_share_last_2yrs` | Share of months employed in previous two years. | Share | Covariate |
| `emp_spells_5yrs` | Number of employment spells in previous five years. | Count | Covariate |
| `gdp_pc` | Regional GDP per capita. | CHF | Covariate |
| `married` | Married indicator. | Binary | Covariate |
| `other_mother_tongue` | Mother tongue not German/French/Italian. | Binary | Covariate |
| `prev_job_*` | Previous job type, sector, skill, and self-employment indicators. | Binary | Covariates |
| `qual_*` | Qualification and education indicators. | Binary | Covariates |
| `swiss` | Swiss citizen indicator. | Binary | Covariate |
| `ue_cw_allocation1`-`ue_cw_allocation6` | Unemployment office/caseworker allocation indicators. | Binary | Covariates |
| `ue_spells_last_2yrs` | Unemployment spells in previous two years. | Count | Covariate |
| `unemp_rate` | Local/regional unemployment rate. | Percent/rate | Covariate |

The analysis uses exactly 45 covariates, matching the covariate count reported in the paper.
