# Health financing decks: R code and data

This repository contains two R Markdown files. Each file rebuilds a World Bank health financing deck, slide by slide,
from public data saved in R's own format (RDS). Each slide has one code chunk with a short explanation above it. The
last chunk of each file checks the numbers printed by the file against the deck.

| Folder | What the file rebuilds |
|---|---|
| `Global decomposition deck/` | What accounted for the change in government health spending per person from 2000 to 2023 in every country with data, and the health budget prescription for 2027 to 2029 (35 slides). |
| `Country financing brief/` | The 23-slide country health financing profile (Policymaker version) for one country, chosen by its three-letter ISO code. |

Each folder contains everything the R Markdown file needs: the `.Rmd` file, data in `data/` and the Open Sans font
in `fonts/`. Every path in the code is relative to the folder. The files download nothing when they run.

To see the results without R, open `Global decomposition deck/global-decomposition-deck.html` in a web browser. For
the country brief, the GitHub repository holds a ready-made page for each of the fifteen reference countries in
[`Country financing brief/examples/`](https://github.com/arc-idn/wb-health-financing-decks-r/tree/main/Country%20financing%20brief/examples).
Clone the repository, open any of those pages in a web browser and choose another country from the **Country** list
at the top: that country's page opens at once.

## What you need

- **R 4.1 or later.** The code uses the native pipe `|>`.
- **RStudio**, or **pandoc** if you render from a terminal. RStudio already includes pandoc.
- **Ten R packages**, installed once:

```r
install.packages(c(
  "rmarkdown", "knitr", "dplyr", "tidyr", "tibble", "scales",
  "ggplot2", "ggrepel", "systemfonts", "ragg"
))
```

You do not need to install a font. Each file's setup chunk registers the Open Sans files in `fonts/` for its figures.

On Linux, R installs ragg and systemfonts from source, so the installation needs a few system libraries. On Ubuntu or
Debian:

```sh
sudo apt install libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libfribidi-dev \
  libpng-dev libtiff-dev libjpeg-dev libwebp-dev
```

Windows and macOS users get ready-built packages and need no extra steps.

## Get the files

Clone the repository:

```sh
git clone https://github.com/arc-idn/wb-health-financing-decks-r.git
cd wb-health-financing-decks-r
```

Or click **Code > Download ZIP** on this page and unzip the archive. Keep each folder whole. The `.Rmd` file reads
`data/` and `fonts/` from its own folder. Folder names contain spaces, so put the names in quotes in a terminal.

## Run the global decomposition deck

In RStudio, open `Global decomposition deck/global-decomposition-deck.Rmd` and press **Knit**.

From the R console, with the repository folder as the working directory:

```r
rmarkdown::render("Global decomposition deck/global-decomposition-deck.Rmd")
```

From a terminal, in the repository folder:

```sh
Rscript -e 'rmarkdown::render("Global decomposition deck/global-decomposition-deck.Rmd")'
```

A run takes under a minute and writes `global-decomposition-deck.html` next to the `.Rmd` file, replacing the example
included in the repository.

## Run the country financing brief

Set the country with `iso` in the header of `country-financing-brief.Rmd`:

```yaml
params:
  iso: "KEN"
```

**In RStudio**, change `"KEN"` to your chosen country's code (for example `"ETH"`) and press **Knit**. Or leave the
file unchanged and choose **Knit > Knit with Parameters...** to enter the code.

**From the R console**, provide the country code and an output filename:

```r
rmarkdown::render(
  "Country financing brief/country-financing-brief.Rmd",
  params = list(iso = "ETH"),
  output_file = "country-financing-brief-ETH.html"
)
```

The HTML file is written to `Country financing brief/`. Without `output_file`, each run writes
`country-financing-brief.html`, replacing the previous file.

**Several countries in one go:**

```r
for (iso in c("KEN", "ETH", "GHA")) {
  rmarkdown::render(
    "Country financing brief/country-financing-brief.Rmd",
    params = list(iso = iso),
    output_file = paste0("country-financing-brief-", iso, ".html"),
    envir = new.env()
  )
}
```

`envir = new.env()` gives each country a clean workspace. No object from one country carries into the next. Each run
for a country takes under a minute.

**Country codes.** The data cover 195 countries. To list the codes:

```r
countries <- readRDS("Country financing brief/data/countries.rds")
countries[, c("iso3", "name")]
```

**Ready-made pages for the fifteen reference countries.** On GitHub, `Country financing brief/examples/` holds one
rendered page for each reference country, with the **Country** list at the top of every page. Copies of this
repository sent as a zip file leave the fifteen pages out, because together the pages take about 70 MB. To build
the pages yourself, or to rebuild them after a change to the analysis, run this from the `Country financing brief`
folder (about four minutes):

```sh
Rscript examples/build_examples.R
```

The script renders the same `.Rmd` file for each country and only adds the **Country** list to the top of each
page.

## The check at the end of each file

The last chunk of each file compares the numbers the file prints with the numbers in the deck.

- **Global decomposition deck** (chunk `check-against-report`): the check compares every number on all 35 slides with
  the output tables used to build the deck (`data/reference_outputs.rds`). The rendered example compares 4,239 numbers
  and finds no mismatch.
- **Country financing brief** (chunk `reference-check`): for the fifteen reference countries (PHL, IDN, KHM, NGA, GHA,
  EGY, ETH, KEN, ZAF, MAR, SLE, SEN, CIV, BGD and LAO), the check compares every value with the deck's own text
  (`data/reference_slides.rds`). For any other country, the file renders in full and prints a note that the check covers
  only the fifteen reference countries.

When a number differs, the check prints a table of the differences and stops the knit. No HTML file is written. If you
deliberately change the analysis, for example by adding a year or another comparator, the check stops the knit because
your numbers no longer match the deck. To render your version, add `eval = FALSE` to that chunk's options, for example
`` ```{r reference-check, eval = FALSE} ``.

## Reading the result

The HTML file is self-contained and can be sent as one file. The code is folded away. A **Show** button above each
result opens that step's code, and the **Code** menu at the top right shows or hides all code. The table of contents
on the left lists the slides.

## Common problems

| Message | What to do |
|---|---|
| `there is no package called 'ragg'` (or another package) | Run the `install.packages()` line above. |
| `pandoc version 1.12.3 or higher is required` | Knit from RStudio, or install pandoc from <https://pandoc.org/installing.html>. |
| `No country with the code XYZ in data/countries.rds` | Use a three-letter ISO code from `countries.rds` (see above). Lower case also works. |
| `cannot open compressed file 'data/...'` when you run chunks one by one | In RStudio, set **Tools > Global Options > R Markdown > Evaluate chunks in directory** to **Document**, or open the `.Rmd` file from its own folder. |
| ragg or systemfonts fails to install on Linux | Install the system libraries listed under "What you need", then install the package again. |

## Data and versions

Each folder's `data/README.md` lists the source, retrieval date and sha256 checksum for every input used to create the
RDS files. Sources include the WHO Global Health Expenditure Database (2025 update), the World Bank's World
Development Indicators, the IMF World Economic Outlook (October 2026), the UN World Population Prospects 2024 and the
other sources listed there.

`Country financing brief/data-raw/` contains the two scripts that created the RDS files in
`Country financing brief/data/`: `convert_site_data.R` uses the deck site's published data, and `build_reference.R`
uses the deck's own HTML export. The scripts' inputs are not in this repository. The `.Rmd` file never calls the scripts.

The rendered examples were made with R 4.6.1. The last chunk of the global file prints the R and package versions used
to render the file.

Open Sans is distributed under the SIL Open Font License 1.1 (`fonts/OFL.txt`).
