#!/bin/bash

# ================================================
# AWS Cloud Manager - IAM Automation Capstone
# ================================================

# This script has declarations  of & GROUP_NAME & ADMIN_POLICY_ARN.
# Single Point of Change/Maintainability: That allows you to change the name in one place.
# Readability: That makes it clear to anyone else reading the code what that specific string represents.
# Reusability: That makes you turn that function into a tool that accepts any name as an argument.

# --- Configuration Variables ---
GROUP_NAME="devOps_admin"
IAM_USER_NAMES=("devops-user1" "devops-user2" "devops-user3" "devops-user4" "devops-user5")
ADMIN_POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

# === 1. Command-Line Argument Validation ===
if [ $# -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Valid environments: local | testing | production"
    exit 1
fi

ENVIRONMENT=$1

case "$ENVIRONMENT" in
    local|testing|production)
        echo "🚀 Running IAM automation for $ENVIRONMENT environment..."
        ;;
    *)
        echo "❌ Invalid environment specified."
        exit 2
        ;;
esac

# === 2. Helper Functions ===

create_iam_user() {
    local user=$1
    echo "→ Checking IAM user: $user"
    if aws iam get-user --user-name "$user" >/dev/null 2>&1; then
        echo "   ✅ User '$user' already exists."
    else
        if aws iam create-user --user-name "$user" >/dev/null 2>&1; then
            echo "   ✅ User '$user' created successfully."
        else
            echo "   ❌ Failed to create user '$user'."
        fi
    fi
}

create_admin_group() {
    echo "→ Creating group: $GROUP_NAME"
    if aws iam get-group --group-name "$GROUP_NAME" >/dev/null 2>&1; then
        echo "   ✅ Group '$GROUP_NAME' already exists."
    else
        if aws iam create-group --group-name "$GROUP_NAME" >/dev/null 2>&1; then
            echo "   ✅ Group '$GROUP_NAME' created."
        else
            echo "   ❌ Failed to create group '$GROUP_NAME'."
            exit 1
        fi
    fi
}

attach_admin_policy() {
    echo "→ Attaching policy to $GROUP_NAME..."
    # Check if policy is already attached
    if aws iam list-attached-group-policies --group-name "$GROUP_NAME" | grep -q "$ADMIN_POLICY_ARN"; then
        echo "   ✅ Policy already attached to '$GROUP_NAME'."
    else
        if aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn "$ADMIN_POLICY_ARN" >/dev/null 2>&1; then
            echo "   ✅ Policy attached successfully."
        else
            echo "   ❌ Failed to attach policy to '$GROUP_NAME'."
        fi
    fi
}

assign_users_to_group() {
    echo "→ Assigning users to $GROUP_NAME..."
    for user in "${IAM_USER_NAMES[@]}"; do
        # Check if user is already in this specific group
        if aws iam list-groups-for-user --user-name "$user" | grep -q "$GROUP_NAME"; then
            echo "   ✅ User '$user' is already a member of '$GROUP_NAME'."
        else
            if aws iam add-user-to-group --user-name "$user" --group-name "$GROUP_NAME" >/dev/null 2>&1; then
                echo "   ✅ Assigned '$user' to '$GROUP_NAME'."
            else
                echo "   ❌ Failed to assign '$user' to '$GROUP_NAME'."
            fi
        fi
    done
}

# === 3. Main Execution ===
echo "============================================"
echo "Starting AWS IAM Automation"
echo "Target Group: $GROUP_NAME"
echo "============================================"

create_admin_group
attach_admin_policy

for user in "${IAM_USER_NAMES[@]}"; do
    create_iam_user "$user"
done

assign_users_to_group

echo "============================================"
echo "🎉 IAM automation completed for $ENVIRONMENT!"