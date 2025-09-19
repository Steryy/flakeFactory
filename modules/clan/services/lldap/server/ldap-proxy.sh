
set +e
if [[ -z "$LISTEN_FDS" || -z "$LISTEN_PID" ]]; then
  echo "No systemd socket passed."
  exit 1
fi

# Verify the PID matches
if [[ "$LISTEN_PID" != "$$" ]]; then
  echo "LISTEN_PID does not match current PID."
  exit 1
fi
FD=3
IFS= read -r -t 5 -u $FD DATA
username=$(echo "$DATA" | jq -r '.user')
password=$(echo "$DATA" | jq -r '.password')
audiance=$(echo "$DATA" | jq -r '.audiance // empty')
LLDAP_TOKEN=$(echo "$DATA" | jq -r '.access_token // empty')
LLDAP_REFRESHTOKEN=$(echo "$DATA" | jq -r '.refresh_token // empty')

# Log in if the refresh token is empty
if [ -z "$LLDAP_REFRESHTOKEN" ]  ; then
  echo "No refresh token found. Logging in..."
  eval "$(lldap-cli -D "$username" -w "$password" login)"
fi
if  [ -z  "$LLDAP_TOKEN"  ]; then
  exit 1
fi

decoded=$(echo "$LLDAP_TOKEN" | jwt decode - -j | jq '.payload')
user_id=$(echo "$decoded" | jq -r '.user')
groups=$(echo "$decoded" | jq '.groups')


# Extract fields from the request

req=$(echo "$DATA" | jq '.request ')

keys=$(echo "$req" | jq -r '(.groups | keys[]) // empty')

# Loop through the keys
for key in $keys; do
  # Extract the corresponding group data
  value=$(echo "$req" | jq -r --arg k "$key" '.groups | .[$k]')
  v=$(echo "$value" | jq -r '.value')
  t=$(echo "$value" | jq -r '.type')
  trim=$(echo "$value" | jq -r '.trim')

  # If the type is "equal", set trim to false
  if [[ "$t" == "equal" ]]; then
    trim="false"
  fi

  # Perform the query to find matching groups based on the extracted values
  requa=$(echo "$groups" | jq -r --arg val "$v" --arg trim "$trim" --arg type "$t" '
  def check_type($v):
  . | (
    if $type == "start" then startswith($v)
    elif $type == "end" then endswith($v)
    else . == $v
    end
    );

    map(select(. | check_type($val))) | first |
      (if $trim == "true" then trimstr($val) else . end)
    ')

  # If a result is found, print it
  if [ -n "$requa" ]; then
    groupReq="$groupReq -P=$key=$requa"
  fi
done

echo $groupReq


jwt_payload=$(echo "$req" | jq -rc '.raw // empty')
additional=""
if [ -n  "$jwt_payload" ]; then
  additional="$jwt_payload"
fi
# Create the new JWT token with the required claims
new_jwt=$(jwt encode   -i "$ISSUER" -e="$DURATION"   --secret "@$PRIVATEKEYFILE"  $additional  $groupReq )

# Output the result as a JSON object
cat <<EOF > &$FD
{
  "access_token": "$LLDAP_TOKEN",
  "refresh_token": "$LLDAP_REFRESHTOKEN",
  "jwt": "$new_jwt"
}
EOF
