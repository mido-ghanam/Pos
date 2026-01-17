from django.http import JsonResponse
from django.urls import resolve

# Endpoints المسموح لها تعدي من غير verified
ALLOWED_PATHS = [
  "register",
  "register-verify",
  "login",
  "login-verify",
  "google-auth",
  "change-password-request",
  "change-password-verify",
]


# Paths prefixes to exempt from CSRF enforcement (API endpoints)
EXEMPT_CSRF_PREFIXES = [
    '/auth/',
    '/partners/',
    '/products/',
    '/billing/',
]

class CsrfExemptAPIMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        path = request.path_info or request.path
        for p in EXEMPT_CSRF_PREFIXES:
            if path.startswith(p):
                setattr(request, '_dont_enforce_csrf_checks', True)
                break
        return self.get_response(request)

class VerifiedUserMiddleware:
  def __init__(self, get_response):
      self.get_response = get_response

  def __call__(self, request):
      user = getattr(request, "user", None)

      if not user or not user.is_authenticated:
          return self.get_response(request)

      if user.verified:
          return self.get_response(request)

      try:
          current_url = resolve(request.path_info).url_name
      except Exception:
          return JsonResponse(
              {"status": False, "message": "Account not verified"},
              status=403
          )

      if current_url in ALLOWED_PATHS:  # يسمح بالـ register/login
          return self.get_response(request)

      return JsonResponse(
          {
              "status": False,
              "message": "Account not verified. Please verify your phone number."
          },
          status=403
      )
