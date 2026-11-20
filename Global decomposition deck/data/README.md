# Data for `global-decomposition-deck.Rmd`

Every file here is an R data file (RDS) read by the Rmd with a relative path (`data/<file>.rds`). The four input files
were converted one to one from the CSV inputs of the report the deck was built from, with the same `read.csv()` options
the report uses, so the columns and their types are the same as in the report:

```r
read.csv(<file>.csv, comment.char = "#", stringsAsFactors = FALSE, na.strings = c("", "NA"))  # ghed_extract, countries
read.csv(<file>.csv, comment.char = "#", stringsAsFactors = FALSE)                            # group_labels, weo_currency_extract
```

The CSV header lines (starting with `#`) carried the source notes repeated below; values were not changed.

## Inputs

| File | Source | Retrieved | Rows x columns | sha256 of the source CSV |
|---|---|---|---|---|
| `ghed_extract.rds` | World Health Organization, Global Health Expenditure Database (GHED), 2025 update, as published in the Health Financing Transition Explorer (wb-works.site), build 2026-08-09. Seven series for every country and year, values unchanged: `gdp_pc_usd`, `gge_gdp`, `gghed_gge`, `che_pc_usd`, `che_usd2023_pc`, `gghed_pc_usd`, `pop`. Licence CC BY-NC-SA 3.0 IGO. | 2026-05-28 | 32,209 x 11 | `11b58001ab4c380a07914d12558bfdffa35d1ee78d3201617ba4bdf04c9063c9` |
| `countries.rds` | The 195 countries with World Bank income group and region (2023 classification, as published with the GHED 2025 update; World Bank country and region metadata, CC BY 4.0), from the same Explorer build. | 2026-05-28 | 195 x 5 | `70a2d1b4af04ae119487f773aae1079163fc4bff9833208d4ba1ae1e62fd4a54` |
| `group_labels.rds` | Labels and member counts of the four World Bank income groups and the World Bank regions, from the same Explorer build. | 2026-05-28 | 12 x 4 | `27f1a16ca82cebc7cfedfdaad0b42660e9b4e16bc4d05898dac4ad1eb5c9671f` |
| `weo_currency_extract.rds` | IMF, World Economic Outlook database, October 2026 (IMF data API, dataflow IMF.RES/WEO): `NGDP` (GDP, national currency, current prices), `NGDP_R` (GDP, national currency, constant prices), `GGX_NGDP` (general government total expenditure, % of GDP), `NGDPD` (GDP, current US$), `LP` (population), 2024 to 2029, full units, missing values omitted. Terms of use of the IMF World Economic Outlook database. | 2026-10-23 | 5,564 x 4 | `bcee76baf19141f00ad602a80b595c6c03cb89d8c4b0419dd5757d21177550ca` |

Why these four and no others: Section 1 of the deck needs only the GHED series, the country list and the group labels;
Section 2 adds the IMF series in national currency. Two other inputs of the report are left out because the deck does
not draw on them: the IMF real GDP, revenue and expenditure series used only by the report's benchmark-check annex, and a
small table of values read off a country profile chart, used only for a cross-check inside the report.

## Reference outputs (for the final check only)

`reference_outputs.rds` is a named list of 15 data frames: the report's own output tables, the tables the deck was built
from, read with `read.csv(<file>.csv, stringsAsFactors = FALSE, check.names = FALSE)`. The Rmd never uses them to
compute a slide; its last chunk runs every slide function on these tables and on its own results and stops on any
difference in a printed number.

| Element | Rows x columns | sha256 of the source CSV |
|---|---|---|
| `country_window_decomposition` | 195 x 40 | `0ce9213837db8b8a2859c68fffdc9b8ce7fb6c7fa9626ae73e5e963b11d65079` |
| `country_period_decomposition` | 567 x 12 | `4d4dbb8f785a924e9b5b1d33b957f667509b14b9b0bbfea31b694bb47929fcd7` |
| `group_decomposition` | 52 x 18 | `27a743fa7af5baa0f372dd83c670cea179a79a31d62a3e8b72ddb4f6fb1fc56d` |
| `group_window_medians_without_flagged` | 13 x 8 | `282049c58c47270dc297f9586aebe64b9f14cef9c2480ad2f77b3e34ec85abdf` |
| `group_aggregates_2013_2023_without_flagged` | 13 x 8 | `22ca8cee63144e84892da6b994f47c83883de9284de9857591cefec7259b6454` |
| `trends_2000_2023` | 312 x 21 | `ba903dcd6112bba850ab4195dbc9268054946b443f75e7b3797a8277560f2c99` |
| `health_priority_pandemic_countries` | 193 x 10 | `a45b5a9f6ba81507f5f50e075f3900e8f339f15821869487c635e0c1e5f416a0` |
| `health_priority_pandemic_groups` | 13 x 13 | `d11b44ee5edae17632b868f53f2785468e05d2cbfd8186b5f918798c944b5017` |
| `patterns_by_income` | 5 x 8 | `90d9862312ad9a678cf0ed6dff34bdbe6606f79b26be601711e5449cd001857b` |
| `patterns_by_region` | 9 x 8 | `282fa055f05887a63c24b8fe8f46950b07347152892f3187fb26f8056dbdd861` |
| `patterns_by_period_income` | 15 x 9 | `c5584803c7027bff2eda195652b9236e5570c8d0babbf0e68ff449aa3eacdfd5` |
| `income_group_contributions_2013_2023` | 191 x 9 | `0df3d44503fef711c5363f199ad78fba833c3abcdd5f20678a1a9048f840d369` |
| `prescription_country_year` | 1,164 x 75 | `7a246fb145e0b42f6c1c6a73a2441f13b1f6ca4701d48c0f2897e81ee4055e65` |
| `prescription_lines_2024_2029` | 2,328 x 12 | `d572fdabc7b7a60dae629b382d82e7708023363a1342a78fa98bf8848f999596` |
| `prescription_groups` | 78 x 24 | `aa0ac0b352612c10502aaabb98cae23fd1ac9566221a7f842e0f3c9fafb3a7f8` |

The prescription tables store numbers to eight significant digits; every other table stores them as R writes a CSV
(15 significant digits).

## Fonts

`../fonts/` holds the six Open Sans files (Regular, Italic, SemiBold, SemiBoldItalic, Bold, BoldItalic) and their
licence, `OFL.txt` (SIL Open Font Licence 1.1). The Rmd registers them at the start of its setup chunk, so the figures
use Open Sans on any computer without installing the font.
