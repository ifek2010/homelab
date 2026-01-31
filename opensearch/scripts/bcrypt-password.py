import bcrypt
# Generate a bcrypt hash and update internal_users.yml file for the admin password 
print(bcrypt.hashpw("Highlyillogical-Sp0ck".encode("utf-8"), bcrypt.gensalt(12, prefix=b"2a")).decode("utf-8"))