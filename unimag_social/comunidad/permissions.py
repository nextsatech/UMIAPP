from rest_framework import permissions

class EsDueñoOLectura(permissions.BasePermission):
    """
    Permite ver a todos, pero editar/borrar solo al dueño.
    """
    def has_object_permission(self, request, view, obj):
        # GET, HEAD, OPTIONS son seguros (cualquiera puede ver)
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # DELETE, PUT solo si el usuario es el dueño del objeto
        return obj.usuario == request.user