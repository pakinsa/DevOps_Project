#!/bin/bash

# ================================================
# AWS Cloud Manager - IAM Automation Capstone
# Encapsulates ALL previous mini-projects
# ================================================

# This script lacks declarations  of & GROUP_NAME & ADMIN_POLICY_ARN.
# Single Point of Change/Maintainability: That allows you to change the name in one place.
# Readability: That makes it clear to anyone else reading the code what that specific string represents.
# Reusability: That makes you turn that function into a tool that accepts any name as an argument.

# === 1. Command-Line Argument Validation (from earlier mini-project) ===
if [ $# -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Valid environments: local | testing | production"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment (environment variable usage)
case "$ENVIRONMENT" in
    local|testing|production)
        echo "🚀 Running IAM automation for $ENVIRONMENT environment..."
        ;;
    *)
        echo "❌ Invalid environment specified. Use 'local', 'testing', or 'production'."
        exit 2
        ;;
esac

# === 2. IAM User Names Array (Objective 2) ===
# You can replace this array of devOps-users with real human names, so all those names are done once. 
IAM_USER_NAMES=("devops-user1" "devops-user2" "devops-user3" "devops-user4" "devops-user5")

# === 3. Helper Functions with Full Error Handling (idempotent) ===

create_iam_user() {
    local user=$1
    echo "→ Creating IAM user: $user"

    # Check if user already exists
    if aws iam get-user --user-name "$user" >/dev/null 2>&1; then
        echo "   ✅ User $user already exists."
    else
        if aws iam create-user --user-name "$user" >/dev/null 2>&1; then
            echo "   ✅ User $user created successfully."
        else
            echo "   ❌ Failed to create user $user."
        fi
    fi
}

create_admin_group() {
    echo "→ Creating admin group..."
    if aws iam get-group --group-name admin >/dev/null 2>&1; then
        echo "   ✅ Group 'admin' already exists."
    else
        if aws iam create-group --group-name admin >/dev/null 2>&1; then
            echo "   ✅ Group 'admin' created."
        else
            echo "   ❌ Failed to create group 'admin'."
        fi
    fi
}

attach_admin_policy() {
    local policy_arn="arn:aws:iam::aws:policy/AdministratorAccess"
    echo "→ Attaching AdministratorAccess policy to admin group..."

    # Check if already attached
    if aws iam list-attached-group-policies --group-name admin | grep -q "$policy_arn"; then
        echo "   ✅ Policy already attached."
    else
        if aws iam attach-group-policy --group-name admin --policy-arn "$policy_arn" >/dev/null 2>&1; then
            echo "   ✅ AdministratorAccess policy attached."
        else
            echo "   ❌ Failed to attach policy."
        fi
    fi
}

assign_users_to_group() {
    echo "→ Assigning users to admin group..."
    for user in "${IAM_USER_NAMES[@]}"; do
        if aws iam list-groups-for-user --user-name "$user" | grep -q "admin"; then
            echo "   ✅ User $user already in admin group."
        else
            if aws iam add-user-to-group --user-name "$user" --group-name admin >/dev/null 2>&1; then
                echo "   ✅ Assigned $user to admin group."
            else
                echo "   ❌ Failed to assign $user."
            fi
        fi
    done
}

# === 4. Main Execution (calls all functions) ===
echo "============================================"
echo "Starting AWS IAM Automation"
echo "Environment: $ENVIRONMENT"
echo "Users to create: ${IAM_USER_NAMES[*]}"
echo "============================================"

create_admin_group
attach_admin_policy

for user in "${IAM_USER_NAMES[@]}"; do
    create_iam_user "$user"
done

assign_users_to_group

echo "🎉 IAM automation completed successfully!"