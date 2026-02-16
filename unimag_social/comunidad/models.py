from django.db import models
from django.contrib.auth.models import User
import random
from django.utils import timezone
import datetime

CARRERAS = [
    ('ADMINISTRATIVO', 'Administrativo / No aplica'), 
    

    ('MEDICINA', 'Medicina'),
    ('ENFERMERIA', 'Enfermería'),
    ('ODONTOLOGIA', 'Odontología'),
    ('PSICOLOGIA', 'Psicología'),

    ('ADMIN_EMPRESAS', 'Administración de Empresas'),
    ('ADMIN_TURISMO', 'Adm. de Empresas Turísticas y Hoteleras'),
    ('NEGOCIOS', 'Negocios Internacionales'),
    ('CONTADURIA', 'Contaduría Pública'),
    ('ECONOMIA', 'Economía'),

    ('DERECHO', 'Derecho'),
    ('ANTROPOLOGIA', 'Antropología'),
    ('CINE', 'Cine y Audiovisuales'),


    ('BIOLOGIA', 'Biología'),


    ('ING_SISTEMAS', 'Ingeniería de Sistemas'),
    ('ING_CIVIL', 'Ingeniería Civil'),
    ('ING_INDUSTRIAL', 'Ingeniería Industrial'),
    ('ING_ELECTRONICA', 'Ingeniería Electrónica'),
    ('ING_AMBIENTAL', 'Ingeniería Ambiental y Sanitaria'),
    ('ING_AGRONOMICA', 'Ingeniería Agronómica'),
    ('ING_PESQUERA', 'Ingeniería Pesquera'),

    ('LIC_ARTES', 'Licenciatura en Artes'),
    ('LIC_CIENCIAS', 'Lic. en Ciencias Naturales y Edu. Ambiental'),
    ('LIC_CAMPESINA', 'Lic. en Educación Campesina y Rural'),
    ('LIC_INFANTIL', 'Licenciatura en Educación Infantil'),
    ('LIC_PREESCOLAR', 'Licenciatura en Educación Preescolar'),
    ('LIC_ETNOEDUCACION', 'Licenciatura en Etnoeducación'),
    ('LIC_LENGUAS', 'Lic. en Lenguas Extranjeras (Inglés)'),
    ('LIC_LITERATURA', 'Lic. en Literatura y Lengua Castellana'),
    ('LIC_MATEMATICAS', 'Licenciatura en Matemáticas'),
    ('LIC_TECNOLOGIA', 'Licenciatura en Tecnología'),
]

class PerfilEstudiante(models.Model):
    usuario = models.OneToOneField(User, on_delete=models.CASCADE)
    carrera = models.CharField(max_length=100, choices=CARRERAS)
    semestre = models.PositiveIntegerField(default=1)
    es_verificado = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.usuario.username} - {self.carrera}"

class ObjetoPerdido(models.Model):
    ESTADOS = [
        ('PERDIDO', 'Buscando'),
        ('ENCONTRADO', 'Encontrado'),
        ('ENTREGADO', 'Entregado al dueño'),
        ('N/A', 'Ninguna / Otro'), 
    ]

    
    titulo = models.CharField(max_length=100, blank=True, null=True) 
    descripcion = models.TextField()
    ubicacion = models.CharField(max_length=100, blank=True, null=True)
    fecha_publicacion = models.DateTimeField(auto_now_add=True)
    
    
    estado = models.CharField(max_length=20, choices=ESTADOS, default='N/A') 
    
    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='objetos')

    def __str__(self):
        return f"{self.titulo} ({self.estado})"

class FotoObjeto(models.Model):
    objeto = models.ForeignKey(ObjetoPerdido, related_name='fotos', on_delete=models.CASCADE)
    imagen = models.ImageField(upload_to='objetos/')

class CodigoVerificacion(models.Model):
    correo = models.EmailField(unique=True)
    codigo = models.CharField(max_length=6)
    creado_en = models.DateTimeField(auto_now_add=True)
    
    def es_valido(self):
        ahora = timezone.now()
        return ahora < self.creado_en + datetime.timedelta(minutes=10)

    def __str__(self):
        return f"{self.correo} - {self.codigo}"

class Comentario(models.Model):
    objeto = models.ForeignKey(ObjetoPerdido, on_delete=models.CASCADE, related_name='comentarios')
    usuario = models.ForeignKey(User, on_delete=models.CASCADE)
    texto = models.TextField()
    fecha = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.usuario.username} - {self.texto[:20]}"

class Like(models.Model):
    objeto = models.ForeignKey(ObjetoPerdido, on_delete=models.CASCADE, related_name='likes')
    usuario = models.ForeignKey(User, on_delete=models.CASCADE)
    
    class Meta:
        unique_together = ('objeto', 'usuario')

class PostForo(models.Model):
    TIPOS_FORO = [
        ('GENERAL', 'General'),
        ('DUDAS', 'Dudas Académicas'),
        ('EVENTOS', 'Eventos y Fiestas'),
        ('CONFESIONES', 'Confesiones'),
    ]

    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts_foro')
    tipo = models.CharField(max_length=20, choices=TIPOS_FORO)
    contenido = models.TextField()
    fecha = models.DateTimeField(auto_now_add=True)
    

    es_anonimo = models.BooleanField(default=False)
    carrera_filtro = models.CharField(max_length=100, choices=CARRERAS, blank=True, null=True) # Para dudas
    tag = models.CharField(max_length=50, blank=True, null=True)
    likes = models.ManyToManyField(User, related_name='likes_foro', blank=True)

    def __str__(self):
        return f"{self.tipo} - {self.usuario.username}"

    @property
    def total_likes(self):
        return self.likes.count()

class MensajeChat(models.Model):
    remitente = models.ForeignKey(User, related_name='mensajes_enviados', on_delete=models.CASCADE)
    destinatario = models.ForeignKey(User, related_name='mensajes_recibidos', on_delete=models.CASCADE)
    contenido = models.TextField()
    fecha = models.DateTimeField(auto_now_add=True)
    leido = models.BooleanField(default=False)

    def __str__(self):
        return f"De {self.remitente} para {self.destinatario}"