import http.client
import json

company = input("Enter Organization Name: ")
conn = http.client.HTTPSConnection("google.serper.dev")
payload = json.dumps({
    "q": f"site:crunchbase.com {company} acquires",
    "num": 100,
    "page": 1
})
headers = {
    'X-API-KEY': '9e6574ff51fe66969fa05c2f8da57788374dd7a8',
    'Content-Type': 'application/json'
}
conn.request("POST", "/search", payload, headers)
res = conn.getresponse()
data = res.read()
with open(f'serpdev-{company}-acquires.json','+a') as f:
    f.write(data.decode("utf-8"))
    content = (data.decode("utf-8"))

with open(f"companies-title-acquired-by-{company}.txt", "+a") as title:
    data = json.loads(content)  #Convert json format to python format
    for acquired in data["organic"]:
        title.write(acquired["title"])
        title.write("\n")
    print(len(data["organic"]),f" Companies Founded Aquired By {company}")
print(f"All Companies Information Data Stored in \"serpdev-{company}-acquires.json\"")
print(f"All Companies Title Extracted Stored in \"companies-title-acquired-by-{company}.txt\"")