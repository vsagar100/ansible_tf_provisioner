#!/bin/bash
sp_site_collection_url="https://myonlinesp.sharepoint.com/teams/Innovation386"
sp_tenant_id="f260df36-bc43-424c-8f44-c85226657b01"
client_id="1c94ecba-30b3-4cfc-bc23-8d384e87f477@f260df36-bc43-424c-8f44-c85226657b01"
client_secret="XbCVwYCfr9JZMdXV4FQEO3FxM5M+5MP8DZ6aDW0WjbI="

curl --location --request GET 'https://accounts.accesscontrol.windows.net/'"${sp_tenant_id}"'/tokens/OAuth/2' \
            --header 'Cookie: esctx=PAQABAAEAAAD--DLA3VO7QrddgJg7Wevrf8wB3IwY9yk9SzE5_2x0s_smDRCq3INDLzGSzzH0II1leHtLFjyDru7E1KD9q1rq0vHAKo55IucIZozkpKfDV96_sbPXadr5BBU5gp7BLH14eqFuT31KdUm4gHXmsUu2FRYOGFR4gvF-yDWe0cNhrAqfyttot20zCT38jGcxbnwgAA; fpc=AgYtaZlIaQxGjoG0nWA46mRifma2AQAAACLyLNwOAAAA; stsservicecookie=estsfd; x-ms-gateway-slice=estsfd' \
            --form 'grant_type="client_credentials"' \
            --form "client_id=$client_id" \
            --form "client_secret=$client_secret" \
            --form 'resource="00000003-0000-0ff1-ce00-000000000000/myonlinesp.sharepoint.com@'${sp_tenant_id}'"' > output.txt
exit_code=$?
if [ $exit_code -eq 0 ]; then
  echo "Token generated successfully."
else
  echo "Error occurred while authenticating, terminating the script."
  exit 1
fi
var=$(cat output.txt)
access_token=$(jq -r '.access_token' 'output.txt')
#echo $access_token
#echo "$(jq -r '.access_token' 'output.txt')"
rm -rf output.txt

###--- File download code ---###
#sp_folder_relative_path="/teams/Innovation386/Shared%20Documents"
#file_name="job_55182.txt"
#local_folder_path="/tmp"
#url="${sp_site_collection_url}/_api/web/GetFileByServerRelativeUrl('${sp_folder_relative_path}/${file_name}')/\$value"
#curl -L --insecure -X GET \
#  -o "${local_folder_path}/${file_name}" \
#  -H "Accept: application/json" \
#  -H "Authorization: Bearer ${access_token}" \
#  "${url}"
#exit_code=$?
#if [ $exit_code -eq 0 ]; then
##  ls -lart /tmp
##  cat /tmp/${file_name}
#  echo "File downloaded successfully."
#else
#  echo "Error occurred while downloading the file."
#fi
### ------------------------###
git_issue_id=$1
issue_comment=$2
echo "Print issue comments : "
echo "$issue_comment"

json_payload='{
    "__metadata": { "type": "SP.Data.Issue_x0020_trackerListItem" },
    "Description": "'"$issue_comment"'",
    "GitIssueId": "'"$git_issue_id"'"
}'

curl --location "https://myonlinesp.sharepoint.com/teams/Innovation386/_api/web/lists/GetByTitle('Issue%20tracker')/items(1)" \
--header "Content-Type: application/json;odata=verbose" \
--header "Accept: application/json;odata=verbose" \
--header "X-HTTP-Method: MERGE" \
--header "Authorization: Bearer $access_token" \
--header "If-Match: *" \
--data-raw "$json_payload"


exit_code=$?
if [ $exit_code -eq 0 ]; then
#  ls -lart /tmp
#  cat /tmp/${file_name}
 echo "Item updated successfully."
else
 echo "Error occurred while updating the item."
fi
