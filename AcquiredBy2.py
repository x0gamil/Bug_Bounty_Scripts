import requests

# Replace 'YOUR_API_KEY' with your SerpAPI key
api_key = '0c045f24f8c609614e6b3c3b0b6335dd39d926047e07293b2131032ad27269f1'
print("*****************************************************************************")
print("*       **Remember This Script API Has Limit 100 Requests In Month**        *")
print("*****************************************************************************")
print("*  This Script is Trying to Find Companies Acquired By other Organanization *")
print("*            Search Source https://serpapi.com/dashboard                    *")
print("*                Powred By: (mohamed gamil) pentester                       *")
print("*****************************************************************************")

company = input("Enter Organization Name: ")
params = {
    'engine': 'google',
    'q': f'site:crunchbase.com {company} acquires',
    'api_key': api_key,
    "num": 100,
    "page": 1
}

response = requests.get('https://serpapi.com/search.json', params=params)
data = response.json()
# Print relevant titles
with open(f'serpapi-companies-acquired-by-{company}.txt','+a') as f:
    for result in data.get('organic_results', []):
        f.write(result['title'])
        f.write("\n")