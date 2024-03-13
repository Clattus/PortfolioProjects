# Importing pandas and matplotlib
import pandas as pd
import matplotlib.pyplot as plt

# 1. Load the CSV file and store as netflix_df
netflix_df=pd.read_csv('netflix_data.csv')

#2.Filter the data to remove TV shows and store as netflix_subset
netflix_subset=netflix_df[netflix_df['type'] == 'Movie']

#3.Investigate the Netflix movie data, keeping only the columns "title", "country", "genre", "release_year", "duration", and saving this into a new DataFrame called netflix_movies.
netflix_movies=netflix_subset[['title','country','genre','release_year','duration']]

#4.Filter netflix_movies to find the movies that are shorter than 60 minutes, saving the resulting DataFrame as short_movies; inspect the result to find possible contributing factors.
short_movies=netflix_movies[netflix_movies['duration']<60]

#5.Using a for loop and if/elif statements, iterate through the rows of netflix_movies and assign colors of your choice to four genre groups ("Children", "Documentaries", "Stand-Up", and "Other" for everything else). Save the results in a colors list. 
colors=[]
for lab,row in netflix_movies.iterrows():
    if row['genre'] == 'Children':
        colors.append('red')
    elif row['genre'] == 'Stand-Up':
        colors.append('blue')
    elif row['genre'] == 'Documentaries':
        colors.append('green')
    else:
        colors.append('grey')

colors[:10]
        
#5.1 Initialize a figure object called fig and create a scatter plot for movie duration by release year using the colors list to color the points and using the labels "Release year" for the x-axis, "Duration (min)" for the y-axis, and the title "Movie Duration by Year of Release"
fig=plt.figure(figsize=(12,8))
plt.scatter(netflix_movies['release_year'],netflix_movies['duration'],c=colors)
plt.xlabel('Release year')
plt.ylabel('Duration (min)')
plt.title('Movie Duration by Year of Release')
plt.show()

#6.After inspecting the plot, answer the question "Are we certain that movies are getting shorter?" by assigning either "yes", "no", or "maybe" to the variable answer
answer = 'maybe'


#netflix_movies.head()

