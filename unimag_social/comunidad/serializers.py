from rest_framework import serializers
from django.contrib.auth.models import User
from .models import PerfilEstudiante
from .models import ObjetoPerdido, Comentario, Like, FotoObjeto
from .models import PostForo
from .models import MensajeChat


class FotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = FotoObjeto
        fields = ['id', 'imagen']

class SolicitarCodigoSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        if not value.endswith('@unimagdalena.edu.co'):
            raise serializers.ValidationError("Solo se permiten correos institucionales")
        return value

class RegistroUsuarioSerializer(serializers.Serializer):
    email = serializers.EmailField()
    codigo = serializers.CharField(max_length=6)
    username = serializers.CharField(max_length=30, required=False) 
    password = serializers.CharField(write_only=True)
    carrera = serializers.CharField()


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

class ComentarioSerializer(serializers.ModelSerializer):
    usuario_nombre = serializers.ReadOnlyField(source='usuario.username')
    class Meta:
        model = Comentario
        fields = ['id', 'usuario_nombre', 'texto', 'fecha']


class ObjetoPerdidoSerializer(serializers.ModelSerializer):
    usuario_nombre = serializers.ReadOnlyField(source='usuario.username')
    usuario_carrera = serializers.ReadOnlyField(source='usuario.perfilestudiante.carrera')
    usuario_id = serializers.ReadOnlyField(source='usuario.id')
    
    es_dueno = serializers.SerializerMethodField()
    num_likes = serializers.SerializerMethodField()
    ya_dio_like = serializers.SerializerMethodField()
    
    comentarios = ComentarioSerializer(many=True, read_only=True)
    fotos = FotoSerializer(many=True, read_only=True)

    imagenes_subidas = serializers.ListField(
        child=serializers.ImageField(),
        write_only=True, 
        required=False
    )

    class Meta:
        model = ObjetoPerdido
        fields = [
            'id', 'titulo', 'descripcion', 'ubicacion', 
            'estado', 'fecha_publicacion', 'usuario_nombre', 'usuario_carrera',
            'es_dueno', 'num_likes', 'ya_dio_like', 
            'comentarios', 'fotos', 'imagenes_subidas', 'usuario_id',
        ]
        read_only_fields = ['usuario', 'fecha_publicacion']
        
        extra_kwargs = {
            'titulo': {'required': False, 'allow_blank': True, 'allow_null': True},
            'ubicacion': {'required': False, 'allow_blank': True, 'allow_null': True},
            'imagenes_subidas': {'required': False}
        }

    def get_es_dueno(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.usuario == request.user
        return False

    def get_num_likes(self, obj):
        return obj.likes.count()

    def get_ya_dio_like(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Like.objects.filter(objeto=obj, usuario=request.user).exists()
        return False

    def create(self, validated_data):
        imagenes = validated_data.pop('imagenes_subidas', [])
        objeto = ObjetoPerdido.objects.create(**validated_data)
        
        for img in imagenes:
            FotoObjeto.objects.create(objeto=objeto, imagen=img)
        
        return objeto

    def update(self, instance, validated_data):
        instance.titulo = validated_data.get('titulo', instance.titulo)
        instance.descripcion = validated_data.get('descripcion', instance.descripcion)
        instance.ubicacion = validated_data.get('ubicacion', instance.ubicacion)
        
        instance.estado = validated_data.get('estado', instance.estado)
        instance.save()
        return instance

class PostForoSerializer(serializers.ModelSerializer):
    usuario_id = serializers.ReadOnlyField(source='usuario.id') 
    usuario_nombre = serializers.SerializerMethodField()
    usuario_carrera = serializers.SerializerMethodField()
    num_likes = serializers.ReadOnlyField(source='total_likes')
    ya_dio_like = serializers.SerializerMethodField()

    class Meta:
        model = PostForo
        fields = [
            'id', 'usuario_id', 'tipo', 'contenido', 'fecha', 
            'es_anonimo', 'carrera_filtro', 'tag',
            'usuario_nombre', 'usuario_carrera', 'num_likes', 'ya_dio_like'
        ]
        
        extra_kwargs = {
            'carrera_filtro': {'required': False, 'allow_null': True, 'allow_blank': True},
            'tag': {'required': False, 'allow_null': True, 'allow_blank': True}
        }

    def get_usuario_nombre(self, obj):
        if obj.es_anonimo:
            return "Anónimo"
        return obj.usuario.username

    def get_usuario_carrera(self, obj):
        if obj.es_anonimo:
            return "Secreto"
        try:
            return obj.usuario.perfilestudiante.get_carrera_display()
        except:
            return ""

    def get_ya_dio_like(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.likes.filter(id=request.user.id).exists()
        return False

class MensajeChatSerializer(serializers.ModelSerializer):
    es_mio = serializers.SerializerMethodField()

    class Meta:
        model = MensajeChat
        fields = ['id', 'remitente', 'destinatario', 'contenido', 'fecha', 'es_mio']

    def get_es_mio(self, obj):
        request = self.context.get('request')
        if request and request.user:
            return obj.remitente == request.user
        return False