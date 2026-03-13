#!/bin/bash
echo "Monitoring spark1 - will auto-fix when it comes back online"
echo "Press Ctrl+C to stop"

while true; do
  if ping -c 1 -W 2 192.168.1.33 >/dev/null 2>&1; then
    if ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no martin@192.168.1.33 "
      pkill -9 -f wait-for-llm
      pkill -9 -f idea-evaluator
      docker stop gpt-oss-120b 2>/dev/null
      docker rm gpt-oss-120b 2>/dev/null
      echo SECURED
    " 2>&1 | grep -q "SECURED"; then
      echo "$(date): ✓ SPARK1 IS BACK AND SECURED!"
      echo "You can now SSH to spark1 and fix the docker-compose file"
      break
    fi
  fi
  echo "$(date +%H:%M:%S): Waiting for spark1..."
  sleep 10
done
