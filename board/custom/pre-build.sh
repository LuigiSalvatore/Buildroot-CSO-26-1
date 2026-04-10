#!/bin/bash

# Diretório raiz do projeto (Buildroot)
ROOT_DIR=$(pwd)
PROJECT_DIR=$ROOT_DIR
TARGET_CC=output/host/bin/i686-buildroot-linux-gnu-gcc
echo "===> Pre-build script iniciado"

# --------------------------------------------------
# 1. Criar diretórios necessários no target
# --------------------------------------------------
mkdir -p $TARGET_DIR/etc/init.d
mkdir -p $TARGET_DIR/var/www/cgi-bin
mkdir -p $TARGET_DIR/var/www

# --------------------------------------------------
# 2. Copiar scripts de init
# --------------------------------------------------
cp -r $PROJECT_DIR/custom-scripts/* $TARGET_DIR/etc/init.d/

# --------------------------------------------------
# 3. Compilar aplicações C (CGI)
# IMPORTANTE: usar o CROSS COMPILER do Buildroot
# --------------------------------------------------

echo "===> Compilando aplicações CGI"

for file in $PROJECT_DIR/apps/*.c; do
    filename=$(basename -- "$file")
    name="${filename%.c}"

    echo "Compilando $filename -> $name"

    $TARGET_CC $file -o $PROJECT_DIR/apps/$name

    if [ $? -ne 0 ]; then
        echo "Erro ao compilar $filename"
        exit 1
    fi
done

# --------------------------------------------------
# 4. Copiar binários CGI para o lugar correto
# --------------------------------------------------

echo "===> Copiando CGIs para /var/www/cgi-bin"

for bin in $PROJECT_DIR/apps/*; do
    if [[ -x "$bin" && ! "$bin" =~ \.c$ ]]; then
        cp "$bin" $TARGET_DIR/var/www/cgi-bin/
    fi
done

# --------------------------------------------------
# 5. Criar index.html com redirecionamento
# --------------------------------------------------

cat <<EOF > $TARGET_DIR/var/www/index.html
<html>
<head>
<meta http-equiv="refresh" content="0; url=/cgi-bin/monitor">
</head>
<body>
Redirecionando...
</body>
</html>
EOF

# --------------------------------------------------
# 6. Permissões
# --------------------------------------------------

echo "===> Ajustando permissões"

chmod +x $TARGET_DIR/etc/init.d/S50monitor

# Permitir execução dos CGIs
chmod +x $TARGET_DIR/var/www/cgi-bin/*

# --------------------------------------------------
# 7. Final
# --------------------------------------------------

echo "===> Pre-build finalizado com sucesso"

