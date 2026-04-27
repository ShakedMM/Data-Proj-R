# Data-Proj-R
# Spotify Data Analysis: Musical Trends & Statistical Insights

## Project Overview
This project provides a comprehensive statistical exploration of musical attributes and industry trends using a dataset of over 30,000 songs from Spotify. By applying data science methodologies in **R**, the analysis investigates how musical characteristics like "danceability" relate to popularity, how song durations have evolved over seven decades, and how the volume of music production has accelerated in the digital age.

---

## Research Questions & Methodology

### 1. Danceability vs. Popularity
* **Objective:** To determine if a song's capacity to be "danceable" (based on tempo, rhythm stability, and beat strength) serves as a predictor for its popularity.
* **Method:** Calculated the **Pearson Correlation Coefficient ($r$)** to measure the linear relationship between the `danceability` and `track_popularity` metrics.
* **Key Finding:** A very weak positive correlation ($r = 0.065$) was found, suggesting that danceability alone is not a primary driver of a song's success in this dataset.

### 2. Historical Trends in Song Duration
* **Objective:** To analyze how the average length of songs (in seconds) has changed from 1960 to 2020.
* **Method:** Extracted release years using string manipulation and applied **LOESS (Locally Estimated Scatterplot Smoothing)** to visualize non-linear trends.
* **Key Finding:** Song lengths peaked in the 1970s (averaging ~300 seconds) followed by a sharp decline during the "Streaming Era," dropping to approximately 200 seconds by 2020.

### 3. Genre Popularity & Musical Mode
* **Objective:** To identify the most popular genres and examine if the musical "Mode" (Major vs. Minor scale) influences a genre's overall success.
* **Method:** Aggregated average popularity by genre with **95% Confidence Intervals** and categorized genres as "Mixed" if they lacked an 80% dominance in a specific mode.
* **Key Finding:** "Pop" and "Latin" emerged as the leading genres. No genre showed a definitive dominance of one musical mode over the other, indicating that "Major" or "Minor" scales do not strictly dictate genre popularity.

### 4. Music Production Growth (Bootstrap Analysis)
* **Objective:** To assess the acceleration of music releases across different decades.
* **Method:** Employed **Bootstrap Resampling** (10,000 iterations) to estimate the empirical distribution of the mean number of songs released per year for each decade.
* **Key Finding:** The analysis revealed an exponential growth in production volume, particularly in the 2010s, reflecting the impact of digital distribution and streaming platforms.

---

## Technical Tools & Libraries
* **Language:** R
* **Key Packages:** `tidyverse` (ggplot2, dplyr, tidyr), `stringr`, `lubridate`
* **Statistical Methods:** Pearson Correlation, Bootstrap Resampling, Confidence Interval Estimation (95%), and LOESS Smoothing.

---

## Visualizations
*(Optional: Add your plot images here to make the project stand out)*

> **Note:** To display your graphs, upload the image files to your repository and use the following syntax:
> `![Alt text](path_to_your_image.png)`
