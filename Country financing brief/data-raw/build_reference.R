# Builds ../data/reference_slides.rds: the text of every slide of the Policymaker deck, as the deck's own HTML
# export prints it, for the fifteen reference countries. The Rmd's last chunk checks its numbers against it.
#   Rscript build_reference.R <folder with <ISO>/<ISO>-country-profile-policy.html>
# Kept per slide: the slide heading and all visible text (speaker notes left out). Axis tick labels (plain
# numbers drawn in the chart's ink colour with no weight) are kept apart, because they are scale marks of the
# drawing library rather than numbers the analysis computes.

suppressPackageStartupMessages(library(xml2))
args <- commandArgs(trailingOnly = TRUE)
IN <- args[1]
ISOS <- c("PHL", "IDN", "KHM", "NGA", "GHA", "EGY", "ETH", "KEN", "ZAF", "MAR", "SLE", "SEN", "CIV", "BGD", "LAO")
squish <- function(x) trimws(gsub("[[:space:]   ]+", " ", x))
TICK <- "^[+-]?[0-9][0-9,]*(\\.[0-9]+)?(%|×)?$|^1/[0-9]+$"

one <- function(iso) {
  f <- file.path(IN, iso, paste0(iso, "-country-profile-policy.html"))
  doc <- read_html(f)
  secs <- xml_find_all(doc, "//section[contains(concat(' ', @class, ' '), ' slide ')]")
  do.call(rbind, lapply(seq_along(secs), function(i) {
    s <- secs[[i]]
    xml_remove(xml_find_all(s, ".//aside"))
    ticks <- character()
    for (t in xml_find_all(s, ".//*[local-name()='svg']//*[local-name()='text']")) {
      txt <- squish(xml_text(t))
      a <- xml_attrs(t)
      if (grepl(TICK, txt) && identical(unname(a["fill"]), "#13212f") && !"font-weight" %in% names(a) && !"transform" %in% names(a)) {
        ticks <- c(ticks, txt)
        xml_remove(t)
      }
    }
    h1 <- xml_find_first(s, ".//h1")
    nodes <- xml_find_all(s, ".//text()[not(ancestor::style) and not(ancestor::script)]")
    data.frame(iso3 = iso, slide = i, title = if (inherits(h1, "xml_missing")) "" else squish(xml_text(h1)),
               text = squish(paste(xml_text(nodes), collapse = " ")), ticks = paste(ticks, collapse = " "),
               stringsAsFactors = FALSE)
  }))
}
reference_slides <- do.call(rbind, lapply(ISOS, one))
attr(reference_slides, "built") <- format(Sys.Date())
saveRDS(reference_slides, "../data/reference_slides.rds", compress = "xz")
cat(nrow(reference_slides), "slides from", length(ISOS), "countries\n")
