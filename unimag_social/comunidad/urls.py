from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    SolicitarCodigoView, RegistrarUsuarioView, ObjetoPerdidoListCreateView, 
    ObjetoPerdidoDetailView, LoginView, toggle_like, crear_comentario,
    recuperar_password_solicitar, recuperar_password_confirmar, 
    PostForoViewSet, actualizar_perfil, cambiar_password, eliminar_cuenta,
    ChatView, enviar_sugerencia, MisChatsRecientesView, CheckNotificacionesView
)

router = DefaultRouter()

router.register(r'foro', PostForoViewSet, basename='postforo')

urlpatterns = [

    path('auth/solicitar-codigo/', SolicitarCodigoView.as_view()),
    path('auth/registro/', RegistrarUsuarioView.as_view()),
    path('auth/login/', LoginView.as_view()),
    path('auth/recuperar/', recuperar_password_solicitar),
    path('auth/recuperar-confirmar/', recuperar_password_confirmar),
    path('objetos/', ObjetoPerdidoListCreateView.as_view()), 
    path('objetos/<int:pk>/', ObjetoPerdidoDetailView.as_view()),
    path('objetos/<int:pk>/like/', toggle_like),
    path('objetos/<int:pk>/comentar/', crear_comentario),
    path('auth/perfil/actualizar/', actualizar_perfil),
    path('auth/password/cambiar/', cambiar_password),
    path('auth/cuenta/eliminar/', eliminar_cuenta),
    path('auth/sugerencia/', enviar_sugerencia),

    path('chat/<int:usuario_id>/', ChatView.as_view()),
    path('mis-chats/', MisChatsRecientesView.as_view()),
    path('notificaciones/check/', CheckNotificacionesView.as_view()),
    path('', include(router.urls)),
]