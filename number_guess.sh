#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

SECRET_NUMBER=$[ $RANDOM % 1000 + 1 ]

USER_ID=$($PSQL "select player_id from players where name = '$USERNAME'")

if ! [[ -z $USER_ID ]]
then
    GAMES_PLAYED_OUT=$($PSQL "select count(game_id) from games where player_id = $USER_ID")
    BEST_GAME_OUT=$($PSQL "select min(winning_step) from games where player_id = $USER_ID")
    USERNAME_DB_OUT=$($PSQL "select name from players where player_id=$USER_ID")

    GAMES_PLAYED=$(echo $GAMES_PLAYED_OUT | sed 's/ |/"/')
    BEST_GAME=$(echo $BEST_GAME_OUT | sed 's/ |/"/')
    USERNAME_DB=$(echo $USERNAME_DB_OUT | sed 's/ |/"/')

    echo "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    USERNAME_ADD=$($PSQL "insert into players (name) values ('$USERNAME')")
    USER_ID=$($PSQL "select player_id from players where name = '$USERNAME'")
fi

echo "Guess the secret number between 1 and 1000:"

CTR=1
WIN=false

read PLAYER_GUESS

while [[ "$WIN" = false ]]
do
    if [[ ! $PLAYER_GUESS =~ ^[0-9]+$ ]]
    then
        echo "That is not an integer, guess again:"
        let 'CTR += 1'
        read PLAYER_GUESS
    elif [[ $PLAYER_GUESS -eq $SECRET_NUMBER ]]
    then
        echo "You guessed it in $CTR tries. The secret number was $SECRET_NUMBER. Nice job!"
        ADD_GAME=$($PSQL "insert into games (player_id, winning_step) values ($USER_ID, $CTR)")
        WIN=true
    elif [[ $PLAYER_GUESS -gt $SECRET_NUMBER ]]
    then
        echo "It's lower than that, guess again:"
        let 'CTR += 1'
        read PLAYER_GUESS
    elif [[ $PLAYER_GUESS -lt $SECRET_NUMBER ]]
    then
        echo "It's higher than that, guess again:"
        let 'CTR += 1'
        read PLAYER_GUESS
    fi
done
