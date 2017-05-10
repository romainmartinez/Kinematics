format_pvalue <- function(input) {
  # format p-value
  input <- format.pval(pv = input,
                         # digits : number of digits, but after the 0.0
                         digits = 2, 
                         # eps = the threshold value above wich the 
                         # function will replace the pvalue by "<0.0xxx"
                         eps = 0.001, 
                         # nsmall = how much tails 0 to keep if digits of 
                         # original value < to digits defined
                         nsmall = 3)
  
  return(input)
}