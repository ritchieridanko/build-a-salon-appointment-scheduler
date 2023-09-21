#!/bin/bash

# connect with PSQL for db query
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# welcome section
echo -e "\n~~~~~ Welcome to BroSalon ~~~~~\n"
echo "Choose a service:"

MAIN_MENU() {
  # if an argument is passed
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  # display services in a list
  SERVICE_LIST="$($PSQL "SELECT service_id, name FROM services")"
  echo "$SERVICE_LIST" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # retrieve chosen service from db 
  read SERVICE_SELECTED

  # check if service_selected is a number
  if [[ $SERVICE_SELECTED =~ [0-9]+ ]]
  then
    SERVICE_ID_IS_VALID=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_SELECTED'")

    # check if service selected exists
    if [[ -z $SERVICE_ID_IS_VALID ]]
    then
      MAIN_MENU "\nSorry, we could not find that service."
    else
      SERVICE $SERVICE_SELECTED;
    fi

  else
    MAIN_MENU "\nPlease enter a valid number."
  fi
}

SERVICE() {
  # if service id is passed as an argument
  if [[ $1 ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$1'")

    # asks for customer's phone no
    echo -e "\nWhat is your phone number?"
    read PHONE_NUMBER

    # get customer from db
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE_NUMBER'")

    # check if customer exists
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nWe do not have a record for that phone number. What is your name?"
      IFS=$'\n\t\r' read CUSTOMER_NAME

      # insert a new customer
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$PHONE_NUMBER', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE_NUMBER'")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$PHONE_NUMBER'")
    fi

    # asks for service's time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # insert a new appointment
    INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$1', '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU