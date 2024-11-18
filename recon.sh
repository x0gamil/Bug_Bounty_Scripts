#!/bin/bash

# Define color codes
#MAGENTA='\033[38;2;128;0;128m' Dark
MAGENTA='\033[38;2;255;0;255m'  #Lighter
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color (reset)

# Print messages in different colors
# echo -e "${MAGENTA}This is a red message.${NC}"
# echo -e "${GREEN}This is a green message.${NC}"
# echo -e "${YELLOW}This is a yellow message.${NC}"
# echo -e "${BLUE}This is a blue message.${NC}"
# echo -e "${MAGENTA}This is a blue message.${NC}"

domain=''
if [ -z $1 ]; then
  echo -e "${MAGENTA}Empty Domain${NC}"
  read -p "Enter Domain Name Here: " domain
else
  domain=$1
fi

if [ -z "$domain" ]; then
  echo -e "${MAGENTA}Empty Domain Name${NC}"
  exit 1
fi

# Improved regex for domain validation
if [[ ! "$domain" =~ ^(([a-zA-Z0-9](-?[a-zA-Z0-9])*)\.)+[a-zA-Z]{2,}$ ]]; then
  echo -e "${MAGENTA}Invalid domain format. Exiting.${NC}"
  exit 1
fi

# Load the .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo -e "${MAGENTA}Error: .env file not found!${NC}"
  echo -e "${MAGENTA}Create '.env' then put your guthub api token inside it, like this style${NC}"
  echo -e "${MAGENTA}GITHUB_TOKEN=your_github_token_here${NC}"
  exit 1
fi


echo -e "${BLUE}Domain Name:${NC} ${GREEN}$domain${NC}"
mkdir -p "/home/kali/$domain"
cd "/home/kali/$domain" || exit

tools=("AcquiredBy.py" "subfinder" "assetfinder" "crtsh.sh" "amass" "github-subdomains" "altdns" "gobuster" "gau" "waybackurls" "httpx")
missing_tools=()
for tool in "${tools[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    missing_tools+=("$tool")
  fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
  echo -e "${RED}The following tools are missing: ${missing_tools[*]}${NC}"
  exit 1
fi


echo -e "${BLUE}Getting Organization Acquired Companies: if You Need Press 'y' if Don't press 'n'${NC}"
read -p "Enter Option Number: " option
if [ $option == 'y' ] || [ $option == 'Y' ];then
  echo -e "${BLUE}Statring AcquiredBy.py Script${NC}"
  AcquiredBy.py
  echo -e "${GREEN}AcquiredBy.py Script Finished${NC}"
fi

echo -e "${BLUE}Starting Passive SubDomains Enumeration For Domain '$domain' ...${NC}"
mkdir "$domain-subdomains"
cd "$domain-subdomains"

echo -e "${BLUE}Starting Subfinder ...${NC}"
subfinder -d $domain -all >> all-subs.txt
echo -e "${GREEN}Subfinder Finished${NC}"

echo -e "${BLUE}Starting assetfinder ...${NC}"
assetfinder -subs-only $domain >> all-subs.txt
echo -e "${GREEN}assetfinder Finished${NC}"

echo -e "${BLUE}Starting Crtsh ...${NC}"
crtsh.sh -d $domain
echo -e "${GREEN}Crtsh Finished${NC}"

echo -e "${BLUE}Starting github-subdomains ...${NC}"
github-subdomains -d $domain -t "$GITHUB_TOKEN" >> subs-github-subdomains.txt
cat subs-github-subdomains.txt| grep "uber.com" | grep -v "http" | grep -v ":%22" | grep -v "domain" | cut -d " " -f 2 >> all-subs.txt
rm -f  subs-github-subdomains.txt
echo -e "${GREEN}github-subdomains Finished${NC}"

echo -e "${BLUE}Starting amass ...${NC}"
amass enum -passive -d $domain >> all-subs.txt
echo -e "${GREEN}amass Finished${NC}"

sort -u all-subs.txt -o all-subs.txt

echo -e "${YELLOW}Getting wayback machines Started${NC}"
echo -e "${BLUE}Starting waybackurls...${NC}"
echo "$domain" | waybackurls >> waybackurls.txt
echo -e "${GREEN}waybackurls Finished.${NC}"

echo -e "${BLUE}Starting gau...${NC}"
echo "$domain" | gau >> gau.txt
echo -e "${GREEN}gau Finished.${NC}"

echo -e "${BLUE}Starting paramspider...${NC}"
python /home/kali/Desktop/hunt/tools/ParamSpider/paramspider.py -d $domain -o paramspider.txt
echo -e "${GREEN}paramspider Finished.${NC}"

cat waybackurls.txt gau.txt paramspider.txt | sort -u >> waybackmachines.txt
rm -f waybackurls.txt gau.txt paramspider.txt 

echo -e "${YELLOW}Sorting And Separating wayback machines Result '[tar zip db env xlsx bak sql js txt]' Files Started${NC}"
mkdir waybackmachines
cat waybackmachines.txt | grep -Eo "\.js$" >> waybackmachines/js.txt
cat waybackmachines.txt | grep -Eo "\.db$" >> waybackmachines/db.txt
cat waybackmachines.txt | grep -Eo "\.zip$" >> waybackmachines/zip.txt
cat waybackmachines.txt | grep -Eo "\.tar$" >> waybackmachines/tar.txt
cat waybackmachines.txt | grep -Eo "\.env$" >> waybackmachines/env.txt
cat waybackmachines.txt | grep -Eo "\.bak$" >> waybackmachines/bak.txt
cat waybackmachines.txt | grep -Eo "\.sql$" >> waybackmachines/sql.txt
cat waybackmachines.txt | grep -Eo "\.txt$" >> waybackmachines/txt.txt
cat waybackmachines.txt | grep -Eo "\.xlsx$" >> waybackmachines/xlsx.txt
echo -e "${GREEN}Finished${NC}"

echo -e "${BLUE}Consolidating subdomains...${NC}"
###################################################
echo -e "${YELLOW}DNS BruteForceing Started${NC}"
echo -e "${BLUE}Starting altdns ...${NC}"
altdns -i all-subs.txt -w /home/kali/Desktop/hunt/wordlists/SecLists-master/Discovery/DNS/subdomains-top1million-110000.txt -o altdns.txt -r -s altdns-resolved.txt
echo -e "${GREEN}altdns Finished${NC}"

#echo -e "${BLUE}Starting SubDomain BruteForce From DNS${NC}"
#gobuster dns -d $domain -w ~/Desktop/hunt/wordlists/SecLists-master/Discovery/DNS/subdomains-top1million-110000.txt >> gobuster-dns-subdomains.txt
#cat gobuster-dns-subdomains.txt| awk -F " " '{print $2}' | grep $domain | tee final-gobuster-dns-brute-subs.txt
echo -e "${GREEN}DNS BruteForcing Finished!${NC}"

echo -e "${BLUE}Starting httpx ...${NC}"
httpx -l all-subs.txt -title -sc -cl -location -td -ip -ct -o httpx-alive.txt
echo -e "${GREEN}httpx Finished${NC}"

echo -e "${GREEN}Passive SubDomains Enumeration Finished!${NC}"
