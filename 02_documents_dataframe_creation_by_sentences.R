## Libraries ---------------------------------------------------------------
library(tidyverse)

## Load functions
source("./Code/transforming_pdf_to_sentences_dataframe_functions.R")

## Dataframe creation ------------------------------------------------------

## Supervisory statements
df_ss_2020 <- multiple_pdfs_to_df("./Data/SupervisoryStatements2020/",
                             "Supervisory Statement")

## Policy statements
df_ps_2020 <- multiple_pdfs_to_df("./Data/PolicyStatements2020/",
                             "Policy statements")

## Statement of policy
df_sop_2020 <- multiple_pdfs_to_df("./Data/StatementOfPolicy2020/",
                             "Statement of policy")


## Save dataframes ---------------------------------------------------------

saveRDS(df_ss_2020,
        "./Data/df_ss_2020.Rds")

saveRDS(df_ps_2020,
        "./Data/df_ps_2020.Rds")

saveRDS(df_sop_2020,
        "./Data/df_sop_2020.Rds")





