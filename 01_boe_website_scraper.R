## Libraries ---------------------------------------------------------------
library(boeWebConnectr)
library(tidyverse)
library(rvest)
library(stringi)
library(stringr)
library(httr)
library(tm)

## Configure proxy server for scraping -------------------------------------

## See Analytical 7355570v5 for further details on scraping from bank laptops
boe_web_config()
# unset_boe_web_config() # Use this to restore default settings

## Scraper -----------------------------------------------------------------

## Set url for prudential regulation sitemap. This is used to gather url data for released docs.
page <- read_html(GET("https://www.bankofengland.co.uk/sitemap/prudential-regulation"))

## Gather vector of urls on the page for every document

## extract links for each release (SS - supervisory-statement; PS - policy-statement; SoP - statement-of-policy)
SS_release_home_url <- page %>% ## find all urls associated with the supervisory-statement subheading
  html_nodes(".list-links__item:nth-child(25) .list-links__item .icon-download") %>% 
  html_attr('href')
PS_release_home_url <- page %>% ## find all urls associated with the policy-statement subheading
  html_nodes(".list-links__item:nth-child(12) .list-links__item .icon-download") %>% 
  html_attr('href')
SoP_release_home_url <- page %>% ## find all urls associated with the statement-of-policy subheading
  html_nodes(".list-links__item:nth-child(21) .list-links__item .icon-download") %>% 
  html_attr('href')

## extract text associated with each link (SS - supervisory-statement; PS - policy-statement)
SS_release_title <- page %>% 
  html_nodes(".list-links__item:nth-child(25) .list-links__item .icon-download") %>% 
  html_text() %>% stri_trim() %>% stri_sub(1, -12) %>% stri_trim() %>% ## Extract text and remove (pdf 12mb) text from end
  str_replace(regex("[[:punct:]]"), "-") ## replace special characters with hyphen
PS_release_title <- page %>% html_nodes(".list-links__item:nth-child(12) .list-links__item .icon-download") %>% 
  html_text() %>% stri_trim() %>% stri_sub(1, -12) %>% stri_trim() %>% ## Extract text and remove (pdf 12mb) text from end
  str_replace(regex("[[:punct:]]"), "-") ## replace special characters with hyphen
SoP_release_title <- page %>% html_nodes(".list-links__item:nth-child(21) .list-links__item .icon-download") %>% 
  html_text() %>% stri_trim() %>% stri_sub(1, -12) %>% stri_trim() %>% ## Extract text and remove (pdf 12mb) text from end
  str_replace(regex("[[:punct:]]"), "-") ## replace special characters with hyphen

## Download and save each pdf document - Save in different folders

setwd("W:/PRA_Economic_Analysis/Barriers to Growth/Thresholds/Threshold tracker/Data/SupervisoryStatements")
SS_release_home_url %>% 
  walk2(., basename(.), download.file, mode = "wb",quiet = T) ## change 'quiet=T' to 'quiet=F' if you wish to see status bar

setwd("W:/PRA_Economic_Analysis/Barriers to Growth/Thresholds/Threshold tracker/Data/PolicyStatements")
PS_release_home_url %>% 
  walk2(., basename(.), download.file, mode = "wb",quiet = T) ## change 'quiet=T' to 'quiet=F' if you wish to see status bar

setwd("W:/PRA_Economic_Analysis/Barriers to Growth/Thresholds/Threshold tracker/Data/StatementOfPolicy")
SoP_release_home_url %>% 
  walk2(., basename(.), download.file, mode = "wb",quiet = T) ## change 'quiet=T' to 'quiet=F' if you wish to see status bar

## To note: Downloading all of these takes around 1-2 hours to complete

## Transform pdf documents into dataframe ---------------------------------------------------------

## Load dataframes


# DEVELOPING/TESTING/DIAGNOSTICS -----------------------------------------------------------------

# setwd("W:/PRA_Economic_Analysis/Barriers to Growth/Thresholds/Threshold tracker/Data/SupervisoryStatements")
# SS_release_home_url[253:302] %>% 
#   walk2(., basename(.), download.file, mode = "wb",quiet = T) ## change 'quiet=T' to 'quiet=F' if you wish to see status bar


