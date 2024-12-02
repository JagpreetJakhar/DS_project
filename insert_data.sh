#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
skip_header=1
echo "$($PSQL "truncate teams,games;")"
while IFS="," read  YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  if (( skip_header ))
  then
    (( skip_header-- ))
  else
    # Check and insert the winner team
    TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name ILIKE '$WINNER';")
    if [[ -z $TEAM_ID_W ]]
    then
      echo "$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER');")"
    fi

    # Check and insert the opponent team
    TEAM_ID_O="$($PSQL "SELECT team_id FROM teams WHERE name ILIKE '$OPPONENT';")"
    if [[ -z $TEAM_ID_O ]]
    then
      echo "$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT');")"
    fi
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER';")
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")
    echo "$($PSQL "insert into games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) values($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)";)"
  fi

done < games.csv
