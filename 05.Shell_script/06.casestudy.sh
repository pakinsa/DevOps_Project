# I added a shebang line to indicate that this is a bash script
#!/usr/bin/bash

# I added double quotes around the variables to prevent word splitting and globbing
# I added spaces around the brackets and the equal sign for readability and consistency
# I added a read command to get the user input for the answer and the account number
# I added a pattern for invalid input and an exit command to end the script

balance=70000

echo "Do you want to check your account balance or withdraw money? Type Balance or Withdrawal accordingly."
read -r ANSWER # -r flag prevents backslash escapes from being interpreted

case "$ANSWER" in
  Balance|balance) # This pattern matches both uppercase and lowercase input
    echo "Kindly enter your account details."
    read -r ACCOUNT # -r flag prevents backslash escapes from being interpreted
    if [ "$ACCOUNT" = "0050432711" ]; then # Double quotes prevent word splitting and globbing
      echo "Your account balance is $balance naira. Thanks."
    else
      echo "Invalid account number. Please go back to the Main Menu."
      exit 1 # Exit with a non-zero status to indicate an error
    fi ;;
  Withdrawal|withdrawal) # This pattern matches both uppercase and lowercase input
    echo "How much would you like to withdraw?"
    read -r WITHDRAW # -r flag prevents backslash escapes from being interpreted
    # I added a check to make sure that the withdrawal amount is not greater than the balance
    if [ "$WITHDRAW" -gt "$balance" ]; then # -gt means greater than for numeric comparison
      echo "You cannot withdraw more than your balance. Please go back to the Main Menu."
      exit 2 # Exit with a different non-zero status to indicate a different error
    else 
      # I used arithmetic expansion to calculate the new balance instead of assigning it with an equal sign 
      # I used let command to perform arithmetic operations on variables without using dollar signs or brackets 
      let balance-=WITHDRAW # This is equivalent to balance=$((balance-WITHDRAW))
      echo "Please wait while your transaction is processing."
      sleep 2 # Pause for two second 
      echo ".  . . . . . . . . . . . . ."
      echo "$WITHDRAW naira has been successfully debited and your new account balance is $balance naira."
      exit 0 # Exit with a zero status to indicate success 
    fi ;;
  *) # This pattern matches anything else that is not matched by the other patterns 
    echo "Invalid input. Please type Balance or Withdrawal."
    exit 3 # Exit with another non-zero status to indicate another error ;;
esac

# This code was corrected and written by BING AI