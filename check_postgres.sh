#!/bin/bash
echo "🔍 Checking Postgres cluster status..."
$HOME/.fly/bin/fly status --app n8n-db-pristine

echo -e "\n🔗 Reconnecting to database..."
echo "Run: $HOME/.fly/bin/fly postgres connect --app n8n-db-pristine"
echo ""
echo "Once connected, run these commands:"
echo "  \\l                    # List databases"
echo "  \\c n8n               # Connect to n8n database (if it exists)"
echo "  \\dt                   # List tables"
echo "  SELECT version();     # Check Postgres version"
echo "  \\q                    # Quit"
