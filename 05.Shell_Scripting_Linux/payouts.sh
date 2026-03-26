#!/bin/bash

# --- The Commission-Based Payout Auditor ---
# This script generates payout reference sheets for brokerage agents.
# It calculates total commissions based on a fixed rate per trade.

echo "=== Investment Brokerage: Payout Auditor ==="

# 1. Prompt for the Commission Rate (The Base Number)
read -p "Enter the commission per trade (e.g., 25, 50, 100): " RATE

# Validation: Check if the rate is a positive integer
if [[ ! "$RATE" =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a valid numerical amount."
    exit 1
fi

# 2. Ask for Table Type (Full vs. Partial)
echo "Choose a range option:"
echo "1) Full Reference Sheet (1 to 10 trades)"
echo "2) Custom Range (e.g., 10 to 500 trades)"
read -p "Selection [1 or 2]: " CHOICE

# 3. Handle Range Logic
if [ "$CHOICE" == "2" ]; then
    read -p "Enter starting number of trades: " START
    read -p "Enter ending number of trades: " END

    # Validation: Ensure inputs are numbers and START is less than END
    if [[ ! "$START" =~ ^[0-9]+$ ]] || [[ ! "$END" =~ ^[0-9]+$ ]] || [ "$START" -gt "$END" ]; then
        echo "Invalid range entered. Defaulting to Full Reference Sheet (1-10)."
        START=1
        END=10
    fi
else
    # Default Full Table
    START=1
    END=10
fi

# 4. Generate the Payout Table
echo -e "\n--- Payout Reference Sheet (Rate: \$$RATE/trade) ---"
printf "%-15s | %-15s\n" "Trades Closed" "Total Payout"
echo "------------------------------------------"

# C-style loop for calculation and display
for (( i=$START; i<=$END; i++ ))
do
    PAYOUT=$(( i * RATE ))
    printf "%-15d | \$%-15d\n" "$i" "$PAYOUT"
done

echo "------------------------------------------"
echo "Report Complete."
