# Get the Data

spotify_songs <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2020/2020-01-21/spotify_songs.csv')

install.packages("tidytuesdayR")
library(tidyverse)

#עריכת הטבלה
#duration_ms-עמודה המציגה את אורך השיר במילישניות
##ארצה להמיר אותה לשניות
spotify_songs <- spotify_songs %>%
  mutate(duration_ms = duration_ms / 1000) %>%   
  rename(duration_sec = duration_ms)      


#2.1
#שאלה מחקר: האם קיים קשר לינארי בין "הרדקידות" של שיר לבין הפופולריות שלו"


#יצירת טבלה המאגדת בתוכה את עמודת ריקודיות ועמודת פופולריות
d <- spotify_songs %>%
  select(danceability, track_popularity) %>%
  drop_na()

#חישוב מתאם פרסון
Person_1 <- cor(d$danceability, d$track_popularity)

#יצירת גרף פיזור scatter plot
d %>%
  ggplot(aes(danceability, track_popularity)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = F, color = "red") +
  labs(
    title ="Danceability vs Popularity",
    subtitle = paste("Pearson r = " , round(Person_1, 3))
    ,
    x = "Danceability (0–1)",
    y = "Track Popularity (0–100)"
  )



#בעבור פופלריות גדולה מ10

#נבין כמה שירים יש לנו שהפופולריות שלהם קטנה מ10
sum(d$track_popularity < 10)


# סינון השורות עם פופולריות נמוכה מ-10
d_low_pop <- d %>%
  filter(track_popularity > 10)

# מתאם פירסון בטווח החדש
Person_low_pop <- cor(d_low_pop$danceability, d_low_pop$track_popularity)

# גרף פיזור עם קו מגמה
d_low_pop %>%
  ggplot(aes(danceability, track_popularity)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = F, color = "blue") +
  labs(
    title =
      "Danceability vs Popularity (Popularity > 10)",
    subtitle = paste("Pearson r = ", round(Person_low_pop, 3))
    ,
    x = "Danceability (0–1)",
    y = "Track Popularity (0–10)"
  )




#2.2- האם השתנה ממוצע אורך השיר לאורך השנים, ואם כן באיזו דרך


spotify_year <- spotify_songs %>%
  mutate(year = str_sub(track_album_release_date, 1, 4) %>% as.numeric()) %>%
  filter(!is.na(year), !is.na(duration_sec))

# חישוב ממוצע + רווח בר-סמך לכל שנה
duration_yearly <- spotify_year %>%
  group_by(year) %>%
  summarise(
    mean_duration_sec = mean(duration_sec, na.rm = TRUE),
    sd_duration_sec= sd(duration_sec, na.rm = TRUE),
    n          = n(),
    se         = sd_duration_sec / sqrt(n),               # סטיית תקן ממוצעת (Standard Error)
    ci_lo      = mean_duration_sec - 1.96 * se,           # גבול תחתון
    ci_hi      = mean_duration_sec + 1.96 * se,           # גבול עליון
    .groups    = "drop"
  )


duration_yearly %>%
  ggplot(aes(x = year, y = mean_duration_sec)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = "lightblue", alpha = 0.5) +
  geom_line(color = "black", size = 1) +
  geom_point(color = "darkblue") +
  geom_smooth(method = "loess", se = FALSE)+
  labs(
    title = "The average length trend of songs over the years",
    subtitle = "With a 95% confidence interval",
    x = "Year",
    y = "Song lenght in secends"
  )+ 
  theme_minimal()







#2.3- האם יש הבדל מומבהק בין פופולריות של ז'אנרים לאורך השנים, והאם יש השפעה על מז'וריות /מינוריות של הז/אנר

# סיכומי סטטיסטיקה תיאורית לכל ז'אנר
genre_summary <- spotify_songs %>%
  filter(!is.na(playlist_genre), !is.na(track_popularity),!is.na(mode)) %>%
  group_by(playlist_genre) %>%
  summarise(
    mean_pop = mean(track_popularity, na.rm = TRUE),
    sd_pop   = sd(track_popularity, na.rm = TRUE),
    mode_major_mean= mean(mode) * 100,
    n        = n(),
    se       = sd_pop / sqrt(n),
    ci_lo    = mean_pop - 1.96 * se,
    ci_hi    = mean_pop + 1.96 * se,
    .groups  = "drop"
  )%>%  
  mutate(playlist_genre = forcats::fct_reorder(playlist_genre, mean_pop))

   
ggplot(genre_summary, aes(x = playlist_genre, y = mean_pop)) +
  geom_col(fill = "steelblue", width = 0.7) +
  scale_y_continuous(
    limits = c(0, max(genre_summary$ci_hi) + 6),
    breaks = seq(0, 100, by = 2),
    minor_breaks = seq(0, 100, by = 1)
  )+
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.2, linewidth = 0.6) +
  geom_segment(data = genre_summary,
               aes(x = 0.5, xend = as.numeric(playlist_genre),
                   y = mean_pop, yend = mean_pop),
               linetype = "dashed", color = "brown") +
  geom_text(aes(y = ci_hi, label = paste0("n=", n)),
            nudge_y = 2, vjust = 0, size = 3.2)+
  labs(
    title = "Average popularity by genre ",
    subtitle = "CI +- 95%",
    x = "Genre",
    y = "Average popularity (0–100)"
  ) +
  theme_bw()









#2.4- האם מספר השירים הממוצע שיצאו מדי שנה השתנה בצורה מובהקת בין עשורים שונים 



#אצור טבלה שיש בה עמודה של שנה
##זאת באמצעות יצירת עמודת שנה עם חבילת lubridate

library(lubridate)

spotify_year <- spotify_songs %>%
  mutate(year = str_sub(track_album_release_date, 1, 4) %>% as.numeric()) %>%
  filter(!is.na(year)) %>%
  count(year, name = "songs_per_year")


# הממוצע לשנה
mean_per_year <- mean(spotify_year$songs_per_year)
        


##המשך שאלה 4.-    

library(tidyverse)

set.seed(123)

#אצור טבלה שתכיל עמודה המגדירה את תקופת הזמן שבה השיר יצא. 
spotify_year_periods <- spotify_year %>%
  filter(!is.na(year), !is.na(songs_per_year)) %>%
  mutate(period = paste0(floor(year/10)*10, "s"))


#נשאיר רק תקופות עם מספיק שנים כדי שנוכל לבצע את המדגם 
min_years_per_period <- 5
periods_keep <- spotify_year_periods %>%
  count(period, name = "n_years") %>%
  filter(n_years >= min_years_per_period) %>%
  pull(period)

spotify_year_periods <- spotify_year_periods %>%
  filter(period %in% periods_keep)


#ביצוע המדגם של ממוצע השירים לשנה, לכל תקופה
B <- 10000

boot_means_by_period <- spotify_year_periods %>%
  group_by(period) %>%
  summarise(
    boot = list({
      vals <- songs_per_year
      n    <- length(vals)
      # דגימת Bootstrap וחישוב ממוצע לכל חזרה
      map_dbl(1:B, ~ mean(sample(vals, size = n, replace = TRUE), na.rm = TRUE))
    }),
    .groups = "drop"
  ) %>%
  unnest_longer(boot, values_to = "mean_songs_per_year")


# סטטיסטיקות לכל תקופה (Mean of Means + CI 90%)
stats_by_period <- boot_means_by_period %>%
  group_by(period) %>%
  summarise(
    mean_of_means = mean(mean_songs_per_year, na.rm = TRUE),
    ci_lo         = quantile(mean_songs_per_year, 0.025, na.rm = TRUE),
    ci_hi         = quantile(mean_songs_per_year, 0.975, na.rm = TRUE),
    .groups       = "drop"
  )

#יצירת היסטוגרמות מפוצלות לפי תקופה
#facet warp באמצעות

ggplot(boot_means_by_period, aes(x = mean_songs_per_year)) +
  geom_histogram(bins = 30, fill = "red", color = "black") +
  facet_wrap(~ period, scales = "free_x") +
  geom_vline(data = stats_by_period, aes(xintercept = mean_of_means),
             color = "blue", linewidth = 1.0) +
  geom_vline(data = stats_by_period, aes(xintercept = ci_lo),
             color = "blue", linetype = "dashed", linewidth = 0.9) +
  geom_vline(data = stats_by_period, aes(xintercept = ci_hi),
             color = "blue", linetype = "dashed", linewidth = 0.9) +
  labs(
    title = "Average Number of Songs per Year — Comparison Between Periods",
    subtitle = "Solid blue line: Mean of Means | Dashed lines: 95% CI",
    x = "Average number of songs per year",
    y = "Frequency"
  ) +
  theme_bw()



#יצירת טבלה ויזואלית בשביל לצרף לעבודה
stats_by_period %>%
  mutate(
    mean_of_means = round(mean_of_means, 2),
    ci_lo = round(ci_lo, 2),
    ci_hi = round(ci_hi, 2)
  ) %>%
  arrange(period)








