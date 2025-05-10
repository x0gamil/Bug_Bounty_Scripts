
# Bug Bounty Scripts

## Description
This repository contains a collection of scripts for Bug Bounty, Penetration Testing, and Security Researchers. These tools aim to help security professionals automate various tasks like discovering hidden parameters, subdomain enumeration, ASN CIDR retrieval, IP/domain information lookup, and more.

## Tools in this Repository

1. **acquiredBy**  
   Tool to find companies acquired by a specific organization by querying data from [serper.dev](https://serper.dev/playground).

2. **crtsh.sh**  
   Subdomain enumeration tool that queries the [crt.sh](https://crt.sh/) database to find subdomains for a given domain.

3. **cidrFetcher.sh**  
   Retrieves CIDR ranges for a given ASN (Autonomous System Number) using the `whois` command.

4. **ipInfo.sh**  
   Retrieves information about an IP address or domain using `dig` and `ipinfo.io` API.

## Installation

1. **Clone the repository**  
   First, clone this repository to your local machine:

   ```bash
   git clone https://github.com/x0gamil/Bug_Bounty_Scripts.git
   ```


## Navigate to a specific tool directory
For example, if you want to use the acquiredBy tool, navigate to the corresponding directory:
```bash
cd Bug_Bounty_Scripts/acquiredBy
```

## Install any required dependencies
Some tools may require dependencies to be installed. For example, for the acquiredBy tool, you need requests:
```bash
pip install requests
```

## Usage
## 1. acquiredBy
`This tool finds companies that were acquired by a specific organization.`

```bash
python acquiredBy.py
```

`Enter the organization name when prompted.`

## 2. crtsh.sh
`This tool fetches subdomains of a given domain from the crt.sh database.`

```bash
bash crtsh.sh -d domain.com
```
`Replace domain.com with the domain you want to search for subdomains.`

## 3. cidrFetcher.sh
`This script retrieves CIDR ranges for a given ASN.`

```bash
cidrFetcher.sh -a ASN_NUMBER
```

`Replace ASN_NUMBER with the Autonomous System Number.`

## 4. ipInfo.sh
`This tool gets information about an IP or domain.`

```bash
ipInfo.sh -d domain.com
```
`Replace domain.com with the domain or IP you want to lookup.`

`License`
This project is licensed under the MIT License.

Contributing
Feel free to fork this repository and contribute by submitting pull requests, or simply open issues if you encounter any bugs or have suggestions for new features!

