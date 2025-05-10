# AcquiredBy Tool

This Python tool helps in finding companies acquired by a specific organization by scraping data from **Google Serper** search results. It fetches relevant data from **Crunchbase** about acquisitions made by companies, providing both the full information and the titles of the acquired companies.

## Features

- Searches for companies acquired by a specified organization.
- Retrieves data from **Google Serper API**.
- Saves the results in two formats:
  - A JSON file containing all the detailed acquisition data.
  - A text file containing only the titles of the acquired companies.

## Installation

1. Clone this repository:

```bash
git clone https://github.com/x0gamil/Bug_Bounty_Scripts.git

cd Bug_Bounty_Scripts/acquiredBy

pip install requests
```

## Get API Key

Get an API Key for Google Serper:

Visit Serper API and sign up to get your API key.

Replace the placeholder API key in the script with your actual API key.

## Run

```bash
python acquiredBy.py
 ```
