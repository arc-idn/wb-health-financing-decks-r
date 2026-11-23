# Data for `country-financing-brief.Rmd`

Every file here is an R data frame saved as RDS. Each one is a reshaped copy of a data file that the
country deck (country health financing profile, Policymaker view, wb-works.site) loads in the browser:
nested JSON became long tables, values were copied as published, and a missing value stays missing
(absent rows or `NA`, never zero). All files cover every country, so any ISO3 code can be rendered.
The files were converted on 20 November 2026 from the site's data as of 17 November 2026; the dates
below are those of the sources. The two scripts that produced them are in `../data-raw/`; the Rmd does not
need them. `convert_site_data.R` only reshapes: it reads the deck's published data files (listed below with their
sha256, first 16 characters, as of 20 November 2026; the files themselves are not in this folder) and writes
every value as published. `build_reference.R` builds `reference_slides.rds`, the text of all 23 slides for the 15
reference countries, from the deck's own HTML export of 20 November 2026; the Rmd's last chunk checks its numbers
against that text.

| Site data file read by `convert_site_data.R` | sha256 |
|---|---|
| `health-financing/data/core.json` | `8d15044561a991f5` |
| `health-financing/data/detail.json` | `b0aba1520dc8a60f` |
| `health-financing/data/meta.json` | `20fbf5638c1267e4` |
| `health-financing/data/aggregates.json` | `eeef6ddc4e462bfe` |
| `health-outcomes/data/outcomes.json` | `4c3b78c8a3044e96` |
| `health-organization/data/health-inputs.json` | `2d847bbc9eacced7` |
| `country-profile/data/fiscal.json` | `93fa44498f38b392` |
| `country-profile/data/purchasing.json` | `5e65d80c1b655f43` |
| `country-profile/data/v2/financing.json` | `93966a04f5c2f2a8` |
| `country-profile/data/v2/funding.json` | `6ebbf6811afa8d75` |
| `country-profile/data/v2/services.json` | `aac8b83708c67443` |
| `country-profile/data/v3/lcu.json` | `84f164357d6af08e` |
| `country-profile/assets/images/cover/credits.json` | `e824ae06ae2301e5` |
| `health-payment/data/cofog-countries/*.json` (195 files) | `272e3de38e13cbd4` (sha256 of the sorted list of file checksums) |
| `health-payment/countries/*/record.json` (195 files) | `94b804142c38b73e` (sha256 of the sorted list of file checksums) |
| `country-profile/assets/js/deck/slides/s09/registry.js` | `7da5c16c4670ba01` |

| File | Rows x columns | Source | Retrieved or built |
|---|---|---|---|
| `countries.rds` | 195 x 6 | WHO Global Health Expenditure Database (GHED), 2025 update: country names; World Bank income groups (2023 classification as published by GHED) and regions; WHO regions. Rows are in the deck's own order (names sorted in English). | GHED file of 28 May 2026 |
| `group_labels.rds` | 12 x 4 | Labels and adjectives of the World Bank income groups and region names, as the site prints them. | 9 August 2026 (site build) |
| `ghed_financing.rds` | 157,179 x 4 | WHO GHED 2025 update, and World Bank World Development Indicators for the series GHED does not carry: one row per country, indicator code and year with a published value, 2000 to 2024. Codes used by the Rmd: `che_pc_usd`, `che_usd2023_pc`, `che_ppp_pc`, `che_gdp`, `gdp_pc_usd`, `gge_gdp`, `gghed_gge`, `gghed_che`, `gghed_pc_usd`, `gghed_ppp_pc`, `gghed_gdp`, `oops_che`, `ext_che`, `pvtd_che`, `other_pvtd_che`, `cfa_che`, `chi_che`, `vfa_che`, `cat10_oop`, `pop` (thousands). | GHED file of 28 May 2026; site build 9 August 2026 |
| `ghed_indicators.rds` | 41 x 4 | Codebook of the financing codes (title, unit, source), from the site's indicator registry. Not read by the Rmd. | 9 August 2026 |
| `ghed_group_stats.rds` | 11,700 x 10 | The site's precomputed group statistics of the GHED series: median, first and third quartile (type 7), countries reporting and members, and `suppressed` where fewer than 8 countries or under 70% of members report. Groupings: world, income group, World Bank region. | 9 August 2026 |
| `country_flags.rds` | 0 x 3 | GHED years in which a country's private residual is negative (none in this release); kept because the cover's reference year reads it. | 9 August 2026 |
| `outcomes.rds` | 96,324 x 4 | Outcome and coverage series, one row per country, series and year: World Bank WDI (UN IGME under-five mortality, UN maternal mortality, WHO GHO premature NCD mortality SH.DYN.NCOM.ZS, immunisation, skilled birth attendance, TB, HIV and malaria series, stunting), WHO and World Bank UHC service coverage index (2025), and financial hardship SDG 3.8.2, 2025 definition (WHO and World Bank, UHC global monitoring report 2025). | 3 October 2026 |
| `lcu_currency.rds` | 195 x 6 | Currency code and name, and GHED's 2023 exchange rate (GDP in national currency over GDP in US$); for a country without one, the reason (Cuba). | built 9 November 2026 from GHED, World Bank WDI currency metadata |
| `lcu_series.rds` | 5,876 x 6 | By country and year: GHED exchange rate, PPP conversion factor (World Bank WDI via GHED), GHED GDP price index (2023 = 100) and IMF World Economic Outlook October 2026 GDP deflator (2023 = 100, to 2031). | built 9 November 2026 |
| `imf_fiscal.rds` | 5,380 x 4 | IMF World Economic Outlook, general government net lending (GGXCNL_NGDP), and IMF Fiscal Monitor general government revenue, % of GDP, via IMF DataMapper. | 14 October 2026 |
| `imf_weo_projections.rds` | 3,230 x 7 | IMF World Economic Outlook, October 2026: real GDP per person (NGDPRPC, national currency), general government revenue, overall balance and expenditure (% of GDP), 2015 to 2031, and the latest year of actual data. | 23 October 2026 |
| `wpp_funding.rds` | 7,020 x 7 | UN World Population Prospects 2024, medium variant: population, deaths and under-five deaths, 2000 to 2035; and two value weights per death built from them: the output of working years regained (ages 15 to 64, 3% discount) and full income (a statistical life at 160 times income per person before age 75, Lancet Commission on Investing in Health, Global health 2050). | 27 October 2026 |
| `ghed_prevention.rds` | 808 x 6 | WHO GHED health care functions by financing source (SHA 2011): preventive care (HC.6) and curative care (HC.1) financed by domestic general government, % of its health spending, and the same from all sources, % of current health expenditure. | GHED file of 28 May 2026 |
| `ghed_medicines.rds` | 727 x 6 | WHO GHED line HC.5.1 (pharmaceuticals and other medical non-durables dispensed outside an episode of care), % of current health expenditure, and the shares financed by government, private and external sources where reported. | GHED file of 28 May 2026 |
| `medicine_availability.rds` | 37 x 3 | WHO Global Health Observatory, SDG indicator 3.b.3: facilities with a core set of essential medicines available and affordable, %. | site services file, built with the GHED file of 28 May 2026 |
| `workforce.rds` | 8,641 x 4 | WHO National Health Workforce Accounts via World Bank WDI: physicians (SH.MED.PHYS.ZS), nurses and midwives (SH.MED.NUMW.P3) and hospital beds (SH.MED.BEDS.ZS) per 1,000 people. | 23 August 2026 |
| `imf_cofog_health.rds` | 4,879 x 4 | IMF Government Finance Statistics, expenditure by function (GFS_COFOG 11.0.0), general government: public health services, hospital and outpatient services and unclassified health spending, % of the COFOG health total. | 10 August 2026 |
| `payment_records.rds` | 195 x 15 | What each country's provider payment record holds (Health Payment Explorer records, last verified 14 August 2026), and, where the record names no purchaser or payment arrangement, the size of a compilation of public sources (15 October 2026). | 14 August and 15 October 2026 |
| `payment_arrangements.rds` | 708 x 9 | The provider payment arrangements of those records and compilations: level of care, role, payment method, provider, status. | as above |
| `payment_methods.rds` | 12 x 2 | Payment method names from the site's payment-method registry (WHO, Analytical guide to assess a mixed provider payment system, 2019). | 14 August 2026 |
| `cover_credits.rds` | 195 x 3 | Photographer and licence of each cover photograph (Wikimedia Commons). | site file |
| `reference_slides.rds` | 330 x 5 | The deck's own text for the check at the end of the Rmd: for PHL, IDN, KHM, NGA, GHA, EGY, ETH, KEN, ZAF, MAR, SLE, SEN, CIV, BGD and LAO, each slide's heading, its visible text (speaker notes left out) and, kept apart, its axis tick labels. Taken from the deck's HTML export (live master 34c1366a, default year 2023). | 20 November 2026 |

## Fonts

`../fonts/` holds Open Sans (Regular, Italic, SemiBold, SemiBold Italic, Bold, Bold Italic), the typeface of the World
Bank decks, under the SIL Open Font Licence 1.1 (`../fonts/OFL.txt`). The Rmd registers it by relative path, so
nothing has to be installed.

## Licences of the sources

WHO GHED: CC BY-NC-SA 3.0 IGO. World Bank WDI and income groups: CC BY 4.0. IMF data: IMF terms of use. UN World
Population Prospects: CC BY 3.0 IGO. Cite the original sources when the numbers are reused.
