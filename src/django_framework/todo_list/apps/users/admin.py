from django.contrib import admin
from django.contrib.auth import get_user_model
from django.contrib.auth.admin import UserAdmin

from .forms import CustomUserChangeForm, CustomUserCreationForm

User = get_user_model()


class CustomUserAdmin(UserAdmin):
    """CustomUserAdmin class."""

    add_form = CustomUserCreationForm
    form = CustomUserChangeForm
    model = User
    fieldsets = ((None, {"fields": ("first_name", "last_name", "email", "password")}),)
    search_fields = ("email", "first_name", "last_name")  # type: ignore
    ordering = ("email",)

    list_display = (  # type: ignore
        "is_active",
        "email",
        "first_name",
        "last_name",
        "is_staff",
        "is_superuser",
    )

    list_display_links = ("email",)

    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": (
                    "first_name",
                    "email",
                    "password1",
                    "password2",
                ),
            },
        ),
    )


admin.site.register(User, CustomUserAdmin)
