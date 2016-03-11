#!/usr/bin/env sh
# Use this script to fetch the latest dump
# from production DB

app='testributor'
data_file="/tmp/testributor_db.dump"
user=`whoami`
default_email=`whoami`

echo "What is the local database that you want to process?"
read local_db

echo "What is your database user? (default: ${user})"
read local_user

echo "What is the email prefix for each user? (default: ${default_email})"
read email

local_user=${local_user:-$user}
email=${email:-$default_email}

if [ -f $data_file ]; then
  echo "Dump file already exists, should I use that or download a fresh one?(Answer 'yes' to use the existing)!"
  read answer

  if [ ! "$answer" = "yes" ]; then
    echo ">> Dumping data from remote ${app} to ${data_file}..."
    curl -o  $data_file `heroku pg:backups public-url -q -a $app`
  fi
else
  echo ">> Dumping data from remote ${app} to ${data_file}..."
  curl -o  $data_file `heroku pg:backups public-url -q -a $app`
fi

echo "<< Restoring ${data_file} into ${local_db}..."
pg_restore --clean --no-acl --no-owner -h localhost -U $local_user -d ${local_db} ${data_file}

# TODO: Replace credentials
#echo 'Replacing emails and phone numbers...'
#rails runner script/replace_credentials.rb $email

#echo "Cleanup..."
#rm ${data_file}

echo "All done!"
