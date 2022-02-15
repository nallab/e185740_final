curl -c cookie.txt --request POST 'https://www.shinya-tan.de/users/sign_in' --header 'Content-Type: application/json' --data-raw '{
    "user": {
        "email": "info@example.com",
        "password": "password"
    }
}'
