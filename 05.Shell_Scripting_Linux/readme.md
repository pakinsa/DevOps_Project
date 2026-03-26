# A Professional Bash Script for Interactive Multiplication Tables**


**Project Scenario: Bash Script For Generating a Multiplication Table**
Objective: Create a Bash script that generates a multiplication table for a number entered by the user. This project will help you practice using loops, handling user input, and applying conditional logic in Bash scripting.


**Project Description**
Your script should prompt the user to enter a number and then ask if they prefer to see a full multiplication table from 1 to 10 or a partial table within a specified range. Based on the user's choice, the script will display the corresponding multiplication table.


**The Problem Statement**
A regional Investment Brokerage pays its agents a fixed commission for every successful trade or "lot" they close. To ensure transparency, the accounting department must provide agents with a Payout Reference Sheet at the start of each month.

**The Pain Point:**
The brokerage offers different commission tiers (e.g., $25, $50, or $100 per trade). Accountants often need to quickly generate a list of potential earnings for agents who close anywhere from 10 to 500 trades. Manually calculating these tiered payouts for every agent is slow, and they need a tool that can be used on their Linux-based internal servers to generate these tables instantly.



**Project Requirements**
* *User Input for Number:* The script must first ask the user to input a number for which the multiplication table will be generated.
* *Choice of Table Range:* Next, ask the user if they want a full multiplication table (1 to 10) or a partial table. If they choose partial, prompt them for the start and end of the range.
Use of Loops: Implement the logic to generate the multiplication table using loops. You may use either the list form or C-style for loop based on what's appropriate.

* *Conditional Logic:* Use if-else statements to handle the logic based on the user's choices (full vs. partial table and valid range input).

* *Input Validation:* Ensure that the user enters valid numbers for the multiplication table and the specified range. Provide feedback for invalid inputs and default to a full table if the range is incorrect.

* *Readable Output:* Display the multiplication table in a clear and readable format, adhering to the user's choice of range.
Comments and Code Quality: Your script should be well-commented, explaining the purpose of different sections and any important variables or logic used. Ensure the code is neatly formatted for easy readability. 

- Example Script Flow:
    1. Prompt the user to enter a number for the multiplication table.
    2. Ask if they want a full table or a partial table.



#### Overview

A **user-friendly, robust, and extensible** Bash script that generates multiplication tables based on user input. It supports:
- Full tables (1–10)
- Custom range (partial tables)
- Input validation
- Multiple display styles
- Repeat functionality without restart

---

#### Features
**Interactive Input**:	Prompts for number and range
**Full / Partial Tables**:	1–10 or custom start/end
**Input Validation**:	Rejects invalid, negative, or non-numeric input
**3 Display Styles**:	Classic, Grid, Compact
**Colorized Output**:	Enhanced readability with ANSI colors
**Repeat Mode**:	Generate multiple tables in one session
**Clean Code Structure**:	Functions, loops, conditionals
---


## Multiplication Table Script

```bash
# Generate the Multiplication table

# Create the script 
touch ./multiplication_table.sh

# Change script mode to become executable
chmod +x multiplication_table.sh

# Run the script "./multiplication_table.sh" in your terminal
./multiplication_table.sh
```



## Multiplication Table Script Screenshots

*Multiplication_table_script*
![multiplication_table_script](./images/01.multiplication_table_script.png)


*Multiplication Table 4*
![multiplication_table4](./images/01.multiplication_table4.png)


*#### Multiplication Table 5*
![multiplication_table5](./images/02.multiplication_table5.png)



*#### Multiplication Table 15*
![multiplication_table15](./images/03.multiplication_table15.png)


*#### Invalid Input*
![invalid_input](./images/04.invalid_input.png)