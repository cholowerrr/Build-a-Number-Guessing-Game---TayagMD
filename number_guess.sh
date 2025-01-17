#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt user for username
echo "Enter your username:"
read USERNAME


# Check if username exceeds 22 characters
if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username cannot exceed 22 characters. Please try again."
  exit
fi


# Check if the username exists in the database

USERNAME_AVAIL=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_AVAIL ]]; then
  # Insert new user
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Fetch games played and best game
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
RANDOM_NUM=$((1 + RANDOM % 1000))
GUESS=0
echo "Guess the secret number between 1 and 1000:"

# Game loop
while read NUM; do
  if [[ ! $NUM =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    GUESS=$((GUESS + 1))
    if [[ $NUM -eq $RANDOM_NUM ]]; then
      break
    elif [[ $NUM -gt $RANDOM_NUM ]]; then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
done

# Completion message
echo "You guessed it in $GUESS tries. The secret number was $RANDOM_NUM. Nice job!"

# Record the game in the database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, number_guesses) VALUES($USER_ID, $GUESS)")
