# duplicate biophysical table


# Read the data from your file (if the table was uploaded as a CSV or similar)
# Assuming it's already in R as `df`
df <- read.csv("C:/InVEST/WORKBENCH/input/biophisical_table2_final.csv", sep = ",")

# Step 1: Create a duplicate of the original table
df_extended <- df

df_extended$red <- substring(df$nc, 2)
# Assuming your dataframe is named `df` and the column is `nc`
df_extended$nc <- gsub("([0-9]+)", "\\1o", df_extended$red)
df_extended <- df_extended %>% select(-red)

# Step 2: Modify the `lucode` column in the extended dataframe to start from `nrow(df)`
df_extended$lucode <- seq(nrow(df), length.out = nrow(df_extended), by = 1)

# Step 3: Add +0.2 to specified columns, ensuring the maximum value doesn't exceed 1
# Assuming the columns to modify are from column 4 to 7: floral_resources_spring_index, nesting_ground_availability_index, nesting_cavity_availability_index, floral_resources_summer_index
#cols_to_adjust <- 4:7
cols_to_adjust <- 5:10
df_extended[cols_to_adjust] <- lapply(df_extended[cols_to_adjust], function(x) pmin(x + 0.2, 1))

# Step 4: Combine the original and modified dataframes
final_df <- rbind(df, df_extended)

# View the final combined dataframe
print(final_df)

write.csv(final_df, "C:/InVEST/WORKBENCH/input/biophisical_table_org2_f.csv")
