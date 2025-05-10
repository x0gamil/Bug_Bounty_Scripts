#!/bin/bash
function treemap()
{
  echo -e "${YELLOW}Tool Directories And Files Output Tree Map:${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/serpdev-$domain-acquires.json${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/companies-title-acquired-by-$domain.txt${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains/all-subs.txt${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains/httpx-alive.txt${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains/paramspider.txt${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains/waybackmachines${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains/waybackmachines/all-waybackmachines.txt${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains/DNS${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains/DNS/altdns-generated-subs.txt${NC}"
  echo -e "  ${MAGENTA}~/recon/$domain/$domain-subdomains/DNS/dnsx-resolved-ips.txt${NC}"

}
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
  echo ""
  echo -e "${MAGENTA}Invalid domain format. Exiting.${NC}"
  echo ""
  exit 1
fi

# Load the .env file
#GITHUB_TOKEN = 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
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ""
  echo -e "${MAGENTA}Error: .env file not found!${NC}"
  echo ""
  echo -e "${MAGENTA}Create '.env' then put your github api token inside it, like this style${NC}"
  echo ""
  echo -e "${MAGENTA}GITHUB_TOKEN=your_github_token_here${NC}"
  echo ""
  exit 1
fi


echo -e "${BLUE}Domain Name:${NC} ${GREEN}$domain${NC}"
mkdir -p "/home/kali/recon/$domain"
cd "/home/kali/recon/$domain" || exit

tools=("AcquiredBy.py" "subfinder" "assetfinder" "crtsh.sh" "amass" "github-subdomains" "altdns" "gobuster" "gau" "waybackurls" "httpx")
missing_tools=()
for tool in "${tools[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    missing_tools+=("$tool")
  fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
  echo ""
  echo -e "${RED}The following tools are missing: ${missing_tools[*]}${NC}"
  echo ""
  exit 1
fi

echo ""
treemap
echo ""

echo ""
echo -e "${YELLOW}Passive Recon Process Starts For Domain '$domain' ...${NC}"
echo ""


echo ""
echo -e "${BLUE}Getting Companies Acquired By The Organization : if You Need Press 'y' if Don't press 'n'${NC}"
read -p "Enter Option Number: " option
if [ $option == 'y' ] || [ $option == 'Y' ];then
  echo ""
  echo -e "${BLUE}Statring AcquiredBy.py Script${NC}"
  echo ""
  python $(which AcquiredBy.py)
  echo -e "${GREEN}AcquiredBy.py Script Finished${NC}"
  echo ""
else
  echo ""
  echo -e "${YELLOW}Skipping..${NC}"
  echo ""
fi

echo ""
echo -e "${YELLOW}Starting Passive SubDomains Enumeration For Domain '$domain'...${NC}"
echo ""
mkdir "$domain-subdomains"
cd "$domain-subdomains"

echo ""
echo -e "${BLUE}Starting Subfinder...${NC}"
echo ""
subfinder -d "$domain" -all -recursive >> all-subs.txt
echo ""
echo -e "${GREEN}Subfinder Finished${NC}"
echo ""

echo ""
echo -e "${BLUE}Starting assetfinder...${NC}"
echo ""
assetfinder -subs-only $domain >> all-subs.txt
echo ""
echo -e "${GREEN}assetfinder Finished${NC}"
echo ""

echo ""
echo -e "${BLUE}Starting Crtsh...${NC}"
echo ""
crtsh.sh -d $domain
echo ""
echo -e "${GREEN}Crtsh Finished${NC}"
echo ""

echo ""
echo -e "${BLUE}Starting github-subdomains...${NC}"
echo ""
github-subdomains -d $domain -t "$GITHUB_TOKEN" >> subs-github-subdomains.txt
cat subs-github-subdomains.txt| grep "$domain" | grep -v "http" | grep -v ":%22" | grep -v "domain" | cut -d " " -f 2 >> all-subs.txt
cat "$domain.txt" >> all-subs.txt
rm -f  subs-github-subdomains.txt "$domain.txt"
echo ""
echo -e "${GREEN}github-subdomains Finished${NC}"
echo ""

echo ""
echo -e "${BLUE}Starting amass...${NC}"
echo ""
amass enum -passive -d $domain >> all-subs.txt
echo ""
echo -e "${GREEN}amass Finished${NC}"
echo ""

mv -f all-subs.txt all-subs-to-sort.txt
sort -u all-subs-to-sort.txt -o all-subs.txt
sudo rm -f all-subs-to-sort.txt

echo ""
echo -e "${YELLOW}Targetting Wayback Machines Starts${NC}"
echo ""
echo -e "${BLUE}Starting waybackurls...${NC}"
echo ""
echo "$domain" | waybackurls >> waybackmachines.txt
echo ""
echo -e "${GREEN}waybackurls Finished.${NC}"
echo ""

echo ""
echo -e "${BLUE}Starting gau...${NC}"
echo ""
echo "$domain" | gau >> waybackmachines.txt
echo ""
echo -e "${GREEN}gau Finished.${NC}"
echo ""

echo ""
echo -e "${BLUE}Starting paramspider...${NC}"
echo ""
python /home/kali/Desktop/hunt/tools/ParamSpider/paramspider.py -d $domain -o paramspider.txt
echo ""
echo -e "${GREEN}paramspider Finished.${NC}"
echo ""

echo ""
echo -e "${BLUE}Starting katana...${NC}"
echo ""
echo "$domain" | katana >> waybackmachines.txt
echo ""

echo ""
echo -e "${GREEN}katana Finished.${NC}"
echo ""

cat paramspider.txt | sort -u | anew waybackmachines.txt &>/dev/null
cat waybackmachines.txt | uro >> all-waybackmachines.txt
rm -f waybackmachines.txt

echo ""
echo -e "${YELLOW}Sorting And Separating wayback machines Result '[tar zip db env xlsx bak sql js txt]' Files Started...${NC}"
echo ""
mkdir waybackmachines
cat all-waybackmachines.txt | grep -Eo "\.js$" >> waybackmachines/js.txt
cat all-waybackmachines.txt | grep -Eo "\.db$" >> waybackmachines/db.txt
cat all-waybackmachines.txt | grep -Eo "\.zip$" >> waybackmachines/zip.txt
cat all-waybackmachines.txt | grep -Eo "\.tar$" >> waybackmachines/tar.txt
cat all-waybackmachines.txt | grep -Eo "\.env$" >> waybackmachines/env.txt
cat all-waybackmachines.txt | grep -Eo "\.bak$" >> waybackmachines/bak.txt
cat all-waybackmachines.txt | grep -Eo "\.sql$" >> waybackmachines/sql.txt
cat all-waybackmachines.txt | grep -Eo "\.txt$" >> waybackmachines/txt.txt
cat all-waybackmachines.txt | grep -Eo "\.xlsx$" >> waybackmachines/xlsx.txt
mv -f all-waybackmachines.txt ./waybackmachines/all-waybackmachines.txt
echo ""
echo -e "${GREEN}Finished${NC}"
echo ""

echo ""
echo -e "${BLUE}Consolidating subdomains...${NC}"
echo ""
###################################################
echo ""
echo -e "${BLUE}Starting mantra...${NC}"
echo ""
cat "~/recon/$domain/$domain-subdomains/waybackmachines/js.txt" | mantra >> mantra-secrets.txt
echo ""

echo ""
echo -e "${GREEN}mantra Finished.${NC}"
echo ""

###################################################
flag=0
echo -e "${MAGENTA}Do You Want To DNS BruteForce Now With altdns, IT Will Retrive most huge data${NC}"
read -p "'y' or 'n':" flag
if [ $flag == "y" ]; then
  echo ""
  echo -e "${YELLOW}DNS BruteForcing Startes${NC}"
  echo ""
  echo -e "${BLUE}Starting altdns...${NC}"
  echo ""
  mkdir DNS
  #altdns -i all-subs.txt -w /home/kali/Desktop/hunt/wordlists/SecLists-master/Discovery/DNS/subdomains-top1million-110000.txt -o ./DNS/altdns-generated-subs.txt
  altdns -i all-subs.txt -w /home/kali/Desktop/hunt/wordlists/SecLists-master/Discovery/DNS/subdomains-top1million-110000.txt -o altdns-generated-subs.txt
  echo ""
  echo -e "${GREEN}altdns Finished${NC}"
  echo ""

  echo ""
  echo -e "${BLUE}Starting dnsx...${NC}"
  echo ""
  dnsx -l ./DNS/altdns-generated-subs.txt -resp-only -o ./DNS/dnsx-resolved-ips.txt
  echo ""
  echo -e "${GREEN}dnsx Finished${NC}"
  echo ""
else
  echo -e "${YELLOW}Skipping..${NC}"
fi

#echo -e "${BLUE}Starting SubDomain BruteForce From DNS${NC}"
#gobuster dns -d $domain -w ~/Desktop/hunt/wordlists/SecLists-master/Discovery/DNS/subdomains-top1million-110000.txt >> gobuster-dns-subdomains.txt
#cat gobuster-dns-subdomains.txt| awk -F " " '{print $2}' | grep $domain | tee final-gobuster-dns-brute-subs.txt
echo ""
echo -e "${GREEN}DNS BruteForcing Finished!${NC}"
echo ""

echo ""
echo -e "${BLUE}Starting httpx...${NC}"
echo ""
httpx -l all-subs.txt -title -sc -cl -location -td -ip -ct -o httpx-alive.txt
echo ""
echo -e "${GREEN}httpx Finished${NC}"
echo ""

echo ""
echo -e "${GREEN}Passive SubDomains Enumeration Finished!${NC}"
echo ""
