reshape_interaction <- function(df) {
  # movement direction
  interaction$sens[interaction$height == 1 | interaction$height == 2 | interaction$height == 4] <- "1"
  interaction$sens[interaction$height == 3 | interaction$height == 5 | interaction$height == 6] <- "2"
  
  interaction$height[interaction$height == 1 | interaction$height == 3] <- 'hips-shoulders'
  interaction$height[interaction$height == 2 | interaction$height == 5] <- 'hips-eyes'
  interaction$height[interaction$height == 4 | interaction$height == 6] <- 'shoulders-eyes'
  
  return(interaction)
}