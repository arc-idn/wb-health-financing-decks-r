# Health financing decks: R code and data

This archive holds two R Markdown files. Each one rebuilds a World Bank deck slide by slide from public data saved
in R's own format (RDS), with one code chunk per slide and a short explanation above each chunk.

- **Global decomposition deck**: what accounted for the change in government health spending per person from 2000 to
  2023 in every country with data, and the health budget prescription for 2027 to 2029. The last chunk checks every
  number on the slides against the output tables the deck was built from.
- **Country financing brief**: the 22-slide country health financing profile for one country. Write the country's
  three-letter code in `params: iso` at the top of the file (for example `iso: "KEN"`) and knit. For the fifteen
  reference countries, the last chunk checks every number against the deck's own text.

To run either file, open its folder in RStudio, open the `.Rmd` file and press Knit. Each folder holds everything its
file needs: the data in `data/` and the Open Sans font in `fonts/`, and every path is relative to the folder. Each
file lists its R packages at the top; both need R 4.1 or later. The sources, dates and checksums of the data are in each folder's
`data/README.md`. A rendered example sits beside each file; its code is folded away, and a Show button above each table opens the
code of that step.
