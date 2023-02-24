from django.apps import AppConfig


class UsersConfig(AppConfig):
    """UsersConfig class."""

    default_auto_field = "django.db.models.BigAutoField"
    name = "todo_list.apps.users"
    verbose_name = "Users"
