#!/bin/bash
function check_status() {
    local stmnt_id=$1
    echo "About to check tx"
    return 0
    # while true; do
    #     echo "Getting tx status ..."
    #     status=$(aws redshift-data describe-statement --id "$stmnt_id")
    #     status=$(echo $response | jq -r '.Status')

    #     echo "Current Status: $status"

    #     if [[ "$status" == "FINISHED" ]] || [[ "$status" == "FAILED" ]] || [[ "$status" == "ABORTED" ]]; then
    #         break
    #     fi

    #     # Wait for a few seconds before checking again
    #     sleep 5
    # done

    # return $status

}
# Set static options
cluster_identifier="dw-dev"
database="dw_dev"
db_user="data_engineer_batch"

# Directory containing SQL files
# sql_directory="/Users/daniel.potter/sss-git/dm-poc/"
sql_directory="/Users/daniel.potter/sss-git/dm-poc/reltest/"

# Loop through SQL files in the directory
for sql_file in $(ls -1v $sql_directory*.sql); do
    # Extract file name without directory path
    file_name=$(basename "$sql_file")

    # Execute AWS Redshift Data API command
    echo "Running: "$sql_file
    response=$(aws redshift-data execute-statement \
        --cluster-identifier "$cluster_identifier" \
        --database "$database" \
        --db-user "$db_user" \
        --sql "file://$sql_file")
    echo "Statement response is: "$response
    #Get response
    id=$(echo $response | jq -r '.Id')
    echo "Id is: "$id
    while true; do
        response=$(aws redshift-data describe-statement --id "$id")
        echo "Stmnt description is: "$response
        clean_response=$(echo $response | tr -d '\000-\037')
        echo "clean response is: "$clean_response
        status=$(echo $clean_response | jq '.Status' | xargs)
        echo $status
        if [[ "$status" == "FINISHED" ]] || [[ "$status" == "FAILED" ]] || [[ "$status" == "ABORTED" ]]; then
            echo "Exit Status for "$sql_file" is "$status
            break
        fi
        echo "Status is - "$status
    done

    # Add a sleep if needed to avoid throttling
    sleep 2
done
