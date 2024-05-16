#download data from https://digital.nhs.uk/data-and-information/publications/statistical/appointments-in-general-practice/march-2023

library(dplyr)

# Specify the path to the ZIP file
zip_file <- "Appointments_GP_Daily_CSV_Mar_23.zip"

# Create a directory named "data" if it doesn't exist
if (!dir.exists("data")) {
  dir.create("data")
}

# Extract the contents of the ZIP file to the "data" folder
unzip(zip_file, exdir = "data")

# Check the extracted files in the "data" folder
list.files("data")

# Specify the path to the file you want to remove
file_to_remove <- "data/APPOINTMENTS_GP_COVERAGE.csv"

# Check if the file exists
if (file.exists(file_to_remove)) {
  # Remove the file
  file.remove(file_to_remove)
  cat("File", file_to_remove, "has been removed.\n")
} else {
  cat("File", file_to_remove, "does not exist.\n")
}

# Check the remaining files in the "data" folder
list.files("data")

# Get the file paths of all CSV files in the "data" folder
csv_files <- list.files("data", pattern = "\\.csv$", full.names = TRUE)

# Read each CSV file into a list of data frames
data_list <- lapply(csv_files, read.csv)

# Merge all data frames into a single data frame
merged_data <- do.call(rbind, data_list)

# Print the structure of the merged data frame
str(merged_data)

# Print the first few rows of the merged data frame
merged_data$Appointment_Date

# Format the Appointment_Date column
merged_data$Appointment_Date <- as.Date(merged_data$Appointment_Date, format = "%d%b%Y")

# Filter the data
filtered_data <- merged_data %>%
  filter(HCP_TYPE == "GP",
         APPT_MODE != "Telephone",
         APPT_MODE != "Unknown",
         Appointment_Date >= as.Date("2022-04-01"),
         Appointment_Date <= as.Date("2023-03-31"))

unique(filtered_data$APPT_STATUS)

# Calculate the total number of appointments for each status
appt_status_count <- aggregate(COUNT_OF_APPOINTMENTS ~ APPT_STATUS, data = filtered_data, sum)

# Calculate the total number of appointments
total_appointments <- sum(appt_status_count$COUNT_OF_APPOINTMENTS)

# Calculate the percentage of attended appointments
attended_percentage <- appt_status_count$COUNT_OF_APPOINTMENTS[appt_status_count$APPT_STATUS == "Attended"] / total_appointments * 100

# Print the percentage of attended appointments
cat("Percentage of attended appointments:", round(attended_percentage, 2), "%\n")