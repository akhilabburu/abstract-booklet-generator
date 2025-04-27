# Load required libraries
library(readr)
library(rmarkdown)
library(knitr)
library(dplyr)
library(stringr)
library(here)

# Function to sanitize text for LaTeX
sanitize_for_latex <- function(text) {
  if (is.na(text) || !is.character(text)) return("")

  # Define replacements in a vector for clearer code
  replacements <- c(
    "\\\\" = "\\\\textbackslash{}",
    "&" = "\\\\&",
    "%" = "\\\\%",
    "_" = "\\\\_",
    "#" = "\\\\#",
    "\\$" = "\\\\$",
    "\\{" = "\\\\{",
    "\\}" = "\\\\}",
    "\\^" = "\\\\^{}",
    "~" = "\\\\textasciitilde{}"
  )

  # Apply
  for (char in names(replacements)) {
    text <- gsub(char, replacements[char], text, fixed = TRUE)
  }

  return(text)
}

data <- read_csv("wip/booklet_helper.csv",
                 locale = locale(encoding = "UTF-8")) |>
  filter(title != "-") |>
  arrange(order)


# Function to generate the abstract booklet
generate_abstract_booklet <- function(data,
                                      output_file = "abstract_booklet.pdf",
                                      template_path = here::here("wip", "template.Rmd"),
                                      logo_path = here::here("wip", "institution_logo.png")) {

  # Ensure template exists
  if (!file.exists(template_path)) {
    stop("Template file not found: ", template_path)
  }

  # Read the template
  rmd_content <- readLines(template_path) |> paste(collapse = "\n")

  # Replace logo path in template
  rmd_content <- gsub("\\{\\{LOGO_PATH\\}\\}", logo_path, rmd_content)

  # Add each abstract to the content with proper sectioning and bookmarks
  abstract_content <- ""
  for(i in 1:nrow(data)) {
    entry <- data[i,]

    # Sanitize text fields
    title <- sanitize_for_latex(entry$title)
    abstract <- sanitize_for_latex(entry$abstract)
    author <- sanitize_for_latex(entry$presenter)
    discussant <- sanitize_for_latex(entry$discussant)

    # Create section for table of contents and bookmarks
    section_header <- sprintf('# %s {#abstract-%d}', title, i)

    entry_template <- '
%s

\\vspace{0.5cm}

\\noindent
\\textbf{Author}: %s

\\vspace{0.3cm}

\\noindent
\\textbf{Abstract}:
\\justify
%s

\\vspace{0.5cm}

\\noindent
\\textbf{Discussant}: %s

\\clearpage
'

    # Format each entry
    entry_text <- sprintf(entry_template,
                          section_header,
                          author,
                          abstract,
                          discussant)

    abstract_content <- paste(abstract_content, entry_text, sep = "\n")
  }

  # Combine template with abstracts
  rmd_content <- paste(rmd_content, abstract_content, sep = "\n")

  # Write the Rmd file
  temp_rmd <- tempfile(fileext = ".Rmd")
  writeLines(rmd_content, temp_rmd)

  # Render the document
  rmarkdown::render(temp_rmd,
                    output_format = rmarkdown::pdf_document(latex_engine = "xelatex"),
                    output_file = output_file,
                    quiet = TRUE)

  # Clean up
  file.remove(temp_rmd)

  message("Done! File:", output_file)
}

# Run
generate_abstract_booklet(data, output_file = here::here("wip","abstract_booklet_2402.pdf"))

