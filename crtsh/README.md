# crtsh.sh - Subdomain Finder from crt.sh

## Description
`crtsh.sh` is a simple script to fetch subdomains of a given domain from the [crt.sh](https://crt.sh/) database. This tool retrieves subdomains by querying the certificate transparency logs and extracting domain information.

## Prerequisites
- `jq` command-line tool for JSON parsing.

## Installation & Usage

### Clone the repository

```bash
git clone https://github.com/x0gamil/Bug_Bounty_Scripts.git

cd Bug_Bounty_Scripts/crtsh.sh

bash crtsh.sh -d domain.com

```

## Options
-d : Domain name to search for subdomains.

## Example
```bash
crtsh.sh -d example.com
```
This will fetch and display all the subdomains associated with example.com from crt.sh and save them to a file all-subs.txt.


