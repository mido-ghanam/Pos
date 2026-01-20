from rest_framework.views import APIView
from rest_framework.response import Response
from billing.models import Expense,CashBox
from rest_framework.permissions import AllowAny
from decimal import Decimal



class ExpenseCreateView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        # Accept both 'title' and 'description' for flexibility
        title = request.data.get("title") or request.data.get("description")
        amount = Decimal(str(request.data.get("amount", 0)))
        category = request.data.get("category") or request.data.get("expense_type", "General")
        
        if not title:
            return Response({"error": "title or description is required"}, status=400)
        if amount <= 0:
            return Response({"error": "amount must be greater than 0"}, status=400)
        # تحديث الخزنة
        cashbox = CashBox.objects.select_for_update().first()
        if not cashbox:
            return Response({"error": "CashBox not found"}, status=500)
        if cashbox.balance < amount:
            return Response({"error": "Insufficient cash balance"}, status=400)
        
        cashbox.balance -= amount
        cashbox.save()
        
        expense = Expense.objects.create(
            title=title,
            amount=amount,
            category=category
        )
        
        return Response({
            "message": "Expense created successfully",
            "expense": {
                "id": expense.id,
                "title": expense.title,
                "amount": float(expense.amount),
                "category": expense.category,
                "created_at": expense.created_at
            }
        }, status=201)
