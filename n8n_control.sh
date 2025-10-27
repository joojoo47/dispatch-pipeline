#!/bin/bash

echo "========================================"
echo "N8N Machine Control Script"
echo "========================================"
echo
echo "Current status: n8n-dispatch-icy-surf-388"
echo
echo "Select an option:"
echo "1. Wake up n8n (scale to 1 instance)"
echo "2. Suspend n8n (scale to 0 instances)"
echo
read -p "Enter your choice (1 or 2): " choice
echo

if [ "$choice" = "1" ]; then
    echo "Waking up n8n..."
    export PATH="$HOME/.fly/bin:$PATH"
    fly scale count 1 --app n8n-dispatch-icy-surf-388
    echo
    echo "✅ n8n should now be waking up. Check status with: fly apps list"
elif [ "$choice" = "2" ]; then
    echo "Suspending n8n..."
    export PATH="$HOME/.fly/bin:$PATH"
    fly scale count 0 --app n8n-dispatch-icy-surf-388
    echo
    echo "✅ n8n suspended. This will save costs when not in use."
else
    echo "❌ Invalid choice. Please run the script again and select 1 or 2."
fi

echo
read -p "Press Enter to continue..."