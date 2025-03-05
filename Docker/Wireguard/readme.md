## Generate password

```bash
#Install htpasswd if not already done
apt update && apt install apache2-utils -y

#Generate passwd hash
htpasswd -bnBC 10 "" "YourSecurePassword" | tr -d ':\n'

#  Explanation:
#  -b → Use the password provided on the command line.
#  -n → Print the result to stdout (without saving to a file).
#  -B → Use bcrypt (stronger) instead of the default MD5.
#  -C 10 → Set bcrypt cost (higher is more secure, but slower).
#  "" → An empty username (since you only need the hash).
#  "YourSecurePassword" → Replace this with your actual password.
#  tr -d ':\n' → Removes unnecessary : and newline characters from output.
```
