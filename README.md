POS Django project scaffold

This workspace contains a minimal Django project named `pos` and an app named `authentication`.

Quickstart:

1. Create a virtual environment and activate it:

```bash
python -m venv .venv
source .venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Apply migrations and run the development server:

```bash
python manage.py migrate
python manage.py runserver
```

4. Visit `http://127.0.0.1:8000/auth/` to see the `authentication` app index.

Authentication API endpoints (DRF token auth):

- `POST /auth/register/` : register new user. Example body: `{"username":"alice","password":"secret123"}`. Returns user data and `token`.
- `POST /auth/login/` : login with `username` and `password`. Returns `token`.
- `POST /auth/logout/` : logout (requires `Authorization: Token <token>`). Deletes token.
- `GET|PUT /auth/me/` : get or update current user (requires token).
- `POST /auth/change-password/` : change password (requires token). Body: `{"old_password":"...","new_password":"..."}`. Returns new token.

Note: After adding `rest_framework` and `rest_framework.authtoken` to `INSTALLED_APPS`, run migrations to create token tables:

```bash
python manage.py migrate
```

Multi-store / multi-organization support
--------------------------------------

This backend supports multiple stores (organizations) such as supermarkets, pharmacies, restaurants, etc.

- `GET|POST /auth/stores/` : list all stores or create a new store (POST requires authentication).
- `GET|PUT|DELETE /auth/stores/<id>/` : retrieve, update or delete a specific store (requires authentication for write operations).

When registering a user you can optionally provide `store_id` to associate the user with a store:

```json
{
	"username": "alice",
	"password": "secret123",
	"store_id": 1
}
```

Database migrations will be required to create the `Store` model and the new `store` FK on the `User` model:

```bash
python manage.py makemigrations
python manage.py migrate
```
# Pos