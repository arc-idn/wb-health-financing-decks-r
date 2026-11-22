# Builds the example pages in this folder: the country brief for each of the fifteen reference
# countries, with a drop-down list at the top of every page to move from one country to another.
#
# Run it from the "Country financing brief" folder (the folder that holds the .Rmd file):
#   Rscript examples/build_examples.R
# It takes about four minutes. The analysis itself is untouched: we only add the drop-down list to
# the top of each page when we render it.

library(dplyr)

reference_isos <- c(
  "PHL", "IDN", "KHM", "NGA", "GHA", "EGY", "ETH", "KEN",
  "ZAF", "MAR", "SLE", "SEN", "CIV", "BGD", "LAO"
)

# we list the countries by name, as a reader looks for them
reference_countries <- readRDS("data/countries.rds") |>
  filter(iso3 %in% reference_isos) |>
  arrange(name) |>
  select(iso3, name)

# The drop-down list for one page, with that page's own country selected. Choosing another country
# opens its page, which sits next to this one in the examples folder.
switcher_html <- function(current_iso) {
  page_files <- paste0("country-financing-brief-", reference_countries$iso3, ".html")
  selected <- ifelse(reference_countries$iso3 == current_iso, " selected", "")
  country_options <- paste0(
    '  <option value="', page_files, '"', selected, ">",
    htmltools::htmlEscape(reference_countries$name), "</option>",
    collapse = "\n"
  )
  paste(
    "<style>",
    ".country-switcher { position: sticky; top: 0; z-index: 1100; background: #ffffff;",
    "  border-bottom: 1px solid #cccccc; padding: 8px 15px; font-size: 14px; }",
    ".country-switcher label { font-weight: 600; margin-right: 8px; }",
    ".country-switcher select { border: 1px solid #888888; border-radius: 0; padding: 3px 6px;",
    "  font-size: 14px; background: #ffffff; }",
    "</style>",
    '<div class="country-switcher">',
    '<label for="country-select">Country</label>',
    '<select id="country-select" onchange="window.location.href = this.value">',
    country_options,
    "</select>",
    "</div>",
    sep = "\n"
  )
}

for (iso in reference_countries$iso3) {
  switcher_file <- tempfile(fileext = ".html")
  writeLines(switcher_html(iso), switcher_file, useBytes = TRUE)

  rmarkdown::render(
    "country-financing-brief.Rmd",
    params = list(iso = iso),
    output_file = paste0("country-financing-brief-", iso, ".html"),
    output_dir = "examples",
    output_options = list(includes = list(before_body = switcher_file)),
    envir = new.env(),
    quiet = TRUE
  )
  message(iso, " done")
}
