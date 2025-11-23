#!/bin/bash
INSTANCE_ID="$1"
PUBLIC_IP="$2"

echo "Checking deployment status..."
echo ""

# Check if instance is running
STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region us-east-1 \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text)

echo "Instance State: $STATE"
echo ""

# Try to check if API is responding
echo "Testing API endpoint..."
for i in {1..5}; do
    if curl -s --connect-timeout 5 "http://$PUBLIC_IP:5000/health" > /dev/null 2>&1; then
        echo "✓ API is responding!"
        break
    else
        echo "  Attempt $i/5: API not ready yet..."
        sleep 10
    fi
done

echo ""
echo "Deployment check complete."
