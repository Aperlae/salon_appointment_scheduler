#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


MAIN_MENU() {

  # output 1st arg, if given
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # fetch service table data
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # output with required formatting
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # prompt for service selection
  echo -e "\nEnter the number of the service you'd like to book: "
  read SERVICE_ID_SELECTED

  # fetch name of service selected
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed -e 's/^ //g')

  # if input is not valid
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $SERVICE_NAME_SELECTED ]]
  then
    # output services list again
    MAIN_MENU "I could not find that service. Please select an available service."
    return
  fi

  # prompt for phone number
  echo  -e "\nPlease enter your phone number: "
  read CUSTOMER_PHONE

  # fetch customer's name for reference
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed -e 's/^ //g')

  # if no customer's name 
  if [[ -z $CUSTOMER_NAME ]]
  then
    # prompt for their name
    echo -e "\nI'm sorry but I do not have a record of that phone number."
    echo "Please enter your name: "
    read CUSTOMER_NAME

    # insert customer info into the db
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # fetch customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # prompt for appointment time
  echo -e "\nAt what time would you like your cursed $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
  read SERVICE_TIME
  
  # insert appointment time into the db
  INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # output feedback to the customer
  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  echo -e "We look forward to welcoming you into the darkness!!\n"
}

#---------------------------------------------START-HERE-------------------------------------

echo -e "\n~~~~~ TWISTED TRESSES SALON ~~~~~\n"
echo -e "Welcome to the Twisted Tresses Appointment Scheduler.\n"
echo "Choose a service and come succumb to the spell of our haunting and mesmerizing salon."

MAIN_MENU
