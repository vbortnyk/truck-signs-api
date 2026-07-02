#!/bin/bash
set -e

python manage.py migrate

python manage.py shell <<EOF
import os
from django.contrib.auth import get_user_model

User = get_user_model()

username = os.environ.get("DJANGO_SUPERUSER_USERNAME", "admin")
email = os.environ.get("DJANGO_SUPERUSER_EMAIL", "admin@example.com")
password = os.environ.get("DJANGO_SUPERUSER_PASSWORD")

if not password:
    raise ValueError("DJANGO_SUPERUSER_PASSWORD is not set")

if User.objects.filter(username=username).exists():
    print(f"Superuser '{username}' exists.")
else:
    User.objects.create_superuser(
        username=username,
        email=email,
        password=password
    )
    print(f"Superuser '{username}' is creatred.")
EOF