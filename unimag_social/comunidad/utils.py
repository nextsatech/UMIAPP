from django.core.mail import send_mail
from django.conf import settings

def enviar_correo_unimag(destinatario, codigo):
    asunto = 'Recupera tu acceso - Unimag Social'
    mensaje = f'''
    Parece que olvidaste tu contraseña. No te preocupes.
    
    Tu código de recuperación es: {codigo}
    
    Si no fuiste tú, ignora este mensaje.
    '''
    try:
        send_mail(
            asunto,
            mensaje,
            settings.EMAIL_HOST_USER,
            [destinatario],
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Error enviando correo: {e}")
        return False