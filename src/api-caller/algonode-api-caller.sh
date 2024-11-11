# -~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-
# !/bin/bash

# -~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-
# Statics
#source="$(readlink -f "{$0}")"
source="$(readlink -f "$0")"
source_dir="$(dirname "${source}")"
origin_cfg="algonode-api-origin.yaml"
endpoint_cfg="algonode-api-endpoint.yaml"
elastic_svc="localhost:9200"

# -~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-
# Functions

dtmu() {
   date -u +"%Y-%m-%dT%H:%M:%S.%7NZ" # 2023-10-10T20:35:53.1898644Z
   }

# -~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-
# Code

# switch to the script directory
# echo "source_dir: ${source_dir}"
cd "${source_dir}";

# read yaml config files and convert to JSON
ao=$(yq -o=json < "${origin_cfg}"); # CentOS/RHEL (elastic instance)
# ao=$(yq -j < "${origin_cfg}"); # Ubuntu (test instance)
ae=$(yq -o=json < "${endpoint_cfg}"); # CentOS/RHEL (elastic instance)
# ae=$(yq -j < "${endpoint_cfg}"); # Ubuntu (test instance)

# loop through the origins and apis...
for origin in $(jq '.[].origin' <<<${ao}); do
   for api in $(jq --argjson origin ${origin} '.[] | select(.origin==$origin).apis[]?.api?' <<<${ao}); do

      # get config values for this origin and api into an array
      declare -A api_origin
      while IFS== read -r key value; do
         api_origin[${key}]=$(eval echo ${value});
      done < <(jq -r --argjson origin ${origin} --argjson api ${api} \
         '.[] | select(.origin==$origin).apis[]? | select(.api==$api) | .origin = $origin | to_entries | .[] | .key + "=" + .value' <<<${ao})

      # loop through the endpoints in the endpoint file...
      for endpoint in $(jq --argjson api ${api} '.[] | select(.api==$api).endpoints[]?.endpoint' <<<${ae}); do

         # get config values for this api endpoint into an array
         declare -A api_endpoint
         while IFS== read -r key value; do
            api_endpoint[${key}]=$(eval echo ${value});
         done < <(jq -r --argjson api ${api} --argjson endpoint ${endpoint} \
            '.[] | select(.api==$api).endpoints[]? | select(.endpoint==$endpoint) | to_entries | .[] | .key + "=" + .value' <<<${ae})

         # call the endpoint and capture the output in an array
         readarray -t api_response < <( \
            curl -sw "%{stderr}%{response_code}\n%{exitcode}\n%{errormsg}\n" \
               -X "${api_endpoint[method]}" \
               -H "${api_origin[header]}: ${api_origin[token]}" \
               "${api_origin[path]}${api_endpoint[path]}${api_endpoint[query]}" \
               2> >(cat) 1> >(jq -rc) | cat);
         # echo "${api_response[@]}" # testing

         # capture the api response
         http_resp_cd=${api_response[0]};
         http_resp=${api_response[3]};

         # capture the curl command output
         cmd_err_cd=${api_response[1]}; 
         cmd_err=${api_response[2]}; 

         # separate the http response from the command standard error output, which have both been combined into the curl command standard output as the first element of the array
         if [ "${cmd_err_cd}" == 0 ]; then
            level="INFO"
         else
            http_resp="{}" # set the http response to an empty JSON object
            level="ERROR" # if there is a non-zero command error code, then report this as an error in the level field
         fi

         # echo "http-response-code: ${http_resp_cd}"
         # echo "http-response: ${http_resp}"
         # echo "command-error-code: ${cmd_err_cd}"
         # echo "command-error-message: ${cmd_err}"
         # echo "level: ${level}"

         # format the data elements as a JSON object
         dataset=$(jq -nc \
            --arg Host "${api_origin[origin]}" \
            --arg @timestamp "$(dtmu)" \
            --arg Message "Algomon API call to ${api_origin[api]} endpoint ${api_endpoint[endpoint]}" \
            --arg API "${api_origin[api]}" \
            --arg API-Path "${api_origin[path]}" \
            --arg Endpoint "${api_endpoint[endpoint]}" \
            --arg Endpoint-Path "${api_endpoint[path]}" \
            --arg Endpoint-Query "${api_endpoint[query]}" \
            --arg Endpoint-Method "${api_endpoint[method]}" \
            --arg Command-Error-Code "${cmd_err_cd}" \
            --arg Command-Error "${cmd_err}" \
            --arg HTTP-Response-Code "${http_resp_cd}" \
            --argjson HTTP-Response ${http_resp} \
            --arg Level "${level}" \
            '$ARGS.named');
         echo "${dataset}" | jq; # testing

         # write the response to elasticsearch
         curl -s "${elastic_svc}/${api_endpoint[elastic_index]}/_doc" \
            -H "Content-Type: application/json" \
            -d "${dataset}" | jq -rc; # formats the response

         # empty the arrays
         unset -f "${api_origin}" "${api_endpoint}" "${api_response}";

      done;
   done;
done;
