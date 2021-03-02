## Libraries ---------------------------------------------------------------
library(tabulizer)
library(tidyverse)
library(lubridate)
library(stringi)
library(stringr)
library(tm)

## Functions ---------------------------------------------------------------

## PDF to DF: This function loads a single bank pdf and transforms this into a dataframe
#' @param doc: pdf file location in network drive
pdf_to_df <- function(pdf_location){
  
  pdf_location <- pdf_location ## inputted pdf file location

  ## Extract document content
  doc <- extract_text(pdf_location)
    
  ## Split by pages, remove headers, remove, contents page and annex, split into sentences
  doc <- strsplit(doc, regex("\r\n\\s*\r\n")) ## split into pages. headers and footers will also be separate cells
  doc <- unlist(doc)  
  
  ## identify page numbers for main body and remove contents and appendices
  all_text <- doc
  body_start <- which((nchar(all_text) > 300 & !grepl("Contents", all_text)))[1] ## identify page number after contents page
  body_end <- ifelse(identical(which(grepl('(Appendix|Annex|Appendices)([[:blank:]\\:\\-]+)\r\n', all_text) & !(grepl('Contents', all_text))) - 1, numeric(0)), length(all_text), 
                     which(grepl('(Appendix|Annex|Appendices)([[:blank:]\\:\\-]+)\r\n', all_text) & !(grepl('Contents', all_text))) - 1)
  main_text <- doc[body_start:body_end]
  main_text <- main_text[which((nchar(main_text) > 320))]
  
  ## clean the text
  main_text <- gsub("£", "&pound;", main_text) ## keeping the pound currency symbol
  main_text <- iconv(main_text, 'ISO-8859-1', 'ascii', sub='') ## remove weird characters
  main_text <- gsub("\r\n", "", main_text) ## replace \r\n with empty string
  main_text <- trimws(stri_trim(main_text)) ## remove extra spaces
  
  sentences_text <- str_split(main_text, ("(?<=\\.)\\s")) ## split into sentences
  sentences_text <- unlist(sentences_text)
  sentences_text <- trimws(stri_trim(sentences_text)) ## remove extra spaces
  
  ## TODO(ZA): Identify and split by paragraphs with paragraph number if available.
  # sections <- unlist(str_split(main_text,regex("(  [0-9]+\\.[0-9]+\\s+(?=[A-Z])|  [0-9]+[:alpha:]\\.[0-9]+\\s+(?=[A-Z]))| [0-9]+\\.\\s+(?=[A-Z])")))[-1]
  # sect_nos <- trimws(unlist(str_extract_all(main_text, regex("(  [0-9]+\\.[0-9]+\\s+(?=[A-Z])|  [0-9]+[:alpha:]\\.[0-9]+\\s+(?=[A-Z]))| [0-9]+\\.\\s+(?=[A-Z])"))))
  
  ## TODO(ZA): Identify chapter headings
  #' 
  
  ## Extract Title, Month, Year
  metadata <- extract_metadata(pdf_location)
  
  title <- metadata$title
  date <- metadata$created
  month <- str_extract(date, "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)")
  year <- as.numeric(str_sub(date, start = -4))
  
  ## Put the document data into dataframe and add a row order index 
  #' Some section numbers restart due to chapter differences. 
  #' Adding row order index helps with identification.
  #' The row order index can be removed once code for identifying chapter heading is completed
  
  df <- data.frame(
    title = rep(title, length(sentences_text)),
    month = rep(month, length(sentences_text)),
    year = rep(year, length(sentences_text)),
    sentences_text = sentences_text,
    stringsAsFactors = FALSE)
  
  df$order <- 1:nrow(df)
  
  return(df)
}


## PDF to DF: This function loads a single bank pdf and transforms this into a dataframe
#' @param doc: pdf file location in network drive

multiple_pdfs_to_df <- function(filepath, document_type){
  pdf_files_in_directory <- list.files(path = filepath, pattern = "\\.pdf$") ## identify all pdf files in the directory
  
  ## create an empty df to then paste into
  df <- data.frame(
    title = "blank",
    month = "blank",
    year = 1900,
    sentences_text = "blank",
    order = 1,
    stringsAsFactors = FALSE)
  
  for (i in 1:length(pdf_files_in_directory)){ ## for each file, scrape the pdf for sentences and add to wider df.
    print(i)
    
    pdf_file <- pdf_to_df(paste(filepath, pdf_files_in_directory[i],sep = "")) ## process pdf to sentences
    
    df <- bind_rows(df, pdf_file) ## add to wider dataframe
    
  }
  
  df$source <- document_type # identify document type
  df <- subset(df, df$title != "blank") ## remove first empty row.
  
  return(df)
  
}



