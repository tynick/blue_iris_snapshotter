#!/bin/bash
# https://tynick.com/blog/11-18-2019/blue-iris-automated-snapshots-with-aws-s3-and-slack-integration/
# this script will take a snapshot 

export PATH=$PATH:/usr/local/bin

# blue iris camera shortname as an argument
camera=$1

# format dates
mydate=$(date +%Y%m%d_%H%M%S) 

# format filename
filename=""${camera}"-"${mydate}".jpeg"

# blue iris variables
bi_user='snapshot'
bi_password='your password'
bi_ip='192.168.1.51'
bi_port='81'

# slack variables
slack_username=$(hostname)
slack_channel='cam-snaps'
slack_emoji=":cinema:"
slack_webhook='https://hooks.slack.com/services/xxxxxxxx/xxxxxxxxxxx/xxxxxxxxxxxxxxxx'

# aws variables
bucketname='cam-snaps'

# check to see if our last command exited with 0
# if not, report to slack and exit
function check_exit ()
{
    exitcode="$1"
    if [[ "${exitcode}" -ne 0 ]];then
        slack_message ":red_circle: Failure!"
        exit 1
    else
        slack_message ":black_circle: Success!"
    fi
}

# send a slack message
function slack_message ()
{
    URL="${slack_webhook}"
    USERNAME="${username}"
    CHAN="${slack_channel}"
    EMOJI="${emoji}"
    TEXT="$1"

    curl --connect-timeout 2 -q -X POST --data-urlencode 'payload={"channel": "'"${CHAN}"'", "username": "'"${USERNAME}"'", "text": "'"${TEXT}"'", "icon_emoji": "'"${EMOJI}"'"}' "${URL}" > /dev/null 2>&1
}

# get snapshot from blueiris
slack_message "Downloading \`"${filename}"\` snapshot from \`"${camera}"\`"
wget  -O "${filename}" "http://"${bi_user}":"${bi_password}"@"${bi_ip}":"${bi_port}"/image/"${camera}"?q=100&s=100"
exitcode=$?
check_exit "${exitcode}"

# make sure file isnt empty
if [[ -s "${filename}" ]]; then
    :
else
    slack_message ":red_circle: File is 0 bytes. Please investigate."
fi

# move file to s3 bucket
slack_message "Moving \`"${filename}"\` to \`"${bucketname}"\`"
aws s3 mv "${filename}" s3://"${bucketname}"/"${camera}"/ --storage-class STANDARD_IA
exitcode=$?
check_exit "${exitcode}"
