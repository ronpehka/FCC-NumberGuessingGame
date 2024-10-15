#!/bin/bash

# Set up PostgreSQL command
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate the secret number
SECRET_NUMBER=$((1 + $RANDOM % 1000))

# Ask for username
echo "Enter your username:"
read USERNAME

# Check if the user exists
RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

# If the user does not exist, insert them into the users table
if [[ -z $RETURNING_USER ]]
then
  INSERTED_USER=$($PSQL "INSERT INTO users (username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Fetch games played and best game statistics for the returning user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start guessing game
echo "Guess the secret number between 1 and 1000:"
read GUESS

TRIES=1

# Loop until the correct guess
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  TRIES=$((TRIES + 1))  # Increment guess count
  
  # Check if the guess is a valid number
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi

  read GUESS  # Get a new guess from the user
done

# After the correct guess
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Get user_id for the current user
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# Insert the game result into the games table
INSERT_GAME=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $TRIES)")

