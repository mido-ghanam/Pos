# Generated migration for OTP Verification

import django.utils.timezone
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('partners', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='OTPVerification',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=True, primary_key=True, serialize=False)),
                ('phone', models.CharField(max_length=30)),
                ('otp_code', models.CharField(max_length=6)),
                ('is_verified', models.BooleanField(default=False)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('expires_at', models.DateTimeField()),
                ('partner_type', models.CharField(choices=[('customer', 'Customer'), ('supplier', 'Supplier')], max_length=20)),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddField(
            model_name='customers',
            name='is_verified',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='suppliers',
            name='is_verified',
            field=models.BooleanField(default=False),
        ),
    ]
