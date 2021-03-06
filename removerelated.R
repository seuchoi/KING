# Making function to remove related individuals from the data
removerelated <- function(one_to_one_to_remove_df, all_ind_col, random = TRUE, keep = NULL){
  #' Removes related individuals from dataset.
  #'
  #' Takes a dataframe with two cols of IDs representing pairs of related individuals from a dataset, as well as a single collumn with IDs from all individuals of that (larger) dataset
  #' Outputs the IDs of unrelated individuals ONLY, throwing out related ones.
  #'
  #' one_to_one_to_remove_df    ==    dataframe of two columns representing related pairs (IDs)
  #' all_ind_col                ==    single column (as dataframe) with IDs from the entire dataset (may be larger than just related ones)
  #' random                     ==    if 'FALSE' will first remove individuals that are related to multiple others in dataset, before randomly excluding individuals from the remaining pairs (WARNING this option is a lot slower, but will maximize eventual sample size)
  #'                                  if 'TRUE' will go down all pairs of related and randomly remove individuals from pairs of related, if both are still present in the dataset
  #' keep                       ==    single column (as dataframe) with IDs that you want to preferentially keep. If an instance arises that an individual from this collumn can be removed, the partner will be preferentially removed. If both individuals of a pair are in this column, one of the two will be excluded randomly.
  #'
  #' Returns a dataframe column with the IDs that made it through the removal process: unrelated individuals
  cat("\n")
  cat("\n")
  cat("\n")

  cat("Welcome to RemoveRelated.\n")
  cat("\n")
  cat("2019\n")
  cat("SJ Jurgens\n")
  cat("Broad Institute of MIT and Harvard\n")
  cat("Amsterdam UMC - Academic Medical Center\n")
  cat("\n")

  cat("Preparing for removal ...\n")
  options(stringsAsFactors = F)
  library(plyr)
  one_to_one_to_remove_df <- as.data.frame(one_to_one_to_remove_df)
  one_to_one_to_remove_df <- cbind(one_to_one_to_remove_df,
                                   c(1:nrow(one_to_one_to_remove_df)))
  colnames(one_to_one_to_remove_df)[1:3] <- c("ID1",
                                              "ID2",
                                              "Match_Number")

  all_ind_col <- as.data.frame(all_ind_col)
  all_ind_col <- as.data.frame(cbind(all_ind_col, rep(1, nrow(all_ind_col))))
  colnames(all_ind_col) <- c("ID", "helper")

  cat(paste0("Starting with ", nrow(all_ind_col), " individuals."))

  if(!is.null(keep)){
    keep <- as.data.frame(keep)
    keep <- as.data.frame(cbind(keep, rep(1, nrow(keep))))
    colnames(keep) <- c("ID", "keep")
  }

  cat("\n")
  cat("Checking to see whether both individuals of all pairs are present in the data ...\n")
  # We can remove one-to-one matches from the relatedness df if either of the individuals is not present in our cohort
  ## Merge ind. list with first col of matches (all=F), to keep only one-to-one matches were the first ind of a match is present in the dataset
  colnames(all_ind_col)[1] <- "ID1"
  present_line_1 <- merge(all_ind_col,
                          one_to_one_to_remove_df,
                          by="ID1",
                          all=F)

  ## Do the same for the second col of matches, to keep only one-to-one matches were the second ind of a match is present in the dataset
  colnames(all_ind_col)[1] <- "ID2"
  present_line_2 <- merge(all_ind_col,
                          one_to_one_to_remove_df,
                          by="ID2",
                          all=F)

  cat("Removing these pairs otherwise ...\n")
  ## Now merge these two df's (all=F), to keep only matches where both of the individuals in a match are present in the dataset
  present_both <- merge(present_line_1,
                        present_line_2,
                        by=c("Match_Number", "ID1", "ID2"),
                        all=F)
  present_both <- present_both[,c(2:3)]
  colnames(all_ind_col)[1] <- "ID"

  # Tell user there are no related if there are none
  if(nrow(present_both)==0){
    cat("WARNING: no pairs of related in the dataset.\n")
    all_ind_col <- as.data.frame(all_ind_col[,-2])
    colnames(all_ind_col) <- "ID"
    return(all_ind_col)
  }

  # Make a frequency table for how often individuals are found in the relatedness table
  col1 <- present_both$ID1
  col2 <- present_both$ID2
  col_of_relatedness <- c(col1, col2)
  freq_table <- as.data.frame(plyr::count(col_of_relatedness))

  if(!is.null(keep)){
    cat("\n")
    cat("Keep == active. Before further removing, relatedness between those specified will be evaluated, as to keep specified individuals where possible.\n")
    cat("\n")
    cat("Removing non-specified individiuals where they are paired with those specified by 'keep' ...\n")

    for(i in 1:nrow(keep)){
      if((i-1) %% 200 == 0){
        cat(paste0(round(((i-1)/nrow(keep))*100,1),"% ...\n"))
      }
      ones_to_remove <- NULL
      continue_1 <- FALSE
      continue_2 <- FALSE
      if(keep[i,1] %in% present_both[,1]){
        ones_to_remove <- c(ones_to_remove, present_both[which(present_both[,1] == keep[i,1]), 2])
        continue_1 <- TRUE
      }
      if(keep[i,1] %in% present_both[,2]){
        ones_to_remove <- c(ones_to_remove, present_both[which(present_both[,2] == keep[i,1]), 1])
        continue_2 <- TRUE
      }

      if(continue_1 | continue_2){
        ones_to_remove <- as.data.frame(cbind(ones_to_remove, rep(0, length(ones_to_remove))))
        colnames(ones_to_remove) <- c("ID", "keep")
        all_ind_col <- merge(all_ind_col, ones_to_remove, by = "ID", all=T)
        all_ind_col[is.na(all_ind_col$keep),"keep"] <- 1
        all_ind_col <- all_ind_col[all_ind_col$keep == 1, ]
        all_ind_col <- all_ind_col[,-3]

        if(continue_1){
          colnames(ones_to_remove)[1] <- "ID1"
          present_both <- merge(present_both, ones_to_remove, by = "ID1", all.x=T, all.y=F)
          present_both[is.na(present_both$keep),"keep"] <- 1
          present_both <- present_both[present_both$keep == 1, ]
          present_both <- present_both[,-3]
        }
        if(continue_2){
          colnames(ones_to_remove)[1] <- "ID2"
          present_both <- merge(present_both, ones_to_remove, by = "ID2", all.x=T, all.y=F)
          present_both[is.na(present_both$keep),"keep"] <- 1
          present_both <- present_both[present_both$keep == 1, ]
          present_both <- present_both[,-3]
        }
      }
    }
    present_both$Match_Num <- c(1:nrow(present_both))
    colnames(all_ind_col)[1] <- "ID1"
    present_line_1 <- merge(all_ind_col,
                            present_both,
                            by="ID1",
                            all=F)
    colnames(all_ind_col)[1] <- "ID2"
    present_line_2 <- merge(all_ind_col,
                            present_both,
                            by="ID2",
                            all=F)
    present_both <- merge(present_line_1,
                          present_line_2,
                          by=c("Match_Num", "ID1", "ID2"),
                          all=F)
    present_both <- present_both[,c(2:3)]
    colnames(all_ind_col)[1] <- "ID"

    col1 <- present_both$ID1
    col2 <- present_both$ID2
    col_of_relatedness <- c(col1, col2)
    freq_table <- as.data.frame(plyr::count(col_of_relatedness))
    cat("\n")
    cat("Partners of specified individuals have been discarded. If two specified individuals were in a pair, one has been discarded at random.\n")
    cat(paste0(nrow(all_ind_col), " individuals remain.\n"))
  }

  if(random == FALSE){
    cat("\n")
    cat("Random == FALSE: Individuals related to multiple other individuals will be removed first.\n")
    freq_table <- freq_table[order(freq_table$freq, decreasing = T), ]

    cat("\n")
    cat("Removing individuals related to multiple others ...\n")
    iteration <- 0
    num_to_do <- nrow(freq_table[freq_table$freq > 1, ])
    while(freq_table[1,2] > 1){

      if(iteration %% 750 == 0){
        num_left <- nrow(freq_table[freq_table$freq > 1, ])
        cat(paste0(round(((num_to_do - num_left)/num_to_do)*100,0), "% complete ...\n"))
      }
      iteration <- iteration + 1

      all_ind_col <- all_ind_col[- which(all_ind_col$ID == freq_table[1,1]), ]

      if(freq_table[1,1] %in% present_both$ID1){
        present_both <- present_both[- which(present_both$ID1 == freq_table[1,1]), ]
      }

      if(freq_table[1,1] %in% present_both$ID2){
        present_both <- present_both[- which(present_both$ID2 == freq_table[1,1]), ]
      }

      col1 <- present_both$ID1
      col2 <- present_both$ID2
      col_of_relatedness <- c(col1, col2)
      freq_table <- as.data.frame(plyr::count(col_of_relatedness))
      freq_table <- freq_table[order(freq_table$freq, decreasing = T), ]

    }
    cat(paste0(nrow(all_ind_col), " individuals left after preferentially excluding those with multiple relatedness partners.\n"))
    cat("\n")
    cat("Only single occurences left: Now removing randomly between pairs of remaining related ...\n")
    for(i in 1:nrow(present_both)){
      if((i-1) %% 4500 == 0){
        cat(paste0(round((i / nrow(present_both))*100,0), "% ...\n"))
      }
      id_to_remove <- present_both[i, sample(2,1)]
      all_ind_col <- all_ind_col[- which(all_ind_col$ID == id_to_remove), ]
    }

    cat("Done.\n")
    cat("\n")
    cat(paste0(nrow(all_ind_col), " individuals remain after all removal steps.\n"))
    all_ind_col <- as.data.frame(all_ind_col[,-2])
    colnames(all_ind_col) <- "ID"
    return(all_ind_col)
  }


  if(random == TRUE){

    cat("\n")
    cat("Random == TRUE: Per pair of related individuals a random individual will be removed each time until no related pairs remain.\n")
    cat("\n")
    cat("Removing randomly between related pairs ...\n")
    num_to_do <- nrow(present_both)
    while(nrow(present_both)>0){
      num_done <- num_to_do - nrow(present_both)
      if(num_done %% 6000 == 0){
        cat(paste0(round((num_done / num_to_do)*100,0), "% ...\n"))
      }
      remove_random_id <- present_both[1,sample(2,1)]

      all_ind_col <- all_ind_col[- which(all_ind_col$ID == remove_random_id), ]

      if(remove_random_id %in% present_both$ID1){
        present_both <- present_both[- which(present_both$ID1 == remove_random_id), ]
      }

      if(remove_random_id %in% present_both$ID2){
        present_both <- present_both[- which(present_both$ID2 == remove_random_id), ]
      }

    }

    cat("Done.\n")
    cat("\n")
    cat(paste0(nrow(all_ind_col), " individuals remain after all removal steps.\n"))
    all_ind_col <- as.data.frame(all_ind_col[,-2])
    colnames(all_ind_col) <- "ID"
    return(all_ind_col)
  }
}
