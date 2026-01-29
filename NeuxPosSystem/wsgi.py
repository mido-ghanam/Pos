from django.core.wsgi import get_wsgi_application
import os

os.environ.setdefault('DJANGO_SETTINGS_MODULE', f'NeuxPosSystem.settings')

application = get_wsgi_application()
