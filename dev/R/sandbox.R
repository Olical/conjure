# The iris dataset is built into R and contains measurements of iris flowers
data(iris)

a <- 2

b <- 5

a + b

iris$Sepal.Width * (b + a)

# Display the structure and summary of the dataset
iris
str(iris)
summary(iris)

# Basic scatter plot using base R
plot(iris$Sepal.Length, iris$Sepal.Width,
  main = "Sepal Dimensions of Iris Flowers",
  xlab = "Sepal Length (cm)",
  ylab = "Sepal Width (cm)",
  col = 5 + as.numeric(iris$Species),
  pch = 19
)

legend("topright",
  legend = levels(iris$Species),
  col = 6:8, pch = 19, title = "Species"
)

analyze_numbers <- function(numbers) {
  if (!is.numeric(numbers) || length(numbers) == 0) {
    stop("Input must be a non-empty numeric vector")
  }

  total <- sum(numbers)
  avg <- mean(numbers)
  med <- median(numbers)
  std_dev <- sd(numbers)

  list(
    count = length(numbers),
    sum = total,
    mean = avg,
    median = med,
    std_dev = std_dev,
    min = min(numbers),
    max = max(numbers),
    summary = paste(
      "Analyzed", length(numbers), "numbers with mean", round(avg, 2)
    )
  )
}

test_data <- c(1, 5, 3, 9, 2, 7, 4, 6, 8)

mean(test_data)

result <- analyze_numbers(test_data)

cat("Summary:", result$summary, "\n")

# error handling
tryCatch(
  {
    analyze_numbers(c()) # Empty vector should cause error
  },
  error = function(e) {
    cat("Caught expected error:", e$message, "\n")
  }
)
