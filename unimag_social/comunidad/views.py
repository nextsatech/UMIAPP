from django.shortcuts import render
from rest_framework import generics, permissions, status, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.core.mail import send_mail
from .models import CodigoVerificacion, PerfilEstudiante, ObjetoPerdido, Comentario, Like, PostForo, MensajeChat
from .serializers import (
    SolicitarCodigoSerializer, 
    RegistroUsuarioSerializer, 
    ObjetoPerdidoSerializer, 
    LoginSerializer,
    ComentarioSerializer,
    PostForoSerializer,
    MensajeChatSerializer
)
from .permissions import EsDueñoOLectura
import random
import string
from django.contrib.auth.hashers import check_password
from django.db.models import Q
from django.conf import settings

# --- FUNCIONES DE CORREO Y SUGERENCIAS ---

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def enviar_sugerencia(request):
    usuario = request.user
    mensaje = request.data.get('mensaje')
    
    if not mensaje:
        return Response({'success': False, 'message': 'El mensaje no puede estar vacío'}, status=400)

    asunto = f"💡 Nueva Sugerencia de {usuario.username} ({usuario.perfilestudiante.carrera})"
    cuerpo = f"""
    El usuario {usuario.username} ({usuario.email}) ha enviado la siguiente sugerencia:
    
    ----------------------------------------------------
    {mensaje}
    ----------------------------------------------------
    
    Fecha: {timezone.now()}
    """
    
    try:
        send_mail(
            asunto,
            cuerpo,
            settings.EMAIL_HOST_USER, 
            ['umimag2026@gmail.com'], 
            fail_silently=False,
        )
        return Response({'success': True, 'message': 'Sugerencia enviada'})
    except Exception as e:
        print(f"Error enviando correo: {e}")
        return Response({'success': False, 'message': 'Error al enviar correo'}, status=500)

def enviar_correo_unimag(email, codigo):
    try:
        send_mail(
            'Tu código de verificación UMi',
            f'Tu código es: {codigo}',
            settings.EMAIL_HOST_USER,
            [email],
            fail_silently=False,
        )
    except Exception as e:
        print(f"Error enviando código: {e}")

# --- VISTAS DE FORO ---

class PostForoViewSet(viewsets.ModelViewSet):
    queryset = PostForo.objects.all().order_by('-fecha')
    serializer_class = PostForoSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def toggle_like(self, request, pk=None):
        post = self.get_object()
        user = request.user
        if post.likes.filter(id=user.id).exists():
            post.likes.remove(user)
            liked = False
        else:
            post.likes.add(user)
            liked = True
        return Response({'liked': liked, 'num_likes': post.total_likes})

# --- VISTAS DE AUTENTICACIÓN Y REGISTRO ---

class SolicitarCodigoView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = SolicitarCodigoSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            
            if User.objects.filter(email=email).exists():
                return Response({"error": "Este correo ya está registrado. Inicia sesión."}, status=status.HTTP_400_BAD_REQUEST)

            codigo_generado = ''.join(random.choices(string.digits, k=6))
            
            CodigoVerificacion.objects.update_or_create(
                correo=email,
                defaults={'codigo': codigo_generado}
            )
            
            enviar_correo_unimag(email, codigo_generado)
            
            return Response({"mensaje": "Código enviado a tu correo"}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class RegistrarUsuarioView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = RegistroUsuarioSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data
            email = data['email']
            codigo = data['codigo']
            
            try:
                registro_codigo = CodigoVerificacion.objects.get(correo=email)
                if registro_codigo.codigo != codigo:
                    return Response({"error": "Código incorrecto"}, status=status.HTTP_400_BAD_REQUEST)
                if not registro_codigo.es_valido():
                    return Response({"error": "El código ha expirado"}, status=status.HTTP_400_BAD_REQUEST)
            except CodigoVerificacion.DoesNotExist:
                return Response({"error": "No has solicitado un código"}, status=status.HTTP_400_BAD_REQUEST)

            username = data.get('username')
            if not username:
                aleatorio = ''.join(random.choices(string.digits, k=4))
                username = f"estudiante_{aleatorio}"
            
            if User.objects.filter(username=username).exists():
                 return Response({"error": "Ese nombre de usuario ya existe"}, status=status.HTTP_400_BAD_REQUEST)

            nuevo_usuario = User.objects.create_user(username=username, email=email, password=data['password'])
            
            PerfilEstudiante.objects.create(
                usuario=nuevo_usuario,
                carrera=data['carrera'],
                es_verificado=True
            )
            
            registro_codigo.delete()

            return Response({
                "mensaje": "Usuario creado con éxito",
                "usuario": username
            }, status=status.HTTP_201_CREATED)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            password = serializer.validated_data['password']
            
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return Response({"error": "Usuario no encontrado"}, status=status.HTTP_400_BAD_REQUEST)

            if user.check_password(password):
                try:
                    carrera_usuario = user.perfilestudiante.carrera
                except Exception:
                    carrera_usuario = "ADMINISTRADOR"
                return Response({
                    "mensaje": "Login exitoso",
                    "username": user.username,
                    "carrera": carrera_usuario,
                }, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Contraseña incorrecta"}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# --- VISTAS DE OBJETOS PERDIDOS ---

class ObjetoPerdidoListCreateView(generics.ListCreateAPIView):
    serializer_class = ObjetoPerdidoSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        fecha_limite = timezone.now() - timedelta(days=3)
        return ObjetoPerdido.objects.filter(fecha_publicacion__gte=fecha_limite).order_by('-fecha_publicacion')

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

class ObjetoPerdidoDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = ObjetoPerdido.objects.all()
    serializer_class = ObjetoPerdidoSerializer
    permission_classes = [IsAuthenticated, EsDueñoOLectura]

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_like(request, pk):
    try:
        objeto = ObjetoPerdido.objects.get(pk=pk)
    except ObjetoPerdido.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    like, created = Like.objects.get_or_create(usuario=request.user, objeto=objeto)
    
    if not created:
        like.delete()
        return Response({'status': 'unliked'})
    else:
        return Response({'status': 'liked'})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def crear_comentario(request, pk):
    try:
        objeto = ObjetoPerdido.objects.get(pk=pk)
    except ObjetoPerdido.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
        
    texto = request.data.get('texto')
    if not texto:
        return Response({'error': 'Texto requerido'}, status=status.HTTP_400_BAD_REQUEST)

    comentario = Comentario.objects.create(objeto=objeto, usuario=request.user, texto=texto)
    return Response(ComentarioSerializer(comentario).data, status=status.HTTP_201_CREATED)

# --- VISTAS DE RECUPERACIÓN Y PERFIL ---

@api_view(['POST'])
@permission_classes([AllowAny]) 
def recuperar_password_solicitar(request):
    email = request.data.get('email')
    
    try:
        user = User.objects.filter(email=email).first()
        if not user:
             return Response({'error': 'Este correo no está registrado.'}, status=404)

        codigo = str(random.randint(100000, 999999))
        
        CodigoVerificacion.objects.update_or_create(
            correo=email,
            defaults={'codigo': codigo, 'creado_en': timezone.now()}
        )
        
        enviar_correo_unimag(email, codigo)
        
        return Response({'mensaje': 'Código enviado. Revisa tu correo.'})
        
    except Exception as e:
        return Response({'error': str(e)}, status=500)

@api_view(['POST'])
@permission_classes([AllowAny])
def recuperar_password_confirmar(request):
    email = request.data.get('email')
    codigo_recibido = request.data.get('codigo')
    nueva_password = request.data.get('password')
    
    try:
        registro_codigo = CodigoVerificacion.objects.get(correo=email)
        if registro_codigo.codigo != codigo_recibido:
             return Response({'error': 'Código incorrecto'}, status=400)
    except CodigoVerificacion.DoesNotExist:
        return Response({'error': 'No has solicitado un código'}, status=400)
        
    try:
        user = User.objects.get(email=email)
        user.set_password(nueva_password) 
        user.save()
        
        registro_codigo.delete()
        
        return Response({'mensaje': 'Contraseña actualizada con éxito'})
    except User.DoesNotExist:
        return Response({'error': 'Usuario no encontrado'}, status=404)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def actualizar_perfil(request):
    user = request.user
    nuevo_username = request.data.get('username')
    
    if not nuevo_username:
        return Response({'success': False, 'message': 'El nombre no puede estar vacío'}, status=400)
    
    if User.objects.filter(username=nuevo_username).exclude(id=user.id).exists():
        return Response({'success': False, 'message': 'Ese nombre de usuario ya está en uso'}, status=400)
    
    user.username = nuevo_username
    user.save()
    return Response({'success': True, 'message': 'Perfil actualizado'})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def cambiar_password(request):
    user = request.user
    old_pass = request.data.get('old_password')
    new_pass = request.data.get('new_password')
    
    if not check_password(old_pass, user.password):
        return Response({'success': False, 'message': 'La contraseña actual es incorrecta'}, status=400)
    
    user.set_password(new_pass)
    user.save()
    return Response({'success': True, 'message': 'Contraseña actualizada'})

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def eliminar_cuenta(request):
    user = request.user
    user.delete()
    return Response({'success': True, 'message': 'Cuenta eliminada permanentemente'})

# --- VISTAS DE CHAT (24 HORAS) ---

class ChatView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, usuario_id):
        limite_tiempo = timezone.now() - timedelta(hours=24)
        
        
        mensajes = MensajeChat.objects.filter(
            (Q(remitente=request.user, destinatario_id=usuario_id) | 
             Q(remitente_id=usuario_id, destinatario=request.user)),
            fecha__gte=limite_tiempo 
        ).order_by('fecha')

        MensajeChat.objects.filter(
            remitente_id=usuario_id, 
            destinatario=request.user,
            leido=False
        ).update(leido=True)

        serializer = MensajeChatSerializer(mensajes, many=True, context={'request': request})
        return Response(serializer.data)

    def post(self, request, usuario_id):
        data = request.data.copy()
        contenido = data.get('contenido') 
        
        if not contenido:
            return Response({'error': 'Mensaje vacío'}, status=400)

        nuevo_mensaje = MensajeChat.objects.create(
            remitente=request.user,
            destinatario_id=usuario_id,
            contenido=contenido
        )
        
        serializer = MensajeChatSerializer(nuevo_mensaje, context={'request': request})
        return Response(serializer.data, status=201)

class MisChatsRecientesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        usuario = request.user
        limite = timezone.now() - timedelta(hours=24)
        
        # Buscar mensajes donde soy remitente o destinatario
        mensajes = MensajeChat.objects.filter(
            (Q(remitente=usuario) | Q(destinatario=usuario)),
            fecha__gte=limite
        ).select_related('remitente', 'destinatario').order_by('-fecha')

        # Filtrar usuarios únicos con los que hablé
        usuarios_vistos = set()
        chats = []

        for m in mensajes:
            otro_usuario = m.destinatario if m.remitente == usuario else m.remitente
            
            if otro_usuario.id not in usuarios_vistos:
                usuarios_vistos.add(otro_usuario.id)
                chats.append({
                    'usuario_id': otro_usuario.id,
                    'usuario_nombre': otro_usuario.username,
                    'ultimo_mensaje': m.contenido,
                    'fecha': m.fecha
                })

        return Response(chats)

class CheckNotificacionesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
       
        nuevos = MensajeChat.objects.filter(
            destinatario=request.user, 
            leido=False
        ).count()
        return Response({'nuevos': nuevos})