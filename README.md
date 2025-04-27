## Abstract Booklet Generator

An R script that converts abstract entries into a formatted PDF booklet for academic events.

## Requirements

- R 4.1.0+
- R packages:
  - readr
  - rmarkdown
  - knitr
  - dplyr
  - stringr
  - here

## Installation

```bash
git clone https://github.com/akhilabburu/abstract-booklet-generator.git
cd abstract-booklet-generator
```

Install dependencies:
```R
install.packages(c("readr", "rmarkdown", "knitr", "dplyr", "stringr", "here"))
```

## Usage

```R
# Load libraries

# Import data
data <- read_csv("data/abstracts.csv") |>
  filter(title != "-") |>
  arrange(order)

# Generate the PDF
generate_abstract_booklet(data, output_file = "output/wip_abstracts_2025.pdf")
```

### Input

Your input csv file needs these columns:
- `title` - Abstract title
- `presenter` - Author name
- `abstract` - Full abstract text
- `discussant` - Discussant name
- `order` - Position in booklet (say, by presentation order)

## Tweaking the Output

Template at `templates/abstract_booklet_template.Rmd` can be modified. The LaTeX settings at the top control the appearance.
