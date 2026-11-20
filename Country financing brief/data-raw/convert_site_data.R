# Converts the JSON files that the country deck reads in the browser into the RDS files in ../data/.
# Run once from this folder with SITE pointing at the site's tools folder; the Rmd itself never needs it.
#   Rscript convert_site_data.R /path/to/site/tools
# Nothing is computed here beyond reshaping: every value is copied as published, nested JSON becomes
# long data frames, and a missing value stays missing.

suppressPackageStartupMessages({
  library(jsonlite)
})

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Give the path of the site's tools/ folder: Rscript convert_site_data.R /path/to/site/tools")
SITE <- args[1]
OUT <- "../data"
dir.create(OUT, showWarnings = FALSE)
rd <- function(...) fromJSON(file.path(SITE, ...), simplifyVector = FALSE)
num <- function(x) if (is.null(x)) NA_real_ else as.numeric(x)
chr <- function(x) if (is.null(x)) NA_character_ else as.character(x)
save <- function(x, name) {
  saveRDS(x, file.path(OUT, paste0(name, ".rds")), compress = "xz")
  cat(sprintf("%-28s %8d rows  %2d cols\n", name, nrow(x), ncol(x)))
}

# ---- WHO GHED panel (health-financing/data: core.json, detail.json, meta.json, aggregates.json) ----------
core <- rd("health-financing", "data", "core.json")
detail <- rd("health-financing", "data", "detail.json")
meta <- rd("health-financing", "data", "meta.json")

# countries, in the deck's own order (names sorted with English collation, as JavaScript localeCompare)
cl <- core$countries
countries <- data.frame(
  iso3 = vapply(cl, function(c) c$iso3, ""),
  name = vapply(cl, function(c) c$name, ""),
  type = vapply(cl, function(c) chr(c$type), ""),
  income_group = vapply(cl, function(c) chr(c$income_group), ""),
  wb_region = vapply(cl, function(c) chr(c$wb_region), ""),
  who_region = vapply(cl, function(c) chr(c$who_region), ""),
  stringsAsFactors = FALSE
)
countries <- countries[stringi::stri_order(countries$name, locale = "en"), ]
rownames(countries) <- NULL
save(countries, "countries")

# composition flags (years in which GHED's private residual is negative), used for the reference year
flags <- do.call(rbind, lapply(cl, function(c) {
  y <- unlist(c$flags$private_residual_negative)
  if (!length(y)) return(NULL)
  data.frame(iso3 = c$iso3, flag = "private_residual_negative", year = as.integer(y))
}))
if (is.null(flags)) flags <- data.frame(iso3 = character(), flag = character(), year = integer())
save(flags, "country_flags")

# income group and region labels
ig <- meta$income_groups
group_labels <- rbind(
  data.frame(grouping = "income", key = unlist(ig$keys),
             label = unlist(ig$labels[unlist(ig$keys)]), adjective = unlist(ig$adjectival[unlist(ig$keys)])),
  data.frame(grouping = "wb_region", key = names(meta$regions$wb$labels),
             label = unlist(meta$regions$wb$labels), adjective = NA_character_)
)
rownames(group_labels) <- NULL
save(group_labels, "group_labels")

# every financing series, long: one row per country, indicator and year with a published value
series_long <- function(tier) {
  y0 <- tier$year_min
  do.call(rbind, lapply(names(tier$countries), function(iso) {
    s <- tier$countries[[iso]]$series
    do.call(rbind, lapply(names(s), function(code) {
      v <- vapply(s[[code]], num, 0)
      ok <- is.finite(v)
      if (!any(ok)) return(NULL)
      data.frame(iso3 = iso, code = code, year = as.integer(y0 + which(ok) - 1), value = v[ok])
    }))
  }))
}
fin_core <- series_long(core)
fin_detail <- series_long(detail)
# detail.json wins where both tiers carry a code (the site merges { ...core, ...detail })
fin_core <- fin_core[!paste(fin_core$iso3, fin_core$code) %in% unique(paste(fin_detail$iso3, fin_detail$code)), ]
financing <- rbind(fin_core, fin_detail)
financing <- financing[order(financing$iso3, financing$code, financing$year), ]
rownames(financing) <- NULL
save(financing, "ghed_financing")

# indicator names and units (the site's indicator registry in meta.json), for the README and labels
ind <- meta$indicators
indicators <- do.call(rbind, lapply(names(ind), function(k) {
  x <- ind[[k]]
  data.frame(code = k, title = chr(x$title), unit = chr(x$unit), source = chr(x$source_id))
}))
indicators <- indicators[indicators$code %in% unique(financing$code), ]
rownames(indicators) <- NULL
save(indicators, "ghed_indicators")

# the site's precomputed group statistics (median and quartiles with the 8-reporter, 70% rule applied)
agg <- rd("health-financing", "data", "aggregates.json")
gs <- list()
for (grouping in c("global", "income", "wb_region")) {
  for (key in names(agg$stats[[grouping]])) {
    codes <- agg$stats[[grouping]][[key]]
    for (code in names(codes)) {
      cells <- codes[[code]]
      gs[[length(gs) + 1]] <- data.frame(
        grouping = grouping, key = key, code = code, year = as.integer(names(cells)),
        median = vapply(cells, function(c) num(c$median), 0),
        q1 = vapply(cells, function(c) num(c$q1), 0),
        q3 = vapply(cells, function(c) num(c$q3), 0),
        n_avail = vapply(cells, function(c) num(c$n_avail), 0),
        n_members = vapply(cells, function(c) num(c$n_members), 0),
        suppressed = vapply(cells, function(c) isTRUE(c$suppressed), TRUE)
      )
    }
  }
}
group_stats <- do.call(rbind, gs)
rownames(group_stats) <- NULL
save(group_stats, "ghed_group_stats")

# ---- outcomes and coverage (health-outcomes/data/outcomes.json: WDI, WHO GHO, UHC monitoring) ----------
oc <- rd("health-outcomes", "data", "outcomes.json")
outcomes <- do.call(rbind, lapply(names(oc$countries), function(iso) {
  s <- oc$countries[[iso]]$series
  do.call(rbind, lapply(names(s), function(id) {
    v <- vapply(s[[id]], num, 0)
    ok <- is.finite(v)
    if (!any(ok)) return(NULL)
    data.frame(iso3 = iso, id = id, year = as.integer(names(v)[ok]), value = unname(v[ok]))
  }))
}))
outcomes <- outcomes[order(outcomes$iso3, outcomes$id, outcomes$year), ]
rownames(outcomes) <- NULL
save(outcomes, "outcomes")

# ---- local currency (country-profile/data/v3/lcu.json: WHO GHED rate and PPP, IMF WEO deflator) --------
lcu <- rd("country-profile", "data", "v3", "lcu.json")
lcu_currency <- do.call(rbind, lapply(names(lcu$countries), function(iso) {
  r <- lcu$countries[[iso]]
  data.frame(iso3 = iso, code = chr(r$code), unit = chr(r$unit), name = chr(r$name), rate = num(r$rate))
}))
miss <- lcu$missing
lcu_currency <- rbind(lcu_currency, data.frame(iso3 = names(miss), code = NA, unit = NA, name = NA, rate = NA))
lcu_currency$missing_reason <- NA_character_
lcu_currency$missing_reason[match(names(miss), lcu_currency$iso3)] <- unlist(miss)
save(lcu_currency, "lcu_currency")
lcu_series <- do.call(rbind, lapply(names(lcu$countries), function(iso) {
  r <- lcu$countries[[iso]]
  yrs <- sort(unique(as.integer(c(names(r$xr), names(r$ppp), names(r$defl), names(r$gdpd)))))
  g <- function(o) vapply(as.character(yrs), function(y) num(o[[y]]), 0)
  data.frame(iso3 = iso, year = yrs, xr = g(r$xr), ppp = g(r$ppp), defl = g(r$defl), gdpd = g(r$gdpd))
}))
rownames(lcu_series) <- NULL
save(lcu_series, "lcu_series")

# ---- IMF (country-profile/data/fiscal.json and v2/financing.json) ---------------------------------------
fis <- rd("country-profile", "data", "fiscal.json")
isos <- union(names(fis$nld), names(fis$rev))
imf_fiscal <- do.call(rbind, lapply(isos, function(iso) {
  a <- fis$nld[[iso]]; b <- fis$rev[[iso]]
  yrs <- sort(unique(as.integer(c(names(a), names(b)))))
  data.frame(iso3 = iso, year = yrs,
             net_lending = vapply(as.character(yrs), function(y) num(a[[y]]), 0),
             revenue = vapply(as.character(yrs), function(y) num(b[[y]]), 0))
}))
rownames(imf_fiscal) <- NULL
save(imf_fiscal, "imf_fiscal")

weo <- rd("country-profile", "data", "v2", "financing.json")
wy <- unlist(weo$years)
imf_weo <- do.call(rbind, lapply(names(weo$countries), function(iso) {
  r <- weo$countries[[iso]]
  g <- function(k) { v <- r[[k]]; if (is.null(v)) rep(NA_real_, length(wy)) else vapply(v, num, 0) }
  data.frame(iso3 = iso, year = as.integer(wy), gdp_pc_real = g("gdpr"), revenue = g("rev"),
             balance = g("bal"), expenditure = g("exp"), last_actual = num(r$actual))
}))
rownames(imf_weo) <- NULL
save(imf_weo, "imf_weo_projections")

# ---- UN WPP 2024 inputs for the funding slide (country-profile/data/v2/funding.json) ------------------
fu <- rd("country-profile", "data", "v2", "funding.json")
fy <- unlist(fu$years)
wpp <- do.call(rbind, lapply(names(fu$countries), function(iso) {
  r <- fu$countries[[iso]]
  g <- function(k) { v <- r[[k]]; if (is.null(v)) rep(NA_real_, length(fy)) else vapply(v, num, 0) }
  data.frame(iso3 = iso, year = as.integer(fy), population = g("pop"), deaths = g("deaths"),
             deaths_under5 = g("u5"), value_work = g("work"), value_full = g("vsl"))
}))
rownames(wpp) <- NULL
save(wpp, "wpp_funding")

# ---- WHO GHED health care functions (country-profile/data/v2/services.json) ---------------------------
sv <- rd("country-profile", "data", "v2", "services.json")$countries
rows <- function(key, cols) do.call(rbind, lapply(names(sv), function(iso) {
  x <- sv[[iso]][[key]]
  if (!length(x)) return(NULL)
  d <- data.frame(iso3 = iso, year = vapply(x, function(p) as.integer(p$year), 0L))
  for (k in cols) d[[k]] <- vapply(x, function(p) num(p[[k]]), 0)
  d
}))
ghed_prevention <- rows("prev", c("gov_prev", "gov_cur", "all_prev", "all_cur"))
save(ghed_prevention, "ghed_prevention")
ghed_medicines <- rows("med", c("share", "gov", "pvt", "ext"))
save(ghed_medicines, "ghed_medicines")
medicine_availability <- rows("avail", "value")
save(medicine_availability, "medicine_availability")

# ---- health workforce (health-organization/data/health-inputs.json, WDI) -------------------------------
hi <- rd("health-organization", "data", "health-inputs.json")$countries
workforce <- do.call(rbind, lapply(names(hi), function(iso) {
  ind <- hi[[iso]]$indicators
  do.call(rbind, lapply(c("SH.MED.PHYS.ZS", "SH.MED.NUMW.P3", "SH.MED.BEDS.ZS"), function(code) {
    x <- ind[[code]]
    if (!length(x)) return(NULL)
    d <- data.frame(iso3 = iso, code = code, year = vapply(x, function(p) as.integer(p$year), 0L),
                    value = vapply(x, function(p) num(p$value), 0))
    d[is.finite(d$value), ]
  }))
}))
rownames(workforce) <- NULL
save(workforce, "workforce")

# ---- IMF government spending by function, general government (health-payment/data/cofog-countries) ----
cf <- list.files(file.path(SITE, "health-payment", "data", "cofog-countries"), pattern = "\\.json$", full.names = TRUE)
lines <- c("GF0740_T", "GF073_T", "GF072_T", "GF0760_T")
cofog <- do.call(rbind, lapply(cf, function(f) {
  x <- fromJSON(f, simplifyVector = FALSE)$countries
  do.call(rbind, lapply(names(x), function(iso) {
    yrs <- x[[iso]]$sectors$S13$years
    if (!length(yrs)) return(NULL)
    do.call(rbind, lapply(names(yrs), function(y) {
      g <- yrs[[y]]$groups
      data.frame(iso3 = iso, year = as.integer(y), line = lines,
                 share_of_health = vapply(lines, function(l) num(g[[l]]$share_of_cofog_health), 0))
    }))
  }))
}))
cofog <- cofog[is.finite(cofog$share_of_health), ]
rownames(cofog) <- NULL
save(cofog, "imf_cofog_health")

# ---- provider payment (health-payment/countries/<ISO>/record.json and country-profile/data/purchasing.json)
pur <- rd("country-profile", "data", "purchasing.json")
rec_files <- list.files(file.path(SITE, "health-payment", "countries"), pattern = "record\\.json$", recursive = TRUE, full.names = TRUE)
arr_rows <- function(iso, src, list) {
  if (!length(list)) return(NULL)
  do.call(rbind, lapply(list, function(a) data.frame(
    iso3 = iso, source = src, care_level = chr(a$care_level), role = chr(a$role),
    payment_method = chr(a$payment_method), payment_method_id = chr(a$payment_method_id),
    provider_label = chr(a$provider_label), implementation_status = chr(a$implementation_status),
    recipient_level = chr(a$recipient_level))))
}
recs <- list(); arrs <- list()
for (f in rec_files) {
  r <- fromJSON(f, simplifyVector = FALSE)
  iso <- basename(dirname(f))
  narr <- function(topic) {
    e <- Filter(function(z) identical(z$topic, topic), r$executive_narrative)
    if (length(e)) chr(e[[1]]$text) else NA_character_
  }
  kt <- Filter(function(z) identical(z$id, "key_tension"), r$narrative_sections)
  pd <- r$architecture_dimensions$pooling_architecture
  if (is.null(pd)) pd <- r$architecture$dimensions$pooling_architecture
  recs[[iso]] <- data.frame(
    iso3 = iso, has_record = TRUE,
    record_purchasers = length(r$purchasers), record_arrangements = length(r$payment_arrangements),
    record_sources = length(r$sources), pooling_dimension = chr(pd),
    key_tension = if (length(kt)) chr(kt[[1]]$text) else NA_character_,
    narrative_architecture = narr("architecture"), narrative_purchasing = narr("purchasing_registry"),
    narrative_payment = narr("payment_registry"),
    has_purchasing_profile = !is.null(r$purchasing_profile), has_architecture = !is.null(r$architecture)
  )
  arrs[[length(arrs) + 1]] <- arr_rows(iso, "record", r$payment_arrangements)
}
payment_records <- do.call(rbind, recs)
comp <- do.call(rbind, lapply(names(pur), function(iso) {
  s <- pur[[iso]]
  data.frame(iso3 = iso, compilation_purchasers = length(s$purchasers),
             compilation_arrangements = length(s$payment_arrangements), compilation_sources = length(s$sources))
}))
payment_records <- merge(payment_records, comp, by = "iso3", all = TRUE)
payment_records$has_record[is.na(payment_records$has_record)] <- FALSE
rownames(payment_records) <- NULL
save(payment_records, "payment_records")
for (iso in names(pur)) arrs[[length(arrs) + 1]] <- arr_rows(iso, "compilation", pur[[iso]]$payment_arrangements)
payment_arrangements <- do.call(rbind, arrs)
rownames(payment_arrangements) <- NULL
save(payment_arrangements, "payment_arrangements")

# payment method names from the site's payment-method registry (WHO 2019 analytical guide)
reg <- readLines(file.path(SITE, "country-profile", "assets", "js", "deck", "slides", "s09", "registry.js"), warn = FALSE)
reg <- paste(reg, collapse = "\n")
m <- regmatches(reg, gregexpr('\n "([a-z_]+)": \\{\n  "label": "([^"]+)"', reg))[[1]]
payment_methods <- data.frame(
  id = sub('^\n "([a-z_]+)".*', "\\1", m),
  label = sub('.*"label": "([^"]+)"$', "\\1", m)
)
save(payment_methods, "payment_methods")

# ---- cover photograph credits (country-profile/assets/images/cover/credits.json) ----------------------
cr <- rd("country-profile", "assets", "images", "cover", "credits.json")
cover_credits <- data.frame(iso3 = names(cr), artist = vapply(cr, function(x) chr(x$artist), ""),
                            licence = vapply(cr, function(x) chr(x$license), ""))
rownames(cover_credits) <- NULL
save(cover_credits, "cover_credits")
