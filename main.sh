#thee ips are ignored, gets yesterdays lof entries from access_log in cpanel
cat /usr/local/cpanel/logs/access_log | grep -v "^1\.1\.1\.1" | grep -v "^127\.0\.0\.1" | awk -v d="$(date -d 'yesterday' +'%m/%d/%Y')" '$0 ~ d' |awk '{for (i=1;i<=NF;i++) if ($i~/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) print $i}' | sort -u > temp_ips.txt

# Download the list of Cloudflare IP ranges
cloudflare_ips=$(curl -s https://www.cloudflare.com/ips-v4)

# Read each line of the temporary file containing the unique IP addresses
while read -r ip; do
  # Check if the IP is in the Cloudflare IP range
  if [[ "$cloudflare_ips" == *"$ip"* ]]; then
    echo "$ip is a Cloudflare IP"
  else
    # Check the IP's description using whois
    descr=$(whois "$ip" | grep -i "descr")
    if [[ "$descr" == *"CloudFlare CDN network"* ]]; then
      echo "$ip is a Cloudflare IP"
    else
      echo "$ip is not a Cloudflare IP"
    fi
  fi
done < ./temp_ips.txt
