#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICES=$($PSQL "SELECT service_id, name FROM services")

echo -e "\n~~~~~ Patrik's Hair Salon ~~~~~\n"

echo -e "\nWelcome to Patrik's Hair Salon, how can I help you?"

MAIN_MENU(){
  if [[ $1$ ]]
  then
    echo -e "\n$1"
  fi
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  read SERVICE_ID_SELECTED

  SELECTED_SERVICE_RAW=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SELECTED_SERVICE_NAME=$(echo $SELECTED_SERVICE_RAW | sed 's/^ *//' )

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get phone number
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # add customer to database
      ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
    fi

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # get service time
    echo -e "\nAt what time would you like your hair $SELECTED_SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # add to appointments
    ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $ADD_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\nI have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
