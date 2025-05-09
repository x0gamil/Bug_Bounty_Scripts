import argparse
import requests

GREEN = '\033[92m'
RED = '\033[91m'
RESET = '\033[0m'

test_values = ["1", "test", "True", "False", "null", "12345", "' OR 1=1 --", "<script>alert(1)</script>"]    

parser = argparse.ArgumentParser(description="hidden.py - Fuzzing Hidden Parameters")

parser.add_argument("-u", "--url" , help='Target Base URL', required=True)
#parser.add_argument('-p', "--param", help="Parameter To Test", required=True)
parser.add_argument('-w', '--wordlist', help='Path To Wordlist')

args = parser.parse_args()

path_to_wordlist='./wordlist.txt'
#parameter = args.param
base_response = requests.get(args.url)

if args.wordlist:
    path_to_wordlist= args.wordlist

print(f"[+] Target URL: {args.url}")
print(f"[+] Wordlist: {path_to_wordlist}")
print("\n")

with open(f"{path_to_wordlist}", "r") as file:
    for param in file:
        param=param.strip()
        #payload = {param: 1}
        for value in test_values:
            payload = {param: value.strip()}
            full_url= f"{args.url}?{param}={value}"

            response = requests.get(f"{args.url}",params=payload)

            print(f"Working on {full_url}")
            if (response.text != base_response.text) and (len(response.text) != len(base_response.text)):
                print(f"{GREEN}[+] Potential Existed Parameter: '{param}' >> status code: '{response.status_code}{RESET}'\n")
            else:
                print(f"{RED}Parameter not existed: '{param}' >> status code: '{response.status_code}{RESET}'\n")
