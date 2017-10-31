
#!/bin/bash

# Script to dump kernel boot log from mac OS Sierra.
# v0.1
# blackosx

# Get boot time
bt=$(sysctl -n kern.boottime | sed 's/^.*} //')

# Split in to parts for refactoring
bTm=$(echo "$bt" | awk '{print $2}')
bTd=$(echo "$bt" | awk '{print $3}')
bTt=$(echo "$bt" | awk '{print $4}')
bTy=$(echo "$bt" | awk '{print $5}')

bTm=$(awk -v "month=$bTm" 'BEGIN {months = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"; print (index(months, month) + 3) / 4}')
bTm=$(printf %02d $bTm)

# Need to go back slightly in time, otherwise kernel log starts too late.

# Convert time to epoch
ep=$(date -jf '%H:%M:%S' $bTt '+%s')

# Rewind by 60 seconds
cs=$((ep - 60 ))

# Convert epoch to time
bTt=$(date -r $cs '+%H:%M:%S')

# find stop point. Use first entry of loginwindow:
stopTime=$(log show --debug --info --start "$bTy-$bTm-$bTd $bTt" | grep loginwindow | head -1)
stopTime="${stopTime%      *}"

# Extract Log
echo "Extract boot log from $bTy-$bTm-$bTd $bTt"

log show --debug --info --start "$bTy-$bTm-$bTd $bTt" | grep -E 'kernel:|loginwindow:' | sed -n -e "/kernel: PMAP: PCID enabled/,/$stopTime/ p"