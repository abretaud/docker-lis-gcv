#!/bin/bash
set -e

### auto-configure database from environment-variables

DB_DRIVER=pgsql
DB_HOST=postgres
: ${DB_PORT:='5432'}
: ${DB_NAME:='postgres'}
: ${DB_USER:='postgres'}
: ${DB_PASS:='postgres'}

PGHOST=${DB_HOST};
PGPORT=${DB_PORT};
PGNAME=${DB_NAME};
PGUSER=${DB_USER};
PGPASSWORD=${DB_PASS};
export PGHOST PGPORT PGNAME PGUSER PGPASSWORD
export DB_DRIVER DB_HOST DB_PORT DB_NAME DB_USER DB_PASS
echo -e "# database configuration\n
export DB_DRIVER=${DB_DRIVER} DB_HOST=${DB_HOST} DB_PORT=${DB_PORT} DB_NAME=${DB_NAME} DB_USER=${DB_USER} DB_PASS=${DB_PASS}" >> /etc/profile
echo -e "# database configuration\n
export DB_DRIVER=${DB_DRIVER} DB_HOST=${DB_HOST} DB_PORT=${DB_PORT} DB_NAME=${DB_NAME} DB_USER=${DB_USER} DB_PASS=${DB_PASS}" >> /etc/bash.bashrc


###  connect to database

echo
echo "=> Trying to connect to a database using:"
echo "      Database Driver:   $DB_DRIVER"
echo "      Database Host:     $DB_HOST"
echo "      Database Port:     $DB_PORT"
echo "      Database Username: $DB_USER"
echo "      Database Password: $DB_PASS"
echo "      Database Name:     $DB_NAME"
echo

for ((i=0;i<20;i++))
do
    DB_CONNECTABLE=$(PGPASSWORD=$DB_PASS psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -l >/dev/null 2>&1; echo "$?")
	if [[ $DB_CONNECTABLE -eq 0 ]]; then
		break
	fi
    sleep 3
done

if ! [[ $DB_CONNECTABLE -eq 0 ]]; then
	echo "Cannot connect to database"
    exit "${DB_CONNECTABLE}"
fi


### Initial setup if database doesn't exist
if [ "$(PGPASSWORD=$DB_PASS psql -U $DB_USER -h $DB_HOST -p $DB_PORT postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" )" != '1' ]
then
    echo "Database $DB_NAME does not exist, creating it"
    echo "CREATE DATABASE $DB_NAME;" | psql -U $DB_USER -h $DB_HOST -p $DB_PORT postgres;
fi

# Check if tables are there, wait a little in case chado is being loaded
for ((i=0;i<40;i++))
do
    DB_LOADED=$(PGPASSWORD=$DB_PASS psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -tAc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organism');")
    if [[ $DB_LOADED == "t" ]]
    then
		break
    fi
    sleep 3
done

if ! [[ $DB_LOADED == "t" ]]; then
	echo "=> Error: could not find chado tables. Something is wrong in the install. Exiting."
    exit 1
fi

export SECRET_KEY=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1`

cd /opt/gcv/server/

# Run nginx in background
nginx -g "daemon on;"

# Run django server in foreground
touch /opt/gcv/server/errors.log
tail -f /opt/gcv/server/errors.log & # Show error log
python manage.py runserver 0.0.0.0:8000

exit 1
