#!/bin/bash

# default values
USER="postgres"
HOST="localhost"
DBNAME="spring-test"
SCHEMA="all"
WITH_DROPS=0
INITIAL_DATA=true

while test $# -gt 0; do
  case "$1" in
    --help)
             echo "initdb runs all project's non-test sql scripts using update or drop-all mode"
             echo " "
             echo "Usage: ./initdb.sh [options]"
             echo " "
             echo "options:"
             echo "--help                show brief help"
             echo "-d                    database name, default=flashbackr-test"
             echo "-s                    schema name, default=all"
	         echo "-h                    host, default=localhost"
             echo "--drop-all            drops all entities, default=0 (false)"
             echo "--no-data             don't run initial-data.sql"
             exit 0
             ;;
    -d)
             shift
             if test $# -gt 0; then
               DBNAME="$1"
             else
               echo "no database name specified"
               exit 1
             fi
             shift
             ;;
    -s)
             shift
             if test $# -gt 0; then
               SCHEMA="$1"
             else
               echo "no database schema name specified"
               exit 1
             fi
             shift
             ;;
    -h)
             shift
             if test $# -gt 0; then
               HOST="$1"
             else
               echo "no host specified"
               exit 1
             fi
             shift
             ;;
    --drop-all)
             WITH_DROPS=1
             shift
             ;;
    --no-data)
             INITIAL_DATA=false
             shift
             ;;
    *)
             break
             ;;
    esac
done

# current directory
PWD_DIR="$(cd $(dirname $0); pwd -P)"
# src directory
SRC="$PWD_DIR/src"
# TARGET directory setup
TARGET="$PWD_DIR/target"

if [ -d "$TARGET" ]; then
  if [ -L "$TARGET" ]; then
    rm "$TARGET"
  else
    rm -rf "$TARGET"
  fi
fi

mkdir "$TARGET"

db_exists=0
db_exists_text="not exists"
if test $(psql -U postgres -h ${HOST} -ltq | cut -d \| -f 1 | grep -w "${DBNAME} *$" | wc -l) -eq 1; then
  db_exists=1
  db_exists_text="exists"
fi

with_drops_text="false"
if test ${WITH_DROPS} -eq 1; then
  with_drops_text="true"
fi

echo "Using USER:       $USER"
echo "Using HOST:       $HOST"
echo "Using DBNAME:     $DBNAME ($db_exists_text)"
echo "Using SCHEMA:     $SCHEMA"
echo "Using WITH_DROPS: $with_drops_text"
echo "Using TARGET:     $TARGET"
echo " "

# filter and copy all sql files except for tests
for ff in $(find ${SRC} -type f -name '*.sql' | grep -v "^.*test.sql$")
do
  fname=`basename "$ff"`
  dir=`dirname "$ff" | sed 's/src/target/'`

  if [ ! -d "$dir" ]; then
    mkdir -p ${dir}
  fi

  if [ ${WITH_DROPS} -eq 1 ]; then
    cp ${ff} ${dir}/${fname}
  else
    sed 's/DROP/--DROP/g' $ff > $dir/${fname}
  fi
done

# make initdb.sql file in the $TARGET directory
echo -e "/**" > ${TARGET}/initdb.sql
if [ ${WITH_DROPS} -eq 1 ]; then
  echo -e "*   Drop-Create all database schemas for flashbackr project" >> ${TARGET}/initdb.sql;
else
  echo -e "*   Update all database schemas for flashbackr project" >> ${TARGET}/initdb.sql;
fi
echo -e "*/\n" >> ${TARGET}/initdb.sql

for f in $(find "$TARGET" -type f -name '*-schema.sql' | sed 's/public/1-public/;s/core/2-core/' | sort)
do
  f=$(echo "$f" | sed 's/\/[0-9]-/\//')
  schema=`basename "$f" | sed 's/-schema.sql//'`
  if [ ${SCHEMA} == "all" ] || [ ${schema} == ${SCHEMA} ]; then
    echo -e "-- $schema schema\n\i $f" >> ${TARGET}/initdb.sql

    # find all functions
    for ff in $(find "$TARGET/$schema" -type f -name '*.sql' | grep -v "schema" | grep -v "^.*test.sql$" | grep -v "initial")
    do
      ffrp=`echo "$ff" | sed 's/\.\/src\///'`
      echo -e "\i $ff" >> ${TARGET}/initdb.sql
    done

    echo -e "\n" >> ${TARGET}/initdb.sql
  fi
done

# initial data scripts
if "$INITIAL_DATA"; then
  for f in $(find "$TARGET" -type f -name '*-schema.sql' | sed 's/public/1-public/;s/core/2-core/' | sort)
  do
    f=$(echo "$f" | sed 's/\/[0-9]-/\//')
    schema=`basename "$f" | sed 's/-schema.sql//'`
    if [ ${SCHEMA} == "all" ] || [ ${schema} == ${SCHEMA} ]; then
      echo -e "-- Initial data for $schema schema" >> ${TARGET}/initdb.sql

      # find initial-data script
      for ff in $(find "$TARGET/$schema" -type f -name 'initial-data.sql')
      do
        ffrp=`echo "$ff" | sed 's/\.\/src\///'`
        echo -e "\i $ff" >> ${TARGET}/initdb.sql
      done

      echo -e "\n" >> ${TARGET}/initdb.sql
    fi
  done
fi

# connect to psql to postgres db as postgres superuser to check if the database DBNAME exists.
# if it doesn't then create it.
if test ${db_exists} -eq 0; then
  echo "Couldn't find the database \"$DBNAME\""
  createdb -U postgres -h ${HOST} -E UTF8 -e ${DBNAME}
fi

# run psql on initdb.sql
PGOPTIONS='--client-min-messages=warning' psql --single-transaction -X -v ON_ERROR_STOP=1 --pset pager=off -U ${USER} -d ${DBNAME} -h ${HOST} < "$TARGET/initdb.sql"
#psql --single-transaction -X -v ON_ERROR_STOP=1 --pset pager=off -U $USER -d $DBNAME -h $HOST < "$TARGET/initdb.sql"

if (( $? == 0 )); then
  echo "$(tput setaf 2)Done, without errors.$(tput sgr 0)"
else
  echo "$(tput setaf 1)Done, with errors.$(tput sgr 0)"
fi